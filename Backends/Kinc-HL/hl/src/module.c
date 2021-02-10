/*
 * Copyright (C)2015-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
#include <hl.h>
#include <hlmodule.h>

#ifdef HL_WIN
#	include <windows.h>
EXTERN_C IMAGE_DOS_HEADER __ImageBase;
#	define dlopen(l,p)		(void*)( (l) ? LoadLibraryA(l) : (HMODULE)&__ImageBase)
#	define dlsym(h,n)		GetProcAddress((HANDLE)h,n)
#else
#	include <dlfcn.h>
#endif

#define HOT_RELOAD_EXTRA_GLOBALS	4096

HL_API void hl_prim_not_loaded( const uchar *err );

static hl_module **cur_modules = NULL;
static int modules_count = 0;

static bool module_resolve_pos( hl_module *m, void *addr, int *fidx, int *fpos ) {
	int code_pos = ((int)(int_val)((unsigned char*)addr - (unsigned char*)m->jit_code));
	int min, max;
	hl_debug_infos *dbg;
	hl_function *fdebug;
	if( m->jit_debug == NULL )
		return false;
	// lookup function from code pos
	min = 0;
	max = m->code->nfunctions;
	while( min < max ) {
		int mid = (min + max) >> 1;
		hl_debug_infos *p = m->jit_debug + mid;
		if( p->start <= code_pos )
			min = mid + 1;
		else
			max = mid;
	}
	if( min == 0 )
		return false; // hl_callback
	*fidx = (min - 1);
	dbg = m->jit_debug + (min - 1);
	fdebug = m->code->functions + (min - 1);
	// lookup inside function
	min = 0;
	max = fdebug->nops;
	code_pos -= dbg->start;
	while( min < max ) {
		int mid = (min + max) >> 1;
		int offset = dbg->large ? ((int*)dbg->offsets)[mid] : ((unsigned short*)dbg->offsets)[mid];
		if( offset <= code_pos )
			min = mid + 1;
		else
			max = mid;
	}
	if( min == 0 )
		return false; // ???
	*fpos = min - 1;
	return true;
}

uchar *hl_module_resolve_symbol_full( void *addr, uchar *out, int *outSize, int **r_debug_addr ) {
	int *debug_addr;
	int file, line;
	int pos = 0;
	int fidx, fpos;
	hl_function *fdebug;
	int i;
	hl_module *m = NULL;
	for(i=0;i<modules_count;i++) {
		m = cur_modules[i];
		if( addr >= m->jit_code && addr <= (void*)((char*)m->jit_code + m->codesize) ) break;
	}
	if( i == modules_count )
		return NULL;
	if( !module_resolve_pos(m,addr,&fidx,&fpos) )
		return NULL;
	// extract debug info
	fdebug = m->code->functions + fidx;
	debug_addr = fdebug->debug + ((fpos&0xFFFF) * 2);
	file = debug_addr[0];
	line = debug_addr[1];
	if( r_debug_addr ) {
		*r_debug_addr = debug_addr;
		if( file < 0 ) return NULL; // already cached
	}
	if( !out )
		return NULL;
	int size = *outSize;
	if( fdebug->obj )
		pos += usprintf(out,size - pos,USTR("%s.%s("),fdebug->obj->name,fdebug->field.name);
	else if( fdebug->field.ref )
		pos += usprintf(out,size - pos,USTR("%s.~%s.%d("),fdebug->field.ref->obj->name, fdebug->field.ref->field.name, fdebug->ref);
	else
		pos += usprintf(out,size - pos,USTR("fun$%d("),fdebug->findex);
	pos += hl_from_utf8(out + pos,size - pos,m->code->debugfiles[file&0x7FFFFFFF]);
	pos += usprintf(out + pos, size - pos, USTR(":%d)"), line);
	*outSize = pos;
	return out;
}

static uchar *module_resolve_symbol( void *addr, uchar *out, int *outSize ) {
	return hl_module_resolve_symbol_full(addr,out,outSize,NULL);
}

int hl_module_capture_stack_range( void *stack_top, void **stack_ptr, void **out, int size ) {
#if defined(HL_64) && defined(HL_WIN)
#else
	void *stack_bottom = stack_ptr;
#endif
	int count = 0;
	if( modules_count == 1 ) {
		hl_module *m = cur_modules[0];
		unsigned char *code = m->jit_code;
		int code_size = m->codesize;
		if( m->jit_debug ) {
			int s = m->jit_debug[0].start;
			code += s;
			code_size -= s;
		}
		while( stack_ptr < (void**)stack_top ) {
#if defined(HL_64) && defined(HL_WIN)
			void *module_addr = *stack_ptr++; // EIP
			if( module_addr >= (void*)code && module_addr < (void*)(code + code_size) ) {
				if( count == size ) break;
				out[count++] = module_addr;
			}
#else
			void *stack_addr = *stack_ptr++; // EBP
			if( stack_addr > stack_bottom && stack_addr < stack_top ) {
				void *module_addr = *stack_ptr; // EIP
				if( module_addr >= (void*)code && module_addr < (void*)(code + code_size) ) {
					if( count == size ) break;
					out[count++] = module_addr;
				}
			}
#endif
		}
	} else {
		while( stack_ptr < (void**)stack_top ) {
#if defined(HL_64) && defined(HL_WIN)
			void *module_addr = *stack_ptr++; // EIP
			{
#else
			void *stack_addr = *stack_ptr++; // EBP
			if( stack_addr > stack_bottom && stack_addr < stack_top ) {
				void *module_addr = *stack_ptr; // EIP
#endif
				int i;
				for(i=0;i<modules_count;i++) {
					hl_module *m = cur_modules[i];
					unsigned char *code = m->jit_code;
					int code_size = m->codesize;
					if( module_addr >= (void*)code && module_addr < (void*)(code + code_size) ) {
						if( count == size ) {
							stack_ptr = stack_top;
							break;
						}
						if( m->jit_debug ) {
							int s = m->jit_debug[0].start;
							code += s;
							code_size -= s;
							if( module_addr < (void*)code || module_addr >= (void*)(code + code_size) ) continue;
						}
						out[count++] = module_addr;
						break;
					}
				}
			}
		}
	}
	return count;
}

static int module_capture_stack( void **stack, int size ) {
	return hl_module_capture_stack_range(hl_get_thread()->stack_top, (void**)&stack, stack, size);
}

static void hl_module_types_dump( void (*fdump)( void *, int) ) {
	int ntypes = 0;
	int i, j, fcount = 0;
	for(i=0;i<modules_count;i++)
		ntypes += cur_modules[i]->code->ntypes;
	fdump(&ntypes,4);
	for(i=0;i<modules_count;i++) {
		hl_module *m = cur_modules[i];
		for(j=0;j<m->code->ntypes;j++) {
			hl_type *t = m->code->types + j;
			fdump(&t,sizeof(void*));
			if( t->kind == HFUN ) fcount++;
		}
	}
	fdump(&fcount,4);
	for(i=0;i<modules_count;i++) {
		hl_module *m = cur_modules[i];
		for(j=0;j<m->code->ntypes;j++) {
			hl_type *t = m->code->types + j;
			if( t->kind == HFUN ) {
				hl_type *ct = (hl_type*)&t->fun->closure_type;
				fdump(&ct,sizeof(void*));
			}
		}
	}
}

hl_module *hl_module_alloc( hl_code *c ) {
	int i;
	int gsize = 0;
	hl_module *m = (hl_module*)malloc(sizeof(hl_module));
	if( m == NULL )
		return NULL;
	memset(m,0,sizeof(hl_module));
	m->code = c;
	m->globals_indexes = (int*)malloc(sizeof(int)*c->nglobals);
	if( m == NULL ) {
		hl_module_free(m);
		return NULL;
	}
	for(i=0;i<c->nglobals;i++) {
		gsize += hl_pad_size(gsize, c->globals[i]);
		m->globals_indexes[i] = gsize;
		gsize += hl_type_size(c->globals[i]);
	}
	m->globals_size = gsize;
	m->globals_data = (unsigned char*)malloc(gsize);
	if( m->globals_data == NULL ) {
		hl_module_free(m);
		return NULL;
	}
	memset(m->globals_data,0,gsize);
	m->functions_ptrs = (void**)malloc(sizeof(void*)*(c->nfunctions + c->nnatives));
	m->functions_indexes = (int*)malloc(sizeof(int)*(c->nfunctions + c->nnatives));
	m->ctx.functions_types = (hl_type**)malloc(sizeof(void*)*(c->nfunctions + c->nnatives));
	if( m->functions_ptrs == NULL || m->functions_indexes == NULL || m->ctx.functions_types == NULL ) {
		hl_module_free(m);
		return NULL;
	}
	memset(m->functions_ptrs,0,sizeof(void*)*(c->nfunctions + c->nnatives));
	memset(m->functions_indexes,0xFF,sizeof(int)*(c->nfunctions + c->nnatives));
	memset(m->ctx.functions_types,0,sizeof(void*)*(c->nfunctions + c->nnatives));
	hl_alloc_init(&m->ctx.alloc);
	m->ctx.functions_ptrs = m->functions_ptrs;
	return m;
}

static void null_function() {
	hl_error("Null function ptr");
}

static void append_type( char **p, hl_type *t ) {
	*(*p)++ = TYPE_STR[t->kind];
	switch( t->kind ) {
	case HFUN:
		{
			int i;
			for(i=0;i<t->fun->nargs;i++)
				append_type(p,t->fun->args[i]);
			*(*p)++ = '_';
			append_type(p,t->fun->ret);
			break;
		}
	case HREF:
	case HNULL:
		append_type(p,t->tparam);
		break;
	case HSTRUCT:
		*(*p)++ = 'S';
	case HOBJ:
		{
			int i;
			for(i=0;i<t->obj->nfields;i++)
				append_type(p,t->obj->fields[i].t);
			*(*p)++ = '_';
		}
		break;
	case HABSTRACT:
		*p += utostr(*p,100,t->abs_name);
		*(*p)++ = '_';
		break;
	default:
		break;
	}
}

#define DISABLED_LIB_PTR ((void*)(int_val)2)

static void *resolve_library( const char *lib, bool is_opt ) {
	char tmp[256];	
	void *h;

#	ifndef HL_CONSOLE
	static char *DISABLED_LIBS = NULL;
	if( !DISABLED_LIBS ) {
		DISABLED_LIBS = getenv("HL_DISABLED_LIBS");
		if( !DISABLED_LIBS ) DISABLED_LIBS = "";
	}
	char *disPart = strstr(DISABLED_LIBS, lib);
	if( disPart ) {
		disPart += strlen(lib);
		if( *disPart == 0 || *disPart == ',' )
			return DISABLED_LIB_PTR;
	}
#	endif

	if( strcmp(lib,"builtin") == 0 )
		return dlopen(NULL,RTLD_LAZY);

	if( strcmp(lib,"std") == 0 ) {
#	ifdef HL_WIN
#		ifdef HL_64						
		h = dlopen("libhl64.dll",RTLD_LAZY);
		if( h == NULL ) h = dlopen("libhl.dll",RTLD_LAZY);
#		else
		h = dlopen("libhl.dll",RTLD_LAZY);
#		endif
		if( h == NULL && !is_opt ) hl_fatal1("Failed to load library %s","libhl.dll");
		return h;
#	else
		return RTLD_DEFAULT;
#	endif
	}
	
	strcpy(tmp,lib);

#	ifdef HL_64
	strcpy(tmp+strlen(lib),"64.hdll");
	h = dlopen(tmp,RTLD_LAZY);
	if( h != NULL ) return h;
#	endif
	
	strcpy(tmp+strlen(lib),".hdll");
	h = dlopen(tmp,RTLD_LAZY);
	if( h == NULL && !is_opt )
		hl_fatal1("Failed to load library %s",tmp);
	return h;
}

static void disabled_primitive() {
	hl_error("This library primitive has been disabled");
}

static void hl_module_init_indexes( hl_module *m ) {
	int i;
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		m->functions_indexes[f->findex] = i;
		m->ctx.functions_types[f->findex] = f->type;
	}
	for(i=0;i<m->code->nnatives;i++) {
		hl_native *n = m->code->natives + i;
		m->functions_indexes[n->findex] = i + m->code->nfunctions;
		m->ctx.functions_types[n->findex] = n->t;
	}
	for(i=0;i<m->code->ntypes;i++) {
		hl_type *t = m->code->types + i;
		switch( t->kind ) {
		case HOBJ:
		case HSTRUCT:
			t->obj->m = &m->ctx;
			t->obj->global_value = ((int)(int_val)t->obj->global_value) ? (void**)(int_val)(m->globals_data + m->globals_indexes[(int)(int_val)t->obj->global_value-1]) : NULL;
			{
				int j;
				for(j=0;j<t->obj->nproto;j++) {
					hl_obj_proto *p = t->obj->proto + j;
					hl_function *f = m->code->functions + m->functions_indexes[p->findex];
					f->obj = t->obj;
					f->field.name = p->name;
				}
				for(j=0;j<t->obj->nbindings;j++) {
					int fid = t->obj->bindings[j<<1];
					int mid = t->obj->bindings[(j<<1)|1];
					hl_obj_field *of = hl_obj_field_fetch(t,fid);
					switch( of->t->kind ) {
					case HFUN:
					case HDYN:
						{
							hl_function *f = m->code->functions + m->functions_indexes[mid];
							f->obj = t->obj;
							f->field.name = of->name;
						}
						break;
					default:
						break;
					}
				}
			}
			break;
		case HENUM:
			hl_init_enum(t,&m->ctx);
			t->tenum->global_value = ((int)(int_val)t->tenum->global_value) ? (void**)(int_val)(m->globals_data + m->globals_indexes[(int)(int_val)t->tenum->global_value-1]) : NULL;
			break;
		case HVIRTUAL:
			hl_init_virtual(t,&m->ctx);
			break;
		default:
			break;
		}
	}
	for(i=0;i<m->code->nfunctions;i++) {
		int k;
		hl_function *f = m->code->functions + i;
		hl_function *real_f = f;		
		while( real_f && !real_f->obj ) real_f = real_f->field.ref;
		if( real_f == NULL ) continue;
		for(k=0;k<f->nops;k++) {
			hl_opcode *op = f->ops + k;
			switch( op->op ) {
			case OCall0:
			case OCall1:
			case OCall2:
			case OCall3:
			case OCall4:
			case OCallN:
			case OStaticClosure:
			case OInstanceClosure:
				if( m->functions_indexes[op->p2] < m->code->nfunctions ) {
					hl_function *floc = m->code->functions + m->functions_indexes[op->p2];
					if( floc->obj ) continue;
					floc->field.ref = real_f;
					floc->ref = real_f->ref++;
				}
				break;
			default:
				break;
			}
		}
	}
}

static void hl_module_init_natives( hl_module *m ) {
	char tmp[256];
	int i;
	void *libHandler = NULL;
	const char *curlib = NULL, *sign;
	for(i=0;i<m->code->nnatives;i++) {
		hl_native *n = m->code->natives + i;
		const char *lib = n->lib;
		bool is_opt = *lib == '?';
		char *p = tmp;
		void *f;
		if( is_opt ) lib++;
		if( curlib != lib ) {
			curlib = lib;
			libHandler = resolve_library(lib, is_opt);
		}
		if( libHandler == DISABLED_LIB_PTR ) {
			m->functions_ptrs[n->findex] = disabled_primitive;
			continue;
		}
		strcpy(p,"hlp_");
		p += 4;
		strcpy(p,n->name);
		p += strlen(n->name);
		*p++ = 0;
		f = dlsym(libHandler,tmp);
		if( f == NULL ) {
			if( is_opt ) {
				m->functions_ptrs[n->findex] = hl_prim_not_loaded;
				continue;
			}
			hl_fatal2("Failed to load function %s@%s",n->lib,n->name);
		}
		m->functions_ptrs[n->findex] = ((void *(*)( const char **p ))f)(&sign);
		p = tmp;
		append_type(&p,n->t);
		*p++ = 0;
		if( memcmp(sign,tmp,strlen(sign)+1) != 0 )
			hl_fatal4("Invalid signature for function %s@%s : %s required but %s found in hdll",n->lib,n->name,tmp,sign);
	}
}

int hl_module_init( hl_module *m, h_bool hot_reload ) {
	int i;
	jit_ctx *ctx;
	// expand globals
	if( hot_reload ) {
		int nsize = m->globals_size + HOT_RELOAD_EXTRA_GLOBALS * sizeof(void*);
		int *nindexes = malloc(sizeof(int) * (m->code->nglobals + HOT_RELOAD_EXTRA_GLOBALS));
		memcpy(nindexes,m->globals_indexes,sizeof(int)*m->code->nglobals);
		memset(nindexes + m->code->nglobals,0xFF,HOT_RELOAD_EXTRA_GLOBALS * sizeof(int));
		free(m->globals_indexes);
		free(m->globals_data);
		m->globals_indexes = nindexes;
		m->globals_data = malloc(nsize);
		memset(m->globals_data,0,m->globals_size);
		memset(m->globals_data + m->globals_size,0xFF,HOT_RELOAD_EXTRA_GLOBALS * sizeof(void*));
	}
	// RESET globals
	for(i=0;i<m->code->nglobals;i++) {
		hl_type *t = m->code->globals[i];
		if( t->kind == HFUN ) *(void**)(m->globals_data + m->globals_indexes[i]) = null_function;
		if( hl_is_ptr(t) )
			hl_add_root(m->globals_data+m->globals_indexes[i]);
	}
	// inits
	if( hot_reload ) m->hash = hl_code_hash_alloc(m->code);
	hl_module_init_natives(m);
	hl_module_init_indexes(m);
	// JIT
	ctx = hl_jit_alloc();
	if( ctx == NULL )
		return 0;
	hl_jit_init(ctx, m);
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		int fpos = hl_jit_function(ctx, m, f);
		if( fpos < 0 ) {
			hl_jit_free(ctx, false);
			return 0;
		}
		m->functions_ptrs[f->findex] = (void*)(int_val)fpos;
	}
	m->jit_code = hl_jit_code(ctx, m, &m->codesize, &m->jit_debug, NULL);
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		m->functions_ptrs[f->findex] = ((unsigned char*)m->jit_code) + ((int_val)m->functions_ptrs[f->findex]);
	}
	// INIT constants
	for(i=0;i<m->code->nconstants;i++) {
		int j;
		hl_constant *c = m->code->constants + i;
		hl_type *t = m->code->globals[c->global];
		hl_runtime_obj *rt;
		vdynamic **global = (vdynamic**)(m->globals_data + m->globals_indexes[c->global]);
		vdynamic *v = NULL;
		switch (t->kind) {
		case HOBJ:
		case HSTRUCT:
			rt = hl_get_obj_rt(t);
			v = (vdynamic*)hl_malloc(&m->ctx.alloc,rt->size);
			v->t = t;
			for (j = 0; j<c->nfields; j++) {
				int idx = c->fields[j];
				hl_type *ft = t->obj->fields[j].t;
				void *addr = (char*)v + rt->fields_indexes[j];
				switch (ft->kind) {
				case HI32:
					*(int*)addr = m->code->ints[idx];
					break;
				case HBOOL:
					*(bool*)addr = idx != 0;
					break;
				case HF64:
					*(double*)addr = m->code->floats[idx];
					break;
				case HBYTES:
					*(const void**)addr = hl_get_ustring(m->code, idx);
					break;
				case HTYPE:
					*(hl_type**)addr = m->code->types + idx;
					break;
				default:
					*(void**)addr = *(void**)(m->globals_data + m->globals_indexes[idx]);
					break;
				}
			}
			break;
		default:
			hl_fatal("assert");
		}
		*global = v;
		hl_remove_root(global);
	}

	// DONE
	hl_module **old_modules = cur_modules;
	hl_module **new_modules = (hl_module**)malloc(sizeof(void*)*(modules_count + 1));
	memcpy(new_modules, old_modules, sizeof(void*)*modules_count);
	new_modules[modules_count] = m;
	cur_modules = new_modules;
	modules_count++;
	free(old_modules);

	hl_setup_exception(module_resolve_symbol, module_capture_stack);
	hl_gc_set_dump_types(hl_module_types_dump);
	hl_jit_free(ctx, hot_reload);
	if( hot_reload ) {
		hl_code_hash_finalize(m->hash);
		m->jit_ctx = ctx;
	}
	return 1;
}

h_bool hl_module_patch( hl_module *m1, hl_code *c ) {
	int i1,i2;
	bool has_changes = false;
	int changes_count = 0;
	jit_ctx *ctx = m1->jit_ctx;

	hl_module *m2 = hl_module_alloc(c);
	m2->hash = hl_code_hash_alloc(c);
	hl_code_hash_remap_globals(m2->hash,m1->hash);

	// share global data
	// TODO : we should assign indexes for new globals
	// and eventually init their value correctly
	free(m2->globals_data);
	free(m2->globals_indexes);
	m2->globals_data = m1->globals_data;
	m2->globals_indexes = m1->globals_indexes;
	
	hl_module_init_natives(m2);
	hl_module_init_indexes(m2);
	hl_jit_reset(ctx, m2);
	hl_code_hash_finalize(m2->hash);

	for(i2=0;i2<m2->code->nfunctions;i2++) {
		hl_function *f2 = m2->code->functions + i2;
		int sign2 = m2->hash->functions_signs[i2];
		if( f2->field.name == NULL ) {
			m2->hash->functions_hashes[i2] = -1;
			continue;
		}
		for(i1=0;i1<m1->code->nfunctions;i1++) {
			int sign1 = m1->hash->functions_signs[i1];
			if( sign1 == sign2 ) {
				hl_function *f1 = m1->code->functions + i1;
				if( (f1->obj != NULL) != (f2->obj != NULL) || !f1->field.name || !f2->field.name ) {
					printf("[HotReload] Signature conflict\n");
					continue;
				}
				if( ucmp(fun_obj(f1)->name,fun_obj(f2)->name) != 0 || ucmp(fun_field_name(f1),fun_field_name(f2)) != 0 ) {
					printf("[HotReload] Signature conflict\n");
					continue;
				}

				int hash2 = m2->hash->functions_hashes[i2];
				int hash1 = m1->hash->functions_hashes[i1];
				m2->hash->functions_hashes[i2] = i1; // index reference
				if( hash1 == hash2 )
					break;
#				ifdef HL_DEBUG
				uprintf(USTR("%s."), fun_obj(f1)->name);
				uprintf(USTR("%s"), fun_field_name(f1));
				if( !f1->obj )
					printf("~%d", f1->ref);
				printf(" has been modified [%d]\n", f1->nops);
#				endif
				changes_count++;

				m1->hash->functions_hashes[i1] = hash2; // update hash
				int fpos = hl_jit_function(ctx, m2, f2);
				if( fpos < 0 ) return false;
				m2->functions_ptrs[f2->findex] = (void*)(int_val)fpos;
				has_changes = true;
				break;
			}
		}
		if( i1 == m1->code->nfunctions ) {
			// not found (signature changed or new method) : inject new method!
			int fpos = hl_jit_function(ctx, m2, f2);
			if( fpos < 0 ) return false;
			m2->hash->functions_hashes[i2] = -1;
			m2->functions_ptrs[f2->findex] = (void*)(int_val)fpos;
#			ifdef HL_DEBUG
			uprintf(USTR("%s."), fun_obj(f2)->name);
			uprintf(USTR("%s"), fun_field_name(f2));
			if( !f2->obj )
				printf("~%d", f2->ref);
			printf(" has been added\n");
#			endif
			changes_count++;
			has_changes = true;
			// should be added to m1 functions for later reload?
		}
	}
	if( !has_changes ) {
		printf("[HotReload] No changes found\n");
		fflush(stdout);
		hl_jit_free(ctx, true);
		return false;
	}

	// patch same types
	for(i1=0;i1<m1->code->ntypes;i1++) {
		hl_type *p = m1->code->types + i1;
		if( p->kind != HOBJ && p->kind != HSTRUCT ) continue;
		for(i2=0;i2<c->ntypes;i2++) {
			hl_type *t = c->types + i2;
			if( p->kind != t->kind ) continue;
			if( ucmp(p->obj->name,t->obj->name) != 0 ) continue;
			if( hl_code_hash_type(m1->hash,p) == hl_code_hash_type(m2->hash,t)  ) {
				t->obj = p->obj; // alias the types ! they are different pointers but have the same layout
			} else {
				uprintf(USTR("[HotReload] Type %s has changed\n"),t->obj->name);
				changes_count++;
			}
			break;
		}
	}

	m2->jit_code = hl_jit_code(ctx, m2, &m2->codesize, &m2->jit_debug, m1);
	hl_jit_free(ctx,true);

	if( m2->jit_code == NULL ) {
		printf("[HotReload] Couldn't JIT result\n");
		fflush(stdout);
		return false;
	}
	
	int i;
	for(i=0;i<m2->code->nfunctions;i++) {
		hl_function *f2 = m2->code->functions + i;
		if( m2->hash->functions_hashes[i] < -1 ) continue;
		if( m2->functions_ptrs[f2->findex] == NULL ) continue;
		void *ptr = ((unsigned char*)m2->jit_code) + ((int_val)m2->functions_ptrs[f2->findex]);
		m2->functions_ptrs[f2->findex] = ptr;
		// update real function ptr
		if( m2->hash->functions_hashes[i] < 0 ) continue;
		hl_function *f1 = m1->code->functions + m2->hash->functions_hashes[i];
		hl_jit_patch_method(m1->functions_ptrs[f1->findex], m1->functions_ptrs + f1->findex);
		m1->functions_ptrs[f1->findex] = ptr;
	}
	for(i=0;i<m1->code->ntypes;i++) {
		hl_type *t = m1->code->types + i;
		if( t->kind == HOBJ || t->kind == HSTRUCT ) hl_flush_proto(t);
	}

	if( changes_count > 0 ) {
		printf("[HotReload] %d changes\n", changes_count);
		fflush(stdout);
	}

	return true;
}

void hl_module_free( hl_module *m ) {
	hl_free(&m->ctx.alloc);
	hl_free_executable_memory(m->code, m->codesize);
	if( m->hash ) hl_code_hash_free(m->hash);
	free(m->functions_indexes);
	free(m->functions_ptrs);
	free(m->ctx.functions_types);
	free(m->globals_indexes);
	free(m->globals_data);
	if( m->jit_debug ) {
		int i;
		for(i=0;i<m->code->nfunctions;i++)
			free(m->jit_debug[i].offsets);
		free(m->jit_debug);
	}
	if( m->jit_ctx )
		hl_jit_free(m->jit_ctx,false);
	free(m);
}

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
#include <hlmodule.h>

#ifdef HL_WIN
#	include <windows.h>
#	define dlopen(l,p)		(void*)( (l) ? LoadLibraryA(l) : GetModuleHandle(NULL))
#	define dlsym(h,n)		GetProcAddress((HANDLE)h,n)
#else
#	include <dlfcn.h>
#endif

static hl_module *cur_module;

static bool module_resolve_pos( void *addr, int *fidx, int *fpos ) {
	int code_pos = ((int)(int_val)((unsigned char*)addr - (unsigned char*)cur_module->jit_code));
	int min, max;
	hl_debug_infos *dbg;
	hl_function *fdebug;
	if( cur_module->jit_debug == NULL )
		return false;
	// lookup function from code pos
	min = 0;
	max = cur_module->code->nfunctions;
	while( min < max ) {
		int mid = (min + max) >> 1;
		hl_debug_infos *p = cur_module->jit_debug + mid;
		if( p->start <= code_pos )
			min = mid + 1;
		else
			max = mid;
	}
	if( min == 0 )
		return false; // hl_callback
	*fidx = (min - 1);
	dbg = cur_module->jit_debug + (min - 1);
	fdebug = cur_module->code->functions + (min - 1);
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

static uchar *module_resolve_symbol( void *addr, uchar *out, int *outSize ) {
	int *debug_addr;
	int file, line;
	int size = *outSize;
	int pos = 0;
	int fidx, fpos;
	hl_function *fdebug;
	if( !module_resolve_pos(addr,&fidx,&fpos) )
		return NULL;
	// extract debug info
	fdebug = cur_module->code->functions + fidx;
	debug_addr = fdebug->debug + ((fpos&0xFFFF) * 2);
	file = debug_addr[0];
	line = debug_addr[1];
	if( fdebug->obj )
		pos += usprintf(out,size - pos,USTR("%s.%s("),fdebug->obj->name,fdebug->field);
	else
		pos += usprintf(out,size - pos,USTR("fun$%d("),fdebug->findex);
	pos += hl_from_utf8(out + pos,size - pos,cur_module->code->debugfiles[file]);
	pos += usprintf(out + pos, size - pos, USTR(":%d)"), line);
	*outSize = pos;
	return out;
}

static int module_capture_stack( void **stack, int size ) {
	void **stack_ptr = (void**)&stack;
	void *stack_bottom = stack_ptr;
	void *stack_top = hl_get_thread()->stack_top;
	int count = 0;
	unsigned char *code = cur_module->jit_code;
	int code_size = cur_module->codesize;
	if( cur_module->jit_debug ) {
		int s = cur_module->jit_debug[0].start;
		code += s;
		code_size -= s;
	}
	while( stack_ptr < (void**)stack_top ) {
		void *stack_addr = *stack_ptr++; // EBP
		if( stack_addr > stack_bottom && stack_addr < stack_top ) {
			void *module_addr = *stack_ptr; // EIP
			if( module_addr >= (void*)code && module_addr < (void*)(code + code_size) ) {
				if( count == size ) break;
				stack[count++] = module_addr;
			}
		}
	}
	return count;
}

static void hl_module_types_dump( void (*fdump)( void *, int) ) {
	int ntypes = cur_module->code->ntypes;
	int i, fcount = 0;
	fdump(&ntypes,4);
	for(i=0;i<ntypes;i++) {
		hl_type *t = cur_module->code->types + i;
		fdump(&t,sizeof(void*));
		if( t->kind == HFUN ) fcount++;
	}
	fdump(&fcount,4);
	for(i=0;i<ntypes;i++) {
		hl_type *t = cur_module->code->types + i;
		if( t->kind == HFUN ) {
			hl_type *ct = (hl_type*)&t->fun->closure_type;
			fdump(&ct,sizeof(void*));
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

static void *resolve_library( const char *lib ) {
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
		if( h == NULL ) hl_fatal1("Failed to load library %s","libhl.dll");
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
	if( h == NULL )
		hl_fatal1("Failed to load library %s",tmp);
	return h;
}

static void disabled_primitive() {
	hl_error("This library primitive has been disabled");
}

int hl_module_init( hl_module *m ) {
	int i;
	jit_ctx *ctx;
	// RESET globals
	for(i=0;i<m->code->nglobals;i++) {
		hl_type *t = m->code->globals[i];
		if( t->kind == HFUN ) *(void**)(m->globals_data + m->globals_indexes[i]) = null_function;
		if( hl_is_ptr(t) )
			hl_add_root(m->globals_data+m->globals_indexes[i]);
	}
	// INIT natives
	{
		char tmp[256];
		void *libHandler = NULL;
		const char *curlib = NULL, *sign;
		for(i=0;i<m->code->nnatives;i++) {
			hl_native *n = m->code->natives + i;
			char *p = tmp;
			void *f;
			if( curlib != n->lib ) {
				curlib = n->lib;
				libHandler = resolve_library(n->lib);
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
			if( f == NULL )
				hl_fatal2("Failed to load function %s@%s",n->lib,n->name);
			m->functions_ptrs[n->findex] = ((void *(*)( const char **p ))f)(&sign);
			p = tmp;
			append_type(&p,n->t);
			*p++ = 0;
			if( memcmp(sign,tmp,strlen(sign)+1) != 0 )
				hl_fatal4("Invalid signature for function %s@%s : %s required but %s found in hdll",n->lib,n->name,tmp,sign);
		}
	}
	// INIT indexes
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
			t->obj->m = &m->ctx;
			t->obj->global_value = ((int)(int_val)t->obj->global_value) ? (void**)(int_val)(m->globals_data + m->globals_indexes[(int)(int_val)t->obj->global_value-1]) : NULL;
			{
				int j;
				for(j=0;j<t->obj->nproto;j++) {
					hl_obj_proto *p = t->obj->proto + j;
					hl_function *f = m->code->functions + m->functions_indexes[p->findex];
					f->obj = t->obj;
					f->field = p->name;
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
							f->field = of->name;
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
	// JIT
	ctx = hl_jit_alloc();
	if( ctx == NULL )
		return 0;
	hl_jit_init(ctx, m);
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		int fpos = hl_jit_function(ctx, m, f);
		if( fpos < 0 ) {
			hl_jit_free(ctx);
			return 0;
		}
		m->functions_ptrs[f->findex] = (void*)(int_val)fpos;
	}
	m->jit_code = hl_jit_code(ctx, m, &m->codesize, &m->jit_debug);
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		m->functions_ptrs[f->findex] = ((unsigned char*)m->jit_code) + ((int_val)m->functions_ptrs[f->findex]);
	}
	// INIT constants
	for (i = 0; i<m->code->nconstants; i++) {
		int j;
		hl_constant *c = m->code->constants + i;
		hl_type *t = m->code->globals[c->global];
		hl_runtime_obj *rt;
		vdynamic **global = (vdynamic**)(m->globals_data + m->globals_indexes[c->global]);
		vdynamic *v = NULL;
		switch (t->kind) {
		case HOBJ:
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
	cur_module = m;
	hl_setup_exception(module_resolve_symbol, module_capture_stack);
	hl_gc_set_dump_types(hl_module_types_dump);
	hl_jit_free(ctx);
	return 1;
}

void hl_module_free( hl_module *m ) {
	hl_free(&m->ctx.alloc);
	hl_free_executable_memory(m->code, m->codesize);
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
	free(m);
}

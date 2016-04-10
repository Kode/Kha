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
#include "hl.h"

#ifdef HL_WIN
#	include <windows.h>
#	define dlopen(l,p)		(void*)( (l) ? LoadLibraryA(l) : GetModuleHandle(NULL))
#	define dlsym(h,n)		GetProcAddress((HANDLE)h,n)
#else
#	include <dlfcn.h>
#endif

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
	if( m->functions_ptrs == NULL || m->functions_indexes == NULL ) {
		hl_module_free(m);
		return NULL;
	}
	memset(m->functions_ptrs,0,sizeof(void*)*(c->nfunctions + c->nnatives));
	memset(m->functions_indexes,0xFF,sizeof(int)*(c->nfunctions + c->nnatives));
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
				append_type(p,(&t->fun->args)[i]);
			*(*p)++ = '_';
			append_type(p,t->fun->ret);
			break;
		}
	case HARRAY:
	case HREF:
		append_type(p,t->t);
		break;
	default:
		break;
	}
}

int hl_module_init( hl_module *m ) {
	int i, entry;
	jit_ctx *ctx;
	// RESET globals
	for(i=0;i<m->code->nglobals;i++) {
		hl_type *t = m->code->globals[i];
		if( t->kind == HFUN ) *(fptr*)(m->globals_data + m->globals_indexes[i]) = null_function;
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
				strcpy(tmp,n->lib);
#				ifdef HL_64
				strcpy(tmp+strlen(tmp),"64.hdll");
#				else
				strcpy(tmp+strlen(tmp),".hdll");
#				endif
				libHandler = dlopen(memcmp(n->lib,"std",4) == 0 ? NULL : tmp,RTLD_LAZY);
				if( libHandler == NULL )
					hl_error("Failed to load library %s",tmp);
			}
			strcpy(p,"hlp_");
			p += 4;
			strcpy(p,n->name);
			p += strlen(n->name);
			*p++ = 0;
			f = dlsym(libHandler,tmp);
			if( f == NULL )
				hl_error("Failed to load function %s@%s",n->lib,n->name);
			m->functions_ptrs[n->findex] = ((void *(*)( const char **p ))f)(&sign);
			p = tmp;
			append_type(&p,n->t);
			*p++ = 0;
			if( memcmp(sign,tmp,strlen(sign)+1) != 0 )
				hl_error("Invalid signature for function %s@%s : %s should be %s",n->lib,n->name,tmp,sign);
		}
	}
	// INIT indexes
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		m->functions_indexes[f->findex] = i;
	}
	for(i=0;i<m->code->nnatives;i++) {
		hl_native *n = m->code->natives + i;
		m->functions_indexes[n->findex] = i + m->code->nfunctions;
	}
	// JIT
	ctx = hl_jit_alloc();
	if( ctx == NULL )
		return 0;
	hl_jit_init(ctx, m);
	entry = hl_jit_init_callback(ctx);
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		int fpos = hl_jit_function(ctx, m, f);
		if( fpos < 0 ) {
			hl_jit_free(ctx);
			return 0;
		}
		m->functions_ptrs[f->findex] = (void*)(int_val)fpos;
	}
	m->jit_code = hl_jit_code(ctx, m, &m->codesize);
	for(i=0;i<m->code->nfunctions;i++) {
		hl_function *f = m->code->functions + i;
		m->functions_ptrs[f->findex] = ((unsigned char*)m->jit_code) + ((int_val)m->functions_ptrs[f->findex]);
	}
	hl_callback_init(((unsigned char*)m->jit_code) + entry);
	hl_jit_free(ctx);
	return 1;
}

void hl_module_free( hl_module *m ) {
	hl_free_executable_memory(m->code, m->codesize);
	free(m->functions_indexes);
	free(m->functions_ptrs);
	free(m->globals_indexes);
	free(m->globals_data);
	free(m);
}

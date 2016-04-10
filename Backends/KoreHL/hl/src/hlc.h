/*
 * Copyright (C)2005-2016 Haxe Foundation
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
#ifndef HLC_H
#define HLC_H

#include <math.h>
#include <hl.h>

#ifdef HL_64
#	define PAD_64_VAL	,0
#else
#	define PAD_64_VAL
#endif

#ifdef HLC_BOOT

// undefine some commonly used names that can clash with class/var name
#undef CONST
#undef stdin
#undef stdout
#undef stderr

// disable some warnings triggered by HLC code generator

#ifdef HL_VCC
#	pragma warning(disable:4702) // unreachable code 
#	pragma warning(disable:4100) // unreferenced param
#	pragma warning(disable:4101) // unreferenced local var
#	pragma warning(disable:4723) // potential divide by 0
#else
#	pragma GCC diagnostic ignored "-Wunused-variable"
#	pragma GCC diagnostic ignored "-Wunused-function"
#	pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#	pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#	pragma GCC diagnostic ignored "-Wcomment" // comment in comment
#endif

static void hl_null_access() {
	hl_error_msg(USTR("Null access"));
}

extern vdynamic *hl_call_method( vdynamic *c, varray *args );

#define HLC_DYN_MAX_ARGS 9
static vdynamic *hlc_dyn_call_args( vclosure *c, vdynamic **args, int nargs ) {
	struct {
		varray a;
		vdynamic *args[HLC_DYN_MAX_ARGS+1];
	} tmp;
	vclosure ctmp;
	int i = 0;
	if( nargs > HLC_DYN_MAX_ARGS ) hl_error("Too many arguments");
	tmp.a.t = &hlt_array;
	tmp.a.at = &hlt_dyn;
	tmp.a.size = nargs;
	if( c->hasValue ) {
		ctmp.t = c->t->fun->parent;
		ctmp.hasValue = 0;
		ctmp.fun = c->fun;
		tmp.args[0] = hl_make_dyn(&c->value,ctmp.t->fun->args[0]);
		tmp.a.size++;
		for(i=0;i<nargs;i++)
			tmp.args[i+1] = args[i];
		c = &ctmp;
	} else {
		for(i=0;i<nargs;i++)
			tmp.args[i] = args[i];
	}
	return hl_call_method((vdynamic*)c,&tmp.a);
}

static vdynamic *hlc_dyn_call_obj( vdynamic *o, int hfield, vdynamic **args, int nargs ) {
	switch( o->t->kind ) {
	case HDYNOBJ:
		hl_fatal("TODO");
		break;
	case HOBJ:
		{
			hl_runtime_obj *rt = o->t->obj->rt;
			while( true ) {
				hl_field_lookup *l = hl_lookup_find(rt->lookup,rt->nlookup, hfield);
				if( l != NULL && l->field_index < 0 ) {
					vclosure *ctmp = hl_alloc_closure_ptr(l->t,rt->methods[-l->field_index-1],o);
					return hlc_dyn_call_args(ctmp,args,nargs);
				}
				rt = rt->parent;
				if( rt == NULL ) break;
			}
			hl_error_msg(USTR("%s has no method %s"),o->t->obj->name,hl_field_name(hfield));
		}
		break;
	default:
		hl_error("Invalid field access");
		break;
	}
	return NULL;
}

#endif

#include <setjmp.h>

typedef struct _hl_trap_ctx hl_trap_ctx;

struct _hl_trap_ctx {
	jmp_buf buf;
	hl_trap_ctx *prev;
};

extern hl_trap_ctx *hl_current_trap;
extern vdynamic *hl_current_exc;

#define hlc_trap(ctx,r,label) { ctx.prev = hl_current_trap; hl_current_trap = &ctx; if( setjmp(ctx.buf) ) { r = hl_current_exc; goto label; } }
#define hlc_endtrap(ctx) hl_current_trap = ctx.prev

#endif
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
#include <hl.h>

#define TK2(a,b)		((a) | ((b)<<5))

vdynamic *hl_make_dyn( void *data, hl_type *t ) {
	vdynamic *v;
	switch( t->kind ) {
	case HI8:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.c = *(char*)data;
		return v;
	case HI16:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.s = *(short*)data;
		return v;
	case HI32:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.i = *(int*)data;
		return v;
	case HF32:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.f = *(float*)data;
		return v;
	case HF64:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.d = *(double*)data;
		return v;
	case HBOOL:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.b = *(bool*)data;
		return v;
	case HBYTES:
	case HTYPE:
	case HREF:
	case HABSTRACT:
	case HENUM:
		{
			void *p = *(void**)data;
			if( p == NULL ) return NULL;
			v = (vdynamic*)hl_gc_alloc(sizeof(vdynamic));
			v->t = t;
			v->v.ptr = p;
			return v;
		}
	default:
		return *(vdynamic**)data;
	}
}


int hl_dyn_casti( void *data, hl_type *t, hl_type *to ) {
	if( t->kind == HDYN ) {
		vdynamic *v = *((vdynamic**)data);
		if( v == NULL ) return 0;
		t = v->t;
		if( !hl_is_dynamic(t) ) data = &v->v;
	}
	switch( t->kind ) {
	case HI8:
		return *(char*)data;
	case HI16:
		return *(short*)data;
	case HI32:
		return *(int*)data;
	case HF32:
		return (int)*(float*)data;
	case HF64:
		return (int)*(double*)data;
	case HBOOL:
		return *(bool*)data;
	case HNULL:
		{
			vdynamic *v = *(vdynamic**)data;
			if( v == NULL ) return 0;
			return hl_dyn_casti(&v->v,t->tparam,to);
		}
	default:
		break;
	}
	hl_error_msg(USTR("Can't cast %s(%s) to %s"),hl_to_string(hl_make_dyn(data,t)),hl_type_str(t),hl_type_str(to));
	return 0;
}

void *hl_dyn_castp( void *data, hl_type *t, hl_type *to ) {
	if( t->kind == HDYN || t->kind == HNULL ) {
		vdynamic *v = *(vdynamic**)data;
		if( v == NULL ) return NULL;
		t = v->t;
		if( !hl_is_dynamic(t) ) data = &v->v;
	} else if( hl_is_dynamic(t) ) {
		vdynamic *v = *(vdynamic**)data;
		if( v == NULL ) return NULL;
		t = v->t;
	}
	if( t == to || hl_safe_cast(t,to) )
		return *(void**)data;
	switch( TK2(t->kind,to->kind) ) {
	case TK2(HOBJ,HOBJ):
		{
			hl_type_obj *t1 = t->obj;
			hl_type_obj *t2 = to->obj;
			while( true ) {
				if( t1 == t2 )
					return *(void**)data;
				if( t1->super == NULL )
					break;
				t1 = t1->super->obj;
			}
			if( t->obj->rt->castFun ) {
				vdynamic *v = t->obj->rt->castFun(*(vdynamic**)data,to);
				if( v ) return v;
			}
			break;
		}
	case TK2(HFUN,HFUN):
		{
			vclosure *c = *(vclosure**)data;
			if( c == NULL ) return NULL;
			c = hl_make_fun_wrapper(c,to);
			if( c ) return c;
		}
		break;
	case TK2(HOBJ,HVIRTUAL):
	case TK2(HDYNOBJ,HVIRTUAL):
	case TK2(HVIRTUAL,HVIRTUAL):
		return hl_to_virtual(to,*(vdynamic**)data);
	case TK2(HVIRTUAL,HOBJ):
		{
			vvirtual *v = *(vvirtual**)data;
			if( v->value == NULL ) break;
			return hl_dyn_castp( &v->value, v->value->t, to);
		}
	case TK2(HOBJ,HDYN):
	case TK2(HDYNOBJ,HDYN):
	case TK2(HFUN,HDYN):
	case TK2(HNULL,HDYN):
	case TK2(HARRAY,HDYN):
		return *(void**)data;
	}
	if( to->kind == HDYN )
		return hl_make_dyn(data,t);
	if( to->kind == HNULL ) {
		if( to->tparam->kind == t->kind )
			return hl_make_dyn(data,t);
		switch( to->tparam->kind ) {
		case HI8:
		case HI16:
		case HI32:
		case HBOOL:
			{
				int v = hl_dyn_casti(data,t,to->tparam);
				return hl_make_dyn(&v,to->tparam);
			}
		case HF32:
			{
				float f = hl_dyn_castf(data,t);
				return hl_make_dyn(&f,to->tparam);
			}
		case HF64:
			{
				double d = hl_dyn_castd(data,t);
				return hl_make_dyn(&d,to->tparam);
			}
		default:
			break;
		}
	}
	hl_error_msg(USTR("Can't cast %s(%s) to %s"),hl_to_string(hl_make_dyn(data,t)),hl_type_str(t),hl_type_str(to));
	return 0;
}

double hl_dyn_castd( void *data, hl_type *t ) {
	if( t->kind == HDYN ) {
		vdynamic *v = *((vdynamic**)data);
		if( v == NULL ) return 0;
		t = v->t;
		if( !hl_is_dynamic(t) ) data = &v->v;
	}
	switch( t->kind ) {
	case HF32:
		return *(float*)data;
	case HF64:
		return *(double*)data;
	case HI8:
		return *(char*)data;
	case HI16:
		return *(short*)data;
	case HI32:
		return *(int*)data;
	case HBOOL:
		return *(bool*)data;
	case HNULL:
		{
			vdynamic *v = *(vdynamic**)data;
			if( v == NULL ) return 0;
			return hl_dyn_castd(&v->v,t->tparam);
		}
	default:
		break;
	}
	return 0.;
}

float hl_dyn_castf( void *data, hl_type *t ) {
	if( t->kind == HDYN ) {
		vdynamic *v = *((vdynamic**)data);
		if( v == NULL ) return 0;
		t = v->t;
		if( !hl_is_dynamic(t) ) data = &v->v;
	}
	switch( t->kind ) {
	case HF32:
		return *(float*)data;
	case HF64:
		return (float)*(double*)data;
	case HI8:
		return *(char*)data;
	case HI16:
		return *(short*)data;
	case HI32:
		return (float)*(int*)data;
	case HBOOL:
		return *(bool*)data;
	case HNULL:
		{
			vdynamic *v = *(vdynamic**)data;
			if( v == NULL ) return 0;
			return hl_dyn_castf(&v->v,t->tparam);
		}
	default:
		break;
	}
	return 0;
}

static int fcompare( float a, float b ) {
	float d = a - b;
	if( d != d )
		return a == b ? 0 : hl_invalid_comparison; // +INF=+INF
 	return d == 0.f ? 0 : (d > 0.f ? 1 : -1);
}

static int dcompare( double a, double b ) {
	double d = a - b;
	if( d != d )
		return a == b ? 0 : hl_invalid_comparison; // +INF=+INF
 	return d == 0. ? 0 : (d > 0. ? 1 : -1);
}

int hl_dyn_compare( vdynamic *a, vdynamic *b ) {
	if( a == b )
		return 0;
	if( a == NULL )
		return -1;
	if( b == NULL )
		return 1;
	switch( TK2(a->t->kind,b->t->kind) ) {
	case TK2(HI8,HI8):
		return a->v.c - b->v.c;
	case TK2(HI16,HI16):
		return a->v.s - b->v.s;
	case TK2(HI32,HI32):
		return a->v.i - b->v.i;
	case TK2(HF32,HF32):
		return fcompare(a->v.f,b->v.f);
	case TK2(HF64,HF64):
		return dcompare(a->v.d,b->v.d);
	case TK2(HBOOL,HBOOL):
		return a->v.b - b->v.b;
	case TK2(HF64, HI32):
		return dcompare(a->v.d,(double)b->v.i);
	case TK2(HI32, HF64):
		return dcompare((double)a->v.i,b->v.d);
	case TK2(HOBJ,HOBJ):
		if( a->t->obj == b->t->obj && a->t->obj->rt->compareFun )
			return a->t->obj->rt->compareFun(a,b);
		return a > b ? 1 : -1;
	case TK2(HENUM,HENUM):
	case TK2(HTYPE,HTYPE):
	case TK2(HBYTES,HBYTES):
		return a->v.ptr != b->v.ptr;
	case TK2(HOBJ,HVIRTUAL):
	case TK2(HDYNOBJ,HVIRTUAL):
		return hl_dyn_compare(a,((vvirtual*)b)->value);
	case TK2(HVIRTUAL,HOBJ):
	case TK2(HVIRTUAL,HDYNOBJ):
		return hl_dyn_compare(((vvirtual*)a)->value,b);
	}
	return hl_invalid_comparison;
}

void hl_write_dyn( void *data, hl_type *t, vdynamic *v ) {
	switch( t->kind ) {
	case HI8:
	case HBOOL:
		*(char*)data = (char)hl_dyn_casti(&v,&hlt_dyn,t);
		break;
	case HI16:
		*(short*)data = (short)hl_dyn_casti(&v,&hlt_dyn,t);
		break;
	case HI32:
		*(int*)data = hl_dyn_casti(&v,&hlt_dyn,t);
		break;
	case HF32:
		*(float*)data = hl_dyn_castf(&v,&hlt_dyn);
		break;
	case HF64:
		*(double*)data = hl_dyn_castd(&v,&hlt_dyn);
		break;
	default:
		*(void**)data = hl_dyn_castp(&v,&hlt_dyn,t);
		break;
	}
}

HL_PRIM vdynamic* hl_value_cast( vdynamic *v, hl_type *t ) {
	if( t->kind == HDYN || v == NULL || hl_safe_cast(v->t,t) )
		return v;
	hl_error_msg(USTR("Can't cast %s to %s"),hl_to_string(v),hl_type_str(t));
	return NULL;
}

HL_PRIM bool hl_type_safe_cast( hl_type *a, hl_type *b ) {
	return hl_safe_cast(a,b);
}

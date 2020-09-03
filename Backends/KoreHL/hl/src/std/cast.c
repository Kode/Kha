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
#include <math.h>

#define TK2(a,b)		((a) | ((b)<<5))

static void invalid_cast( hl_type *from, hl_type *to ) {
	hl_error("Can't cast %s to %s",hl_type_str(from),hl_type_str(to));
}

HL_PRIM vdynamic *hl_make_dyn( void *data, hl_type *t ) {
	vdynamic *v;
	switch( t->kind ) {
	case HUI8:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.i = *(unsigned char*)data;
		return v;
	case HUI16:
		v = (vdynamic*)hl_gc_alloc_noptr(sizeof(vdynamic));
		v->t = t;
		v->v.i = *(unsigned short*)data;
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
		return hl_alloc_dynbool(*(bool*)data);
	case HBYTES:
	case HTYPE:
	case HREF:
	case HABSTRACT:
		{
			void *p = *(void**)data;
			if( p == NULL ) return NULL;
			v = hl_alloc_dynamic(t);
			v->v.ptr = p;
			return v;
		}
	default:
		return *(vdynamic**)data;
	}
}


HL_PRIM int hl_dyn_casti( void *data, hl_type *t, hl_type *to ) {
	hl_track_call(HL_TRACK_CAST, on_cast(t,to));
	if( t->kind == HDYN ) {
		vdynamic *v = *((vdynamic**)data);
		if( v == NULL ) return 0;
		t = v->t;
		if( !hl_is_dynamic(t) ) data = &v->v;
	}
	switch( t->kind ) {
	case HUI8:
		return *(unsigned char*)data;
	case HUI16:
		return *(unsigned short*)data;
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
	invalid_cast(t,to);
	return 0;
}

HL_PRIM void *hl_dyn_castp( void *data, hl_type *t, hl_type *to ) {
	hl_track_call(HL_TRACK_CAST, on_cast(t,to));
	if( to->kind == HDYN && hl_is_dynamic(t) )
		return *(vdynamic**)data;
	if( t->kind == HDYN || t->kind == HNULL ) {
		vdynamic *v = *(vdynamic**)data;
		if( v == NULL )
			return NULL;
		if( to->kind == HNULL && v->t == to->tparam && hl_is_gc_ptr(v) )
			return v; // v might be a vdynamic on the stack
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
	case TK2(HSTRUCT,HSTRUCT):
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
	// NO(HSTRUCT,HDYN)
		return *(void**)data;
	}
	if( to->kind == HDYN )
		return hl_make_dyn(data,t);
	if( to->kind == HNULL ) {
		if( to->tparam->kind == t->kind )
			return hl_make_dyn(data,t);
		switch( to->tparam->kind ) {
		case HUI8:
		case HUI16:
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
	if( to->kind == HREF ) {
		switch( to->tparam->kind ) {
		case HUI8:
		case HUI16:
		case HI32:
		case HBOOL:
			{
				int *v = (int*)hl_gc_alloc_noptr(sizeof(int));
				*v = hl_dyn_casti(data,t,to->tparam);
				return v;
			}
		case HF32:
			{
				float *f = (float*)hl_gc_alloc_noptr(sizeof(float));
				*f = hl_dyn_castf(data,t);
				return f;
			}
		case HF64:
			{
				double *d = (double*)hl_gc_alloc_noptr(sizeof(double));
				*d = hl_dyn_castd(data,t);
				return d;
			}
		default:
			{
				void **p = (void**)hl_gc_alloc_raw(sizeof(void*));
				*p = hl_dyn_castp(data,t,to->tparam);
				return p;
			}
			break;
		}
	}
	invalid_cast(t,to);
	return 0;
}

HL_PRIM double hl_dyn_castd( void *data, hl_type *t ) {
	hl_track_call(HL_TRACK_CAST, on_cast(t,&hlt_f64));
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
	case HUI8:
		return *(unsigned char*)data;
	case HUI16:
		return *(unsigned short*)data;
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
	invalid_cast(t,&hlt_f64);
	return 0.;
}

HL_PRIM float hl_dyn_castf( void *data, hl_type *t ) {
	hl_track_call(HL_TRACK_CAST, on_cast(t,&hlt_f32));
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
	case HUI8:
		return *(unsigned char*)data;
	case HUI16:
		return *(unsigned short*)data;
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
	invalid_cast(t,&hlt_f32);
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

HL_PRIM int hl_ptr_compare( vdynamic *a, vdynamic *b ) {
	if( a == b )
		return 0;
	return a > b ? 1 : -1;
}

HL_PRIM int hl_dyn_compare( vdynamic *a, vdynamic *b ) {
	hl_track_call(HL_TRACK_CAST, on_cast(a?a->t:&hlt_dyn,b?b->t:&hlt_dyn));
	if( a == b )
		return 0;
	if( a == NULL )
		return -1;
	if( b == NULL )
		return 1;
	switch( TK2(a->t->kind,b->t->kind) ) {
	case TK2(HUI8,HUI8):
		return (int)a->v.ui8 - (int)b->v.ui8;
	case TK2(HUI16,HUI16):
		return (int)a->v.ui16 - (int)b->v.ui16;
	case TK2(HI32,HI32):
		{
			int d = a->v.i - b->v.i;
			return d == hl_invalid_comparison ? -1 : d;
		}
	case TK2(HF32,HF32):
		return fcompare(a->v.f,b->v.f);
	case TK2(HF64,HF64):
		return dcompare(a->v.d,b->v.d);
	case TK2(HBOOL,HBOOL):
		return (int)a->v.b - (int)b->v.b;
	case TK2(HF64, HI32):
		return dcompare(a->v.d,(double)b->v.i);
	case TK2(HI32, HF64):
		return dcompare((double)a->v.i,b->v.d);
	case TK2(HF64, HF32):
		return dcompare(a->v.d,(double)b->v.f);
	case TK2(HF32, HF64):
		return dcompare((double)a->v.f,b->v.d);
	case TK2(HOBJ,HOBJ):
	case TK2(HSTRUCT,HSTRUCT):
		if( a->t->obj->rt->compareFun )
			return a->t->obj->rt->compareFun(a,b);
		return a > b ? 1 : -1;
	case TK2(HENUM,HENUM):
		return a > b ? 1 : -1;
	case TK2(HTYPE,HTYPE):
	case TK2(HBYTES,HBYTES):
		return a->v.ptr != b->v.ptr;
	case TK2(HOBJ,HVIRTUAL):
	case TK2(HDYNOBJ,HVIRTUAL):
		return hl_dyn_compare(a,((vvirtual*)b)->value);
	case TK2(HVIRTUAL,HOBJ):
	case TK2(HVIRTUAL,HDYNOBJ):
		return hl_dyn_compare(((vvirtual*)a)->value,b);
	case TK2(HFUN,HFUN):
		if( ((vclosure*)a)->hasValue == 2 )
			return hl_dyn_compare((vdynamic*)((vclosure_wrapper*)a)->wrappedFun,b);
		if( ((vclosure*)b)->hasValue == 2 )
			return hl_dyn_compare(a,(vdynamic*)((vclosure_wrapper*)b)->wrappedFun);
		if( ((vclosure*)a)->fun != ((vclosure*)b)->fun )
			return hl_invalid_comparison;
		return hl_dyn_compare(((vclosure*)a)->value,((vclosure*)b)->value);
	case TK2(HVIRTUAL,HVIRTUAL):
		if( ((vvirtual*)a)->value && ((vvirtual*)b)->value )
			return hl_dyn_compare(((vvirtual*)a)->value,((vvirtual*)b)->value);
		return hl_invalid_comparison;
	}
	return hl_invalid_comparison;
}

HL_PRIM void hl_write_dyn( void *data, hl_type *t, vdynamic *v, bool is_tmp ) {
	hl_track_call(HL_TRACK_CAST, on_cast(v?v->t:&hlt_dyn,t));
	switch( t->kind ) {
	case HUI8:
		*(unsigned char*)data = (unsigned char)hl_dyn_casti(&v,&hlt_dyn,t);
		break;
	case HBOOL:
		*(bool*)data = hl_dyn_casti(&v,&hlt_dyn,t) != 0;
		break;
	case HUI16:
		*(unsigned short*)data = (unsigned short)hl_dyn_casti(&v,&hlt_dyn,t);
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
		{
			void *ret = (v && hl_same_type(t,v->t)) ? v : hl_dyn_castp(&v,&hlt_dyn,t);
			if( is_tmp && ret == v ) {
				ret = hl_alloc_dynamic(v->t);
				((vdynamic*)ret)->v = v->v;
			}
			*(void**)data = ret;
		}
		break;
	}
}

HL_PRIM vdynamic* hl_value_cast( vdynamic *v, hl_type *t ) {
	hl_track_call(HL_TRACK_CAST, on_cast(v?v->t:&hlt_dyn,t));
	if( t->kind == HDYN || v == NULL || hl_safe_cast(v->t,t) )
		return v;
	invalid_cast(v->t,t);
	return NULL;
}

HL_PRIM bool hl_type_safe_cast( hl_type *a, hl_type *b ) {
	return hl_safe_cast(a,b);
}

#define NULL_VAL HLAST
#define OP(op,t1,t2)	(TK2(t1,t2) | (op << 10))
#define OP_ADD 0
#define OP_SUB 1
#define OP_MUL 2
#define OP_MOD 3
#define OP_DIV 4
#define OP_SHL 5
#define OP_SHR 6
#define OP_USHR 7
#define OP_AND 8
#define OP_OR  9
#define OP_XOR 10

static vdynamic *hl_dynf64( double v ) {
	vdynamic *d = hl_alloc_dynamic(&hlt_f64);
	d->v.d = v;
	return d;
}

static vdynamic *hl_dyni32( int v ) {
	vdynamic *d = hl_alloc_dynamic(&hlt_i32);
	d->v.i = v;
	return d;
}

static bool is_number( hl_type *t ) {
	return t->kind >= HUI8 && t->kind <= HBOOL;
}

#define FOP(op) { double va = hl_dyn_castd(&a,&hlt_dyn); double vb = hl_dyn_castd(&b,&hlt_dyn); return hl_dynf64(va op vb); }
#define IOP(op) { int va = hl_dyn_casti(&a,&hlt_dyn,&hlt_i32); int vb = hl_dyn_casti(&b,&hlt_dyn,&hlt_i32); return hl_dyni32(va op vb); }

HL_PRIM vdynamic *hl_dyn_op( int op, vdynamic *a, vdynamic *b ) {
	static uchar *op_names[] = { USTR("+"), USTR("-"), USTR("*"), USTR("%"), USTR("/"), USTR("<<"), USTR(">>"), USTR(">>>"), USTR("&"), USTR("|"), USTR("^") };
	if( op < 0 || op >= OpLast ) hl_error("Invalid op %d",op);
	hl_track_call(HL_TRACK_CAST, on_cast(a?a->t:&hlt_dyn,b?b->t:&hlt_dyn));
	if( !a && !b ) return op == OP_DIV || op == OP_MOD ? hl_dynf64(hl_nan()) : NULL;
	if( (!a || is_number(a->t)) && (!b || is_number(b->t)) ) {
		switch( op ) {
		case OP_ADD: FOP(+);
		case OP_SUB: FOP(-);
		case OP_MUL: FOP(*);
		case OP_MOD: {
			double va = hl_dyn_castd(&a,&hlt_dyn);
			double vb = hl_dyn_castd(&b,&hlt_dyn);
			return hl_dynf64(fmod(va,vb));
		}
		case OP_DIV: FOP(/);
		case OP_SHL: IOP(<<);
		case OP_SHR: IOP(>>);
		case OP_USHR: {
			int va = hl_dyn_casti(&a,&hlt_dyn,&hlt_i32);
			int vb = hl_dyn_casti(&b,&hlt_dyn,&hlt_i32);
			return hl_dyni32( ((unsigned)va) >> ((unsigned)vb) );
		}
		case OP_AND: IOP(&);
		case OP_OR: IOP(|);
		case OP_XOR: IOP(^);
		}
	}
	hl_error("Can't perform dyn op %s %s %s",hl_type_str(a->t),op_names[op],hl_type_str(b->t));
	return NULL;
}

DEFINE_PRIM(_I32, dyn_compare, _DYN _DYN);
DEFINE_PRIM(_DYN, value_cast, _DYN _TYPE);
DEFINE_PRIM(_BOOL, type_safe_cast, _TYPE _TYPE);
DEFINE_PRIM(_DYN, dyn_op, _I32 _DYN _DYN);
DEFINE_PRIM(_I32, ptr_compare, _DYN _DYN);


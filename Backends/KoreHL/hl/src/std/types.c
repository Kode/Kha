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

hl_type hlt_array = { HARRAY };
hl_type hlt_bytes = { HBYTES };
hl_type hlt_dynobj = { HDYNOBJ };
hl_type hlt_dyn = { HDYN };
hl_type hlt_i32 = { HI32 };
hl_type hlt_f32 = { HF32 };
hl_type hlt_f64 = { HF64 };
hl_type hlt_void = { HVOID };

static const uchar *TSTR[] = {
	USTR("void"), USTR("i8"), USTR("i16"), USTR("i32"), USTR("f32"), USTR("f64"),
	USTR("bool"), USTR("bytes"), USTR("dynamic"), NULL, NULL, 
	USTR("array"), USTR("type"), NULL, NULL, USTR("dynobj"), 
	NULL, NULL, NULL
};


int hl_type_size( hl_type *t ) {
	static int SIZES[] = {
		0, // VOID
		1, // I8
		2, // I16
		4, // I32
		4, // F32
		8, // F64
		1, // BOOL
		HL_WSIZE, // BYTES
		HL_WSIZE, // DYN
		HL_WSIZE, // FUN
		HL_WSIZE, // OBJ
		HL_WSIZE, // ARRAY
		HL_WSIZE, // TYPE
		HL_WSIZE, // REF
		HL_WSIZE, // VIRTUAL
		HL_WSIZE, // DYNOBJ
		HL_WSIZE, // ABSTRACT
		HL_WSIZE, // ENUM
		HL_WSIZE, // NULL
	};
	return SIZES[t->kind];
}

int hl_pad_size( int pos, hl_type *t ) {
	int sz = hl_type_size(t);
	int align;
	align = pos & (sz - 1);
	if( align && t->kind != HVOID )
		return sz - align;
	return 0;
}

bool hl_same_type( hl_type *a, hl_type *b ) {
	if( a == b )
		return true;
	if( a->kind != b->kind )
		return false;
	switch( a->kind ) {
	case HVOID:
	case HI8:
	case HI16:
	case HI32:
	case HF32:
	case HF64:
	case HBOOL:
	case HTYPE:
	case HBYTES:
	case HDYN:
	case HARRAY:
	case HDYNOBJ:
		return true;
	case HREF:
	case HNULL:
		return hl_same_type(a->tparam, b->tparam);
	case HFUN:
		{
			int i;
			if( a->fun->nargs != b->fun->nargs )
				return false;
			for(i=0;i<a->fun->nargs;i++)
				if( !hl_same_type(a->fun->args[i],b->fun->args[i]) )
					return false;
			return hl_same_type(a->fun->ret, b->fun->ret);
		}
	case HOBJ:
		return a->obj == b->obj;
	case HVIRTUAL:
		return a->virt == b->virt;
	case HABSTRACT:
		return a->abs_name == b->abs_name;
	case HENUM:
		return a->tenum == b->tenum;
	default:
		break;
	}
	return false;
}

bool hl_is_dynamic( hl_type *t ) {
	static bool T_IS_DYNAMIC[] = {
		false, // HVOID,
		false, // HI8
		false, // HI16
		false, // HI32
		false, // HF32
		false, // HF64
		false, // HBOOL
		false, // HBYTES
		true, // HDYN
		true, // HFUN
		true, // HOBJ
		true, // HARRAY
		false, // HTYPE
		false, // HREF
		true, // HVIRTUAL
		true, // HDYNOBJ
		false, // HABSTRACT
		false, // HENUM
		true, // HNULL
	};
	return T_IS_DYNAMIC[t->kind];
}

bool hl_safe_cast( hl_type *t, hl_type *to ) {
	if( t == to )
		return true;
	if( to->kind == HDYN )
		return hl_is_dynamic(t);
	if( t->kind != to->kind )
		return false;
	switch( t->kind ) {
	case HVIRTUAL:
		if( to->virt->nfields < t->virt->nfields ) {
			int i;
			for(i=0;i<to->virt->nfields;i++) {
				hl_obj_field *f1 = t->virt->fields + i;
				hl_obj_field *f2 = to->virt->fields + i;
				if( f1->hashed_name != f2->hashed_name || !hl_same_type(f1->t,f2->t) )
					break;
			}
			if( i == to->virt->nfields )
				return true;
		}
		break;
	case HOBJ:
		{
			hl_type_obj *o = t->obj;
			hl_type_obj *oto = to->obj;
			while( true ) {
				if( o == oto ) return true;
				if( o->super == NULL ) return false;
				o = o->super->obj;
			}
		}
	case HFUN:
		if( t->fun->nargs == to->fun->nargs ) {
			int i;
			if( !hl_safe_cast(t->fun->ret,to->fun->ret) )
				return false;
			for(i=0;i<t->fun->nargs;i++) {
				hl_type *t1 = t->fun->args[i];
				hl_type *t2 = to->fun->args[i];
				if( !hl_safe_cast(t1,t2) && (t1->kind != HDYN || !hl_is_dynamic(t2)) )
					return false;
			}
			return true;
		}
		break;
	default:
		break;
	}
	return hl_same_type(t,to);
}

static void hl_type_str_rec( hl_buffer *b, hl_type *t ) {
	const uchar *c = TSTR[t->kind];
	int i;
	if( c != NULL ) {
		hl_buffer_str(b,c);
		return;
	}
	switch( t->kind ) {
	case HFUN:
		hl_buffer_char(b,'(');
		hl_type_str_rec(b,t->fun->ret);
		hl_buffer_char(b,' ');
		hl_buffer_char(b,'(');
		for(i=0; i<t->fun->nargs; i++) {
			if( i ) hl_buffer_char(b,',');
			hl_type_str_rec(b,t->fun->args[i]);
		}
		hl_buffer_char(b,')');
		hl_buffer_char(b,')');
		break;
	case HOBJ:
		hl_buffer_char(b,'#');
		hl_buffer_str(b,t->obj->name);
		break;
	case HREF:
		hl_buffer_str(b,USTR("ref<"));
		hl_type_str_rec(b,t->tparam);
		hl_buffer_char(b,'>');
		break;
	case HVIRTUAL:
		hl_buffer_str(b,USTR("virtual<"));
		for(i=0; i<t->virt->nfields; i++) {
			hl_obj_field *f = t->virt->fields + i;
			if( i ) hl_buffer_char(b,',');
			hl_buffer_str(b,f->name);
			hl_buffer_char(b,':');
			hl_type_str_rec(b,f->t);
		}
		hl_buffer_char(b,'>');
		break;
	case HABSTRACT:
		hl_buffer_str(b,t->abs_name);
		break;
	case HENUM:
		hl_buffer_str(b,USTR("enum"));
		if( t->tenum->name ) {
			hl_buffer_char(b,'<');
			hl_buffer_str(b,t->tenum->name);
			hl_buffer_char(b,'>');
		}
		break;
	case HNULL:
		hl_buffer_str(b,USTR("null<"));
		hl_type_str_rec(b,t->tparam);
		hl_buffer_char(b,'>');
		break;
	default:
		hl_buffer_str(b,USTR("???"));
		break;
	}
}

const uchar *hl_type_str( hl_type *t ) {
	const uchar *c = TSTR[t->kind];
	hl_buffer *b;
	if( c != NULL )
		return c;
	b = hl_alloc_buffer();
	hl_type_str_rec(b,t);
	return hl_buffer_content(b,NULL);
}

HL_PRIM vbyte* hl_type_name( hl_type *t ) {
	switch( t->kind ) {
	case HOBJ:
		return (vbyte*)t->obj->name;
	case HENUM:
		return (vbyte*)t->tenum->name;
	case HABSTRACT:
		return (vbyte*)t->abs_name;
	default:
		break;
	}
	return NULL;
}

HL_PRIM varray* hl_type_enum_fields( hl_type *t ) {
	varray *a = hl_alloc_array(&hlt_bytes,t->tenum->nconstructs);
	int i;
	for( i=0; i<t->tenum->nconstructs;i++)
		hl_aptr(a,vbyte*)[i] = (vbyte*)t->tenum->constructs[i].name;
	return a;
}

HL_PRIM int hl_type_args_count( hl_type *t ) {
	if( t->kind == HFUN )
		return t->fun->nargs;
	return 0;
}

HL_PRIM varray *hl_type_instance_fields( hl_type *t ) {
	varray *a;
	const uchar **names;
	int mcount = 0;
	int out = 0;
	hl_type_obj *o;
	hl_runtime_obj *rt;
	if( t->kind != HOBJ )
		return NULL;
	o = t->obj;
	while( true ) {
		int i;
		for(i=0;i<o->nproto;i++) {
			hl_obj_proto *p = o->proto + i;
			if( p->pindex < 0 ) mcount++;
		}
		if( o->super == NULL ) break;
		o = o->super->obj;
	}
	rt = hl_get_obj_rt(t);
	a = hl_alloc_array(&hlt_bytes,mcount + rt->nproto + rt->nfields);
	names = hl_aptr(a,const uchar*);
	o = t->obj;
	while( true ) {
		int i;
		int pproto = rt->parent ? rt->parent->nproto : 0;
		for(i=0;i<o->nproto;i++) {
			hl_obj_proto *p = o->proto + i;
			if( p->pindex < 0 || p->pindex >= pproto )
				names[out++] = p->name;
		}
		for(i=0;i<o->nfields;i++) {
			hl_obj_field *f = o->fields + i;
			names[out++] = f->name;
		}
		if( o->super == NULL ) break;
		o = o->super->obj;
		rt = o->rt;
	}
	return a;
}

HL_PRIM hl_type *hl_type_super( hl_type *t ) {
	if( t->kind == HOBJ && t->obj->super )
		return t->obj->super;
	return &hlt_void;
}

HL_PRIM vdynamic *hl_type_get_global( hl_type *t ) {
	switch( t->kind ) {
	case HOBJ:
		return t->obj->global_value ? *(vdynamic**)t->obj->global_value : NULL;
	case HENUM:
		return *(vdynamic**)t->tenum->global_value;
	default:
		break;
	}
	return NULL;
}

bool hl_type_enum_eq( vdynamic *a, vdynamic *b ) {
	int i;
	venum *ea, *eb;
	hl_enum_construct *c;
	if( a == b )
		return true;
	if( !a || !b || a->t != b->t || a->t->kind != HENUM )
		return false;
	ea = (venum*)a->v.ptr;
	eb = (venum*)b->v.ptr;
	if( ea->index != eb->index )
		return false;
	c = a->t->tenum->constructs + ea->index;
	for(i=0;i<c->nparams;i++) {
		hl_type *t = c->params[i];
		switch( t->kind ) {
		case HENUM:
			{
				vdynamic pa, pb;
				pa.t = pb.t = t;
				pa.v.ptr = *(void**)((char*)ea + c->offsets[i]);
				pb.v.ptr = *(void**)((char*)eb + c->offsets[i]);
				if( !hl_type_enum_eq(&pa,&pb) )
					return false;
			}
			break;
		default:
			if( hl_dyn_compare(hl_make_dyn((char*)ea + c->offsets[i],t),hl_make_dyn((char*)eb + c->offsets[i],t)) )
				return false;
			break;
		}
	}
	return true;
}

HL_PRIM vdynamic *hl_alloc_enum( hl_type *t, int index, varray *args ) {
	hl_enum_construct *c = t->tenum->constructs + index;
	venum *e;
	vdynamic *v;
	int i;
	bool hasPtr = false;
	if( c->nparams != args->size )
		return NULL;
	for(i=0;i<c->nparams;i++)
		if( hl_is_ptr(c->params[i]) ) {
			hasPtr = true;
			break;
		}
	e = (venum*)(hasPtr ? hl_gc_alloc(c->size) : hl_gc_alloc_noptr(c->size));
	e->index = index;
	for(i=0;i<c->nparams;i++)
		hl_write_dyn((char*)e+c->offsets[i],c->params[i],hl_aptr(args,vdynamic*)[i]);
	v = hl_alloc_dynamic(t);
	v->v.ptr = e;
	return v;
}

HL_PRIM varray *hl_enum_parameters( vdynamic *v ) {
	varray *a;
	venum *e = (venum*)v->v.ptr;
	hl_enum_construct *c = v->t->tenum->constructs + e->index;
	int i;
	a = hl_alloc_array(&hlt_dyn,c->nparams);
	for(i=0;i<c->nparams;i++)
		hl_aptr(a,vdynamic*)[i] = hl_make_dyn((char*)e+c->offsets[i],c->params[i]);
	return a;
}

DEFINE_PRIM(_BYTES, hl_type_name, _TYPE);
DEFINE_PRIM(_ARR, hl_type_enum_fields, _TYPE);

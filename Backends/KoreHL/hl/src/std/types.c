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

HL_PRIM hl_type hlt_array = { HARRAY };
HL_PRIM hl_type hlt_bytes = { HBYTES };
HL_PRIM hl_type hlt_dynobj = { HDYNOBJ };
HL_PRIM hl_type hlt_dyn = { HDYN };
HL_PRIM hl_type hlt_i32 = { HI32 };
HL_PRIM hl_type hlt_i64 = { HI64 };
HL_PRIM hl_type hlt_f32 = { HF32 };
HL_PRIM hl_type hlt_f64 = { HF64 };
HL_PRIM hl_type hlt_void = { HVOID };
HL_PRIM hl_type hlt_bool = { HBOOL };
HL_PRIM hl_type hlt_abstract = { HABSTRACT, {USTR("<abstract>")} };

static const uchar *TSTR[] = {
	USTR("void"), USTR("i8"), USTR("i16"), USTR("i32"), USTR("i64"), USTR("f32"), USTR("f64"),
	USTR("bool"), USTR("bytes"), USTR("dynamic"), NULL, NULL,
	USTR("array"), USTR("type"), NULL, NULL, USTR("dynobj"),
	NULL, NULL, NULL, NULL, NULL
};

static int T_SIZES[] = {
	0, // VOID
	1, // I8
	2, // I16
	4, // I32
	8, // I64
	4, // F32
	8, // F64
	sizeof(bool), // BOOL
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
	HL_WSIZE, // METHOD
	HL_WSIZE, // STRUCT
};

HL_PRIM int hl_type_size( hl_type *t ) {
	return T_SIZES[t->kind];
}

HL_PRIM int hl_pad_struct( int size, hl_type *t ) {
	int align = sizeof(void*);
#	define GET_ALIGN(type) { struct { unsigned char a; type b; } s = {0}; align = (int)((unsigned char *)&s.b - (unsigned char*)&s); }
	switch( t->kind ) {
	case HVOID:
		return 0;
	case HUI8:
		GET_ALIGN(unsigned char);
		break;
	case HUI16:
		GET_ALIGN(unsigned short);
		break;
	case HI32:
		GET_ALIGN(unsigned int);
		break;
	case HI64:
		GET_ALIGN(int64);
		break;
	case HF32:
		GET_ALIGN(float);
		break;
	case HF64:
		GET_ALIGN(double);
		break;
	case HBOOL:
		GET_ALIGN(bool);
		break;
	default:
		break;
	}
	return (-size) & (align - 1);
}

HL_PRIM bool hl_same_type( hl_type *a, hl_type *b ) {
	if( a == b )
		return true;
	if( a->kind != b->kind )
		return false;
	switch( a->kind ) {
	case HVOID:
	case HUI8:
	case HUI16:
	case HI32:
	case HI64:
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
	case HMETHOD:
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
	case HSTRUCT:
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

HL_PRIM bool hl_is_dynamic( hl_type *t ) {
	static bool T_IS_DYNAMIC[] = {
		false, // HVOID,
		false, // HI8
		false, // HI16
		false, // HI32
		false, // HI64
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
		true, // HENUM
		true, // HNULL
		false, // HMETHOD
		false, // HSTRUCT
	};
	return T_IS_DYNAMIC[t->kind];
}

HL_PRIM bool hl_safe_cast( hl_type *t, hl_type *to ) {
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
	case HSTRUCT:
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
	case HMETHOD:
		if( t->fun->nargs == to->fun->nargs ) {
			int i;
			if( !hl_safe_cast(t->fun->ret,to->fun->ret) )
				return false;
			for(i=0;i<t->fun->nargs;i++) {
				hl_type *t1 = t->fun->args[i];
				hl_type *t2 = to->fun->args[i];
				if( !hl_safe_cast(t2,t1) && (t1->kind != HDYN || !hl_is_dynamic(t2)) )
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

typedef struct tlist {
	hl_type *t;
	struct tlist *next;
} tlist;

static void hl_type_str_rec( hl_buffer *b, hl_type *t, tlist *parents ) {
	const uchar *c = TSTR[t->kind];
	tlist *l, cur;
	int i;
	if( c != NULL ) {
		hl_buffer_str(b,c);
		return;
	}
	l = parents;
	while( l ) {
		if( l->t == t ) {
			hl_buffer_str(b,USTR("<...>"));
			return;
		}
		l = l->next;
	}
	cur.t = t;
	cur.next = parents;
	l = &cur;
	switch( t->kind ) {
	case HFUN:
	case HMETHOD:
		hl_buffer_char(b,'(');
		hl_type_str_rec(b,t->fun->ret,l);
		hl_buffer_char(b,' ');
		hl_buffer_char(b,'(');
		for(i=0; i<t->fun->nargs; i++) {
			if( i ) hl_buffer_char(b,',');
			hl_type_str_rec(b,t->fun->args[i],l);
		}
		hl_buffer_char(b,')');
		hl_buffer_char(b,')');
		break;
	case HSTRUCT:
		hl_buffer_char(b,'@');
	case HOBJ:
		hl_buffer_str(b,t->obj->name);
		break;
	case HREF:
		hl_buffer_str(b,USTR("ref<"));
		hl_type_str_rec(b,t->tparam,l);
		hl_buffer_char(b,'>');
		break;
	case HVIRTUAL:
		hl_buffer_str(b,USTR("virtual<"));
		for(i=0; i<t->virt->nfields; i++) {
			hl_obj_field *f = t->virt->fields + i;
			if( i ) hl_buffer_char(b,',');
			hl_buffer_str(b,f->name);
			hl_buffer_char(b,':');
			hl_type_str_rec(b,f->t,l);
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
		hl_type_str_rec(b,t->tparam,l);
		hl_buffer_char(b,'>');
		break;
	default:
		hl_buffer_str(b,USTR("???"));
		break;
	}
}

HL_PRIM const uchar *hl_type_str( hl_type *t ) {
	const uchar *c = TSTR[t->kind];
	hl_buffer *b;
	if( c != NULL )
		return c;
	b = hl_alloc_buffer();
	hl_type_str_rec(b,t,NULL);
	return hl_buffer_content(b,NULL);
}

HL_PRIM vbyte* hl_type_name( hl_type *t ) {
	switch( t->kind ) {
	case HOBJ:
	case HSTRUCT:
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

HL_PRIM int hl_mark_size( int data_size );

HL_PRIM void hl_init_enum( hl_type *et, hl_module_context *m ) {
	int i, j;
	int mark_size = 0;
	unsigned int *mark;
	for(i=0;i<et->tenum->nconstructs;i++) {
		hl_enum_construct *c = et->tenum->constructs + i;
		c->hasptr = false;
		c->size = sizeof(void*)+sizeof(int); // t + index
		for(j=0;j<c->nparams;j++) {
			hl_type *t = c->params[j];
			c->size += hl_pad_struct(c->size,t);
			c->offsets[j] = c->size;
			if( hl_is_ptr(t) ) c->hasptr = true;
			c->size += hl_type_size(t);
		}
		if( c->hasptr ) {
			int max_pos = i * sizeof(int) + hl_mark_size(c->size - HL_WSIZE*2);
			if( max_pos > mark_size ) mark_size = max_pos;
		}
	}

	mark = (unsigned int*)hl_zalloc(&m->alloc,mark_size);
	for(i=0;i<et->tenum->nconstructs;i++) {
		hl_enum_construct *c = et->tenum->constructs + i;
		if( !c->hasptr ) continue;
		for(j=0;j<c->nparams;j++)
			if( hl_is_ptr(c->params[j]) ) {
				int pos = (c->offsets[j] / HL_WSIZE) - 2;
				mark[i + (pos >> 5)] |= 1 << (pos & 31);
			}
	}
	et->mark_bits = mark;
}

HL_PRIM varray* hl_type_enum_fields( hl_type *t ) {
	varray *a = hl_alloc_array(&hlt_bytes,t->tenum->nconstructs);
	int i;
	for( i=0; i<t->tenum->nconstructs;i++)
		hl_aptr(a,vbyte*)[i] = (vbyte*)t->tenum->constructs[i].name;
	return a;
}

HL_PRIM varray* hl_type_enum_values( hl_type *t ) {
	varray *a = hl_alloc_array(&hlt_dyn,t->tenum->nconstructs);
	int i;
	for( i=0; i<t->tenum->nconstructs;i++) {
		hl_enum_construct *c = t->tenum->constructs + i;
		if(c->nparams == 0)
			hl_aptr(a,venum*)[i] = hl_alloc_enum(t, i);
	}
	return a;
}

HL_PRIM int hl_type_args_count( hl_type *t ) {
	if( t->kind == HFUN || t->kind == HMETHOD )
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
	if( t->kind == HVIRTUAL ) {
		int i;
		a = hl_alloc_array(&hlt_bytes,t->virt->nfields);
		names = hl_aptr(a,const uchar *);
		for(i=0;i<t->virt->nfields;i++)
			names[i] = t->virt->fields[i].name;
		return a;
	}
	if( t->kind != HOBJ && t->kind != HSTRUCT )
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
	if( (t->kind == HOBJ || t->kind == HSTRUCT) && t->obj->super )
		return t->obj->super;
	return &hlt_void;
}

HL_PRIM vdynamic *hl_type_get_global( hl_type *t ) {
	switch( t->kind ) {
	case HOBJ:
	case HSTRUCT:
		return t->obj->global_value ? *(vdynamic**)t->obj->global_value : NULL;
	case HENUM:
		return *(vdynamic**)t->tenum->global_value;
	default:
		break;
	}
	return NULL;
}

HL_PRIM bool hl_type_set_global( hl_type *t, vdynamic *v ) {
	switch( t->kind ) {
	case HOBJ:
	case HSTRUCT:
		if( t->obj->global_value ) {
			*(vdynamic**)t->obj->global_value = v;
			return true;
		}
		break;
	case HENUM:
		if( t->tenum->global_value ) {
			*(vdynamic**)t->tenum->global_value = v;
			return true;
		}
		break;
	default:
		break;
	}
	return false;
}

HL_PRIM bool hl_type_enum_eq( venum *a, venum *b ) {
	int i;
	hl_enum_construct *c;
	if( a == b )
		return true;
	if( !a || !b || a->t != b->t )
		return false;
	if( a->index != b->index )
		return false;
	c = a->t->tenum->constructs + a->index;
	for(i=0;i<c->nparams;i++) {
		hl_type *t = c->params[i];
		switch( t->kind ) {
		case HENUM:
			{
				venum *pa = *(venum**)((char*)a + c->offsets[i]);
				venum *pb = *(venum**)((char*)b + c->offsets[i]);
				if( !hl_type_enum_eq(pa,pb) )
					return false;
			}
			break;
		default:
			{
				vdynamic *pa = hl_make_dyn((char*)a + c->offsets[i],t);
				vdynamic *pb = hl_make_dyn((char*)b + c->offsets[i],t);
				if( pa && pb && pa->t->kind == HENUM && pb->t->kind == HENUM ) {
					if( !hl_type_enum_eq((venum*)pa,(venum*)pb) )
						return false;
					continue;
				}
				if( hl_dyn_compare(pa,pb) )
					return false;
			}
			break;
		}
	}
	return true;
}

HL_PRIM venum *hl_alloc_enum( hl_type *t, int index ) {
	hl_enum_construct *c = t->tenum->constructs + index;
	venum *v = (venum*)hl_gc_alloc_gen(t, c->size, MEM_KIND_DYNAMIC | (c->hasptr ? 0 : MEM_KIND_NOPTR) | MEM_ZERO);
	v->t = t;
	v->index = index;
	return v;
}

HL_PRIM venum *hl_alloc_enum_dyn( hl_type *t, int index, varray *args, int nargs ) {
	hl_enum_construct *c = t->tenum->constructs + index;
	venum *e;
	int i;
	if( c->nparams != nargs || args->size < nargs )
		return NULL;
	e = hl_alloc_enum(t, index);
	for(i=0;i<c->nparams;i++)
		hl_write_dyn((char*)e+c->offsets[i],c->params[i],hl_aptr(args,vdynamic*)[i],false);
	return e;
}

HL_PRIM varray *hl_enum_parameters( venum *e ) {
	varray *a;
	hl_enum_construct *c = e->t->tenum->constructs + e->index;
	int i;
	a = hl_alloc_array(&hlt_dyn,c->nparams);
	for(i=0;i<c->nparams;i++)
		hl_aptr(a,vdynamic*)[i] = hl_make_dyn((char*)e+c->offsets[i],c->params[i]);
	return a;
}

DEFINE_PRIM(_BYTES, type_str, _TYPE);
DEFINE_PRIM(_BYTES, type_name, _TYPE);
DEFINE_PRIM(_I32, type_args_count, _TYPE);
DEFINE_PRIM(_ARR, type_instance_fields, _TYPE);
DEFINE_PRIM(_TYPE, type_super, _TYPE);
DEFINE_PRIM(_DYN, type_get_global, _TYPE);
DEFINE_PRIM(_ARR, type_enum_fields, _TYPE);
DEFINE_PRIM(_ARR, type_enum_values, _TYPE);
DEFINE_PRIM(_BOOL, type_enum_eq, _DYN _DYN);
DEFINE_PRIM(_DYN, alloc_enum_dyn, _TYPE _I32 _ARR _I32);
DEFINE_PRIM(_ARR, enum_parameters, _DYN);
DEFINE_PRIM(_BOOL, type_set_global, _TYPE _DYN);

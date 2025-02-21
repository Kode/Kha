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
	NULL, NULL, NULL, NULL, NULL, NULL
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
	0, // PACKED
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
	case HPACKED:
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
		false, // HPACKED
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
	case HPACKED:
		return hl_safe_cast(t->tparam, to);
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
	case HPACKED:
		hl_buffer_str(b, USTR("packed<"));
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
	if( c->nparams < nargs || args->size < nargs )
		return NULL;
	if( nargs < c->nparams ) {
		// allow missing params if they are null-able
		for(i=nargs;i<c->nparams;i++)
			if( !hl_is_ptr(c->params[i]) )
				return NULL;
	}
	e = hl_alloc_enum(t, index);
	for(i=0;i<nargs;i++)
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


typedef struct {
	char *buf;
	int buf_pos;
	int buf_size;
	int *offsets;
	int offsets_pos;
	int offsets_size;
	void **lookup;
	int *lookup_index;
	int lookup_pos;
	int lookup_size;
	int *remap_target;
	int remap_pos;
	int remap_size;
	void **todos;
	int todos_pos;
	int todos_size;
	int flags;
} mem_context;

#define compact_grow(buf,pos,size,req,type) \
	if( ctx->pos + req > ctx->size ) { \
		int nsize = ctx->size; \
		if( nsize == 0 ) nsize = 256 /sizeof(type); \
		while( nsize < ctx->pos + req ) nsize = (nsize * 3) / 2; \
		type *nbuf = (type*)malloc(nsize * sizeof(type)); \
		memcpy(nbuf,ctx->buf,ctx->pos * sizeof(type)); \
		free(ctx->buf); \
		ctx->buf = nbuf; \
		ctx->size = nsize; \
	}


static void compact_write_mem( mem_context *ctx, void *mem, int size ) {
	compact_grow(buf,buf_pos,buf_size,size,char);
	memcpy(ctx->buf + ctx->buf_pos, mem, size);
	ctx->buf_pos += size;
}

static void compact_write_ptr( mem_context *ctx, void *ptr ) {
	compact_write_mem(ctx,&ptr,sizeof(void*));
}

static void compact_write_int( mem_context *ctx, int v ) {
	compact_write_mem(ctx,&v,4);
}

static void compact_write_offset( mem_context *ctx, int position ) {
	compact_grow(offsets,offsets_pos,offsets_size,1,int);
	ctx->offsets[ctx->offsets_pos++] = ctx->buf_pos;
	compact_write_ptr(ctx,(void*)(int_val)position);
}

static int compact_lookup_index( mem_context *ctx, void *addr ) {
	int min = 0;
	int max = ctx->lookup_pos;
	while( min < max ) {
		int mid = (min + max) >> 1;
		void *a = ctx->lookup[mid];
		if( a < addr ) min = mid + 1; else if( a > addr ) max = mid; else return mid;
	}
	return -1;
}

#define BYTE_MARK 0x40000000

static int compact_lookup_ref( mem_context *ctx, void *addr, bool is_bytes ) {
	int min = 0;
	int max = ctx->lookup_pos;
	while( min < max ) {
		int mid = (min + max) >> 1;
		void *a = ctx->lookup[mid];
		if( a < addr ) min = mid + 1; else if( a > addr ) max = mid; else return ctx->remap_target[ctx->lookup_index[mid]&~BYTE_MARK];
	}
	if( ctx->lookup_pos == ctx->lookup_size ) {
		int nsize = ctx->lookup_size == 0 ? 128 : (ctx->lookup_size * 3) / 2;
		void **nlookup = (void**)malloc(nsize * sizeof(void*));
		int *nindex = (int*)malloc(nsize * sizeof(int));
		memcpy(nlookup,ctx->lookup,ctx->lookup_pos * sizeof(void*));
		memcpy(nindex,ctx->lookup_index,ctx->lookup_pos * sizeof(int));
		free(ctx->lookup);
		free(ctx->lookup_index);
		ctx->lookup = nlookup;
		ctx->lookup_index = nindex;
		ctx->lookup_size = nsize;
	}
	int pos = (min + max) >> 1;
	memmove(ctx->lookup + pos + 1, ctx->lookup + pos, (ctx->lookup_pos - pos) * sizeof(void*));
	memmove(ctx->lookup_index + pos + 1, ctx->lookup_index + pos, (ctx->lookup_pos - pos) * sizeof(int));
	int id = ctx->lookup_pos++;
	ctx->lookup[pos] = addr;
	ctx->lookup_index[pos] = id | (is_bytes ? BYTE_MARK : 0);
	compact_grow(todos,todos_pos,todos_size,1,void*);
	ctx->todos[ctx->todos_pos++] = addr;
	compact_grow(remap_target,remap_pos,remap_size,1,int);
	int target = -id-1;
	ctx->remap_target[ctx->remap_pos++] = target;
	return target;
}

static void compact_write_ref( mem_context *ctx, void *ptr, bool is_bytes ) {
	if( !ptr ) {
		compact_write_ptr(ctx, NULL);
		return;
	}
	int ref = compact_lookup_ref(ctx,ptr,is_bytes);
	compact_write_offset(ctx, ref);
}

static void compact_write_data( mem_context *ctx, hl_type *t, void *addr ) {
	if( hl_is_dynamic(t) ) {
		vdynamic *v = *(vdynamic**)addr;
		if( v == NULL || (v->t->kind == HENUM && v->t->tenum->constructs[((venum*)v)->index].nparams == 0) ) {
			compact_write_ptr(ctx,v);
			return;
		}
		compact_write_ref(ctx,v,false);
		return;
	}
	switch( t->kind ) {
	case HUI8:
		compact_write_mem(ctx, addr, 1);
		break;
	case HUI16:
		compact_write_mem(ctx, addr, 2);
		break;
	case HI32:
	case HF32:
		compact_write_mem(ctx, addr, 4);
		break;
	case HF64:
	case HI64:
		compact_write_mem(ctx, addr, 8);
		break;
	case HBOOL:
		compact_write_mem(ctx, addr, sizeof(bool));
		break;
	case HBYTES:
		{
			void *bytes = *(void**)addr;
			if( bytes == NULL || !hl_is_gc_ptr(bytes) ) {
				compact_write_ptr(ctx, bytes);
				break;
			}
			compact_write_ref(ctx, bytes, true);
		}
		break;
	case HABSTRACT:
		hl_error("Unsupported abstract %s", t->abs_name);
		break;
	default:
		hl_error("Unsupported type %d", t->kind);
		break;
	}
}

static void compact_pad( mem_context *ctx, hl_type *t ) {
	int sz = hl_pad_size(ctx->buf_pos,t);
	ctx->buf_pos += sz;
}

static void compact_write_content( mem_context *ctx, vdynamic *d ) {
	int i;
	hl_type *t = d->t;
	if( !hl_is_ptr(t) ) {
		compact_write_ptr(ctx, t);
		compact_write_mem(ctx,&d->v,hl_type_size(t));
		return;
	}
	switch( t->kind ) {
	case HOBJ: {
		char *obj_data = (char*)d;
		hl_runtime_obj *rt = hl_get_obj_rt(t);
		compact_grow(buf,buf_pos,buf_size,rt->size,char);
		memset(ctx->buf + ctx->buf_pos, 0xCD, rt->size);
		int buf_start = ctx->buf_pos;
		int fstart = rt->nfields;
		compact_write_ptr(ctx,t);
		while( t ) {
			fstart -= t->obj->nfields;
			for(i=0;i<t->obj->nfields;i++) {
				int fid = i + fstart;
				ctx->buf_pos = buf_start + rt->fields_indexes[fid];
				compact_write_data(ctx, t->obj->fields[i].t, obj_data + rt->fields_indexes[fid]);
			}
			t = t->obj->super;
		}
		ctx->buf_pos = buf_start + rt->size;
		break;
	}
	case HVIRTUAL: {
		vvirtual *v = (vvirtual*)d;
		int start = ctx->buf_pos;
		compact_write_ptr(ctx, t);
		if( ctx->flags & 4 )
			compact_write_offset(ctx, start); // virtual self value
		else if( ctx->flags & 2 )
			compact_write_ptr(ctx, NULL); // optimize virtuals
		else
			compact_write_data(ctx, &hlt_dyn, &v->value);
		compact_write_data(ctx, &hlt_dyn, &v->next);
		if( !v->value || (ctx->flags&6) ) {
			int target = ctx->buf_pos + t->virt->nfields * sizeof(void*);
			for(i=0;i<t->virt->nfields;i++) {
				hl_type *ft = t->virt->fields[i].t;
				target += hl_pad_size(target, ft);
				compact_write_offset(ctx, target);
				target += hl_type_size(ft);
			}
			for(i=0;i<t->virt->nfields;i++) {
				void *addr = ((void**)(v + 1))[i];
				hl_type *ft = t->virt->fields[i].t;
				compact_pad(ctx,ft);
				if( !addr ) {
					if( !hl_is_ptr(ft) ) hl_error("assert");
					compact_write_ptr(ctx,NULL);
				} else
					compact_write_data(ctx,ft,addr);
			}
		} else {
			vdynobj *obj = (vdynobj*)v->value;
			if( obj->t->kind != HDYNOBJ ) hl_error("assert");
			int todo_save = ctx->todos_pos;
			for(i=0;i<t->virt->nfields;i++) {
				void *addr = ((void**)(v + 1))[i];
				compact_write_ref(ctx, addr, false);
			}
			ctx->todos_pos = todo_save;
		}
		break;
	}
	case HDYNOBJ: {
		vdynobj *obj = (vdynobj*)d;
		int lookup_data = ctx->buf_pos + sizeof(vdynobj);
		int raw_data = lookup_data + obj->nfields * sizeof(hl_field_lookup);
		int values_data = raw_data + obj->raw_size;
		values_data += hl_pad_size(values_data,&hlt_dyn);

		compact_write_ptr(ctx, t);
		if( obj->lookup )
			compact_write_offset(ctx, lookup_data);
		else
			compact_write_ptr(ctx, NULL);
		if( obj->raw_data )
			compact_write_offset(ctx, raw_data);
		else
			compact_write_ptr(ctx, NULL);
		if( obj->values )
			compact_write_offset(ctx, values_data);
		else
			compact_write_ptr(ctx, NULL);
		compact_write_int(ctx,obj->nfields);
		compact_write_int(ctx,obj->raw_size);
		compact_write_int(ctx,obj->nvalues);
#		ifdef HL_64
		compact_write_int(ctx,0);
#		endif
		compact_write_ref(ctx,obj->virtuals,false);
		if( obj->lookup )
			compact_write_mem(ctx,obj->lookup,sizeof(hl_field_lookup) * obj->nfields);
		if( obj->raw_data )
			compact_write_mem(ctx,obj->raw_data,obj->raw_size);
		if( obj->values ) {
			compact_pad(ctx,&hlt_dyn);
			for(i=0;i<obj->nvalues;i++) {
				int j;
				for(j=0;i<obj->nfields;j++) {
					if( obj->lookup[j].field_index == i && hl_is_ptr(obj->lookup[j].t) ) {
						compact_write_data(ctx, obj->lookup[j].t, obj->values + i);
						break;
					}
				}
			}
		}
		int save_pos = ctx->todos_pos;
		for(i=0;i<obj->nfields;i++) {
			hl_field_lookup *f = obj->lookup + i;
			int idx = compact_lookup_ref(ctx, hl_is_ptr(f->t) ? (char*)(obj->values + f->field_index) : (char*)(obj->raw_data + f->field_index), false);
			idx = -idx-1;
			ctx->remap_target[idx] = hl_is_ptr(f->t) ? values_data + sizeof(void*)*f->field_index : raw_data + f->field_index;
		}
		ctx->todos_pos = save_pos;
		break;
	}
	case HARRAY: {
		varray *a = (varray*)d;
		compact_write_ptr(ctx, a->t);
		compact_write_ptr(ctx, a->at);
		compact_write_int(ctx, a->size);
		compact_write_int(ctx, 0);
		char *array_data = (char*)(a + 1);
		int stride = hl_type_size(a->at);
		for(i=0;i<a->size;i++) {
			compact_write_data(ctx,a->at, array_data + stride * i);
		}
		break;
	}
	case HENUM: {
		venum *e = (venum*)d;
		hl_enum_construct *c = &t->tenum->constructs[e->index];
		int buf_start = ctx->buf_pos;
		compact_write_ptr(ctx, e->t);
		compact_write_int(ctx, e->index);
		for(i=0;i<c->nparams;i++) {
			compact_pad(ctx,c->params[i]);
			compact_write_data(ctx,c->params[i],(char*)e+(ctx->buf_pos-buf_start));
		}
		break;
	}
	default:
		hl_error("Unsupported type %d", t->kind);
	}
}

HL_PRIM vdynamic *hl_mem_compact( vdynamic *d, varray *exclude, int flags, int *outCount ) {
	mem_context _ctx;
	mem_context *ctx = &_ctx;
	int i;
	int object_count = 0;
	memset(ctx,0,sizeof(mem_context));
	ctx->flags = flags;
	compact_lookup_ref(ctx,d,false);
	if( exclude ) {
		for(i=0;i<exclude->size;i++) {
			vdynamic *ptr = (vdynamic*)hl_aptr(exclude,void*)[i];
			compact_lookup_ref(ctx,ptr,false);
			ctx->todos_pos--;
		}
	}
	while( ctx->todos_pos > 0 ) {
		void *addr = ctx->todos[--ctx->todos_pos];
		int pos = compact_lookup_index(ctx, addr);
		int index = ctx->lookup_index[pos];
		compact_pad(ctx, &hlt_dyn);
		ctx->remap_target[index&~BYTE_MARK] = ctx->buf_pos;
		if( index & BYTE_MARK ) {
			int size = hl_gc_get_memsize(addr);
			if( size < 0 ) hl_error("assert");
			compact_write_mem(ctx, addr, size);
		} else
			compact_write_content(ctx, (vdynamic*)addr);
		object_count++;
	}
	vbyte *data = NULL;
#	ifdef HL_WIN
	if( flags & 1 )
		data = (vbyte*)VirtualAlloc(NULL,ctx->buf_pos,MEM_COMMIT|MEM_RESERVE,PAGE_READWRITE);
#	endif
	if( data == NULL )
		data = hl_gc_alloc_noptr(ctx->buf_pos);
	memcpy(data,ctx->buf,ctx->buf_pos);
	int exclude_count = exclude ? exclude->size : 0;
	for(i=0;i<ctx->offsets_pos;i++) {
		int pos = ctx->offsets[i];
		int target = *(int*)(data + pos);
		if( target < 0 ) {
			int eid = -target-1;
			if( eid > 0 && eid <= exclude_count ) {
				*(void**)(data+pos) = hl_aptr(exclude,void*)[eid-1];
				continue;
			}
			target = ctx->remap_target[eid];
		}
		*(void**)(data+pos) = data + target;
	}
	free(ctx->buf);
	free(ctx->offsets);
	free(ctx->lookup);
	free(ctx->lookup_index);
	free(ctx->remap_target);
	free(ctx->todos);
#	ifdef HL_WIN
	if( flags & 1 ) {
		DWORD old = 0;
		VirtualProtect(data,ctx->buf_pos,PAGE_READONLY,&old);
	}
#	endif
	if( outCount )
		*outCount = object_count;
	return (vdynamic*)data;
}

DEFINE_PRIM(_DYN, mem_compact, _DYN _ARR _I32 _REF(_I32));

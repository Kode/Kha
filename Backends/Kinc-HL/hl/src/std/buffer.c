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

#ifdef PRId64
#	define PR_I64 USTR("%" PRId64)
#else
#	define PR_I64 USTR("%lld")
#endif

typedef struct _stringitem {
	uchar *str;
	int size;
	int len;
	struct _stringitem *next;
} * stringitem;

struct hl_buffer {
	int totlen;
	int blen;
	stringitem data;
};

HL_PRIM hl_buffer *hl_alloc_buffer() {
	hl_buffer *b = (hl_buffer*)hl_gc_alloc_raw(sizeof(hl_buffer));
	b->totlen = 0;
	b->blen = 16;
	b->data = NULL;
	return b;
}

static void buffer_append_new( hl_buffer *b, const uchar *s, int len ) {
	int size;
	stringitem it;
	while( b->totlen >= (b->blen << 2) )
		b->blen <<= 1;
	size = (len < b->blen)?b->blen:len;
	it = (stringitem)hl_gc_alloc_raw(sizeof(struct _stringitem));
	it->str = (uchar*)hl_gc_alloc_noptr(size<<1);
	memcpy(it->str,s,len<<1);
	it->size = size;
	it->len = len;
	it->next = b->data;
	b->data = it;
}

HL_PRIM void hl_buffer_str_sub( hl_buffer *b, const uchar *s, int len ) {
	stringitem it;
	int offset = 0;
	if( s == NULL || len <= 0 )
		return;
	b->totlen += len;
	it = b->data;
	if( it ) {
		int free = it->size - it->len;
		if( free >= len ) {
			memcpy(it->str + it->len,s,len<<1);
			it->len += len;
			return;
		} else {
			memcpy(it->str + it->len,s,free<<1);
			it->len += free;
			offset = free;
			len -= free;
		}
	}
	buffer_append_new(b,s + offset,len);
}

HL_PRIM void hl_buffer_str( hl_buffer *b, const uchar *s ) {
	if( s ) hl_buffer_str_sub(b,s,(int)ustrlen(s)); else hl_buffer_str_sub(b,USTR("NULL"),4);
}

HL_PRIM void hl_buffer_cstr( hl_buffer *b, const char *s ) {
	if( s ) {
		int len = (int)hl_utf8_length((vbyte*)s,0);
		uchar *out = (uchar*)malloc(sizeof(uchar)*(len+1));
		hl_from_utf8(out,len,s);
		hl_buffer_str_sub(b,out,len);
		free(out);
	} else hl_buffer_str_sub(b,USTR("NULL"),4);
}

HL_PRIM void hl_buffer_char( hl_buffer *b, uchar c ) {
	stringitem it;
	b->totlen++;
	it = b->data;
	if( it && it->len != it->size ) {
		it->str[it->len++] = c;
		return;
	}
	buffer_append_new(b,(uchar*)&c,1);
}

HL_PRIM uchar *hl_buffer_content( hl_buffer *b, int *len ) {
	uchar *buf = (uchar*)hl_gc_alloc_noptr((b->totlen+1)<<1);
	stringitem it = b->data;
	uchar *s = ((uchar*)buf) + b->totlen;
	*s = 0;
	while( it != NULL ) {
		stringitem tmp;
		s -= it->len;
		memcpy(s,it->str,it->len<<1);
		tmp = it->next;
		it = tmp;
	}
	if( len ) *len = b->totlen;
	return buf;
}

int hl_buffer_length( hl_buffer *b ) {
	return b->totlen;
}

typedef struct vlist {
	vdynamic *v;
	struct vlist *next;
} vlist;

static void hl_buffer_rec( hl_buffer *b, vdynamic *v, vlist *stack );

static void hl_buffer_addr( hl_buffer *b, void *data, hl_type *t, vlist *stack ) {
	uchar buf[32];
	switch( t->kind ) {
	case HUI8:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%d"),(int)*(unsigned char*)data));
		break;
	case HUI16:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%d"),(int)*(unsigned short*)data));
		break;
	case HI32:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%d"),*(int*)data));
		break;
	case HI64:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,PR_I64,*(int64*)data));
		break;
	case HF32:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%.9f"),*(float*)data));
		break;
	case HF64:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%.17g"),*(double*)data));
		break;
	case HBYTES:
		hl_buffer_str(b,*(uchar**)data);
		break;
	case HTYPE:
	case HREF:
	case HABSTRACT:
		{
			vdynamic tmp;
			tmp.t = t;
			tmp.v.ptr = *(void**)data;
			hl_buffer_rec(b, tmp.v.ptr ? &tmp : NULL, stack);
		}
		break;
	case HBOOL:
		if( *(unsigned char*)data )
			hl_buffer_str_sub(b,USTR("true"),4);
		else
			hl_buffer_str_sub(b,USTR("false"),5);
		break;
	default:
		hl_buffer_rec(b, *(vdynamic**)data, stack);
		break;
	}
}

static void hl_buffer_rec( hl_buffer *b, vdynamic *v, vlist *stack ) {
	uchar buf[32];
	if( v == NULL ) {
		hl_buffer_str_sub(b,USTR("null"),4);
		return;
	}
	switch( v->t->kind ) {
	case HVOID:
		hl_buffer_str_sub(b,USTR("void"),4);
		break;
	case HUI8:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%d"),v->v.ui8));
		break;
	case HUI16:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%d"),v->v.ui16));
		break;
	case HI32:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%d"),v->v.i));
		break;
	case HI64:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,PR_I64,v->v.i64));
		break;
	case HF32:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%.9f"),v->v.f));
		break;
	case HF64:
		hl_buffer_str_sub(b,buf,usprintf(buf,32,USTR("%.17g"),v->v.d));
		break;
	case HBOOL:
		if( v->v.b )
			hl_buffer_str_sub(b,USTR("true"),4);
		else
			hl_buffer_str_sub(b,USTR("false"),5);
		break;
	case HBYTES:
		hl_buffer_str(b,(uchar*)v->v.bytes);
		break;
	case HFUN:
		hl_buffer_str_sub(b,USTR("function#"),9);
		hl_buffer_str_sub(b, buf, usprintf(buf, 32, _PTR_FMT,(int_val)v));
		break;
	case HMETHOD:
		hl_buffer_str_sub(b,USTR("method#"),7);
		hl_buffer_str_sub(b, buf, usprintf(buf, 32, _PTR_FMT,(int_val)v->v.ptr));
		break;
	case HOBJ:
	case HSTRUCT:
		{
			hl_type_obj *o = v->t->obj;
			if( o->rt == NULL || hl_get_obj_proto(v->t)->toStringFun == NULL ) {
				if( v->t->kind == HSTRUCT ) hl_buffer_char(b,'@');
				hl_buffer_str(b,o->name);
			} else
				hl_buffer_str(b,o->rt->toStringFun(v->t->kind == HSTRUCT ? (vdynamic*)v->v.ptr : v));
		}
		break;
	case HARRAY:
		{
			int i;
			varray *a = (varray*)v;
			hl_type *at = a->at;
			int stride = hl_type_size(at);
			vlist l;
			vlist *vtmp = stack;
			while( vtmp != NULL ) {
				if( vtmp->v == v ) {
					hl_buffer_str_sub(b,USTR("..."),3);
					return;
				}
				vtmp = vtmp->next;
			}
			l.v = v;
			l.next = stack;
			hl_buffer_char(b,'[');
			for(i=0;i<a->size;i++) {
				if( i )
					hl_buffer_str_sub(b,USTR(", "),2);
				hl_buffer_addr(b,hl_aptr(a,char) + i * stride,at,&l);
			}
			hl_buffer_char(b,']');
		}
		break;
	case HTYPE:
		hl_buffer_str(b, hl_type_str((hl_type*)v->v.ptr));
		break;
	case HREF:
		hl_buffer_str_sub(b, USTR("ref"), 3);
		break;
	case HVIRTUAL:
		{
			vvirtual *vv = (vvirtual*)v;
			int i;
			vlist l;
			vlist *vtmp = stack;
			if( vv->value ) {
				hl_buffer_rec(b, vv->value, stack);
				return;
			}
			while( vtmp != NULL ) {
				if( vtmp->v == v ) {
					hl_buffer_str_sub(b,USTR("..."),3);
					return;
				}
				vtmp = vtmp->next;
			}
			l.v = v;
			l.next = stack;
			hl_buffer_char(b, '{');
			for(i=0;i<vv->t->virt->nfields;i++) {
				hl_field_lookup *f = vv->t->virt->lookup + i;
				if( i ) hl_buffer_str_sub(b,USTR(", "),2);
				hl_buffer_str(b,(uchar*)hl_field_name(f->hashed_name));
				hl_buffer_str_sub(b,USTR(" : "),3);
				hl_buffer_addr(b, (char*)v + vv->t->virt->indexes[f->field_index], f->t, &l);
			}
			hl_buffer_char(b, '}');
		}
		break;
	case HDYNOBJ:
		{
			vdynobj *o = (vdynobj*)v;
			int i;
			vlist l;
			vlist *vtmp = stack;
			hl_field_lookup *f;
			while( vtmp != NULL ) {
				if( vtmp->v == v ) {
					hl_buffer_str_sub(b,USTR("..."),3);
					return;
				}
				vtmp = vtmp->next;
			}
			l.v = v;
			l.next = stack;
			f = hl_lookup_find(o->lookup,o->nfields,hl_hash_gen(USTR("__string"),false));
			if( f && f->t->kind == HFUN && f->t->fun->nargs == 0 && f->t->fun->ret->kind == HBYTES ) {
				vclosure *v = (vclosure*)o->values[f->field_index];
				if( v ) {
					hl_buffer_str(b, v->hasValue ? ((uchar*(*)(void*))v->fun)(v->value) : ((uchar*(*)())v->fun)());
					break;
				}
			}
			hl_buffer_char(b, '{');
			for(i=0;i<o->nfields;i++) {
				hl_field_lookup *f = o->lookup + i;
				if( i ) hl_buffer_str_sub(b,USTR(", "),2);
				hl_buffer_str(b,(uchar*)hl_field_name(f->hashed_name));
				hl_buffer_str_sub(b,USTR(" : "),3);
				hl_buffer_addr(b, hl_is_ptr(f->t) ? (void*)(o->values + f->field_index) : (void*)(o->raw_data + f->field_index), f->t, &l);
			}
			hl_buffer_char(b, '}');
		}
		break;
	case HABSTRACT:
		hl_buffer_char(b, '~');
		hl_buffer_str(b, v->t->abs_name);
		hl_buffer_char(b, ':');
		hl_buffer_str_sub(b, buf, usprintf(buf, 32, _PTR_FMT,(int_val)v->v.ptr));
		break;
	case HENUM:
		{
			int i;
			vlist l;
			vlist *vtmp = stack;
			hl_enum_construct *c = v->t->tenum->constructs + ((venum*)v)->index;
			if( !c->nparams ) {
				hl_buffer_str(b, c->name);
				break;
			}
			while( vtmp != NULL ) {
				if( vtmp->v == v ) {
					hl_buffer_str_sub(b,USTR("..."),3);
					return;
				}
				vtmp = vtmp->next;
			}
			l.v = v;
			l.next = stack;
			hl_buffer_str(b, c->name);
			hl_buffer_char(b,'(');
			for(i=0;i<c->nparams;i++) {
				if( i ) hl_buffer_char(b,',');
				hl_buffer_addr(b,(char*)v + c->offsets[i],c->params[i], &l);
			}
			hl_buffer_char(b,')');
		}
		break;
	case HNULL:
		hl_buffer_str_sub(b, USTR("_null_"), 6);
		break;
	default:
		hl_buffer_str_sub(b, buf, usprintf(buf, 32, _PTR_FMT USTR("H"),(int_val)v));
		break;
	}
}

HL_PRIM void hl_buffer_val( hl_buffer *b, vdynamic *v ) {
	hl_buffer_rec(b,v,NULL);
}

HL_PRIM uchar *hl_to_string( vdynamic *v ) {
	if( v == NULL )
		return USTR("null");
	if( v->t->kind == HBOOL )
		return v->v.b ? USTR("true") : USTR("false");
	hl_buffer *b = hl_alloc_buffer();
	hl_buffer_val(b,v);
	hl_buffer_char(b,0);
	return hl_buffer_content(b,NULL);
}

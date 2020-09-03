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
#include "hl.h"
#include <string.h>

HL_PRIM hl_field_lookup *hl_lookup_insert( hl_field_lookup *l, int size, int hash, hl_type *t, int index ) {
	int min = 0;
	int max = size;
	int pos;
	while( min < max ) {
		int mid = (min + max) >> 1;
		int h = l[mid].hashed_name;
		if( h < hash ) min = mid + 1; else max = mid;
	}
	pos = (min + max) >> 1;
	memmove(l + pos + 1, l + pos, (size - pos) * sizeof(hl_field_lookup));
	l[pos].field_index = index;
	l[pos].hashed_name = hash;
	l[pos].t = t;
	return l + pos;
}

HL_PRIM hl_field_lookup *hl_lookup_find( hl_field_lookup *l, int size, int hash ) {
	int min = 0;
	int max = size;
	while( min < max ) {
		int mid = (min + max) >> 1;
		int h = l[mid].hashed_name;
		if( h < hash ) min = mid + 1; else if( h > hash ) max = mid; else return l + mid;
	}
	return NULL;
}

static int hl_lookup_find_index( hl_field_lookup *l, int size, int hash ) {
	int min = 0;
	int max = size;
	while( min < max ) {
		int mid = (min + max) >> 1;
		int h = l[mid].hashed_name;
		if( h < hash ) min = mid + 1; else if( h > hash ) max = mid; else return mid;
	}
	return (min + max) >> 1;
}

static hl_field_lookup *obj_resolve_field( hl_type_obj *o, int hfield ) {
	hl_runtime_obj *rt = o->rt;
	do {
		hl_field_lookup *f = hl_lookup_find(rt->lookup,rt->nlookup,hfield);
		if( f ) return f;
		rt = rt->parent;
	} while( rt );
	return NULL;
}

static int hl_cache_count = 0;
static int hl_cache_size = 0;
static hl_mutex *hl_cache_lock = NULL;
static hl_field_lookup *hl_cache = NULL;

void hl_cache_init() {
#	ifdef HL_THREADS
	hl_add_root(&hl_cache_lock);
#	endif
	hl_cache_lock = hl_mutex_alloc(false);
}

HL_PRIM int hl_hash( vbyte *b ) {
	return hl_hash_gen((uchar*)b,true);
}

HL_PRIM int hl_hash_utf8( const char *name ) {
	int h = 0;
	// ASCII should be enough
	while( *name ) {
		h = 223 * h + (unsigned)*name;
		name++;
	}
	h %= 0x1FFFFF7B;
	return h;
}

HL_PRIM int hl_hash_gen( const uchar *name, bool cache_name ) {
	int h = 0;
	const uchar *oname = name;
	while( *name ) {
		h = 223 * h + (unsigned)*name;
		name++;
	}
	h %= 0x1FFFFF7B;
	if( cache_name ) {
		hl_field_lookup *l;
		hl_mutex_acquire(hl_cache_lock);
		l = hl_lookup_find(hl_cache, hl_cache_count, h);
		// check for potential conflict (see haxe#5572)
		while( l && ucmp((uchar*)l->t,oname) != 0 ) {
			h++;
			l = hl_lookup_find(hl_cache, hl_cache_count, h);
		}
		if( l == NULL ) {
			if( hl_cache_size == hl_cache_count ) {
				// resize
				int newsize = hl_cache_size ? (hl_cache_size * 3) >> 1 : 16;
				hl_field_lookup *cache = (hl_field_lookup*)malloc(sizeof(hl_field_lookup) * newsize);
				memcpy(cache,hl_cache,sizeof(hl_field_lookup) * hl_cache_count);
				free(hl_cache);
				hl_cache = cache;
				hl_cache_size = newsize;
			}
			hl_lookup_insert(hl_cache,hl_cache_count++,h,(hl_type*)ustrdup(oname),0);
		}
		hl_mutex_release(hl_cache_lock);
	}
	return h;
}

HL_PRIM vbyte *hl_field_name( int hash ) {
	hl_field_lookup *l = hl_lookup_find(hl_cache, hl_cache_count, hash);
	return l ? (vbyte*)l->t : (vbyte*)USTR("???");
}

HL_PRIM void hl_cache_free() {
	int i;
	for(i=0;i<hl_cache_count;i++)
		free(hl_cache[i].t);
	free(hl_cache);
	hl_cache = NULL;
	hl_cache_count = hl_cache_size = 0;
	hl_mutex_free(hl_cache_lock);
	hl_cache_lock = NULL;
	hl_remove_root(&hl_cache_lock);
}

HL_PRIM hl_obj_field *hl_obj_field_fetch( hl_type *t, int fid ) {
	hl_runtime_obj *rt;
	if( t->kind != HOBJ )
		return NULL;
	rt = hl_get_obj_rt(t);
	if( fid < 0 || fid >= rt->nfields )
		return NULL;
	while( rt->parent && fid < rt->parent->nfields )
		rt = rt->parent;
	return rt->t->obj->fields + (fid - (rt->parent?rt->parent->nfields:0));
}

HL_PRIM int hl_mark_size( int data_size ) {
	int ptr_count = (data_size + HL_WSIZE - 1) / HL_WSIZE;
	return ((ptr_count + 31) >> 5) * sizeof(int);
}

/**
	Builds class metadata (fields indexes, etc.)
	Does not require the method table to be finalized.
**/
HL_PRIM hl_runtime_obj *hl_get_obj_rt( hl_type *ot ) {
	hl_type_obj *o = ot->obj;
	hl_module_context *m = o->m;
	hl_alloc *alloc = &m->alloc;
	hl_runtime_obj *p = NULL, *t;
	int i, size, start, nlookup, compareHash;
	if( o->rt ) return o->rt;
	if( o->super ) p = hl_get_obj_rt(o->super);
	t = (hl_runtime_obj*)hl_malloc(alloc,sizeof(hl_runtime_obj));
	t->t = ot;
	t->nfields = o->nfields + (p ? p->nfields : 0);
	t->nproto = p ? p->nproto : 0;
	t->nlookup = o->nfields;
	t->nbindings = p ? p->nbindings : 0;
	t->hasPtr = p ? p->hasPtr : false;

	if( !p ) {
		t->nlookup += o->nproto;
		t->nbindings += o->nbindings;
	} else {
		for(i=0;i<o->nproto;i++) {
			hl_obj_proto *pr = o->proto + i;
			if( pr->pindex >= 0 && pr->pindex < p->nproto )
				continue;
			t->nlookup++;
		}
		for(i=0;i<o->nbindings;i++) {
			int j;
			int fid = o->bindings[i<<1];
			bool found = false;
			hl_type_obj *pp = p ? p->t->obj : NULL;
			while( pp && !found ) {
				for(j=0;j<pp->nbindings;j++)
					if( pp->bindings[j<<1] == fid ) {
						found = true;
						break;
					}
				pp = pp->super ? pp->super->obj : NULL;
			}
			if( !found )
				t->nbindings++;
		}
	}

	t->lookup = (hl_field_lookup*)hl_malloc(alloc,sizeof(hl_field_lookup) * t->nlookup);
	t->fields_indexes = (int*)hl_malloc(alloc,sizeof(int)*t->nfields);
	t->bindings = (hl_runtime_binding*)hl_malloc(alloc,sizeof(hl_runtime_binding)*t->nbindings);
	t->toStringFun = NULL;
	t->compareFun = NULL;
	t->castFun = NULL;
	t->getFieldFun = NULL;
	t->parent = p;

	// fields indexes
	start = 0;
	if( p ) {
		start = p->nfields;
		memcpy(t->fields_indexes, p->fields_indexes, sizeof(int)*p->nfields);
	}
	size = p ? p->size : (ot->kind == HSTRUCT ? 0 : HL_WSIZE); // hl_type*
	nlookup = 0;
	for(i=0;i<o->nfields;i++) {
		hl_type *ft = o->fields[i].t;
		size += hl_pad_struct(size,ft);
		t->fields_indexes[i+start] = size;
		if( *o->fields[i].name )
			hl_lookup_insert(t->lookup,nlookup++,o->fields[i].hashed_name,o->fields[i].t,size);
		else
			t->nlookup--;
		size += hl_type_size(ft);
		if( !t->hasPtr && hl_is_ptr(ft) ) t->hasPtr = true;
	}
	t->size = size;
	t->nmethods = p ? p->nmethods : o->nproto;
	t->methods = NULL;
	o->rt = t;
	ot->vobj_proto = NULL;

	// fields lookup
	compareHash = hl_hash_gen(USTR("__compare"),false);
	for(i=0;i<o->nproto;i++) {
		hl_obj_proto *pr = o->proto + i;
		hl_type *mt;
		int method_index;
		if( p ) {
			if( pr->pindex >= 0 && pr->pindex < p->nproto )
				continue;
			method_index = t->nmethods++;
		} else
			method_index = i;
		if( pr->pindex >= t->nproto ) t->nproto = pr->pindex + 1;
		mt = m->functions_types[pr->findex];
		hl_lookup_insert(t->lookup,nlookup++,pr->hashed_name,mt,-(method_index+1));
		// tell if we have a compare fun (req for JIT)
		if( pr->hashed_name == compareHash && mt->fun->nargs == 2 && mt->fun->args[1]->kind == HDYN && mt->fun->ret->kind == HI32 )
			t->compareFun = (void*)(int_val)pr->findex;
	}

	// mark bits
	if( t->hasPtr ) {
		unsigned int *mark = (unsigned int*)hl_zalloc(alloc,hl_mark_size(t->size));
		ot->mark_bits = mark;
		if( p && p->t->mark_bits ) memcpy(mark, p->t->mark_bits, hl_mark_size(p->size));
		for(i=0;i<o->nfields;i++) {
			hl_type *ft = o->fields[i].t;
			if( hl_is_ptr(ft) ) {
				int pos = t->fields_indexes[i + start] / HL_WSIZE;
				mark[pos >> 5] |= 1 << (pos & 31);
			}
		}
	}
	return t;
}

/**
	Fill class prototype with method pointers.
	Requires method table to be finalized
**/
HL_API hl_runtime_obj *hl_get_obj_proto( hl_type *ot ) {
	hl_type_obj *o = ot->obj;
	hl_module_context *m = o->m;
	hl_alloc *alloc = &m->alloc;
	hl_runtime_obj *p = NULL, *t = hl_get_obj_rt(ot);
	hl_field_lookup *strField, *cmpField, *castField, *getField;
	int i;
	int nmethods, nbindings;
	if( ot->vobj_proto ) return t;
	if( o->super ) p = hl_get_obj_proto(o->super);

	if( t->nproto ) {
		void **fptr = (void**)hl_malloc(alloc, sizeof(void*) * t->nproto);
		ot->vobj_proto = fptr;
		if( p )
			memcpy(fptr, p->t->vobj_proto, p->nproto * sizeof(void*));
		for(i=0;i<o->nproto;i++) {
			hl_obj_proto *p = o->proto + i;
			if( p->pindex >= 0 ) fptr[p->pindex] = m->functions_ptrs[p->findex];
		}
	}

	t->methods = (void**)hl_malloc(alloc, sizeof(void*) * t->nmethods);
	if( p ) memcpy(t->methods,p->methods,p->nmethods * sizeof(void*));

	nmethods = p ? p->nmethods : 0;
	for(i=0;i<o->nproto;i++) {
		hl_obj_proto *pr = o->proto + i;
		int method_index;
		if( p ) {
			if( pr->pindex >= 0 && pr->pindex < p->nproto )
				method_index = -obj_resolve_field(o->super->obj,pr->hashed_name)->field_index-1;
			else
				method_index = nmethods++;
		} else
			method_index = i;
		t->methods[method_index] = m->functions_ptrs[pr->findex];
	}

	// bindings
	if( p ) {
		nbindings = p->nbindings;
		memcpy(t->bindings,p->bindings,p->nbindings*sizeof(hl_runtime_binding));
	} else
		nbindings = 0;
	for(i=0;i<o->nbindings;i++) {
		int fid = o->bindings[i<<1];
		int mid = o->bindings[(i<<1)|1];
		hl_runtime_binding *b = NULL;
		hl_type *ft;
		if( p ) {
			int j;
			for(j=0;j<p->nbindings;j++)
				if( p->bindings[j].fid == fid ) {
					b = t->bindings + j;
					break;
				}
		}
		if( b == NULL )
			b = t->bindings + nbindings++;
		b->fid = fid;
		ft = hl_obj_field_fetch(t->t, fid)->t;
		switch( ft->kind ) {
		case HFUN:
			if( ft->fun->nargs == m->functions_types[mid]->fun->nargs ) {
				// static fun
				vclosure *c = (vclosure*)hl_malloc(alloc,sizeof(vclosure));
				c->fun = m->functions_ptrs[mid];
				c->t = m->functions_types[mid];
				c->hasValue = false;
				c->value = NULL;
				b->closure = NULL;
				b->ptr = c;
				break;
			}
			// fallthrough
		case HDYN: // __constructor__ is defined as dynamic in Class
			b->closure = m->functions_types[mid];
			b->ptr = m->functions_ptrs[mid];
			break;
		default:
			hl_fatal("invalid bind field");
			break;
		}
	}

	strField = obj_resolve_field(o,hl_hash_gen(USTR("__string"),false));
	cmpField = obj_resolve_field(o,hl_hash_gen(USTR("__compare"),false));
	castField = obj_resolve_field(o,hl_hash_gen(USTR("__cast"),false));
	getField = obj_resolve_field(o,hl_hash_gen(USTR("__get_field"),false));
	t->toStringFun = strField ? t->methods[-(strField->field_index+1)] : NULL;
	t->compareFun = cmpField && t->compareFun ? t->methods[-(cmpField->field_index+1)] : NULL;
	t->castFun = castField ? t->methods[-(castField->field_index+1)] : NULL;
	t->getFieldFun = getField ? t->methods[-(getField->field_index+1)] : NULL;
	if( p && !t->getFieldFun ) t->getFieldFun = p->getFieldFun;

	return t;
}

HL_API void hl_flush_proto( hl_type *ot ) {
	int i;
	hl_type_obj *o = ot->obj;
	hl_runtime_obj *rt = ot->obj->rt;
	hl_module_context *m = o->m;
	if( !rt || !ot->vobj_proto ) return;
	for(i=0;i<o->nbindings;i++) {
		hl_runtime_binding *b = rt->bindings + i;
		int mid = o->bindings[(i<<1)|1];
		if( b->closure )
			b->ptr = m->functions_ptrs[mid];
		else
			((vclosure*)b->ptr)->fun = m->functions_ptrs[mid];
	}
}

HL_API void hl_init_virtual( hl_type *vt, hl_module_context *ctx ) {
	int i;
	int vsize = sizeof(vvirtual) + sizeof(void*) * vt->virt->nfields;
	int size = vsize;
	hl_field_lookup *l = (hl_field_lookup*)hl_malloc(&ctx->alloc,sizeof(hl_field_lookup)*vt->virt->nfields);
	int *indexes = (int*)hl_malloc(&ctx->alloc,sizeof(int)*vt->virt->nfields);
	unsigned int *mark;
	for(i=0;i<vt->virt->nfields;i++) {
		hl_obj_field *f = vt->virt->fields + i;
		hl_lookup_insert(l,i,f->hashed_name,f->t,i);
		size += hl_pad_struct(size, f->t);
		indexes[i] = size;
		size += hl_type_size(f->t);
	}
	vt->virt->lookup = l;
	vt->virt->indexes = indexes;
	vt->virt->dataSize = size - vsize;
	mark = (unsigned int*)hl_zalloc(&ctx->alloc, hl_mark_size(size));
	vt->mark_bits = mark;
	mark[0] = 2 | 4; // value | next
	for(i=0;i<vt->virt->nfields;i++) {
		hl_obj_field *f = vt->virt->fields + i;
		if( hl_is_ptr(f->t) ) {
			int pos = indexes[i] / HL_WSIZE;
			mark[pos >> 5] |= 1 << (pos & 31);
		}
	}
}

#define hl_dynobj_field(o,f) (hl_is_ptr((f)->t) ? (void*)((o)->values + (f)->field_index) : (void*) ((o)->raw_data + (f)->field_index))

vdynamic *hl_virtual_make_value( vvirtual *v ) {
	vdynobj *o;
	int i, nfields;
	int raw_size = 0, nvalues = 0;
	if( v->value )
		return v->value;
	nfields = v->t->virt->nfields;
	o = hl_alloc_dynobj();
	// copy the lookup table
	o->lookup = (hl_field_lookup*)hl_gc_alloc_noptr(sizeof(hl_field_lookup) * nfields);
	o->nfields = nfields;
	memcpy(o->lookup,v->t->virt->lookup,nfields * sizeof(hl_field_lookup));
	for(i=0;i<nfields;i++) {
		hl_field_lookup *f = o->lookup + i;
		if( hl_is_ptr(f->t) )
			f->field_index = nvalues++;
		else {
			raw_size += hl_pad_size(raw_size, f->t);
			f->field_index = raw_size;
			raw_size += hl_type_size(f->t);
		}
	}
	// copy the data & rebind virtual addresses
	o->raw_data = hl_gc_alloc_noptr(raw_size);
	o->raw_size = raw_size;
	o->values = hl_gc_alloc_raw(nvalues*sizeof(void*));
	o->nvalues = nvalues;
	for(i=0;i<nfields;i++) {
		hl_field_lookup *f = o->lookup + i;
		hl_field_lookup *vf = v->t->virt->lookup + i;
		void **vaddr = hl_vfields(v) + vf->field_index;
		memcpy(hl_dynobj_field(o,f),*vaddr, hl_type_size(f->t));
		*vaddr = hl_dynobj_field(o,f);
	}
	// erase virtual data
	memset(hl_vfields(v) + nfields, 0, v->t->virt->dataSize);
	o->virtuals = v;
	v->value = (vdynamic*)o;
	return v->value;
}

static bool should_recast( hl_type *t, hl_type *vt ) {
	if( vt->kind == HF64 && t->kind == HI32 )
		return true;
	if( vt->kind == HNULL && vt->tparam->kind == t->kind )
		return true;
	if( vt->kind == HNULL && vt->tparam->kind == HF64 && t->kind == HI32 )
		return true;
	if( vt->kind == HVIRTUAL && t->kind == HDYNOBJ )
		return true;
	if( vt->kind == HOBJ && t->kind == HOBJ && vt->obj->rt->castFun )
		return true;
	return false;
}

/**
	Allocate a virtual fields mapping to a given value.
**/
vvirtual *hl_to_virtual( hl_type *vt, vdynamic *obj ) {
	vvirtual *v = NULL;
	if( obj == NULL ) return NULL;
#ifdef _DEBUG
	if( vt->virt->nfields && vt->virt->lookup == NULL ) hl_fatal("virtual not initialized");
#endif
	switch( obj->t->kind ) {
	case HOBJ:
		{
			int i;
			v = (vvirtual*)hl_gc_alloc(vt, sizeof(vvirtual) + sizeof(void*)*vt->virt->nfields);
			v->t = vt;
			v->value = obj;
			v->next = NULL;
			for(i=0;i<vt->virt->nfields;i++) {
				hl_field_lookup *f = obj_resolve_field(obj->t->obj,vt->virt->fields[i].hashed_name);
				if( f && f->field_index < 0 ) {
					hl_type *ft = vt->virt->fields[i].t;
					hl_type tmp;
					hl_type_fun tf;
					tmp.kind = HMETHOD;
					tmp.fun = &tf;
					tf.args = f->t->fun->args + 1;
					tf.nargs = f->t->fun->nargs - 1;
					tf.ret = f->t->fun->ret;
					if( hl_safe_cast(&tmp,ft) )
						hl_vfields(v)[i] = obj->t->obj->rt->methods[-f->field_index-1];
					else
						hl_vfields(v)[i] = NULL;
				} else
					hl_vfields(v)[i] = f == NULL || !hl_same_type(f->t,vt->virt->fields[i].t) ? NULL : (char*)obj + f->field_index;
			}
		}
		break;
	case HDYNOBJ:
		{
			int i;
			int64 need_recast = 0;
			vdynobj *o = (vdynobj*)obj;
			v = o->virtuals;
			while( v ) {
				if( v->t->virt == vt->virt )
					return v;
				v = v->next;
			}
			// allocate a new virtual mapping
			v = (vvirtual*)hl_gc_alloc(vt, sizeof(vvirtual) + sizeof(void*) * vt->virt->nfields);
			v->t = vt;
			v->value = obj;
			for(i=0;i<vt->virt->nfields;i++) {
				hl_field_lookup *f = hl_lookup_find(o->lookup,o->nfields,vt->virt->fields[i].hashed_name);
				hl_type *vft = vt->virt->fields[i].t;
				void *addr = f == NULL || !hl_same_type(f->t,vft) ? NULL : hl_dynobj_field(o,f);
				// check if we will perform recast of some fields to match the virtual definition
				// recast will not work for >64 fields, but this should be pretty rare
				if( addr == NULL && f && !o->virtuals && should_recast(f->t,vft) )
					need_recast |= ((int64)1) << ((int64)i);
				hl_vfields(v)[i] = addr;
			}
			// add it to the list
			v->next = o->virtuals;
			o->virtuals = v;
			// recast
			if( need_recast ) {
				for(i=0;i<vt->virt->nfields;i++)
					if( need_recast & (((int64)1) << ((int64)i)) ) {
						hl_obj_field *f = vt->virt->fields + i;
						if( hl_is_ptr(f->t) )
							hl_dyn_setp(obj,f->hashed_name,f->t,hl_dyn_getp(obj,f->hashed_name,f->t));
						else if( f->t->kind == HF64 )
							hl_dyn_setd(obj,f->hashed_name,hl_dyn_getd(obj,f->hashed_name));
					}
			}
		}
		break;
	case HVIRTUAL:
		if( hl_safe_cast(obj->t, vt) ) return (vvirtual*)obj;
		return hl_to_virtual(vt,hl_virtual_make_value((vvirtual*)obj));
	default:
		hl_error("Can't cast %s to %s", hl_type_str(obj->t), hl_type_str(vt));
		break;
	}
	return v;
}

static void hl_dynobj_remap_virtuals( vdynobj *o, hl_field_lookup *f, int_val address_offset ) {
	vvirtual *v = o->virtuals;
	bool is_ptr = hl_is_ptr(f->t);
	while( v ) {
		hl_field_lookup *vf = hl_lookup_find(v->t->virt->lookup,v->t->virt->nfields,f->hashed_name);
		int i;
		if( address_offset )
			for(i=0;i<v->t->virt->nfields;i++)
				if( hl_vfields(v)[i] && hl_is_ptr(v->t->virt->fields[i].t) == is_ptr )
					((char**)hl_vfields(v))[i] += address_offset;
		if( vf )
			hl_vfields(v)[vf->field_index] = hl_same_type(vf->t,f->t) ? hl_dynobj_field(o, f) : NULL;
		v = v->next;
	}
}

static void hl_dynobj_delete_field( vdynobj *o, hl_field_lookup *f ) {
	int i;
	int index = f->field_index;
	bool is_ptr = hl_is_ptr(f->t); 
	// erase data
	if( is_ptr ) {
		memmove(o->values + index, o->values + index + 1, (o->nvalues - (index + 1)) * sizeof(void*));
		o->nvalues--;
		o->values[o->nvalues] = NULL;
		for(i=0;i<o->nfields;i++) {
			hl_field_lookup *f = o->lookup + i;
			if( hl_is_ptr(f->t) && f->field_index > index )
				f->field_index--;
		}
	} else {
		// no erase needed, compaction will be performed on next add
	}

	// remove from virtuals
	vvirtual *v = o->virtuals;
	while( v ) {
		hl_field_lookup *vf = hl_lookup_find(v->t->virt->lookup,v->t->virt->nfields,f->hashed_name);
		if( vf ) hl_vfields(v)[vf->field_index] = NULL;
		// remap pointers that were moved
		if( is_ptr ) {
			for(i=0;i<v->t->virt->nfields;i++) {
				vf = v->t->virt->lookup + i;
				if( hl_is_ptr(vf->t) ) {
					void ***pf = (void***)hl_vfields(v) + vf->field_index;
					if( *pf && *pf > (void**)(o->values + index) )
						*pf = (*pf) - 1;
				}
			}
		}
		v = v->next;
	}

	// remove from lookup
	int field = (int)(f - o->lookup);
	memmove(o->lookup + field, o->lookup + field + 1, (o->nfields - (field + 1)) * sizeof(hl_field_lookup));
	o->nfields--;
}

static hl_field_lookup *hl_dynobj_add_field( vdynobj *o, int hfield, hl_type *t ) {
	int index;
	int_val address_offset;

	// expand data
	if( hl_is_ptr(t) ) {
		void **nvalues = hl_gc_alloc_raw( (o->nvalues + 1) * sizeof(void*) );
		memcpy(nvalues,o->values,o->nvalues * sizeof(void*));
		index = o->nvalues;
		nvalues[index] = NULL;
		address_offset = (char*)nvalues - (char*)o->values;
		o->values = nvalues;
		o->nvalues++;
	} else {
		int raw_size = 0;
		int i;
		for(i=0;i<o->nfields;i++) {
			hl_field_lookup *f = o->lookup + i;
			if( hl_is_ptr(f->t) ) continue;
			raw_size += hl_pad_size(raw_size, f->t);
			raw_size += hl_type_size(f->t);
		}
		if( raw_size > o->raw_size ) // our current mapping is better
			raw_size = o->raw_size;
		int pad = hl_pad_size(raw_size, t);
		int size = hl_type_size(t);
		char *newData = (char*)hl_gc_alloc_noptr(raw_size + pad + size);
		if( raw_size == o->raw_size )
			memcpy(newData,o->raw_data,o->raw_size);
		else {
			raw_size = 0;
			for(i=0;i<o->nfields;i++) {
				hl_field_lookup *f = o->lookup + i;
				int index = f->field_index;
				if( hl_is_ptr(f->t) ) continue;
				raw_size += hl_pad_size(raw_size, f->t);
				memcpy(newData + raw_size, o->raw_data + index, hl_type_size(f->t));
				f->field_index = raw_size;
				if( index != raw_size )
					hl_dynobj_remap_virtuals(o, f, 0);
				raw_size += hl_type_size(f->t);
			}
			o->raw_size = raw_size;
		}
		address_offset = newData - o->raw_data;
		o->raw_data = newData;
		o->raw_size += pad;
		index = o->raw_size;
		o->raw_size += size;
	}

	// update field table
	hl_field_lookup *new_lookup = (hl_field_lookup*)hl_gc_alloc_noptr(sizeof(hl_field_lookup) * (o->nfields + 1));
	int field_pos = hl_lookup_find_index(o->lookup, o->nfields, hfield);
	memcpy(new_lookup,o->lookup,field_pos * sizeof(hl_field_lookup));
	hl_field_lookup *f = new_lookup + field_pos;
	f->t = t;
	f->hashed_name = hfield;
	f->field_index = index;
	memcpy(new_lookup + (field_pos + 1),o->lookup + field_pos, (o->nfields - field_pos) * sizeof(hl_field_lookup));
	o->nfields++;
	o->lookup = new_lookup;

	hl_dynobj_remap_virtuals(o, f, address_offset);
	return f;
}

// -------------------- DYNAMIC GET ------------------------------------

static void *hl_obj_lookup( vdynamic *d, int hfield, hl_type **t ) {
	switch( d->t->kind ) {
	case HDYNOBJ:
		{
			vdynobj *o = (vdynobj*)d;
			hl_field_lookup *f = hl_lookup_find(o->lookup,o->nfields,hfield);
			if( f == NULL ) return NULL;
			*t = f->t;
			return hl_dynobj_field(o,f);
		}
		break;
	case HOBJ:
		{
			hl_field_lookup *f = obj_resolve_field(d->t->obj,hfield);
			if( f == NULL || f->field_index < 0 ) return NULL;
			*t = f->t;
			return (char*)d + f->field_index;
		}
		break;
	case HSTRUCT:
		{
			hl_field_lookup *f = obj_resolve_field(d->t->obj,hfield);
			if( f == NULL || f->field_index < 0 ) return NULL;
			*t = f->t;
			return (char*)d->v.ptr + f->field_index;
		}
		break;
	case HVIRTUAL:
		{
			vdynamic *v = ((vvirtual*)d)->value;
			hl_field_lookup *f;
			if( v )
				return hl_obj_lookup(v, hfield, t);
			f = hl_lookup_find(d->t->virt->lookup,d->t->virt->nfields,hfield);
			if( f == NULL ) return NULL;
			*t = f->t;
			return (char*)d + d->t->virt->indexes[f->field_index];
		}
	default:
		hl_error("Invalid field access");
		break;
	}
	return NULL;
}

// fetch method or dynamic field (getField)
static vdynamic *hl_obj_lookup_extra( vdynamic *d, int hfield ) {
	switch( d->t->kind ) {
	case HOBJ:
	case HSTRUCT:
		{
			hl_field_lookup *f = obj_resolve_field(d->t->obj,hfield);
			if( f && f->field_index < 0 )
				return (vdynamic*)hl_alloc_closure_ptr(f->t,d->t->obj->rt->methods[-f->field_index-1],d);
			if( f == NULL ) {
				hl_runtime_obj *rt = d->t->obj->rt;
				if( rt->getFieldFun )
					return rt->getFieldFun(d,hfield);
			}
			return NULL;
		}
		break;
	case HVIRTUAL:
		{
			vdynamic *v = ((vvirtual*)d)->value;
			if( v ) return hl_obj_lookup_extra(v, hfield);
		}
		break;
	default:
		break;
	}
	return NULL;
}

HL_PRIM int hl_dyn_geti( vdynamic *d, int hfield, hl_type *t ) {
	hl_type *ft;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup(d,hfield,&ft);
	if( !addr ) {
		d = hl_obj_lookup_extra(d,hfield);
		return d == NULL ? 0 : hl_dyn_casti(&d,&hlt_dyn,t);
	}
	switch( ft->kind ) {
	case HUI8:
		return *(unsigned char*)addr;
	case HUI16:
		return *(unsigned short*)addr;
	case HI32:
		return *(int*)addr;
	case HF32:
		return (int)*(float*)addr;
	case HF64:
		return (int)*(double*)addr;
	case HBOOL:
		return *(bool*)addr;
	default:
		return hl_dyn_casti(addr,ft,t);
	}
}

HL_PRIM float hl_dyn_getf( vdynamic *d, int hfield ) {
	hl_type *ft;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup(d,hfield,&ft);
	if( !addr ) {
		d = hl_obj_lookup_extra(d,hfield);
		return d == NULL ? 0.f : hl_dyn_castf(&d,&hlt_dyn);
	}
	return ft->kind == HF32 ? *(float*)addr : hl_dyn_castf(addr,ft);
}

HL_PRIM double hl_dyn_getd( vdynamic *d, int hfield ) {
	hl_type *ft;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup(d,hfield,&ft);
	if( !addr ) {
		d = hl_obj_lookup_extra(d,hfield);
		return d == NULL ? 0. : hl_dyn_castd(&d,&hlt_dyn);
	}
	return ft->kind == HF64 ? *(double*)addr : hl_dyn_castd(addr,ft);
}

HL_PRIM void *hl_dyn_getp( vdynamic *d, int hfield, hl_type *t ) {
	hl_type *ft;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup(d,hfield,&ft);
	if( !addr ) {
		d = hl_obj_lookup_extra(d,hfield);
		return d == NULL ? NULL : hl_dyn_castp(&d,&hlt_dyn,t);
	}
	return hl_same_type(t,ft) ? *(void**)addr : hl_dyn_castp(addr,ft,t);
}

// -------------------- DYNAMIC SET ------------------------------------

static void *hl_obj_lookup_set( vdynamic *d, int hfield, hl_type *t, hl_type **ft ) {
	switch( d->t->kind ) {
	case HDYNOBJ:
		{
			vdynobj *o = (vdynobj*)d;
			hl_field_lookup *f = hl_lookup_find(o->lookup,o->nfields,hfield);
			if( f == NULL )
				f = hl_dynobj_add_field(o,hfield,t);
			else if( !hl_same_type(t,f->t) ) {
				if( hl_is_ptr(t) != hl_is_ptr(f->t) || hl_type_size(t) != hl_type_size(f->t) ) {
					hl_dynobj_delete_field(o, f);
					f = hl_dynobj_add_field(o,hfield,t);
				} else {
					f->t = t;
					hl_dynobj_remap_virtuals(o,f,0);
				}
			}
			*ft = f->t;
			return hl_dynobj_field(o,f);
		}
		break;
	case HOBJ:
		{
			hl_field_lookup *f = obj_resolve_field(d->t->obj,hfield);
			if( f == NULL || f->field_index < 0 ) hl_error("%s does not have field %s",d->t->obj->name,hl_field_name(hfield));
			*ft = f->t;
			return (char*)d + f->field_index;
		}
		break;
	case HSTRUCT:
		{
			hl_field_lookup *f = obj_resolve_field(d->t->obj,hfield);
			if( f == NULL || f->field_index < 0 ) hl_error("%s does not have field %s",d->t->obj->name,hl_field_name(hfield));
			*ft = f->t;
			return (char*)d->v.ptr + f->field_index;
		}
		break;
	case HVIRTUAL:
		{
			vvirtual *v = (vvirtual*)d;
			hl_field_lookup *f;
			if( v->value ) return hl_obj_lookup_set(v->value, hfield, t, ft);
			f = hl_lookup_find(v->t->virt->lookup,v->t->virt->nfields,hfield);
			if( f == NULL || !hl_safe_cast(t,f->t) )
				return hl_obj_lookup_set(hl_virtual_make_value(v), hfield, t, ft);
			*ft = f->t;
			return (char*)v + v->t->virt->indexes[f->field_index];
		}
	default:
		hl_error("Invalid field access");
		break;
	}
	return NULL;
}

HL_PRIM void hl_dyn_seti( vdynamic *d, int hfield, hl_type *t, int value ) {
	hl_type *ft = NULL;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup_set(d,hfield,t,&ft);
	switch( ft->kind ) {
	case HUI8:
		*(unsigned char*)addr = (unsigned char)value;
		break;
	case HUI16:
		*(unsigned short*)addr = (unsigned short)value;
		break;
	case HI32:
		*(int*)addr = value;
		break;
	case HBOOL:
		*(bool*)addr = value != 0;
		break;
	case HF32:
		*(float*)addr = (float)value;
		break;
	case HF64:
		*(double*)addr = value;
		break;
	default:
		{
			vdynamic tmp;
			tmp.t = t;
			tmp.v.i = value;
			hl_write_dyn(addr,ft,&tmp,true);
		}
		break;
	}
}

HL_PRIM void hl_dyn_setf( vdynamic *d, int hfield, float value ) {
	hl_type *t = NULL;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup_set(d,hfield,&hlt_f32,&t);
	if( t->kind == HF32 )
		*(float*)addr = value;
	else {
		vdynamic tmp;
		tmp.t = &hlt_f32;
		tmp.v.f = value;
		hl_write_dyn(addr,t,&tmp,true);
	}
}

HL_PRIM void hl_dyn_setd( vdynamic *d, int hfield, double value ) {
	hl_type *t = NULL;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup_set(d,hfield,&hlt_f64,&t);
	if( t->kind == HF64 )
		*(double*)addr = value;
	else {
		vdynamic tmp;
		tmp.t = &hlt_f64;
		tmp.v.d = value;
		hl_write_dyn(addr,t,&tmp,true);
	}
}

HL_PRIM void hl_dyn_setp( vdynamic *d, int hfield, hl_type *t, void *value ) {
	hl_type *ft = NULL;
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(d,hfield));
	void *addr = hl_obj_lookup_set(d,hfield,t,&ft);
	if( hl_same_type(t,ft) || (hl_is_ptr(ft) && value == NULL) )
		*(void**)addr = value;
	else if( hl_is_dynamic(t) )
		hl_write_dyn(addr,ft,(vdynamic*)value,false);
	else {
		vdynamic tmp;
		tmp.t = t;
		tmp.v.ptr = value;
		hl_write_dyn(addr,ft,&tmp, true);
	}
}

// -------------------- HAXE API ------------------------------------

HL_PRIM vdynamic *hl_obj_get_field( vdynamic *obj, int hfield ) {
	if( obj == NULL )
		return NULL;
	switch( obj->t->kind ) {
	case HOBJ:
	case HVIRTUAL:
	case HDYNOBJ:
	case HSTRUCT:
		return (vdynamic*)hl_dyn_getp(obj,hfield,&hlt_dyn);
	default:
		return NULL;
	}
}

HL_PRIM void hl_obj_set_field( vdynamic *obj, int hfield, vdynamic *v ) {
	if( v == NULL ) {
		hl_dyn_setp(obj,hfield,&hlt_dyn,NULL);
		return;
	}
	hl_track_call(HL_TRACK_DYNFIELD, on_dynfield(obj,hfield));
	hl_type *ft = NULL;
	void *addr = hl_obj_lookup_set(obj,hfield,v->t,&ft);
	hl_write_dyn(addr,ft,v,false);
}

HL_PRIM bool hl_obj_has_field( vdynamic *obj, int hfield ) {
	if( obj == NULL ) return false;
	switch( obj->t->kind ) {
	case HOBJ:
	case HSTRUCT:
		{
			hl_field_lookup *l = obj_resolve_field(obj->t->obj, hfield);
			return l && l->field_index >= 0;
		}
		break;
	case HDYNOBJ:
		{
			vdynobj *d = (vdynobj*)obj;
			hl_field_lookup *f = hl_lookup_find(d->lookup,d->nfields,hfield);
			return f != NULL;
		}
		break;
	case HVIRTUAL:
		{
			vvirtual *v = (vvirtual*)obj;
			if( v->value ) return hl_obj_has_field(v->value,hfield);
			return hl_lookup_find(v->t->virt->lookup,v->t->virt->nfields,hfield) != NULL;
		}
	default:
		break;
	}
	return false;
}

HL_PRIM bool hl_obj_delete_field( vdynamic *obj, int hfield ) {
	if( obj == NULL ) return false;
	switch( obj->t->kind ) {
	case HDYNOBJ:
		{
			vdynobj *d = (vdynobj*)obj;
			hl_field_lookup *f = hl_lookup_find(d->lookup,d->nfields,hfield);
			if( f == NULL ) return false;
			hl_dynobj_delete_field(d, f);
			return true;
		}
		break;
	case HVIRTUAL:
		{
			vvirtual *v = (vvirtual*)obj;
			if( v->value ) return hl_obj_delete_field(v->value,hfield);
			if( hl_lookup_find(v->t->virt->lookup,v->t->virt->nfields,hfield) == NULL ) return false;
			return hl_obj_delete_field(hl_virtual_make_value(v),hfield);
		}
	default:
		break;
	}
	return false;
}

HL_PRIM varray *hl_obj_fields( vdynamic *obj ) {
	varray *a = NULL;
	if( obj == NULL ) return NULL;
	switch( obj->t->kind ) {
	case HDYNOBJ:
		{
			vdynobj *o = (vdynobj*)obj;
			int i;
			a = hl_alloc_array(&hlt_bytes,o->nfields);
			for(i=0;i<o->nfields;i++)
				hl_aptr(a,vbyte*)[i] = (vbyte*)hl_field_name((o->lookup + i)->hashed_name);
		}
		break;
	case HOBJ:
	case HSTRUCT:
		{
			hl_type_obj *tobj = obj->t->obj;
			hl_runtime_obj *o = tobj->rt;
			int i, p = 0;
			a = hl_alloc_array(&hlt_bytes,o->nfields);
			while( true ) {
				for(i=0;i<tobj->nfields;i++) {
					hl_obj_field *f = tobj->fields + i;
					if( !*f->name ) {
						a->size--;
						continue;
					}
					hl_aptr(a,vbyte*)[p++] =  (vbyte*)f->name;
				}
				if( tobj->super == NULL ) break;
				tobj = tobj->super->obj;
			}
		}
		break;
	case HVIRTUAL:
		{
			vvirtual *v = (vvirtual*)obj;
			int i;
			if( v->value ) return hl_obj_fields(v->value);
			a = hl_alloc_array(&hlt_bytes,v->t->virt->nfields);
			for(i=0;i<v->t->virt->nfields;i++)
				hl_aptr(a,vbyte*)[i] = (vbyte*)v->t->virt->fields[i].name;
		}
		break;
	default:
		break;
	}
	return a;
}

HL_PRIM vdynamic *hl_obj_copy( vdynamic *obj ) {
	if( obj == NULL )
		return NULL;
	switch( obj->t->kind ) {
	case HDYNOBJ:
		{
			vdynobj *o = (vdynobj*)obj;
			vdynobj *c = hl_alloc_dynobj();
			int lsize = sizeof(hl_field_lookup) * o->nfields;
			c->raw_size = o->raw_size;
			c->nfields = o->nfields;
			c->nvalues = o->nvalues;
			c->virtuals = NULL;
			c->lookup = (hl_field_lookup*)hl_gc_alloc_noptr(lsize);
			memcpy(c->lookup,o->lookup,lsize);
			c->raw_data = (char*)hl_gc_alloc_noptr(o->raw_size);
			c->values = (void**)hl_gc_alloc_raw(o->nvalues * sizeof(void*));
			memcpy(c->raw_data,o->raw_data,o->raw_size);
			memcpy(c->values,o->values,o->nvalues * sizeof(void*));
			return (vdynamic*)c;
		}
		break;
	case HVIRTUAL:
		{
			vvirtual *v = (vvirtual*)obj;
			vvirtual *v2;
			if( v->value )
				return hl_obj_copy(v->value);
			v2 = hl_alloc_virtual(v->t);
			memcpy(hl_vfields(v2) + v->t->virt->nfields, hl_vfields(v) + v->t->virt->nfields, v->t->virt->dataSize);
			return (vdynamic*)v2;
		}
	default:
		break;
	}
	return NULL;
}

HL_PRIM vdynamic *hl_get_virtual_value( vdynamic *v ) {
	return ((vvirtual*)v)->value;
}

DEFINE_PRIM(_DYN, alloc_obj, _TYPE);
DEFINE_PRIM(_DYN, obj_get_field, _DYN _I32);
DEFINE_PRIM(_VOID, obj_set_field, _DYN _I32 _DYN);
DEFINE_PRIM(_BOOL, obj_has_field, _DYN _I32);
DEFINE_PRIM(_BOOL, obj_delete_field, _DYN _I32);
DEFINE_PRIM(_ARR, obj_fields, _DYN);
DEFINE_PRIM(_DYN, obj_copy, _DYN);
DEFINE_PRIM(_DYN, get_virtual_value, _DYN);
DEFINE_PRIM(_I32, hash, _BYTES);
DEFINE_PRIM(_BYTES, field_name, _I32);


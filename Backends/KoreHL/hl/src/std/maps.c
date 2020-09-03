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

#define H_SIZE_INIT 3

// successive primes that double every time
static int H_PRIMES[] = {
	7,17,37,79,163,331,673,1361,2729,5471,10949,21911,43853,87613,175229,350459,700919,1401857,2803727,5607457,11214943,22429903,44859823,89719661,179424673,373587883,776531401,1611623773
};

// ----- FREE LIST ---------------------------------

typedef struct {
	int pos;
	int count;
} hl_free_bucket;

typedef struct {
	hl_free_bucket *buckets;
	int head;
	int nbuckets;
} hl_free_list;

static void hl_freelist_resize( hl_free_list *f, int newsize ) {
	hl_free_bucket *buckets = (hl_free_bucket*)hl_gc_alloc_noptr(sizeof(hl_free_bucket)*newsize);
	memcpy(buckets,f->buckets,f->head * sizeof(hl_free_bucket));
	f->buckets = buckets;
	f->nbuckets = newsize;
}

static void hl_freelist_init( hl_free_list *f ) {
	memset(f,0,sizeof(hl_free_list));
}

static void hl_freelist_add_range( hl_free_list *f, int pos, int count ) {
	hl_free_bucket *b = f->buckets;
	hl_free_bucket *prev = NULL;
	if( !b ) {
		// special handling for countinuous space
		if( f->nbuckets == 0 ) {
			f->head = pos;
			f->nbuckets = count;
			return;
		} else if( f->head + f->nbuckets == pos ) {
			f->nbuckets += count;
			return;
		} else if( pos + count == f->head ) {
			f->head -= count;
			f->nbuckets += count;
			return;
		} else {
			int cur_pos = f->head, cur_count = f->nbuckets;
			f->head = 0;
			f->nbuckets = 0;
			hl_freelist_resize(f,2);
			if( cur_count ) hl_freelist_add_range(f,cur_pos,cur_count);
			b = f->buckets;
		}
	}
	while( b < f->buckets + f->head ) {
		if( b->pos > pos ) break;
		prev = b;
		b++;
	}
	if( b < f->buckets + f->head && b->pos == pos + count ) {
		b->pos -= count;
		b->count += count;
		// merge
		if( prev && prev->pos + prev->count == b->pos ) {
			prev->count += b->count;
			memmove(b,b+1,((f->buckets + f->head) - (b+1)) * sizeof(hl_free_bucket));
			f->head--;
		}
		return;
	}
	if( prev && prev->pos + prev->count == pos ) {
		prev->count += count;
		return;
	}
	// insert
	if( f->head == f->nbuckets ) {
		int pos = (int)(b - f->buckets);
		hl_freelist_resize(f,((f->nbuckets * 3) + 1) >> 1);
		b = f->buckets + pos;
	}
	memmove(b+1,b,((f->buckets + f->head) - b) * sizeof(hl_free_bucket));
	b->pos = pos;
	b->count = count;
	f->head++;
}

static void hl_freelist_add( hl_free_list *f, int pos ) {
	hl_freelist_add_range(f,pos,1);
}

static int hl_freelist_get( hl_free_list *f ) {
	hl_free_bucket *b;
	int p;
	if( !f->buckets ) {
		if( f->nbuckets == 0 ) return -1;
		f->nbuckets--;
		return f->head++;
	}
	if( f->head == 0 )
		return -1;
	b = f->buckets + f->head - 1;
	b->count--;
	p = b->pos + b->count;
	if( b->count == 0 ) {
		f->head--;
		if( f->head < (f->nbuckets>>1) )
			hl_freelist_resize(f,f->nbuckets>>1);
	}
	return p;
}

// ----- INT MAP ---------------------------------

typedef struct {
	int key;
	int next;
} hl_hi_entry;

typedef struct {
	vdynamic *value;
} hl_hi_value;

#define hlt_key		hlt_i32
#define hl_hifilter(key) key
#define hl_hihash(h)	((unsigned)(h))
#define _MKEY_TYPE	int
#define _MNAME(n)	hl_hi##n
#define _MMATCH(c)	m->entries[c].key == key
#define _MKEY(m,c)	m->entries[c].key
#define	_MSET(c)	m->entries[c].key = key
#define _MERASE(c)

#include "maps.h"


// ----- BYTES MAP ---------------------------------

typedef struct {
	unsigned int hash;
	int next;
} hl_hb_entry;

typedef struct {
	uchar *key;
	vdynamic *value;
} hl_hb_value;

#define hlt_key		hlt_bytes
#define hl_hbfilter(key) key
#define hl_hbhash(key)	((unsigned)hl_hash_gen(key,false))
#define _MKEY_TYPE	uchar*
#define _MNAME(n)	hl_hb##n
#define _MMATCH(c)	m->entries[c].hash == hash && ucmp(m->values[c].key,key) == 0
#define _MKEY(m,c)	m->values[c].key
#define	_MSET(c)	m->entries[c].hash = hash; m->values[c].key = key
#define _MERASE(c)  m->values[c].key = NULL

#include "maps.h"

// ----- OBJECT MAP ---------------------------------

typedef struct {
	int next;
} hl_ho_entry;

typedef struct {
	vdynamic *key;
	vdynamic *value;
} hl_ho_value;

static vdynamic *hl_hofilter( vdynamic *key ) {
	if( key )
		switch( key->t->kind ) {
		// erase virtual (prevent mismatch once virtualized)
		case HVIRTUAL:
			key = hl_virtual_make_value((vvirtual*)key);
			break;
		// store real pointer instead of dynamic wrapper
		case HBYTES:
		case HTYPE:
		case HABSTRACT:
		case HREF:
		case HENUM:
			key = (vdynamic*)key->v.ptr;
			break;
		default:
			break;
		}
	return key;
}

#define hlt_key		hlt_dyn
#define hl_hohash(key)	((unsigned int)(int_val)(key))
#define _MKEY_TYPE	vdynamic*
#define _MNAME(n)	hl_ho##n
#define _MMATCH(c)	m->values[c].key == key
#define _MKEY(m,c)	m->values[c].key
#define	_MSET(c)	m->values[c].key = key
#define _MERASE(c)  m->values[c].key = NULL

#include "maps.h"

#define _IMAP _ABSTRACT(hl_int_map)
DEFINE_PRIM( _IMAP, hialloc, _NO_ARG );
DEFINE_PRIM( _VOID, hiset, _IMAP _I32 _DYN );
DEFINE_PRIM( _BOOL, hiexists, _IMAP _I32 );
DEFINE_PRIM( _DYN, higet, _IMAP _I32 );
DEFINE_PRIM( _BOOL, hiremove, _IMAP _I32 );
DEFINE_PRIM( _ARR, hikeys, _IMAP );
DEFINE_PRIM( _ARR, hivalues, _IMAP );
DEFINE_PRIM( _VOID, hiclear, _IMAP );

#define _BMAP _ABSTRACT(hl_bytes_map)
DEFINE_PRIM( _BMAP, hballoc, _NO_ARG );
DEFINE_PRIM( _VOID, hbset, _BMAP _BYTES _DYN );
DEFINE_PRIM( _BOOL, hbexists, _BMAP _BYTES );
DEFINE_PRIM( _DYN, hbget, _BMAP _BYTES );
DEFINE_PRIM( _BOOL, hbremove, _BMAP _BYTES );
DEFINE_PRIM( _ARR, hbkeys, _BMAP );
DEFINE_PRIM( _ARR, hbvalues, _BMAP );
DEFINE_PRIM( _VOID, hbclear, _BMAP );

#define _OMAP _ABSTRACT(hl_obj_map)
DEFINE_PRIM( _OMAP, hoalloc, _NO_ARG );
DEFINE_PRIM( _VOID, hoset, _OMAP _DYN _DYN );
DEFINE_PRIM( _BOOL, hoexists, _OMAP _DYN );
DEFINE_PRIM( _DYN, hoget, _OMAP _DYN );
DEFINE_PRIM( _BOOL, horemove, _OMAP _DYN );
DEFINE_PRIM( _ARR, hokeys, _OMAP );
DEFINE_PRIM( _ARR, hovalues, _OMAP );
DEFINE_PRIM( _VOID, hoclear, _OMAP );

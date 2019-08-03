/*
 * Copyright (C)2005-2017 Haxe Foundation
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
#include <stdio.h>

static int track_depth = 10;
static int max_depth = 0;

#ifdef HL_TRACK_ENABLE
hl_track_info hl_track = {0};
#endif

typedef enum {
	KALLOC,
	KCAST,
	KDYNFIELD,
	KDYNCALL,
	_KLAST
} bucket_kind;

typedef struct {
	hl_type *t;
	void **stack;
	int stack_count;
	int hit_count;
	int info;
} bucket;

typedef struct {
	unsigned int *hashes;
	bucket *buckets;
	int bcount;
	int max_buckets;
	unsigned int prev_hash;
	unsigned int prev_hash2;
	bucket *prev_b;
	bucket *prev_b2;
} bucket_list;

static bucket_list all_data[_KLAST] = {{0}};
static hl_mutex *track_lock = NULL;

int hl_internal_capture_stack( void **stack, int size );

static bucket *bucket_find_insert( bucket_list *data, unsigned int hash, void **stack, int count ) {
	int min = 0, mid;
	int max = data->bcount;
	bucket *b;
	while( min < max ) {
		mid = (min + max) >> 1;
		if( data->hashes[mid] < hash )
			min = mid + 1;
		else if( data->hashes[mid] > hash )
			max = mid;
		else {
			b = data->buckets + mid;
			if( b->stack_count != count ) {
				if( b->stack_count < count )
					min = mid + 1;
				else
					max = mid;
			} else {
				int i;
				for(i=0;i<count;i++)
					if( b->stack[i] != stack[i] ) {
						if( b->stack[i] < stack[i] )
							min = mid + 1;
						else
							max = mid;
						break;
					}
				if( i == count )
					return b;
			}
		}
	}
	mid = (min + max) >> 1;
	if( data->bcount == data->max_buckets ) {
		int nbuckets = data->max_buckets ? data->max_buckets << 1 : 256;
		bucket *bnew = (bucket*)malloc(sizeof(bucket)*nbuckets);
		unsigned int *hnew = (unsigned int*)malloc(sizeof(int)*nbuckets);
		memcpy(bnew,data->buckets,data->bcount*sizeof(bucket));
		memcpy(hnew,data->hashes,data->bcount*sizeof(int));
		free(data->buckets);
		free(data->hashes);
		data->buckets = bnew;
		data->hashes = hnew;
		data->max_buckets = nbuckets;
	}
	b = data->buckets + mid;
	if( data->hashes[mid] == hash && b->stack_count == count ) {
		int i;
		for(i=0;i<count;i++)
			if( b->stack[i] != stack[i] )
				break;
		if( i == count )
			return b;
	}
	memmove(data->buckets + (mid + 1), data->buckets + mid, (data->bcount - mid) * sizeof(bucket));
	memmove(data->hashes + (mid + 1), data->hashes + mid, (data->bcount - mid) * sizeof(int));
	memset(b, 0, sizeof(bucket));
	b->stack = malloc(sizeof(void*)*count);
	memcpy(b->stack, stack, sizeof(void*)*count);
	b->stack_count = count;
	data->hashes[mid] = hash;
	data->bcount++;
	return b;
}

static void init_lock() {
	hl_thread_info *tinf = hl_get_thread();
	int flags = tinf->flags;
	tinf->flags &= ~(HL_TRACK_ALLOC<<HL_TREAD_TRACK_SHIFT);
	track_lock = hl_mutex_alloc(true);
	hl_add_root(&track_lock);
	tinf->flags = flags;
}

static bucket *fetch_bucket( bucket_kind kind ) {
	int count, i;
	unsigned int hash;
	hl_thread_info *tinf = hl_get_thread();
	bucket_list *data = &all_data[kind];
	bucket *b;
	if( track_lock == NULL ) init_lock();
	count = hl_internal_capture_stack(tinf->exc_stack_trace,track_depth);
	if( count > max_depth ) max_depth = count;
	hash = -count;
	for(i=0;i<count;i++)
		hash = (hash * 31) + (((unsigned int)(int_val)tinf->exc_stack_trace[i]) >> 1);
	// look for bucket
	hl_mutex_acquire(track_lock);
	if( hash == data->prev_hash && data->prev_b ) {
		b = data->prev_b;
	} else if( hash == data->prev_hash2 && data->prev_b2 ) {
		b = data->prev_b2;
	} else {
		b = bucket_find_insert(data, hash, tinf->exc_stack_trace, count);
		data->prev_hash2 = data->prev_hash;
		data->prev_b2 = data->prev_b;
		data->prev_hash = hash;
		data->prev_b = b;
	}
	return b;
}

static void on_alloc( hl_type *t, int size, int flags, void *ptr ) {
	bucket *b = fetch_bucket(KALLOC);
	b->t = t;
	b->hit_count++;
	b->info += size;
	hl_mutex_release(track_lock);
}

static void on_cast( hl_type *t1, hl_type *t2 ) {
	bucket *b = fetch_bucket(KCAST);
	b->t = t1;
	b->hit_count++;
	b->info = t2->kind;
	hl_mutex_release(track_lock);
}

static void on_dynfield( vdynamic *d, int hfield ) {
	bucket *b = fetch_bucket(KDYNFIELD);
	b->t = d?d->t:&hlt_dyn;
	b->hit_count++;
	b->info = hfield;
	hl_mutex_release(track_lock);
}

static void on_dyncall( vdynamic *d, int hfield ) {
	bucket *b = fetch_bucket(KDYNCALL);
	b->t = d?d->t:&hlt_dyn;
	b->hit_count++;
	b->info = hfield;
	hl_mutex_release(track_lock);
}

HL_PRIM void hl_track_init() {
#ifdef HL_TRACK_ENABLE
	char *env = getenv("HL_TRACK");
	if( env )
		hl_track.flags = atoi(env);
	hl_track.on_alloc = on_alloc;
	hl_track.on_cast = on_cast;
	hl_track.on_dynfield = on_dynfield;
	hl_track.on_dyncall = on_dyncall;
#endif
}

HL_PRIM void hl_track_lock( bool lock ) {
#ifdef HL_TRACK_ENABLE
	if( !track_lock ) init_lock();
	if( lock )
		hl_mutex_acquire(track_lock);
	else
		hl_mutex_release(track_lock);
#endif
}

HL_PRIM int hl_track_count( int *depth ) {
	int value = 0;
	int i;
	for(i=0;i<_KLAST;i++)
		value += all_data[i].bcount;
	*depth = max_depth;
	return value;
}

HL_PRIM int hl_track_entry( int id, hl_type **t, int *count, int *info, varray *stack ) {
	static bucket_list *cur = NULL;
	static int prev_id = -10;
	static int count_before = 0;
	bucket *b = NULL;
	if( id == prev_id + 1 ) {
		if( id - count_before == cur->bcount ) {
			if( cur - all_data == _KLAST ) return -1;
			count_before += cur->bcount;
			cur++;
		}
		b = cur->buckets + (id - count_before);		
		prev_id++;
	} else {
		int i;		
		count_before = 0;
		for(i=0;i<_KLAST;i++) {
			bucket_list *data = &all_data[i];
			if( id - count_before < data->bcount ) break;
			count_before += data->bcount;
		}
		if( i == _KLAST ) return -1; // out of range
		prev_id = id;
		cur = &all_data[i];
		b = cur->buckets;
	}	
	*t = b->t;
	*count = b->hit_count;
	*info = b->info;
	stack->size = b->stack_count;
	memcpy(hl_aptr(stack,void*), b->stack, b->stack_count * sizeof(void*));
	return (int)(cur - all_data);
}

HL_PRIM int hl_track_get_bits( bool thread ) {
#	ifdef HL_TRACK_ENABLE
	return (thread ? (hl_get_thread()->flags>>HL_TREAD_TRACK_SHIFT) : hl_track.flags) & HL_TRACK_MASK;
#	else
	return 0;
#	endif
}

HL_PRIM void hl_track_set_depth( int d ) {
	track_depth = d;
}

HL_PRIM void hl_track_set_bits( int flags, bool thread ) {
#	ifdef HL_TRACK_ENABLE
	if( thread ) {
		hl_thread_info *t = hl_get_thread();
		if( t ) t->flags = (t->flags & ~(HL_TRACK_MASK<<HL_TREAD_TRACK_SHIFT)) | ((flags & HL_TRACK_MASK) << HL_TREAD_TRACK_SHIFT);	
	} else {
		hl_track.flags = (hl_track.flags & ~HL_TRACK_MASK) | (flags & HL_TRACK_MASK);
	}
#	endif
}

HL_PRIM void hl_track_reset() {
	int i;
	for(i=0;i<_KLAST;i++)
		all_data[i].bcount = 0;
}

DEFINE_PRIM(_VOID, track_init, _NO_ARG);
DEFINE_PRIM(_I32, track_count, _REF(_I32));
DEFINE_PRIM(_I32, track_entry, _I32 _REF(_TYPE) _REF(_I32) _REF(_I32) _ARR);
DEFINE_PRIM(_VOID, track_lock, _BOOL);
DEFINE_PRIM(_VOID, track_set_depth, _I32);
DEFINE_PRIM(_I32, track_get_bits, _BOOL);
DEFINE_PRIM(_VOID, track_set_bits, _I32 _BOOL);
DEFINE_PRIM(_VOID, track_reset, _NO_ARG);

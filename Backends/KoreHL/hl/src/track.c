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

HL_PRIM void hl_gc_set_track( void *f );

static int track_depth = 5;
static void **track_buffer = NULL;

typedef struct {
	hl_type *t;
	int stack_count;
	void **stack;
	int alloc_count;
	int total_size;
} bucket;

static unsigned int *hashes = NULL;
static bucket *buckets = NULL;
static int bcount = 0;
static int max_buckets = 0;

int hl_internal_capture_stack( void **stack, int size );

static bucket *bucket_find_insert( unsigned int hash, void **stack, int count ) {
	int min = 0, mid;
	int max = bcount;
	bucket *b;
	while( min < max ) {
		mid = (min + max) >> 1;
		if( hashes[mid] < hash )
			min = mid + 1;
		else if( hashes[mid] > hash )
			max = mid;
		else {
			b = buckets + mid;
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
	if( bcount == max_buckets ) {
		int nbuckets = max_buckets ? max_buckets << 1 : 256;
		bucket *bnew = (bucket*)malloc(sizeof(bucket)*nbuckets);
		unsigned int *hnew = (unsigned int*)malloc(sizeof(int)*nbuckets);
		memcpy(bnew,buckets,bcount*sizeof(bucket));
		memcpy(hnew,hashes,bcount*sizeof(int));
		free(buckets);
		free(hashes);
		buckets = bnew;
		hashes = hnew;
		max_buckets = nbuckets;
	}
	b = buckets + mid;
	if( hashes[mid] == hash && b->stack_count == count ) {
		int i;
		for(i=0;i<count;i++)
			if( b->stack[i] != stack[i] )
				break;
		if( i == count )
			return b;
	}
	memmove(buckets + (mid + 1), buckets + mid, (bcount - mid) * sizeof(bucket));
	memmove(hashes + (mid + 1), hashes + mid, (bcount - mid) * sizeof(int));
	memset(b, 0, sizeof(bucket));
	b->stack = malloc(sizeof(void*)*count);
	memcpy(b->stack, stack, sizeof(void*)*count);
	b->stack_count = count;
	hashes[mid] = hash;
	bcount++;
	return b;
}

static void on_alloc( hl_type *t, int size, int flags, void *ptr ) {
	static unsigned int prev_hash = 0, prev_hash2 = 0;
	static bucket *prev_b = NULL, *prev_b2 = NULL;
	int count, i;
	unsigned int hash;
	bucket *b;
	if( track_buffer == NULL ) track_buffer = malloc(sizeof(void*)*track_depth);
	count = hl_internal_capture_stack(track_buffer,track_depth);
	hash = -count;
	for(i=0;i<count;i++)
		hash = (hash * 31) + (((unsigned int)(int_val)track_buffer[i]) >> 1);
	// look for bucket
	if( hash == prev_hash ) {
		b = prev_b;
	} else if( hash == prev_hash2 ) {
		b = prev_b2;
	} else {
		b = bucket_find_insert(hash, track_buffer, count);
		prev_hash2 = prev_hash;
		prev_b2 = prev_b;
		prev_hash = hash;
		prev_b = b;
	}
	b->t = t;
	b->alloc_count++;
	b->total_size += size;
}

HL_PRIM void hl_track_init() {
	hl_gc_set_track(on_alloc);
}

HL_PRIM int hl_track_count( int *depth ) {
	*depth = track_depth;
	return bcount;
}

HL_PRIM void hl_track_entry( int id, hl_type **t, int *allocs, int *size, varray *stack ) {
	bucket *b = buckets + id;
	*t = b->t;
	*allocs = b->alloc_count;
	*size = b->total_size;
	stack->size = b->stack_count;
	memcpy(hl_aptr(stack,void*), b->stack, b->stack_count * sizeof(void*));
}

DEFINE_PRIM(_VOID, track_init, _NO_ARG);
DEFINE_PRIM(_I32, track_count, _REF(_I32));
DEFINE_PRIM(_VOID, track_entry, _I32 _REF(_TYPE) _REF(_I32) _REF(_I32) _ARR);

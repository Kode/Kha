/*
 * Copyright (C)2005-2020 Haxe Foundation
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

#ifdef HL_WIN
#	include <intrin.h>
static unsigned int __inline TRAILING_ONES( unsigned int x ) {
	DWORD msb = 0;
	if( _BitScanForward( &msb, ~x ) )
		return msb;
	return 32;
}
static unsigned int __inline TRAILING_ZEROES( unsigned int x ) {
	DWORD msb = 0;
	if( _BitScanForward( &msb, x ) )
		return msb;
	return 32;
}
#else
static inline unsigned int TRAILING_ONES( unsigned int x ) {
	return (~x) ? __builtin_ctz(~x) : 32;
}
static inline unsigned int TRAILING_ZEROES( unsigned int x ) {
	return x ? __builtin_ctz(x) : 32;
}
#endif

#define GC_PARTITIONS	9
#define GC_PART_BITS	4
#define GC_FIXED_PARTS	5
#define GC_LARGE_PART	(GC_PARTITIONS-1)
#define GC_LARGE_BLOCK	(1 << 20)
static const int GC_SBITS[GC_PARTITIONS] = {0,0,0,0,0,		3,6,13,0};

#ifdef HL_64
static const int GC_SIZES[GC_PARTITIONS] = {8,16,24,32,40,	8,64,1<<13,0};
#	define GC_ALIGN_BITS		3
#else
static const int GC_SIZES[GC_PARTITIONS] = {4,8,12,16,20,	8,64,1<<13,0};
#	define GC_ALIGN_BITS		2
#endif


#define GC_ALL_PAGES	(GC_PARTITIONS << PAGE_KIND_BITS)
#define	GC_ALIGN		(1 << GC_ALIGN_BITS)

static gc_pheader *gc_pages[GC_ALL_PAGES] = {NULL};
static gc_pheader *gc_free_pages[GC_ALL_PAGES] = {NULL};

#define MAX_FL_CACHED 16

typedef struct {
	int count;
	gc_fl *data[MAX_FL_CACHED];
} cached_slot;

static cached_slot cached_slots[32] = {0};
static int free_lists_size = 0;
static int free_lists_count = 0;

static void alloc_freelist( gc_freelist *fl, int size ) {
	cached_slot *slot = &cached_slots[size];
	if( slot->count ) {
		fl->data = slot->data[--slot->count];
		fl->size_bits = size;
		fl->count = 0;
		fl->current = 0;
		return;
	}
	int bytes = (int)sizeof(gc_fl) * (1<<size);
	free_lists_size += bytes;
	free_lists_count++;
	fl->data = (gc_fl*)malloc(bytes);
	fl->count = 0;
	fl->current = 0;
	fl->size_bits = size;
}

static void free_freelist( gc_freelist *fl ) {
	cached_slot *slot = &cached_slots[fl->size_bits];
	if( slot->count == MAX_FL_CACHED ) {
		free(fl->data);
		free_lists_size -= (int)sizeof(gc_fl) * (1 << fl->size_bits);
		return;
	}
	slot->data[slot->count++] = fl->data;
}


#define GET_FL(fl,pos) ((fl)->data + (pos))

static void freelist_append( gc_freelist *fl, int pos, int count ) {
	if( fl->count == 1<<fl->size_bits ) {
#		ifdef GC_DEBUG
		if( fl->current ) hl_fatal("assert");
#		endif
		gc_freelist fl2;
		alloc_freelist(&fl2, fl->size_bits + 1);
		memcpy(GET_FL(&fl2,0),GET_FL(fl,0),sizeof(gc_fl)*fl->count);
		free_freelist(fl);
		fl->size_bits++;
		fl->data = fl2.data;
	}
	gc_fl *p = GET_FL(fl,fl->count++);
	p->pos = (fl_cursor)pos;
	p->count = (fl_cursor)count;
}

static gc_pheader *gc_allocator_new_page( int pid, int block, int size, int kind, bool varsize ) {
	// increase size based on previously allocated pages
	if( block < 256 ) {
		int num_pages = 0;
		gc_pheader *ph = gc_pages[pid];
		while( ph ) {
			num_pages++;
			ph = ph->next_page;
		}
		while( num_pages > 8 && (size<<1) / block <= GC_PAGE_SIZE ) {
			size <<= 1;
			num_pages /= 3;
		}
	}

	int start_pos = 0;
	int max_blocks = size / block;

	gc_pheader *ph = gc_alloc_page(size, kind, max_blocks);
	gc_allocator_page_data *p = &ph->alloc;

	p->block_size = block;
	p->max_blocks = max_blocks;
	p->sizes = NULL;
	if( p->max_blocks > GC_PAGE_SIZE )
		hl_fatal("Too many blocks for this page");
	if( varsize ) {
		if( p->max_blocks <= 8 )
			p->sizes = (unsigned char*)&p->sizes_ref;
		else {
			p->sizes = ph->base + start_pos;
			start_pos += p->max_blocks;
			start_pos += (-start_pos) & 63; // align on cache line
		}
		MZERO(p->sizes,p->max_blocks);
	}
	int m = start_pos % block;
	if( m ) start_pos += block - m;
	int fl_bits = 1;
	while( fl_bits < 8 && (1<<fl_bits) < (p->max_blocks>>3) ) fl_bits++;
	p->first_block = start_pos / block;
	alloc_freelist(&p->free,fl_bits);
	freelist_append(&p->free,p->first_block, p->max_blocks - p->first_block);
	p->need_flush = false;

	ph->next_page = gc_pages[pid];
	gc_pages[pid] = ph;

	return ph;
}


static void flush_free_list( gc_pheader *ph ) {
	gc_allocator_page_data *p = &ph->alloc;

	int bid = p->first_block;
	int last = p->max_blocks;
	gc_freelist new_fl;
	alloc_freelist(&new_fl,p->free.size_bits);
	gc_freelist old_fl = p->free;
	gc_fl *cur_pos = NULL;
	int reuse_index = old_fl.current;
	gc_fl *reuse = reuse_index < old_fl.count ? GET_FL(&old_fl,reuse_index++) : NULL;
	int next_bid = reuse ? reuse->pos : -1;
	unsigned char *bmp = ph->bmp;

	while( bid < last ) {
		if( bid == next_bid ) {
			if( cur_pos && cur_pos->pos + cur_pos->count == bid ) {
				cur_pos->count += reuse->count;
			} else {
				freelist_append(&new_fl,reuse->pos,reuse->count);
				cur_pos = GET_FL(&new_fl,new_fl.count - 1);
			}
			reuse = reuse_index < old_fl.count ? GET_FL(&old_fl,reuse_index++) : NULL;
			bid = cur_pos->count + cur_pos->pos;
			next_bid = reuse ? reuse->pos : -1;
			continue;
		}
		fl_cursor count;
		if( p->sizes ) {
			count = p->sizes[bid];
			if( !count ) count = 1;
		} else
			count = 1;
		if( (bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
			if( p->sizes ) p->sizes[bid] = 0;
			if( cur_pos && cur_pos->pos + cur_pos->count == bid )
				cur_pos->count += count;
			else {
				freelist_append(&new_fl,bid,count);
				cur_pos = GET_FL(&new_fl,new_fl.count - 1);
			}
		}
		bid += count;
	}
	p->free = new_fl;
	p->need_flush = false;
#ifdef __GC_DEBUG
	if( ph->page_id == -1 ) {
		int k;
		for(k=0;k<p->free.count;k++) {
			gc_fl *fl = GET_FL(&p->free,k);
			printf("(%d-%d)",fl->pos,fl->pos+fl->count-1); 
		}
		printf("\n");
	}
	if( reuse && reuse->count ) hl_fatal("assert");
	for(bid=p->first_block;bid<p->max_blocks;bid++) {
		int k;
		bool is_free = false;
		for(k=0;k<p->free.count;k++) {
			gc_fl *fl = GET_FL(&p->free,k);
			if( fl->pos < p->first_block || fl->pos + fl->count > p->max_blocks ) hl_fatal("assert");
			if( bid >= fl->pos && bid < fl->pos + fl->count ) {
				if( is_free ) hl_fatal("assert");
				is_free = true;
			}
		}
		bool is_marked = ((ph->bmp[bid>>3] & (1<<(bid&7))) != 0); 
		if( is_marked && is_free ) {
			// check if it was already free before
			for(k=0;k<old_fl.count;k++) {
				gc_fl *fl = GET_FL(&old_fl,k);
				if( bid >= fl->pos && bid < fl->pos+fl->count ) {
					is_marked = false; // false positive
					ph->bmp[bid>>3] &= ~(1<<(bid&7));
					break;
				}
			}
		}
		if( is_free == is_marked )
			hl_fatal("assert");
		if( p->sizes && !is_free )
			bid += p->sizes[bid]-1;
	}
#endif
	free_freelist(&old_fl);
}

static void *gc_alloc_fixed( int part, int kind ) {
	int pid = (part << PAGE_KIND_BITS) | kind;
	gc_pheader *ph = gc_free_pages[pid];
	gc_allocator_page_data *p = NULL;
	int bid = -1;
	while( ph ) {
		p = &ph->alloc;
		if( p->need_flush )
			flush_free_list(ph);
		gc_freelist *fl = &p->free;
		if( fl->current < fl->count ) {
			gc_fl *c = GET_FL(fl,fl->current);
			bid = c->pos++;
			c->count--;
#			ifdef GC_DEBUG
			if( c->count < 0 ) hl_fatal("assert");
#			endif
			if( !c->count ) fl->current++;
			break;
		}
		ph = ph->next_page;
	}
	if( ph == NULL ) {
		ph = gc_allocator_new_page(pid, GC_SIZES[part], GC_PAGE_SIZE, kind, false);
		p = &ph->alloc;
		bid = p->free.data->pos++;
		p->free.data->count--;
	}
	unsigned char *ptr = ph->base + bid * p->block_size;
#	ifdef GC_DEBUG
	{
		int i;
		if( bid < p->first_block || bid >= p->max_blocks )
			hl_fatal("assert");
		for(i=0;i<p->block_size;i++)
			if( ptr[i] != 0xDD )
				hl_fatal("assert");
	}
#	endif
	gc_free_pages[pid] = ph;
	return ptr;
}

static void *gc_alloc_var( int part, int size, int kind ) {
	int pid = (part << PAGE_KIND_BITS) | kind;
	gc_pheader *ph = gc_free_pages[pid];
	gc_allocator_page_data *p = NULL;
	unsigned char *ptr;
	fl_cursor nblocks = (fl_cursor)(size >> GC_SBITS[part]);
	int bid = -1;
	while( ph ) {
		p = &ph->alloc;
		if( p->need_flush )
			flush_free_list(ph);
		gc_freelist *fl = &p->free;
		int k;
		for(k=fl->current;k<fl->count;k++) {
			gc_fl *c = GET_FL(fl,k);
			if( c->count >= nblocks ) {
				bid = c->pos;
				c->pos += nblocks;
				c->count -= nblocks;
#				ifdef GC_DEBUG
				if( c->count < 0 ) hl_fatal("assert");
#				endif
				if( c->count == 0 ) fl->current++;
				goto alloc_var;
			}
		}
		ph = ph->next_page;
	}
	if( ph == NULL ) {
		int psize = GC_PAGE_SIZE;
		while( psize < size + 1024 )
			psize <<= 1;
		ph = gc_allocator_new_page(pid, GC_SIZES[part], psize, kind, true);
		p = &ph->alloc;
		bid = p->first_block;
		p->free.data->pos += nblocks;
		p->free.data->count -= nblocks;
	}
alloc_var:
	ptr = ph->base + bid * p->block_size;
#	ifdef GC_DEBUG
	{
		int i;
		if( bid < p->first_block || bid + nblocks > p->max_blocks )
			hl_fatal("assert");
		for(i=0;i<size;i++)
			if( ptr[i] != 0xDD )
				hl_fatal("assert");
	}
#	endif
	if( ph->bmp ) {
#		ifdef GC_DEBUG
		int i;
		for(i=0;i<nblocks;i++) {
			int b = bid + i;
			if( (ph->bmp[b>>3]&(1<<(b&7))) != 0 ) hl_fatal("Alloc on marked block");
		}
#		endif
		ph->bmp[bid>>3] |= 1<<(bid&7);
	}
	if( nblocks > 1 ) MZERO(p->sizes + bid, nblocks);
	p->sizes[bid] = (unsigned char)nblocks;
	gc_free_pages[pid] = ph;
	return ptr;
}

static void *gc_allocator_alloc( int *size, int page_kind ) {
	int sz = *size;
	sz += (-sz) & (GC_ALIGN - 1);
	if( sz >= GC_LARGE_BLOCK ) {
		sz += (-sz) & (GC_PAGE_SIZE - 1);
		*size = sz;
		gc_pheader *ph = gc_allocator_new_page((GC_LARGE_PART << PAGE_KIND_BITS) | page_kind,sz,sz,page_kind,false);
		return ph->base;
	}
	if( sz <= GC_SIZES[GC_FIXED_PARTS-1] && page_kind != MEM_KIND_FINALIZER ) {
		int part = (sz >> GC_ALIGN_BITS) - 1;
		*size = GC_SIZES[part];
		return gc_alloc_fixed(part, page_kind);
	}
	int p;
	for(p=GC_FIXED_PARTS;p<GC_PARTITIONS;p++) {
		int block = GC_SIZES[p];
		int query = sz + ((-sz) & (block - 1));
		if( query < block * 255 ) {
			*size = query;
			return gc_alloc_var(p, query, page_kind);
		}
	}
	*size = -1;
	return NULL;
}

static bool is_zero( void *ptr, int size ) {
	static char ZEROMEM[256] = {0};
	unsigned char *p = (unsigned char*)ptr;
	while( size>>8 ) {
		if( memcmp(p,ZEROMEM,256) ) return false;
		p += 256;
		size -= 256;
	}
	return memcmp(p,ZEROMEM,size) == 0;
}

static void gc_flush_empty_pages() {
	int i;
	for(i=0;i<GC_ALL_PAGES;i++) {
		gc_pheader *ph = gc_pages[i];
		gc_pheader *prev = NULL;
		while( ph ) {
			gc_allocator_page_data *p = &ph->alloc;
			gc_pheader *next = ph->next_page;
			if( ph->bmp && is_zero(ph->bmp+(p->first_block>>3),((p->max_blocks+7)>>3) - (p->first_block>>3)) ) {
				if( prev )
					prev->next_page = next;
				else
					gc_pages[i] = next;
				if( gc_free_pages[i] == ph )
					gc_free_pages[i] = next;
				free_freelist(&p->free);
				gc_free_page(ph, p->max_blocks);
			} else
				prev = ph;
			ph = next;
		}
	}
}

#ifdef GC_DEBUG
static void gc_clear_unmarked_mem() {
	int i;
	for(i=0;i<GC_ALL_PAGES;i++) {
		gc_pheader *ph = gc_pages[i];
		while( ph ) {
			int bid;
			gc_allocator_page_data *p = &ph->alloc;
			for(bid=p->first_block;bid<p->max_blocks;bid++) {
				if( p->sizes && !p->sizes[bid] ) continue;
				int size = p->sizes ? p->sizes[bid] * p->block_size : p->block_size;
				unsigned char *ptr = ph->base + bid * p->block_size;
				if( bid * p->block_size + size > ph->page_size ) hl_fatal("invalid block size");
#				ifdef GC_MEMCHK
				int_val eob = *(int_val*)(ptr + size - HL_WSIZE);
#				ifdef HL_64
				if( eob != 0xEEEEEEEEEEEEEEEE && eob != 0xDDDDDDDDDDDDDDDD )
#				else
				if( eob != 0xEEEEEEEE && eob != 0xDDDDDDDD )
#				endif
					hl_fatal("Block written out of bounds");
#				endif
				if( (ph->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
					memset(ptr,0xDD,size);
					if( p->sizes ) p->sizes[bid] = 0;
				}
			}
			ph = ph->next_page;
		}
	}
}
#endif

static void gc_call_finalizers(){
	int i;
	for(i=MEM_KIND_FINALIZER;i<GC_ALL_PAGES;i+=1<<PAGE_KIND_BITS) {
		gc_pheader *ph = gc_pages[i];
		while( ph ) {
			int bid;
			gc_allocator_page_data *p = &ph->alloc;
			for(bid=p->first_block;bid<p->max_blocks;bid++) {
				int size = p->sizes[bid];
				if( !size ) continue;
				if( (ph->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
					unsigned char *ptr = ph->base + bid * p->block_size;
					void *finalizer = *(void**)ptr;
					p->sizes[bid] = 0;
					if( finalizer )
						((void(*)(void *))finalizer)(ptr);
#					ifdef GC_DEBUG
					memset(ptr,0xDD,size*p->block_size);
#					endif
				}
			}
			ph = ph->next_page;
		}
	}
}

static void gc_allocator_before_mark( unsigned char *mark_cur ) {
	int pid;
	for(pid=0;pid<GC_ALL_PAGES;pid++) {
		gc_pheader *p = gc_pages[pid];
		gc_free_pages[pid] = p;
		while( p ) {
			p->bmp = mark_cur;
			p->alloc.need_flush = true;
			mark_cur += (p->alloc.max_blocks + 7) >> 3;
			p = p->next_page;
		}
	}
}

#define gc_allocator_fast_block_size(page,block) \
	(page->alloc.sizes ? page->alloc.sizes[(int)(((unsigned char*)(block)) - page->base) / page->alloc.block_size] * page->alloc.block_size : page->alloc.block_size)

static void gc_allocator_init() {
	if( TRAILING_ONES(0x080003FF) != 10 || TRAILING_ONES(0) != 0 || TRAILING_ONES(0xFFFFFFFF) != 32 )
		hl_fatal("Invalid builtin tl1");
	if( TRAILING_ZEROES((unsigned)~0x080003FF) != 10 || TRAILING_ZEROES(0) != 32 || TRAILING_ZEROES(0xFFFFFFFF) != 0 )
		hl_fatal("Invalid builtin tl0");
}

static int gc_allocator_get_block_id( gc_pheader *page, void *block ) {
	int offset = (int)((unsigned char*)block - page->base);
	if( offset%page->alloc.block_size != 0 )
		return -1;
	int bid = offset / page->alloc.block_size;
	if( page->alloc.sizes && page->alloc.sizes[bid] == 0 ) return -1;
	return bid;
}

#ifdef GC_INTERIOR_POINTERS
static int gc_allocator_get_block_interior( gc_pheader *page, void **block ) {
	int offset = (int)((unsigned char*)*block - page->base);
	int bid = offset / page->alloc.block_size;
	if( page->alloc.sizes ) {
		if( bid < page->alloc.first_block ) return -1;
		while( page->alloc.sizes[bid] == 0 ) {
			if( bid == page->alloc.first_block ) return -1;
			bid--;
		}
	}
	*block = page->base + bid * page->alloc.block_size;
	return bid;
}
#endif

static void gc_allocator_after_mark() {
	gc_call_finalizers();
#	ifdef GC_DEBUG
	gc_clear_unmarked_mem();
#	endif
	gc_flush_empty_pages();
}

static void gc_get_stats( int *page_count, int *private_data ) {
	int count = 0;
	int i;
	for(i=0;i<GC_ALL_PAGES;i++) {
		gc_pheader *p = gc_pages[i];
		while( p ) {
			count++;
			p = p->next_page;
		}
	}
	*page_count = count;
	*private_data = 0; // no malloc
} 

static void gc_iter_pages( gc_page_iterator iter ) {
	int i;
	for(i=0;i<GC_ALL_PAGES;i++) {
		gc_pheader *p = gc_pages[i];
		while( p ) {
			int size = 0;
			if( p->alloc.sizes && p->alloc.max_blocks > 8 ) size = p->alloc.max_blocks;
			iter(p,size);
			p = p->next_page;
		}
	}
}

static void gc_iter_live_blocks( gc_pheader *ph, gc_block_iterator iter ) {
	int i;
	gc_allocator_page_data *p = &ph->alloc;
	for(i=0;i<p->max_blocks;i++) {
		if( ph->bmp[(i>>3)] & (1<<(i&7)) )
			iter(ph->base + i*p->block_size,p->sizes?p->sizes[i]*p->block_size:p->block_size);
	}
}

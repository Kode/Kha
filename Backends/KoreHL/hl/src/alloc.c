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
#ifdef HL_WIN
#	include <windows.h>
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
#	include <sys/types.h>
#	include <sys/mman.h>
static inline unsigned int TRAILING_ONES( unsigned int x ) {
	return (~x) ? __builtin_ctz(~x) : 32;
}
static inline unsigned int TRAILING_ZEROES( unsigned int x ) {
	return x ? __builtin_ctz(x) : 32;
}
#endif
#	define MZERO(ptr,size)		memset(ptr,0,size)

// GC

#define	GC_ALIGN		(1 << GC_ALIGN_BITS)
#define GC_ALL_PAGES	(GC_PARTITIONS << PAGE_KIND_BITS)

#define GC_PAGE_BITS	16
#define GC_PAGE_SIZE	(1 << GC_PAGE_BITS)

#ifndef HL_64
#	define gc_hash(ptr)			((unsigned int)(ptr))
#	define GC_LEVEL0_BITS		8
#	define GC_LEVEL1_BITS		8
#	define GC_ALIGN_BITS		2
#else
#	define GC_LEVEL0_BITS		10
#	define GC_LEVEL1_BITS		10
#	define GC_ALIGN_BITS		3

// we currently discard the higher bits
// we should instead have some special handling for them
// in x86-64 user space grows up to 0x8000-00000000 (16 bits base + 31 bits page id)

#ifdef HL_WIN
#	define gc_hash(ptr)			((int_val)(ptr)&0x0000000FFFFFFFFF)
#else
// Linux gives addresses using the following patterns (X=any,Y=small value - can be 0): 
//		0x0000000YXXX0000
//		0x0007FY0YXXX0000
static int_val gc_hash( void *ptr ) {
	int_val v = (int_val)ptr;
	return (v ^ ((v >> 33) << 28)) & 0x0000000FFFFFFFFF;
}
#endif

#endif

#define GC_MASK_BITS		16
#define GC_GET_LEVEL1(ptr)	hl_gc_page_map[gc_hash(ptr)>>(GC_MASK_BITS+GC_LEVEL1_BITS)]
#define GC_GET_PAGE(ptr)	GC_GET_LEVEL1(ptr)[(gc_hash(ptr)>>GC_MASK_BITS)&GC_LEVEL1_MASK]
#define GC_LEVEL1_MASK		((1 << GC_LEVEL1_BITS) - 1)

#define PAGE_KIND_BITS		2
#define PAGE_KIND_MASK		((1 << PAGE_KIND_BITS) - 1)

#if defined(HL_DEBUG) && !defined(HL_CONSOLE)
#	define GC_DEBUG
#	define GC_MEMCHK
#endif

#define out_of_memory(reason)		hl_fatal("Out of Memory (" reason ")")

typedef struct _gc_pheader gc_pheader;

struct _gc_pheader {
	// const
	int page_size;
	int page_kind;
	int block_size;
	int max_blocks;
	int first_block;
	// mutable
	int next_block;
	int free_blocks;
	unsigned char *sizes;
	unsigned char *bmp;
	gc_pheader *next_page;
#ifdef HL_TRACK_ALLOC
	int *alloc_hashes;
#endif
#ifdef GC_DEBUG
	int page_id;
#endif
};

#define GC_PARTITIONS	9
#define GC_PART_BITS	4
#define GC_FIXED_PARTS	5
static const int GC_SBITS[GC_PARTITIONS] = {0,0,0,0,0,		3,6,14,22};

#ifdef HL_64
static const int GC_SIZES[GC_PARTITIONS] = {8,16,24,32,40,	8,64,1<<14,1<<22};
#else
static const int GC_SIZES[GC_PARTITIONS] = {4,8,12,16,20,	8,64,1<<14,1<<22};
#endif

#define INPAGE(ptr,page) ((void*)(ptr) > (void*)(page) && (unsigned char*)(ptr) < (unsigned char*)(page) + (page)->page_size)

#define GC_PROFILE		1
#define GC_DUMP_MEM		2
#define GC_NO_THREADS	4
#define GC_FORCE_MAJOR	8

static int gc_flags = 0;
static gc_pheader *gc_pages[GC_ALL_PAGES] = {NULL};
static int gc_free_blocks[GC_ALL_PAGES] = {0};
static gc_pheader *gc_free_pages[GC_ALL_PAGES] = {NULL};
static gc_pheader *gc_level1_null[1<<GC_LEVEL1_BITS] = {NULL};
static gc_pheader **hl_gc_page_map[1<<GC_LEVEL0_BITS] = {NULL};
static void (*gc_track_callback)(hl_type *,int,int,void*) = NULL;

static struct {
	int count;
	bool stopping_world;
	hl_thread_info **threads;
	hl_mutex *global_lock;
} gc_threads;

HL_THREAD_STATIC_VAR hl_thread_info *current_thread;

static struct {
	int64 total_requested;
	int64 total_allocated;
	int64 last_mark;
	int64 last_mark_allocs;
	int64 pages_total_memory;
	int64 allocation_count;
	int pages_count;
	int pages_allocated;
	int pages_blocks;
	int mark_bytes;
	int mark_time;
	int mark_count;
	int alloc_time; // only measured if gc_profile active
} gc_stats = {0};

static struct {
	int64 total_allocated;
	int64 allocation_count;
	int alloc_time;
} last_profile;

#ifdef HL_WIN
#	define TIMESTAMP() ((int)GetTickCount())
#else
#	define TIMESTAMP() 0
#endif

// -------------------------  ROOTS ----------------------------------------------------------

static void ***gc_roots = NULL;
static int gc_roots_count = 0;
static int gc_roots_max = 0;

HL_API hl_thread_info *hl_get_thread() {
	return current_thread;
}

static void gc_save_context(hl_thread_info *t ) {
	setjmp(t->gc_regs);
	t->stack_cur = &t;
}

#ifndef HL_THREADS
#	define gc_global_lock(_)
#else
static void gc_global_lock( bool lock ) {
	hl_thread_info *t = current_thread;
	bool mt = (gc_flags & GC_NO_THREADS) == 0;
	if( !t && gc_threads.count == 0 ) return;
	if( lock ) {
		if( !t )
			hl_fatal("Can't lock GC in unregistered thread");
		if( mt ) gc_save_context(t);
		t->gc_blocking++;
		if( mt ) hl_mutex_acquire(gc_threads.global_lock);
	} else {
		t->gc_blocking--;
		if( mt ) hl_mutex_release(gc_threads.global_lock);
	}
}
#endif

HL_PRIM void hl_gc_set_track( void *f ) {
	gc_track_callback = f;
}

HL_PRIM void hl_add_root( void *r ) {
	gc_global_lock(true);
	if( gc_roots_count == gc_roots_max ) {
		int nroots = gc_roots_max ? (gc_roots_max << 1) : 16;
		void ***roots = (void***)malloc(sizeof(void*)*nroots);
		memcpy(roots,gc_roots,sizeof(void*)*gc_roots_count);
		free(gc_roots);
		gc_roots = roots;
		gc_roots_max = nroots;
	}
	gc_roots[gc_roots_count++] = (void**)r;
	gc_global_lock(false);
}

HL_PRIM void hl_remove_root( void *v ) {
	int i;
	gc_global_lock(true);
	for(i=gc_roots_count-1;i>=0;i--)
		if( gc_roots[i] == (void**)v ) {
			gc_roots_count--;
			memmove(gc_roots + i, gc_roots + (i+1), (gc_roots_count - i) * sizeof(void*));
			break;
		}
	gc_global_lock(false);
}

HL_PRIM gc_pheader *hl_gc_get_page( void *v ) {
	gc_pheader *page = GC_GET_PAGE(v);
#	ifdef HL_64
	if( page && !INPAGE(v,page) )
		page = NULL;
#	endif
	return page;
}

// -------------------------  THREADS ----------------------------------------------------------

HL_API int hl_thread_id();

HL_API void hl_register_thread( void *stack_top ) {
	if( hl_get_thread() )
		hl_fatal("Thread already registered");

	hl_thread_info *t = (hl_thread_info*)malloc(sizeof(hl_thread_info));
	memset(t, 0, sizeof(hl_thread_info));
	t->thread_id = hl_thread_id();
	t->stack_top = stack_top;
	current_thread = t;
	hl_add_root(&t->exc_value);
	hl_add_root(&t->exc_handler);

	gc_global_lock(true);
	hl_thread_info **all = (hl_thread_info**)malloc(sizeof(void*) * (gc_threads.count + 1));
	memcpy(all,gc_threads.threads,sizeof(void*)*gc_threads.count);
	gc_threads.threads = all;
	all[gc_threads.count++] = t;
	gc_global_lock(false);
}

HL_API void hl_unregister_thread() {
	int i;
	hl_thread_info *t = hl_get_thread();
	if( !t )
		hl_fatal("Thread not registered");
	hl_remove_root(&t->exc_value);
	hl_remove_root(&t->exc_handler);
	gc_global_lock(true);
	for(i=0;i<gc_threads.count;i++)
		if( gc_threads.threads[i] == t ) {
			memmove(gc_threads.threads + i, gc_threads.threads + i + 1, sizeof(void*) * (gc_threads.count - i - 1));
			gc_threads.count--;
			break;
		}
	free(t);
	current_thread = NULL;
	// don't use gc_global_lock(false)
	hl_mutex_release(gc_threads.global_lock);
}

HL_API void *hl_gc_threads_info() {
	return &gc_threads;
}

static void gc_stop_world( bool b ) {
#	ifdef HL_THREADS
	if( b ) {
		int i;
		gc_threads.stopping_world = true;
		for(i=0;i<gc_threads.count;i++) {
			hl_thread_info *t = gc_threads.threads[i];
			while( t->gc_blocking == 0 ) {}; // spinwait
		}
	} else {
		// releasing global lock will release all threads
		gc_threads.stopping_world = false;
	}
#	else
	if( b ) gc_save_context(current_thread);
#	endif
}

// -------------------------  ALLOCATOR ----------------------------------------------------------

static void *gc_alloc_page_memory( int size );
static void gc_free_page_memory( void *ptr, int size );

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
		gc_pheader *p = gc_pages[i];
		gc_pheader *prev = NULL;
		while( p ) {
			gc_pheader *next = p->next_page;
			if( p->bmp && is_zero(p->bmp+(p->first_block>>3),((p->max_blocks+7)>>3) - (p->first_block>>3)) ) {
				int j;
				gc_stats.pages_count--;
				gc_stats.pages_blocks -= p->max_blocks;
				gc_stats.pages_total_memory -= p->page_size;
				gc_stats.mark_bytes -= (p->max_blocks + 7) >> 3;
				if( prev )
					prev->next_page = next;
				else
					gc_pages[i] = next;
				if( gc_free_pages[i] == p )
					gc_free_pages[i] = next;
				for(j=0;j<p->page_size>>GC_MASK_BITS;j++) {
					void *ptr = (unsigned char*)p + (j<<GC_MASK_BITS);
					GC_GET_PAGE(ptr) = NULL;
				}
				gc_free_page_memory(p,p->page_size);
			} else
				prev = p;
			p = next;
		}
	}
}

#ifdef GC_DEBUG
static int PAGE_ID = 0;
#endif

HL_API void hl_gc_dump_memory( const char *filename );
static void gc_major( void );

static void *gc_will_collide( void *p, int size ) {
#	ifdef HL_64
	int i;
	for(i=0;i<size>>GC_MASK_BITS;i++) {
		void *ptr = (unsigned char*)p + (i<<GC_MASK_BITS);
		if( GC_GET_PAGE(ptr) )
			return ptr;
	}
#	endif
	return NULL;
}

static gc_pheader *gc_alloc_new_page( int pid, int block, int size, int kind, bool varsize ) {
	int m, i;
	unsigned char *base;
	gc_pheader *p;
	int start_pos;
	int old_size = size;

	// increase size based on previously allocated pages
	if( block < 256 ) {
		int num_pages = 0;
		p = gc_pages[pid];
		while( p ) {
			num_pages++;
			p = p->next_page;
		}
		while( num_pages > 8 && (size<<1) / block <= GC_PAGE_SIZE ) {
			size <<= 1;
			num_pages /= 3;
		}
	}

retry:
	base = (unsigned char*)gc_alloc_page_memory(size);
	p = (gc_pheader*)base;
	if( !base ) {
		int pages = gc_stats.pages_allocated;
		gc_major();
		if( pages != gc_stats.pages_allocated ) {
			size = old_size;
			goto retry;
		}
		// big block : report stack trace - we should manage to handle it
		if( size >= (8 << 20) ) {
			gc_global_lock(false);
			hl_error("Failed to alloc %d KB",size>>10);
		}
		if( gc_flags & GC_DUMP_MEM ) hl_gc_dump_memory("hlmemory.dump");
		out_of_memory("pages");
	}

#	ifdef HL_64
	void *ptr = gc_will_collide(p,size);
	if( ptr ) {
#		ifdef HL_VCC
		printf("GC Page HASH collide %IX %IX\n",(int_val)GC_GET_PAGE(ptr),(int_val)ptr);
#		else
		printf("GC Page HASH collide %lX %lX\n",(int_val)GC_GET_PAGE(ptr),(int_val)ptr);
#		endif
		return gc_alloc_new_page(pid,block,size,kind,varsize);
	}
#endif

#	if defined(GC_DEBUG)
	memset(base,0xDD,size);
	p->page_id = PAGE_ID++;
#	else
	// prevent false positive to access invalid type
	if( kind == MEM_KIND_DYNAMIC ) memset(base, 0, size);
#	endif
	if( ((int_val)base) & ((1<<GC_MASK_BITS) - 1) )
		hl_fatal("Page memory is not correctly aligned");
	p->page_size = size;
	p->block_size = block;
	p->page_kind = kind;
	p->max_blocks = size / block;
	p->sizes = NULL;
	p->bmp = NULL;
	start_pos = sizeof(gc_pheader);
	if( p->max_blocks > GC_PAGE_SIZE )
		hl_fatal("Too many blocks for this page");
	if( varsize ) {
		p->sizes = base + start_pos;
		start_pos += p->max_blocks;
		MZERO(p->sizes,p->max_blocks);
	}
#	ifdef HL_TRACK_ALLOC
	p->alloc_hashes = (int*)malloc(sizeof(int) * p->max_blocks);
	MZERO(p->alloc_hashes,p->max_blocks * sizeof(int));
#	endif
	m = start_pos % block;
	if( m ) start_pos += block - m;
	p->first_block = start_pos / block;
	p->next_block = p->first_block;
	p->free_blocks = p->max_blocks - p->first_block;
	// update stats
	gc_stats.pages_count++;
	gc_stats.pages_allocated++;
	gc_stats.pages_blocks += p->max_blocks;
	gc_stats.pages_total_memory += size;
	gc_stats.mark_bytes += (p->max_blocks + 7) >> 3;

	// register page in page map
	p->next_page = gc_pages[pid];
	gc_pages[pid] = p;
	for(i=0;i<size>>GC_MASK_BITS;i++) {
		void *ptr = (unsigned char*)p + (i<<GC_MASK_BITS);
		if( GC_GET_LEVEL1(ptr) == gc_level1_null ) {
			gc_pheader **level = (gc_pheader**)malloc(sizeof(void*) * (1<<GC_LEVEL1_BITS));
			MZERO(level,sizeof(void*) * (1<<GC_LEVEL1_BITS));
			GC_GET_LEVEL1(ptr) = level;
		}
		GC_GET_PAGE(ptr) = p;
	}
	return p;
}

static void *gc_alloc_fixed( int part, int kind ) {
	int pid = (part << PAGE_KIND_BITS) | kind;
	gc_pheader *p = gc_free_pages[pid];
	unsigned char *ptr;
	while( p ) {
		if( p->bmp ) {
			int next = p->next_block;
			while( true ) {
				unsigned int fetch_bits = ((unsigned int*)p->bmp)[next >> 5];
				int ones = TRAILING_ONES(fetch_bits >> (next&31));
				next += ones;
				if( (next&31) == 0 && ones ) {
					if( next >= p->max_blocks ) {
						p->next_block = next;
						break;
					}
					continue;
				}
				p->next_block = next;
				if( next >= p->max_blocks )
					break;
				goto alloc_fixed;
			}
		} else if( p->next_block < p->max_blocks )
			break;
		p = p->next_page;
	}
	if( p == NULL )
		p = gc_alloc_new_page(pid, GC_SIZES[part], GC_PAGE_SIZE, kind, false);
alloc_fixed:
	ptr = (unsigned char*)p + p->next_block * p->block_size;
#	ifdef GC_DEBUG
	{
		int i;
		if( p->next_block < p->first_block || p->next_block >= p->max_blocks )
			hl_fatal("assert");
		if( p->bmp && (p->bmp[p->next_block>>3]&(1<<(p->next_block&7))) != 0 )
			hl_fatal("Alloc on marked bit");
		for(i=0;i<p->block_size;i++)
			if( ptr[i] != 0xDD )
				hl_fatal("assert");
	}
#	endif
#	ifdef HL_TRACK_ALLOC
	p->alloc_hashes[p->next_block] = hl_get_stack_hash();
#	endif
	p->next_block++;
	gc_stats.total_allocated += p->block_size;
	gc_free_pages[pid] = p;
	return ptr;
}

static void *gc_alloc_var( int part, int size, int kind ) {
	int pid = (part << PAGE_KIND_BITS) | kind;
	gc_pheader *p = gc_free_pages[pid];
	unsigned char *ptr;
	int nblocks = size >> GC_SBITS[part];
	int max_free = gc_free_blocks[pid];
loop:
	while( p ) {
		if( p->bmp ) {
			int next, avail = 0;
			if( p->free_blocks >= nblocks ) {
				p->next_block = p->first_block;
				p->free_blocks = 0;
			}
			next = p->next_block;
			if( next + nblocks > p->max_blocks )
				goto skip;
			while( true ) {
				int fid = next >> 5;
				unsigned int fetch_bits = ((unsigned int*)p->bmp)[fid];
				int bits;
resume:
				bits = TRAILING_ONES(fetch_bits >> (next&31));
				if( bits ) {
					if( avail > p->free_blocks ) p->free_blocks = avail;
					avail = 0;
					next += bits - 1;
#					ifdef GC_DEBUG
					if( p->sizes[next] == 0 ) hl_fatal("assert");
#					endif
					next += p->sizes[next];
					if( next + nblocks > p->max_blocks ) {
						p->next_block = next;
						p = p->next_page;
						goto loop;
					}
					if( (next>>5) != fid )
						continue;
					goto resume;
				}
				bits = TRAILING_ZEROES( (next & 31) ? (fetch_bits >> (next&31)) | (1<<(32-(next&31))) : fetch_bits );
				avail += bits;
				next += bits;
				if( next > p->max_blocks ) {
					avail -= next - p->max_blocks;
					next = p->max_blocks;
					if( avail < nblocks ) break;
				}
				if( avail >= nblocks ) {
					p->next_block = next - avail;
					goto alloc_var;
				}
				if( next & 31 ) goto resume;
			}
			if( avail > p->free_blocks ) p->free_blocks = avail;
			p->next_block = next;
		} else if( p->next_block + nblocks <= p->max_blocks )
			break;
skip:
		if( p->free_blocks > max_free )
			max_free = p->free_blocks;
		p = p->next_page;
		if( p == NULL && max_free >= nblocks ) {
			max_free = 0;
			p = gc_pages[pid];
		}
	}
	if( p == NULL ) {
		int psize = GC_PAGE_SIZE;
		while( psize < size + 1024 )
			psize <<= 1;
		p = gc_alloc_new_page(pid, GC_SIZES[part], psize, kind, true);
	}
alloc_var:
	ptr = (unsigned char*)p + p->next_block * p->block_size;
#	ifdef GC_DEBUG
	{
		int i;
		if( p->next_block < p->first_block || p->next_block + nblocks > p->max_blocks )
			hl_fatal("assert");
		for(i=0;i<size;i++)
			if( ptr[i] != 0xDD )
				hl_fatal("assert");
	}
#	endif
	if( p->bmp ) {
		int i;
		int bid = p->next_block;
		for(i=0;i<nblocks;i++) {
#			ifdef GC_DEBUG
			if( (p->bmp[bid>>3]&(1<<(bid&7))) != 0 ) hl_fatal("Alloc on marked block");
#			endif
			p->bmp[bid>>3] &= ~(1<<(bid&7));
			bid++;
		}
		bid = p->next_block;
		p->bmp[bid>>3] |= 1<<(bid&7);
	} else {
		p->free_blocks = p->max_blocks - (p->next_block + nblocks);
	}
#	ifdef HL_TRACK_ALLOC
	p->alloc_hashes[p->next_block] = hl_get_stack_hash();
#	endif
	if( nblocks > 1 ) MZERO(p->sizes + p->next_block, nblocks);
	p->sizes[p->next_block] = (unsigned char)nblocks;
	p->next_block += nblocks;
	gc_stats.total_allocated += size + 1;
	gc_free_pages[pid] = p;
	gc_free_blocks[pid] = max_free;
	return ptr;
}

static void *gc_alloc_gen( int size, int flags, int *allocated ) {
	int m = size & (GC_ALIGN - 1);
	int p;
	gc_stats.allocation_count++;
	gc_stats.total_requested += size;
	if( m ) size += GC_ALIGN - m;
	if( size <= 0 ) {
		*allocated = 0;
		return NULL;
	}
	if( size <= GC_SIZES[GC_FIXED_PARTS-1] && (flags & MEM_ALIGN_DOUBLE) == 0 && flags != MEM_KIND_FINALIZER ) {
		*allocated = size;
		return gc_alloc_fixed( (size >> GC_ALIGN_BITS) - 1, flags & PAGE_KIND_MASK);
	}
	for(p=GC_FIXED_PARTS;p<GC_PARTITIONS;p++) {
		int block = GC_SIZES[p];
		int query = size;
		int m = query & (block - 1);
		if( m ) query += block - m;
		if( query < block * 255 ) {
			void *ptr = gc_alloc_var(p, query, flags & PAGE_KIND_MASK);
			*allocated = query;
			return ptr;
		}
	}
	gc_global_lock(false);
	hl_error("Required memory allocation too big");
	return NULL;
}

static void gc_check_mark();

void *hl_gc_alloc_gen( hl_type *t, int size, int flags ) {
	void *ptr;
	int time = 0;
	int allocated = 0;
	gc_global_lock(true);
	gc_check_mark();
#	ifdef GC_MEMCHK
	size += HL_WSIZE;
#	endif
	if( gc_flags & GC_PROFILE ) time = TIMESTAMP();
	ptr = gc_alloc_gen(size, flags, &allocated);
	if( gc_flags & GC_PROFILE ) gc_stats.alloc_time += TIMESTAMP() - time;
#	ifdef GC_DEBUG
	memset(ptr,0xCD,allocated);
#	endif
	if( flags & MEM_ZERO )
		MZERO(ptr,allocated);
	else if( MEM_HAS_PTR(flags) && allocated != size )
		MZERO((char*)ptr+size,allocated-size); // erase possible pointers after data
#	ifdef GC_MEMCHK
	memset((char*)ptr+(allocated - HL_WSIZE),0xEE,HL_WSIZE);
#	endif
	gc_global_lock(false);
	if( gc_track_callback && (current_thread->exc_flags&HL_TRACK_DISABLE) == 0 )
		((void (*)(hl_type *,int,int,void*))gc_track_callback)(t,size,flags,ptr);
	return ptr;
}

// -------------------------  MARKING ----------------------------------------------------------

static float gc_mark_threshold = 0.2f;
static int mark_size = 0;
static unsigned char *mark_data = NULL;
static void **cur_mark_stack = NULL;
static void **mark_stack_end = NULL;
static int mark_stack_size = 0;

#define GC_PUSH_GEN(ptr,page,bid) \
	if( MEM_HAS_PTR((page)->page_kind) ) { \
		if( mark_stack == mark_stack_end ) mark_stack = hl_gc_mark_grow(mark_stack); \
		*mark_stack++ = ptr; \
		*mark_stack++ = ((unsigned char*)page) + bid; \
	}

HL_PRIM void **hl_gc_mark_grow( void **stack ) {
	int nsize = mark_stack_size ? (((mark_stack_size * 3) >> 1) & ~1) : 256;
	void **nstack = (void**)malloc(sizeof(void**) * nsize);
	void **base_stack = mark_stack_end - mark_stack_size;
	int avail = (int)(stack - base_stack);
	if( nstack == NULL ) {
		out_of_memory("markstack");
		return NULL;
	}
	memcpy(nstack, base_stack, avail * sizeof(void*));
	free(base_stack);
	mark_stack_size = nsize;
	mark_stack_end = nstack + nsize;
	cur_mark_stack = nstack + avail;
	if( avail == 0 ) {
		*cur_mark_stack++ = 0;
		*cur_mark_stack++ = 0;
	}
	return cur_mark_stack;
}

#define GC_PRECISE

static void gc_flush_mark() {
	register void **mark_stack = cur_mark_stack;
	while( true ) {
		unsigned char *page_bid = *--mark_stack;
		void **block = (void**)*--mark_stack;
		gc_pheader *page = (gc_pheader*)((int_val)page_bid & ~(GC_PAGE_SIZE - 1));
		int bid = ((int)(int_val)page_bid) & (GC_PAGE_SIZE - 1);
		unsigned int *mark_bits = NULL;
		int pos = 0, size, nwords;
#		ifdef GC_DEBUG
		vdynamic *ptr = (vdynamic*)block;
		ptr += 0; // prevent unreferenced warning
#		endif
		if( !block ) {
			mark_stack += 2;
			break;
		}
		size = page->sizes ? page->sizes[bid] * page->block_size : page->block_size;
		nwords = size / HL_WSIZE;
#		ifdef GC_PRECISE
		if( page->page_kind == MEM_KIND_DYNAMIC ) {
			hl_type *t = *(hl_type**)block;
#			ifdef GC_DEBUG
#				ifdef HL_64
				if( (int_val)t == 0xDDDDDDDDDDDDDDDD ) continue;
#				else
				if( (int_val)t == 0xDDDDDDDD ) continue;
#				endif
#			endif
			if( t && t->mark_bits && t->kind != HFUN ) {
				mark_bits = t->mark_bits;
				if( t->kind == HENUM ) {
					mark_bits += ((venum*)block)->index;
					block += 2;
					nwords -= 2;
				} else {
					block++;
					pos++;
				}
			}
		}
#		endif
		while( pos < nwords ) {
			void *p;
			if( mark_bits && (mark_bits[pos >> 5] & (1 << (pos&31))) == 0 ) {
				pos++;
				block++;
				continue;
			}
			p = *block++;
			pos++;
			page = GC_GET_PAGE(p);
			if( !page || ((((unsigned char*)p - (unsigned char*)page))%page->block_size) != 0 ) continue;
#			ifdef HL_64
			if( !INPAGE(p,page) ) continue;
#			endif
			bid = (int)((unsigned char*)p - (unsigned char*)page) / page->block_size;
			if( page->sizes ) {
				if( page->sizes[bid] == 0 ) continue;
			} else if( bid < page->first_block )
				continue;
			if( (page->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
				page->bmp[bid>>3] |= 1<<(bid&7);
				GC_PUSH_GEN(p,page,bid);
			}
		}
	}
	cur_mark_stack = mark_stack;
}

#ifdef GC_DEBUG
static void gc_clear_unmarked_mem() {
	int i;
	for(i=0;i<GC_ALL_PAGES;i++) {
		gc_pheader *p = gc_pages[i];
		while( p ) {
			int bid;
			for(bid=p->first_block;bid<p->max_blocks;bid++) {
				if( p->sizes && !p->sizes[bid] ) continue;
				int size = p->sizes ? p->sizes[bid] * p->block_size : p->block_size;
				unsigned char *ptr = (unsigned char*)p + bid * p->block_size;
				if( bid * p->block_size + size > p->page_size ) hl_fatal("invalid block size");
#				ifdef GC_MEMCHK
				int_val eob = *(int_val*)(ptr + size - HL_WSIZE);
#				ifdef HL_64
				if( eob != 0xEEEEEEEEEEEEEEEE && eob != 0xDDDDDDDDDDDDDDDD )
#				else
				if( eob != 0xEEEEEEEE && eob != 0xDDDDDDDD )
#				endif
					hl_fatal("Block written out of bounds");
#				endif
				if( (p->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
					memset(ptr,0xDD,size);
					if( p->sizes ) p->sizes[bid] = 0;
				}
			}
			p = p->next_page;
		}
	}
}
#endif

static void gc_call_finalizers(){
	int i;
	for(i=MEM_KIND_FINALIZER;i<GC_ALL_PAGES;i+=1<<PAGE_KIND_BITS) {
		gc_pheader *p = gc_pages[i];
		while( p ) {
			int bid;
			for(bid=p->first_block;bid<p->max_blocks;bid++) {
				int size = p->sizes[bid];
				if( !size ) continue;
				if( (p->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
					unsigned char *ptr = (unsigned char*)p + bid * p->block_size;
					void *finalizer = *(void**)ptr;
					p->sizes[bid] = 0;
					if( finalizer )
						((void(*)(void *))finalizer)(ptr);
#					ifdef GC_DEBUG
					memset(ptr,0xDD,size*p->block_size);
#					endif
				}
			}
			p = p->next_page;
		}
	}
}

static void gc_mark_stack( void *start, void *end ) {
	void **mark_stack = cur_mark_stack;
	void **stack_head = (void**)start;
	while( stack_head < (void**)end ) {
		void *p = *stack_head++;
		gc_pheader *page = GC_GET_PAGE(p);
		int bid;
		if( !page || (((unsigned char*)p - (unsigned char*)page)%page->block_size) != 0 ) continue;
#		ifdef HL_64
		if( !INPAGE(p,page) ) continue;
#		endif
		bid = (int)((unsigned char*)p - (unsigned char*)page) / page->block_size;
		if( page->sizes ) {
			if( page->sizes[bid] == 0 ) continue;
		} else if( bid < page->first_block )
			continue;
		if( (page->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
			page->bmp[bid>>3] |= 1<<(bid&7);
			GC_PUSH_GEN(p,page,bid);
		}
	}
	cur_mark_stack = mark_stack;
}

static void gc_mark() {
	void **mark_stack = cur_mark_stack;
	int mark_bytes = gc_stats.mark_bytes;
	int pid, i;
	unsigned char *mark_cur;
	// prepare mark bits
	if( mark_bytes > mark_size ) {
		gc_free_page_memory(mark_data, mark_size);
		if( mark_size == 0 ) mark_size = GC_PAGE_SIZE;
		while( mark_size < mark_bytes )
			mark_size <<= 1;
		mark_data = gc_alloc_page_memory(mark_size);
		if( mark_data == NULL ) out_of_memory("markbits");
	}
	mark_cur = mark_data;
	MZERO(mark_data,mark_bytes);
	for(pid=0;pid<GC_ALL_PAGES;pid++) {
		gc_pheader *p = gc_pages[pid];
		gc_free_pages[pid] = p;
		gc_free_blocks[pid] = 0;
		while( p ) {
			p->bmp = mark_cur;
			p->next_block = p->first_block;
			p->free_blocks = 0;
			mark_cur += (p->max_blocks + 7) >> 3;
			p = p->next_page;
		}
	}
	// push roots
	for(i=0;i<gc_roots_count;i++) {
		void *p = *gc_roots[i];
		gc_pheader *page;
		int bid;
		if( !p ) continue;
		page = GC_GET_PAGE(p);
		if( !page ) continue; // the value was set to a not gc allocated ptr
		// don't check if valid ptr : it's a manual added root, so should be valid
		bid = (int)((unsigned char*)p - (unsigned char*)page) / page->block_size;
		if( (page->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
			page->bmp[bid>>3] |= 1<<(bid&7);
			GC_PUSH_GEN(p,page,bid);
		}
	}

	// scan threads stacks & registers
	for(i=0;i<gc_threads.count;i++) {
		hl_thread_info *t = gc_threads.threads[i];
		cur_mark_stack = mark_stack;
		gc_mark_stack(t->stack_cur,t->stack_top);
		gc_mark_stack(&t->gc_regs,(void**)&t->gc_regs + (sizeof(jmp_buf) / sizeof(void*) - 1));
		mark_stack = cur_mark_stack;
	}

	cur_mark_stack = mark_stack;
	if( mark_stack ) gc_flush_mark();
	gc_call_finalizers();
#	ifdef GC_DEBUG
	gc_clear_unmarked_mem();
#	endif
	gc_flush_empty_pages();
}

static void gc_major() {
	int time = TIMESTAMP(), dt;
	gc_stats.last_mark = gc_stats.total_allocated;
	gc_stats.last_mark_allocs = gc_stats.allocation_count;
	gc_stop_world(true);
	gc_mark();
	gc_stop_world(false);
	dt = TIMESTAMP() - time;
	gc_stats.mark_count++;
	gc_stats.mark_time += dt;
	if( gc_flags & GC_PROFILE ) {
		printf("GC-PROFILE %d\n\tmark-time %.3g\n\talloc-time %.3g\n\ttotal-mark-time %.3g\n\ttotal-alloc-time %.3g\n\tallocated %d (%dKB)\n",
			gc_stats.mark_count,
			dt/1000.,
			(gc_stats.alloc_time - last_profile.alloc_time)/1000.,
			gc_stats.mark_time/1000.,
			gc_stats.alloc_time/1000.,
			(int)(gc_stats.allocation_count - last_profile.allocation_count),
			(int)((gc_stats.total_allocated - last_profile.total_allocated)>>10)
		);
		last_profile.allocation_count = gc_stats.allocation_count;
		last_profile.alloc_time = gc_stats.alloc_time;
		last_profile.total_allocated = gc_stats.total_allocated;
	}
}

HL_API void hl_gc_major() {
	gc_global_lock(true);
	gc_major();
	gc_global_lock(false);
}

HL_API bool hl_is_gc_ptr( void *ptr ) {
	gc_pheader *page = GC_GET_PAGE(ptr);
	int bid;
	if( !page ) return false;
	if( ((unsigned char*)ptr - (unsigned char*)page) % page->block_size != 0 ) return false;
	bid = (int)((unsigned char*)ptr - (unsigned char*)page) / page->block_size;
	if( bid < page->first_block || bid >= page->max_blocks ) return false;
	if( page->sizes && page->sizes[bid] == 0 ) return false;
	// not live (only available if we haven't allocate since then)
	if( page->bmp && page->next_block == page->first_block && (page->bmp[bid>>3]&(1<<(bid&7))) == 0 ) return false;
	return true;
}

static bool gc_is_active = true;

static void gc_check_mark() {
	int64 m = gc_stats.total_allocated - gc_stats.last_mark;
	int64 b = gc_stats.allocation_count - gc_stats.last_mark_allocs;
	if( (m > gc_stats.pages_total_memory * gc_mark_threshold || b > gc_stats.pages_blocks * gc_mark_threshold || (gc_flags & GC_FORCE_MAJOR)) && gc_is_active )
		gc_major();
}

static void hl_gc_init() {
	int i;
	for(i=0;i<1<<GC_LEVEL0_BITS;i++)
		hl_gc_page_map[i] = gc_level1_null;
	if( TRAILING_ONES(0x080003FF) != 10 || TRAILING_ONES(0) != 0 || TRAILING_ONES(0xFFFFFFFF) != 32 )
		hl_fatal("Invalid builtin tl1");
	if( TRAILING_ZEROES((unsigned)~0x080003FF) != 10 || TRAILING_ZEROES(0) != 32 || TRAILING_ZEROES(0xFFFFFFFF) != 0 )
		hl_fatal("Invalid builtin tl0");
#	ifndef HL_CONSOLE
	if( getenv("HL_GC_PROFILE") )
		gc_flags |= GC_PROFILE;
	if( getenv("HL_DUMP_MEMORY") )
		gc_flags |= GC_DUMP_MEM;
#	endif
	memset(&gc_threads,0,sizeof(gc_threads));
	gc_threads.global_lock = hl_mutex_alloc(false);
	hl_add_root(&gc_threads.global_lock);
}

// ---- UTILITIES ----------------------

HL_API bool hl_is_blocking() {
	hl_thread_info *t = current_thread;
	// when called from a non GC thread, tells if the main thread is blocking
	if( t == NULL ) {
		if( gc_threads.count == 0 )
			return false;
		t = gc_threads.threads[0];
	}
	return t->gc_blocking > 0;
}

HL_API void hl_blocking( bool b ) {
	hl_thread_info *t = current_thread;
	if( !t )
		return; // allow hl_blocking in non-GC threads
	if( b ) {
#		ifdef HL_THREADS
		if( t->gc_blocking == 0 )
			gc_save_context(t);
#		endif
		t->gc_blocking++;
	} else if( t->gc_blocking == 0 )
		hl_error("Unblocked thread");
	else {
		t->gc_blocking--;
		if( t->gc_blocking == 0 && gc_threads.stopping_world ) {
			gc_global_lock(true);
			gc_global_lock(false);
		}
	}
}

void hl_cache_free();
void hl_cache_init();

void hl_global_init() {
	hl_gc_init();
	hl_cache_init();
}

void hl_global_free() {
	hl_cache_free();
}

struct hl_alloc_block {
	int size;
	hl_alloc_block *next;
	unsigned char *p;
};

void hl_alloc_init( hl_alloc *a ) {
	a->cur = NULL;
}

void *hl_malloc( hl_alloc *a, int size ) {
	hl_alloc_block *b = a->cur;
	void *p;
	if( !size ) return NULL;
	size += hl_pad_size(size,&hlt_dyn);
	if( b == NULL || b->size <= size ) {
		int alloc = size < 4096-sizeof(hl_alloc_block) ? 4096-sizeof(hl_alloc_block) : size;
		b = (hl_alloc_block *)malloc(sizeof(hl_alloc_block) + alloc);
		if( b == NULL ) out_of_memory("malloc");
		b->p = ((unsigned char*)b) + sizeof(hl_alloc_block);
		b->size = alloc;
		b->next = a->cur;
		a->cur = b;
	}
	p = b->p;
	b->p += size;
	b->size -= size;
	return p;
}

void *hl_zalloc( hl_alloc *a, int size ) {
	void *p = hl_malloc(a,size);
	if( p ) MZERO(p,size);
	return p;
}

void hl_free( hl_alloc *a ) {
	hl_alloc_block *b = a->cur;
	int_val prev = 0;
	int size = 0;
	while( b ) {
		hl_alloc_block *n = b->next;
		size = (int)(b->p + b->size - ((unsigned char*)b));
		prev = (int_val)b;
		free(b);
		b = n;
	}
	// check if our allocator was not part of the last free block
	if( (int_val)a < prev || (int_val)a > prev+size )
		a->cur = NULL;
}

#ifdef HL_WIN
#	if defined(GC_DEBUG) && defined(HL_64)
#		define STATIC_ADDRESS
#	endif
#	ifdef STATIC_ADDRESS
	// force out of 32 bits addresses to check loss of precision
	static char *start_address = (char*)0x100000000;
#	else
	static void *start_address = NULL;
#	endif
#endif
HL_PRIM void *hl_alloc_executable_memory( int size ) {
#ifdef __APPLE__
#  	ifndef MAP_ANONYMOUS
#     		define MAP_ANONYMOUS MAP_ANON
#       endif
#endif
#if defined(HL_WIN)
	void *ptr = VirtualAlloc(start_address,size,MEM_RESERVE|MEM_COMMIT,PAGE_EXECUTE_READWRITE);
#	ifdef STATIC_ADDRESS
	start_address += size + ((-size) & (GC_PAGE_SIZE - 1));
#	endif
	return ptr;
#elif defined(HL_CONSOLE)
	return NULL;
#else
	void *p;
	p = mmap(NULL,size,PROT_READ|PROT_WRITE|PROT_EXEC,(MAP_PRIVATE|MAP_ANONYMOUS),-1,0);
	return p;
#endif
}

HL_PRIM void hl_free_executable_memory( void *c, int size ) {
#if defined(HL_WIN)
	VirtualFree(c,0,MEM_RELEASE);
#elif !defined(HL_CONSOLE)
	munmap(c, size);
#endif
}

#if defined(HL_CONSOLE)
void *sys_alloc_align( int size, int align );
void sys_free_align( void *ptr, int size );
#elif !defined(HL_WIN)
static void *base_addr = (void*)0x40000000;
#endif

static void *gc_alloc_page_memory( int size ) {
#if defined(HL_WIN)
	void *ptr = VirtualAlloc(start_address,size,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE);
#	ifdef STATIC_ADDRESS
	if( ptr == NULL && start_address ) {
		start_address = NULL;
		return gc_alloc_page_memory(size);
	}
	start_address += size + ((-size) & (GC_PAGE_SIZE - 1));
#	endif
	return ptr;
#elif defined(HL_CONSOLE)
	return sys_alloc_align(size, GC_PAGE_SIZE);
#else
	int i = 0;
	while( gc_will_collide(base_addr,size) ) {
		base_addr = (char*)base_addr + GC_PAGE_SIZE;
		i++;
		// most likely our hashing creates too many collisions
		if( i >= 1 << (GC_LEVEL0_BITS + GC_LEVEL1_BITS + 2) )
			return NULL;
	}
	void *ptr = mmap(base_addr,size,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
	if( ptr == (void*)-1 )
		return NULL;
	if( ((int_val)ptr) & (GC_PAGE_SIZE-1) ) {
		munmap(ptr,size);
		void *tmp;
		int tmp_size = (int)((int_val)ptr - (int_val)base_addr);
		if( tmp_size > 0 ) {
			base_addr = (void*)((((int_val)ptr) & ~(GC_PAGE_SIZE-1)) + GC_PAGE_SIZE);
			tmp = ptr;
		} else {
			base_addr = (void*)(((int_val)ptr) & ~(GC_PAGE_SIZE-1));
			tmp = NULL;
		}
		if( tmp ) tmp = mmap(tmp,tmp_size,PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
		ptr = gc_alloc_page_memory(size);
		if( tmp ) munmap(tmp,tmp_size);
		return ptr;
	}
	base_addr = (char*)ptr+size;
	return ptr;
#endif
}

static void gc_free_page_memory( void *ptr, int size ) {
#ifdef HL_WIN
	VirtualFree(ptr, 0, MEM_RELEASE);
#elif defined(HL_CONSOLE)
	sys_free_align(ptr,size);
#else
	munmap(ptr,size);
#endif
}

vdynamic *hl_alloc_dynamic( hl_type *t ) {
	vdynamic *d = (vdynamic*)hl_gc_alloc_gen(t, sizeof(vdynamic), (hl_is_ptr(t) ? MEM_KIND_DYNAMIC : MEM_KIND_NOPTR) | MEM_ZERO);
	d->t = t;
	return d;
}

#ifndef HL_64
#	define DYN_PAD	0,
#else
#	define DYN_PAD
#endif

static const vdynamic vdyn_true = { &hlt_bool, DYN_PAD {true} };
static const vdynamic vdyn_false = { &hlt_bool, DYN_PAD {false} };

vdynamic *hl_alloc_dynbool( bool b ) {
	return (vdynamic*)(b ? &vdyn_true : &vdyn_false);
}


vdynamic *hl_alloc_obj( hl_type *t ) {
	vobj *o;
	int size;
	int i;
	hl_runtime_obj *rt = t->obj->rt;
	if( rt == NULL || rt->methods == NULL ) rt = hl_get_obj_proto(t);
	size = rt->size;
	if( size & (HL_WSIZE-1) ) size += HL_WSIZE - (size & (HL_WSIZE-1));
	o = (vobj*)hl_gc_alloc_gen(t, size, (rt->hasPtr ? MEM_KIND_DYNAMIC : MEM_KIND_NOPTR) | MEM_ZERO);
	o->t = t;
	for(i=0;i<rt->nbindings;i++) {
		hl_runtime_binding *b = rt->bindings + i;
		*(void**)(((char*)o) + rt->fields_indexes[b->fid]) = b->closure ? hl_alloc_closure_ptr(b->closure,b->ptr,o) : b->ptr;
	}
	return (vdynamic*)o;
}

vdynobj *hl_alloc_dynobj() {
	vdynobj *o = (vdynobj*)hl_gc_alloc_gen(&hlt_dynobj,sizeof(vdynobj),MEM_KIND_DYNAMIC | MEM_ZERO);
	o->t = &hlt_dynobj;
	return o;
}

vvirtual *hl_alloc_virtual( hl_type *t ) {
	vvirtual *v = (vvirtual*)hl_gc_alloc(t, t->virt->dataSize + sizeof(vvirtual) + sizeof(void*) * t->virt->nfields);
	void **fields = (void**)(v + 1);
	char *vdata = (char*)(fields + t->virt->nfields);
	int i;
	v->t = t;
	v->value = NULL;
	v->next = NULL;
	for(i=0;i<t->virt->nfields;i++)
		fields[i] = (char*)v + t->virt->indexes[i];
	MZERO(vdata,t->virt->dataSize);
	return v;
}

HL_API void hl_gc_stats( double *total_allocated, double *allocation_count, double *current_memory ) {
	*total_allocated = (double)gc_stats.total_allocated;
	*allocation_count = (double)gc_stats.allocation_count;
	*current_memory = (double)gc_stats.pages_total_memory;
}

HL_API void hl_gc_enable( bool b ) {
	gc_is_active = b;
}

HL_API int hl_gc_get_flags() {
	return gc_flags;
}

HL_API void hl_gc_set_flags( int f ) {
	gc_flags = f;
}

HL_API void hl_gc_profile( bool b ) {
	if( b )
		gc_flags |= GC_PROFILE;
	else
		gc_flags &= GC_PROFILE;
}

static FILE *fdump;
static void fdump_i( int i ) {
	fwrite(&i,1,4,fdump);
}
static void fdump_p( void *p ) {
	fwrite(&p,1,sizeof(void*),fdump);
}
static void fdump_d( void *p, int size ) {
	fwrite(p,1,size,fdump);
}

static hl_types_dump gc_types_dump = NULL;
HL_API void hl_gc_set_dump_types( hl_types_dump tdump ) {
	gc_types_dump = tdump;
}

HL_API void hl_gc_dump_memory( const char *filename ) {
	int i;
	gc_global_lock(true);
	gc_stop_world(true);
	gc_mark();
	fdump = fopen(filename,"wb");
	// header
	fdump_d("HMD0",4);
	fdump_i(((sizeof(void*) == 8)?1:0) | ((sizeof(bool) == 4)?2:0));
	// pages
	fdump_i(GC_ALL_PAGES);
	for(i=0;i<GC_ALL_PAGES;i++) {
		gc_pheader *p = gc_pages[i];
		while( p != NULL ) {
			fdump_p(p);
			fdump_i(p->page_kind);
			fdump_i(p->page_size);
			fdump_i(p->block_size);
			fdump_i(p->first_block);
			fdump_i(p->max_blocks);
			fdump_i(p->next_block);
			fdump_d(p,p->page_size);
			fdump_i((p->bmp ? 1 :0) | (p->sizes?2:0));
			if( p->bmp ) fdump_d(p->bmp,(p->max_blocks + 7) >> 3);
			if( p->sizes ) fdump_d(p->sizes,p->max_blocks);
			p = p->next_page;
		}
		fdump_p(NULL);
	}
	// roots
	fdump_i(gc_roots_count);
	for(i=0;i<gc_roots_count;i++)
		fdump_p(*gc_roots[i]);
	// stacks
	fdump_i(gc_threads.count);
	for(i=0;i<gc_threads.count;i++) {
		hl_thread_info *t = gc_threads.threads[i];
		fdump_p(t->stack_top);
		int size = (int)((void**)t->stack_top - (void**)t->stack_cur);
		fdump_i(size);
		fdump_d(t->stack_cur,size*sizeof(void*));
	}
	// types
#	define fdump_t(t)	fdump_i(t.kind); fdump_p(&t);
	fdump_t(hlt_i32);
	fdump_t(hlt_f32);
	fdump_t(hlt_f64);
	fdump_t(hlt_dyn);
	fdump_t(hlt_array);
	fdump_t(hlt_bytes);
	fdump_t(hlt_dynobj);
	fdump_t(hlt_bool);
	fdump_i(-1);
	if( gc_types_dump ) gc_types_dump(fdump_d);
	fclose(fdump);
	fdump = NULL;
	gc_stop_world(false);
	gc_global_lock(false);
}

#ifdef HL_VCC
#	pragma optimize( "", off )
#endif
HL_API vdynamic *hl_debug_call( int mode, vdynamic *v ) {
	return NULL;
}
#ifdef HL_VCC
#	pragma optimize( "", on )
#endif

DEFINE_PRIM(_VOID, gc_major, _NO_ARG);
DEFINE_PRIM(_VOID, gc_enable, _BOOL);
DEFINE_PRIM(_VOID, gc_profile, _BOOL);
DEFINE_PRIM(_VOID, gc_stats, _REF(_F64) _REF(_F64) _REF(_F64));
DEFINE_PRIM(_VOID, gc_dump_memory, _BYTES);
DEFINE_PRIM(_I32, gc_get_flags, _NO_ARG);
DEFINE_PRIM(_VOID, gc_set_flags, _I32);
DEFINE_PRIM(_DYN, debug_call, _I32 _DYN);
DEFINE_PRIM(_VOID, blocking, _BOOL);

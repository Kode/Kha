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
#else
#	include <sys/types.h>
#	include <sys/mman.h>
#endif

#define MZERO(ptr,size)		memset(ptr,0,size)

// GC

#define GC_PAGE_BITS	16
#define GC_PAGE_SIZE	(1 << GC_PAGE_BITS)

#ifndef HL_64
#	define gc_hash(ptr)			((unsigned int)(ptr))
#	define GC_LEVEL0_BITS		8
#	define GC_LEVEL1_BITS		8
#else
#	define GC_LEVEL0_BITS		10
#	define GC_LEVEL1_BITS		10

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

#if defined(HL_NX)
#	define GC_INTERIOR_POINTERS
#endif

#define out_of_memory(reason)		hl_fatal("Out of Memory (" reason ")")

typedef struct _gc_pheader gc_pheader;

// page + private total reserved data per page
typedef void (*gc_page_iterator)( gc_pheader *, int );
// block-ptr + size
typedef void (*gc_block_iterator)( void *, int );

//#define GC_EXTERN_API

#ifdef GC_EXTERN_API
typedef void* gc_allocator_page_data;

// Initialize the allocator
void gc_allocator_init();

// Get the block size within the given page. The block validity has already been checked.
int gc_allocator_fast_block_size( gc_pheader *page, void *block );

// Get the block id within the given page, or -1 if it's an invalid ptr. The block is already checked within page bounds
int gc_allocator_get_block_id( gc_pheader *page, void *block );

// Same as get_block_id but handles interior pointers and modify the block value
int gc_allocator_get_block_id_interior( gc_pheader *page, void **block );

// Called before marking starts: should update each page "bmp" with mark_bits
void gc_allocator_before_mark( unsigned char *mark_bits );

// Called when marking ends: should call finalizers, sweep unused blocks and free empty pages
void gc_allocator_after_mark();

// Allocate a block with given size using the specified page kind. 
// Returns NULL if no block could be allocated
// Sets size to really allocated size (could be larger)
// Sets size to -1 if allocation refused (required size is invalid)
void *gc_allocator_alloc( int *size, int page_kind );

// returns the number of pages allocated and private data size (global)
void gc_get_stats( int *page_count, int *private_data);
void gc_iter_pages( gc_page_iterator i );
void gc_iter_live_blocks( gc_pheader *p, gc_block_iterator i );

#else
#	include "allocator.h"
#endif

struct _gc_pheader {
	// const
	unsigned char *base;
	unsigned char *bmp;
	int page_size;
	int page_kind;
	gc_allocator_page_data alloc;
	gc_pheader *next_page;
#ifdef GC_DEBUG
	int page_id;
#endif
};

#ifdef HL_64
#	define INPAGE(ptr,page) ((unsigned char*)(ptr) >= (page)->base && (unsigned char*)(ptr) < (page)->base + (page)->page_size)
#else
#	define INPAGE(ptr,page) true
#endif

#define GC_PROFILE		1
#define GC_DUMP_MEM		2
#define GC_NO_THREADS	4
#define GC_FORCE_MAJOR	8

static int gc_flags = 0;
static gc_pheader *gc_level1_null[1<<GC_LEVEL1_BITS] = {NULL};
static gc_pheader **hl_gc_page_map[1<<GC_LEVEL0_BITS] = {NULL};
static gc_pheader *gc_free_pheaders = NULL;

static gc_pheader *gc_alloc_page( int size, int kind, int block_count );
static void gc_free_page( gc_pheader *page, int block_count );

#ifndef GC_EXTERN_API
#include "allocator.c"
#endif

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

static void gc_save_context(hl_thread_info *t, void *prev_stack ) {
	void *stack_cur = &t;
	setjmp(t->gc_regs);
	// some compilers (such as clang) might push/pop some callee registers in call
	// to gc_save_context (or before) which might hold a gc value !
	// let's capture them immediately in extra per-thread data
	t->stack_cur = &prev_stack;
	int size = (int)((char*)prev_stack - (char*)stack_cur) / sizeof(void*);
	if( size > HL_MAX_EXTRA_STACK ) hl_fatal("GC_SAVE_CONTEXT");
	t->extra_stack_size = size;
	memcpy(t->extra_stack_data, prev_stack, size*sizeof(void*));
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
		if( mt ) gc_save_context(t,&lock);
		t->gc_blocking++;
		if( mt ) hl_mutex_acquire(gc_threads.global_lock);
	} else {
		t->gc_blocking--;
		if( mt ) hl_mutex_release(gc_threads.global_lock);
	}
}
#endif

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
	if( page && !INPAGE(v,page) )
		page = NULL;
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
	t->flags = HL_TRACK_MASK << HL_TREAD_TRACK_SHIFT;
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
	if( b ) gc_save_context(current_thread,&b);
#	endif
}

// -------------------------  ALLOCATOR ----------------------------------------------------------

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

static void gc_free_page_memory( void *ptr, int page_size );
static void *gc_alloc_page_memory( int size );

static gc_pheader *gc_alloc_page( int size, int kind, int block_count ) {
	unsigned char *base = (unsigned char*)gc_alloc_page_memory(size);
	if( !base ) {
		int pages = gc_stats.pages_allocated;
		gc_major();
		if( pages != gc_stats.pages_allocated )
			return gc_alloc_page(size, kind, block_count);
		// big block : report stack trace - we should manage to handle it
		if( size >= (8 << 20) ) {
			gc_global_lock(false);
			hl_error("Failed to alloc %d KB",size>>10);
		}
		if( gc_flags & GC_DUMP_MEM ) hl_gc_dump_memory("hlmemory.dump");
		out_of_memory("pages");
	}

	gc_pheader *p = gc_free_pheaders;
	if( !p ) {
		// alloc pages by chunks so we get good memory locality
		int i, count = 100;
		gc_pheader *head = (gc_pheader*)malloc(sizeof(gc_pheader)*count);
		p = head;
		for(i=1;i<count-1;i++) {
			p->next_page = head + i;
			p = p->next_page;
		}
		p->next_page = NULL;
		p = gc_free_pheaders = head;
	}
	gc_free_pheaders = p->next_page;
	memset(p,0,sizeof(gc_pheader));
	p->base = (unsigned char*)base;
	p->page_size = size;

#	ifdef HL_64
	void *ptr = gc_will_collide(p->base,size);
	if( ptr ) {
#		ifdef HL_VCC
		printf("GC Page HASH collide %IX %IX\n",(int_val)GC_GET_PAGE(ptr),(int_val)ptr);
#		else
		printf("GC Page HASH collide %lX %lX\n",(int_val)GC_GET_PAGE(ptr),(int_val)ptr);
#		endif
		return gc_alloc_page(size, kind, block_count);
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
	p->page_kind = kind;
	p->bmp = NULL;

	// update stats
	gc_stats.pages_count++;
	gc_stats.pages_allocated++;
	gc_stats.pages_blocks += block_count;
	gc_stats.pages_total_memory += size;
	gc_stats.mark_bytes += (block_count + 7) >> 3;

	// register page in page map
	int i;
	for(i=0;i<size>>GC_MASK_BITS;i++) {
		void *ptr = p->base + (i<<GC_MASK_BITS);
		if( GC_GET_LEVEL1(ptr) == gc_level1_null ) {
			gc_pheader **level = (gc_pheader**)malloc(sizeof(void*) * (1<<GC_LEVEL1_BITS));
			MZERO(level,sizeof(void*) * (1<<GC_LEVEL1_BITS));
			GC_GET_LEVEL1(ptr) = level;
		}
		GC_GET_PAGE(ptr) = p;
	}

	return p;
}

static void gc_free_page( gc_pheader *ph, int block_count ) {
	int i;
	for(i=0;i<ph->page_size>>GC_MASK_BITS;i++) {
		void *ptr = ph->base + (i<<GC_MASK_BITS);
		GC_GET_PAGE(ptr) = NULL;
	}
	gc_stats.pages_count--;
	gc_stats.pages_blocks -= block_count;
	gc_stats.pages_total_memory -= ph->page_size;
	gc_stats.mark_bytes -= (block_count + 7) >> 3;
	gc_free_page_memory(ph->base,ph->page_size);
	ph->next_page = gc_free_pheaders;
	gc_free_pheaders = ph;
}

static void gc_check_mark();

void *hl_gc_alloc_gen( hl_type *t, int size, int flags ) {
	void *ptr;
	int time = 0;
	int allocated = 0;
	if( size == 0 )
		return NULL;
	gc_global_lock(true);
	gc_check_mark();
#	ifdef GC_MEMCHK
	size += HL_WSIZE;
#	endif
	if( gc_flags & GC_PROFILE ) time = TIMESTAMP();
	{
		allocated = size;
		gc_stats.allocation_count++;
		gc_stats.total_requested += size;
#		ifdef GC_PRINT_ALLOCS_SIZES
#		define MAX_WORDS 16
		static int SIZE_CATEGORIES[MAX_WORDS] = {0};
		static int LARGE_BLOCKS[33] = {0};
		int wsize = (size + sizeof(void*) - 1) & ~(sizeof(void*)-1);
		if( wsize < MAX_WORDS * sizeof(void*) )
			SIZE_CATEGORIES[wsize/sizeof(void*)]++;
		else {
			int k = 0;
			while( size > (1<<k) && k < 20 ) {
				k++;
			}
			LARGE_BLOCKS[k]++;
		}
		if( (gc_stats.allocation_count & 0xFFFF) == 0 ) {
			int i;
			for(i=0;i<MAX_WORDS;i++)
				if( SIZE_CATEGORIES[i] )
					printf("%d=%.1f ",i*sizeof(void*),(SIZE_CATEGORIES[i] * 100.) / gc_stats.allocation_count);
			for(i=0;i<33;i++)
				if( LARGE_BLOCKS[i] )
					printf("%d=%.2f ",1<<i,(LARGE_BLOCKS[i] * 100.) / gc_stats.allocation_count);
			printf("%d\n",gc_stats.allocation_count);
		}
#		endif
		ptr = gc_allocator_alloc(&allocated,flags & PAGE_KIND_MASK);
		if( ptr == NULL ) {
			if( allocated < 0 ) {
				gc_global_lock(false);
				hl_error("Required memory allocation too big");
			}
			hl_fatal("TODO");
		}
		gc_stats.total_allocated += allocated;
	}
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
	hl_track_call(HL_TRACK_ALLOC, on_alloc(t,size,flags,ptr));
	return ptr;
}

// -------------------------  MARKING ----------------------------------------------------------

static float gc_mark_threshold = 0.2f;
static int mark_size = 0;
static unsigned char *mark_data = NULL;
static void **cur_mark_stack = NULL;
static void **mark_stack_end = NULL;
static int mark_stack_size = 0;

#define GC_PUSH_GEN(ptr,page) \
	if( MEM_HAS_PTR((page)->page_kind) ) { \
		if( mark_stack == mark_stack_end ) mark_stack = hl_gc_mark_grow(mark_stack); \
		*mark_stack++ = ptr; \
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
	if( avail == 0 )
		*cur_mark_stack++ = 0;
	return cur_mark_stack;
}

#define GC_PRECISE

static void gc_flush_mark() {
	register void **mark_stack = cur_mark_stack;
	while( true ) {
		void **block = (void**)*--mark_stack;
		gc_pheader *page = GC_GET_PAGE(block);
		unsigned int *mark_bits = NULL;
		int pos = 0, nwords;
#		ifdef GC_DEBUG
		vdynamic *ptr = (vdynamic*)block;
		ptr += 0; // prevent unreferenced warning
#		endif
		if( !block ) {
			mark_stack++;
			break;
		}
		int size = gc_allocator_fast_block_size(page, block);
#		ifdef GC_DEBUG
		if( size <= 0 ) hl_fatal("assert");
#		endif
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
			if( !page || !INPAGE(p,page) ) continue;
			int bid = gc_allocator_get_block_id(page,p);
			if( bid >= 0 && (page->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
				page->bmp[bid>>3] |= 1<<(bid&7);
				GC_PUSH_GEN(p,page);
			}
		}
	}
	cur_mark_stack = mark_stack;
}

static void gc_mark_stack( void *start, void *end ) {
	void **mark_stack = cur_mark_stack;
	void **stack_head = (void**)start;
	while( stack_head < (void**)end ) {
		void *p = *stack_head++;
		gc_pheader *page = GC_GET_PAGE(p);
		if( !page || !INPAGE(p,page) ) continue;
#		ifdef GC_INTERIOR_POINTERS
		int bid = gc_allocator_get_block_interior(page, &p);
#		else
		int bid = gc_allocator_get_block_id(page, p);
#		endif
		if( bid >= 0 && (page->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
			page->bmp[bid>>3] |= 1<<(bid&7);
			GC_PUSH_GEN(p,page);
		}
	}
	cur_mark_stack = mark_stack;
}

static void gc_mark() {
	void **mark_stack = cur_mark_stack;
	int mark_bytes = gc_stats.mark_bytes;
	int i;
	// prepare mark bits
	if( mark_bytes > mark_size ) {
		gc_free_page_memory(mark_data, mark_size);
		if( mark_size == 0 ) mark_size = GC_PAGE_SIZE;
		while( mark_size < mark_bytes )
			mark_size <<= 1;
		mark_data = gc_alloc_page_memory(mark_size);
		if( mark_data == NULL ) out_of_memory("markbits");
	}
	MZERO(mark_data,mark_bytes);
	gc_allocator_before_mark(mark_data);
	// push roots
	for(i=0;i<gc_roots_count;i++) {
		void *p = *gc_roots[i];
		gc_pheader *page;
		if( !p ) continue;
		page = GC_GET_PAGE(p);
		if( !page || !INPAGE(p,page) ) continue; // the value was set to a not gc allocated ptr
		int bid = gc_allocator_get_block_id(page, p);
		if( bid >= 0 && (page->bmp[bid>>3] & (1<<(bid&7))) == 0 ) {
			page->bmp[bid>>3] |= 1<<(bid&7);
			GC_PUSH_GEN(p,page);
		}
	}

	// scan threads stacks & registers
	for(i=0;i<gc_threads.count;i++) {
		hl_thread_info *t = gc_threads.threads[i];
		cur_mark_stack = mark_stack;
		gc_mark_stack(t->stack_cur,t->stack_top);
		gc_mark_stack(&t->gc_regs,(void**)&t->gc_regs + (sizeof(jmp_buf) / sizeof(void*) - 1));
		gc_mark_stack(&t->extra_stack_data,(void**)&t->extra_stack_data + t->extra_stack_size);
		mark_stack = cur_mark_stack;
	}

	cur_mark_stack = mark_stack;
	if( mark_stack ) gc_flush_mark();
	gc_allocator_after_mark();
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
	if( !page || !INPAGE(ptr,page) ) return false;
	int bid = gc_allocator_get_block_id(page, ptr);
	if( bid < 0 ) return false;
	//if( page->bmp && page->next_block == page->first_block && (page->bmp[bid>>3]&(1<<(bid&7))) == 0 ) return false;
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
	gc_allocator_init();
#	ifndef HL_CONSOLE
	if( getenv("HL_GC_PROFILE") )
		gc_flags |= GC_PROFILE;
	if( getenv("HL_DUMP_MEMORY") )
		gc_flags |= GC_DUMP_MEM;
#	endif
	gc_stats.mark_bytes = 4; // prevent reading out of bmp
	memset(&gc_threads,0,sizeof(gc_threads));
	gc_threads.global_lock = hl_mutex_alloc(false);
#	ifdef HL_THREADS
	hl_add_root(&gc_threads.global_lock);
#	endif
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
			gc_save_context(t,&b);
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

HL_PRIM void *hl_alloc_executable_memory( int size ) {
#ifdef __APPLE__
#  	ifndef MAP_ANONYMOUS
#     		define MAP_ANONYMOUS MAP_ANON
#       endif
#endif
#if defined(HL_WIN) && defined(HL_64)
	static char *jit_address = (char*)0x000076CA9F000000;
	void *ptr;
retry_jit_alloc:
	ptr = VirtualAlloc(jit_address,size,MEM_RESERVE|MEM_COMMIT,PAGE_EXECUTE_READWRITE);
	if( !ptr ) {
		jit_address = (char*)(((int_val)jit_address)>>1); // fix for Win7 - will eventually reach NULL
		goto retry_jit_alloc;
	}
	jit_address += size + ((-size) & (GC_PAGE_SIZE - 1));
	return ptr;
#elif defined(HL_WIN)
	void *ptr = VirtualAlloc(NULL,size,MEM_RESERVE|MEM_COMMIT,PAGE_EXECUTE_READWRITE);
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
#	if defined(GC_DEBUG) && defined(HL_64)
#		define STATIC_ADDRESS
#	endif
#	ifdef STATIC_ADDRESS
	// force out of 32 bits addresses to check loss of precision
	static char *start_address = (char*)0x100000000;
#	else
	static void *start_address = NULL;
#	endif
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
	if( t->kind == HSTRUCT ) {
		o = (vobj*)hl_gc_alloc_gen(t, size, (rt->hasPtr ? MEM_KIND_RAW : MEM_KIND_NOPTR) | MEM_ZERO);
	} else {
		o = (vobj*)hl_gc_alloc_gen(t, size, (rt->hasPtr ? MEM_KIND_DYNAMIC : MEM_KIND_NOPTR) | MEM_ZERO);
		o->t = t;
	}
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

static void gc_dump_block( void *block, int size ) {
	fdump_p(block);
	fdump_i(size);
}

static void gc_dump_block_ptr( void *block, int size ) {
	fdump_p(block);
	fdump_i(size);
	if( size >= sizeof(void*) ) fdump_p(*(void**)block);
}

static void gc_dump_page( gc_pheader *p, int private_data ) {
	fdump_p(p->base);
	fdump_i(p->page_kind);
	fdump_i(p->page_size);
	fdump_i(private_data);
	if( p->page_kind & MEM_KIND_NOPTR ) {
		gc_iter_live_blocks(p, gc_dump_block_ptr); // only dump type
		fdump_p(NULL);
	} else {
		gc_iter_live_blocks(p,gc_dump_block);
		fdump_p(NULL);
		fdump_d(p->base, p->page_size);
	}
}

HL_API void hl_gc_dump_memory( const char *filename ) {
	int i;
	gc_global_lock(true);
	gc_stop_world(true);
	gc_mark();
	fdump = fopen(filename,"wb");

	// header
	fdump_d("HMD1",4);
	fdump_i(((sizeof(void*) == 8)?1:0) | ((sizeof(bool) == 4)?2:0));

	// pages
	int page_count, private_data;
	gc_get_stats(&page_count, &private_data);

	// all mallocs
	private_data += sizeof(gc_pheader) * page_count;
	private_data += sizeof(void*) * gc_roots_max;
	private_data += gc_threads.count * (sizeof(void*) + sizeof(hl_thread_info));
	for(i=0;i<1<<GC_LEVEL0_BITS;i++)
		if( hl_gc_page_map[i] != gc_level1_null )
			private_data += sizeof(void*) * (1<<GC_LEVEL1_BITS);

	fdump_i(private_data);
	fdump_i(mark_stack_size); // keep separate
	fdump_i(page_count);
	gc_iter_pages(gc_dump_page);

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

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

void hl_global_init() {
}

void hl_cache_free();

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
	if( b == NULL || b->size <= size ) {
		int alloc = size < 4096-sizeof(hl_alloc_block) ? 4096-sizeof(hl_alloc_block) : size;
		b = (hl_alloc_block *)malloc(sizeof(hl_alloc_block) + alloc);
		if( b == NULL ) {
			printf("Out of memory");
			exit(99);
		}
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
	if( p ) memset(p,0,size);
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

void *hl_alloc_executable_memory( int size ) {
#ifdef HL_WIN
	return VirtualAlloc(NULL,size,MEM_COMMIT,PAGE_EXECUTE_READWRITE);
#else
	void *p;
	p = mmap(NULL,size,PROT_READ|PROT_WRITE|PROT_EXEC,(MAP_PRIVATE|MAP_ANON),-1,0);
	return p;
#endif
}

void hl_free_executable_memory( void *c, int size ) {
#ifdef HL_WIN
	VirtualFree(c,0,MEM_RELEASE);
#else
	munmap(c, size);
#endif
}

void *hl_gc_alloc( int size ) {
	return malloc(size);
}

void *hl_gc_alloc_noptr( int size ) {
	return (char*)malloc(size);
}

void *hl_gc_alloc_finalizer( int size ) {
	return malloc(size);
}

vdynamic *hl_alloc_dynamic( hl_type *t ) {
	vdynamic *d = (vdynamic*) ((t->kind == HENUM || t->kind == HABSTRACT) ? hl_gc_alloc(sizeof(vdynamic)) : hl_gc_alloc_noptr(sizeof(vdynamic)));
	d->t = t;
	d->v.ptr = NULL;
	return d;
}

vdynamic *hl_alloc_obj( hl_type *t ) {
	vobj *o;
	int size;
	hl_runtime_obj *rt = t->obj->rt;
	if( rt == NULL || rt->methods == NULL ) rt = hl_get_obj_proto(t);
	size = rt->size;
	if( size & (HL_WSIZE-1) ) size += HL_WSIZE - (size & (HL_WSIZE-1));
	o = (vobj*)hl_gc_alloc(size);
	memset(o,0,size);
	o->t = t;
	return (vdynamic*)o;
}

vdynobj *hl_alloc_dynobj() {
	vdynobj *o = (vdynobj*)hl_gc_alloc(sizeof(vdynobj));
	o->dproto = (vdynobj_proto*)&hlt_dynobj;
	o->nfields = 0;
	o->dataSize = 0;
	o->fields_data = NULL;
	o->virtuals = NULL;
	return o;
}

vvirtual *hl_alloc_virtual( hl_type *t ) {
	vvirtual *v = (vvirtual*)hl_gc_alloc(t->virt->dataSize + sizeof(vvirtual) + sizeof(void*) * t->virt->nfields);
	void **fields = (void**)(v + 1);
	char *vdata = (char*)(fields + t->virt->nfields);
	int i;
	v->t = t;
	v->value = NULL;
	v->next = NULL;
	for(i=0;i<t->virt->nfields;i++)
		fields[i] = (char*)v + t->virt->indexes[i];
	memset(vdata,0,t->virt->dataSize);
	return v;
}
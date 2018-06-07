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

HL_PRIM varray *hl_alloc_array( hl_type *at, int size ) {
	int esize = hl_type_size(at);
	varray *a;
	if( size < 0 ) hl_error("Invalid array size");
	a = (varray*)hl_gc_alloc_gen(&hlt_array, sizeof(varray) + esize*size, (hl_is_ptr(at) ? MEM_KIND_DYNAMIC : MEM_KIND_NOPTR) | MEM_ZERO);
	a->t = &hlt_array;
	a->at = at;
	a->size = size;
	return a;
}

HL_PRIM void hl_array_blit( varray *dst, int dpos, varray *src, int spos, int len ) {
	int size = hl_type_size(dst->at); 
	memmove( hl_aptr(dst,vbyte) + dpos * size, hl_aptr(src,vbyte) + spos * size, len * size); 
}

HL_PRIM hl_type *hl_array_type( varray *a ) {
	return a->at;
}

DEFINE_PRIM(_ARR,alloc_array,_TYPE _I32);
DEFINE_PRIM(_VOID,array_blit,_ARR _I32 _ARR _I32 _I32);
DEFINE_PRIM(_TYPE,array_type,_ARR);

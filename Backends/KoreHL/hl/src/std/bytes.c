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

HL_PRIM vbyte *hl_alloc_bytes( int size ) {
	return (vbyte*)hl_gc_alloc_noptr(size);
}

HL_PRIM vbyte *hl_copy_bytes( const vbyte *ptr, int size ) {
	vbyte *b = hl_alloc_bytes(size);
	memcpy(b,ptr,size);
	return b;
}

HL_PRIM void hl_bytes_blit( char *dst, int dpos, char *src, int spos, int len ) {
	memmove(dst + dpos,src+spos,len);
}

HL_PRIM int hl_bytes_compare( vbyte *a, int apos, vbyte *b, int bpos, int len ) {
	return memcmp(a+apos,b+bpos,len);
}

typedef unsigned char byte;
static void *
memfind_rb (const void  *in_block,      /*  Block containing data            */
            size_t       block_size,    /*  Size of block in bytes           */
            const void  *in_pattern,    /*  Pattern to search for            */
            size_t       pattern_size,  /*  Size of pattern block            */
            size_t      *shift,         /*  Shift table (search buffer)      */
            bool        *repeat_find)   /*  TRUE: search buffer already init */
{
    size_t
        byte_nbr,                       /*  Distance through block           */
        match_size;                     /*  Size of matched part             */
    const byte
        *match_base = NULL,             /*  Base of match of pattern         */
        *match_ptr  = NULL,             /*  Point within current match       */
        *limit      = NULL;             /*  Last potiental match point       */
    const byte
        *block   = (byte *) in_block,   /*  Concrete pointer to block data   */
        *pattern = (byte *) in_pattern; /*  Concrete pointer to search value */

    if (block == NULL || pattern == NULL || shift == NULL)
        return (NULL);

    /*  Pattern must be smaller or equal in size to string                   */
    if (block_size < pattern_size)
        return (NULL);                  /*  Otherwise it's not found         */

    if (pattern_size == 0)              /*  Empty patterns match at start    */
        return ((void *)block);

    /*  Build the shift table unless we're continuing a previous search      */

    /*  The shift table determines how far to shift before trying to match   */
    /*  again, if a match at this point fails.  If the byte after where the  */
    /*  end of our pattern falls is not in our pattern, then we start to     */
    /*  match again after that byte; otherwise we line up the last occurence */
    /*  of that byte in our pattern under that byte, and try match again.    */

    if (!repeat_find || !*repeat_find)
      {
        for (byte_nbr = 0; byte_nbr < 256; byte_nbr++)
            shift [byte_nbr] = pattern_size + 1;
        for (byte_nbr = 0; byte_nbr < pattern_size; byte_nbr++)
            shift [(byte) pattern [byte_nbr]] = pattern_size - byte_nbr;

        if (repeat_find)
            *repeat_find = true;
      }

    /*  Search for the block, each time jumping up by the amount             */
    /*  computed in the shift table                                          */

    limit = block + (block_size - pattern_size + 1);

    for (match_base = block;
         match_base < limit;
         match_base += shift [*(match_base + pattern_size)])
      {
        match_ptr  = match_base;
        match_size = 0;

        /*  Compare pattern until it all matches, or we find a difference    */
        while (*match_ptr++ == pattern [match_size++])
          {
            /*  If we found a match, return the start address                */
            if (match_size >= pattern_size)
              return ((void*)(match_base));

          }
      }
    return NULL;
}

HL_PRIM int hl_bytes_find( vbyte *where, int pos, int len, vbyte *which, int wpos, int wlen ) {
	size_t searchbuf [256];
	bool repeat_find = false;
	vbyte *found = (vbyte*)memfind_rb(where + pos,len,which+wpos,wlen,searchbuf,&repeat_find);
	if( found == NULL ) return -1;
	return (int)(size_t)(found - where);
}

HL_PRIM void hl_bytes_fill( vbyte *bytes, int pos, int len, int value ) {
	memset(bytes+pos,value,len);
}


static int ms_gcd( int m, int n ) {
 	while( n != 0 ) {
		int t = m % n;
		m=n; n=t;
	}
 	return m;
}

#define TSORT int
#define TID(t)	t##_i32
#include "sort.h"
#define TSORT double
#define TID(t)	t##_f64
#include "sort.h"

HL_PRIM void hl_bsort_i32( vbyte *bytes, int pos, int len, vclosure *cmp ) {
	m_sort_i32 m;
	m.arr = (int*)(bytes + pos);
	m.c = cmp;
	merge_sort_rec_i32(&m,0,len);
}

HL_PRIM void hl_bsort_f64( vbyte *bytes, int pos, int len, vclosure *cmp ) {
	m_sort_f64 m;
	m.arr = (double*)(bytes + pos);
	m.c = cmp;
	merge_sort_rec_f64(&m,0,len);
}

HL_PRIM double hl_parse_float( vbyte *bytes, int pos, int len ) {
	uchar *str = (uchar*)(bytes+pos);
	uchar *end = NULL;
	double d = utod(str,&end);
	if( end == str )
		return hl_nan();
	return d;
}

HL_PRIM vdynamic *hl_parse_int( vbyte *bytes, int pos, int len ) {
	uchar *c = (uchar*)(bytes + pos), *end = NULL;
	int h;
	if( len >= 2 && c[0] == '0' && (c[1] == 'x' || c[1] == 'X') ) {
		h = 0;
		c += 2;
		while( *c ) {
			uchar k = *c++;
			if( k >= '0' && k <= '9' )
				h = (h << 4) | (k - '0');
			else if( k >= 'A' && k <= 'F' )
				h = (h << 4) | ((k - 'A') + 10);
			else if( k >= 'a' && k <= 'f' )
				h = (h << 4) | ((k - 'a') + 10);
			else
				return NULL;
		}
		return hl_make_dyn(&h,&hlt_i32);
	}
	h = utoi(c,&end);
	return c == end ? NULL : hl_make_dyn(&h,&hlt_i32);
}

// pointer manipulation

HL_PRIM vbyte *hl_bytes_offset( vbyte *src, int offset ) {
	return src + offset;
}

HL_PRIM int hl_bytes_subtract( vbyte *a, vbyte *b ) {
	return (int)(a - b);
}

HL_PRIM int hl_bytes_address( vbyte *a, int *high ) {
#	ifdef HL_64
	*high = (int)(((uint64)a)>>32);
#	else
	*high = 0;
#	endif
	return (int)(int_val)a;
}

HL_PRIM vbyte *hl_bytes_from_address( int low, int high ) {
#	ifdef HL_64
	// MSVC does overflow on <<32 even on uint64...
	struct { int low; int high; } i64;
	i64.low = low;
	i64.high = high;
	return *(vbyte**)&i64;
#	else
	return (vbyte*)low;
#	endif
}

HL_PRIM int hl_string_compare( vbyte *a, vbyte *b, int len ) {
	return memcmp(a,b,len * sizeof(uchar));
}

DEFINE_PRIM(_BYTES,alloc_bytes,_I32);
DEFINE_PRIM(_VOID,bytes_blit,_BYTES _I32 _BYTES _I32 _I32);
DEFINE_PRIM(_I32,bytes_compare,_BYTES _I32 _BYTES _I32 _I32);
DEFINE_PRIM(_I32,string_compare,_BYTES _BYTES _I32);
DEFINE_PRIM(_I32,bytes_find,_BYTES _I32 _I32 _BYTES _I32 _I32);
DEFINE_PRIM(_VOID,bytes_fill,_BYTES _I32 _I32 _I32);
DEFINE_PRIM(_F64, parse_float,_BYTES _I32 _I32);
DEFINE_PRIM(_NULL(_I32), parse_int, _BYTES _I32 _I32);
DEFINE_PRIM(_VOID,bsort_i32,_BYTES _I32 _I32 _FUN(_I32,_I32 _I32));
DEFINE_PRIM(_VOID,bsort_f64,_BYTES _I32 _I32 _FUN(_I32,_F64 _F64));
DEFINE_PRIM(_BYTES,bytes_offset, _BYTES _I32);
DEFINE_PRIM(_I32,bytes_subtract, _BYTES _BYTES);
DEFINE_PRIM(_I32,bytes_address, _BYTES _REF(_I32));
DEFINE_PRIM(_BYTES,bytes_from_address, _I32 _I32);

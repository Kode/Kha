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

#define MAX_ARGS	16

static void *hl_callback_entry = NULL;

void hl_callback_init( void *e ) {
	hl_callback_entry = e;
}

void *hl_callback( void *f, int nargs, vdynamic **args ) {
	union {
		unsigned char b[MAX_ARGS * HL_WSIZE];
		double d[MAX_ARGS];
		int i[MAX_ARGS];
		int_val i64[MAX_ARGS];
	} stack;
	/*
		Same as jit(prepare_call_args) but writes values to the stack var
	*/
	int i, size = 0, pad = 0, pos = 0;
	for(i=0;i<nargs;i++) {
		vdynamic *d = args[i];
		hl_type *dt = d->t;
		size += hl_pad_size(size,dt);
		size += hl_type_size(dt);
	}
	if( size & 15 )
		pad = 16 - (size&15);
	size = pos = pad;
	for(i=0;i<nargs;i++) {
		// RTL
		vdynamic *d = args[i];
		hl_type *dt = d->t;
		int pad;
		int tsize = hl_type_size(dt);
		size += tsize;
		pad = hl_pad_size(size,dt);
		if( pad ) {
			pos += pad;
			size += pad;
		}
		switch( tsize ) {
		case 0:
			continue;
		case 1:
			stack.b[pos] = d->v.b;
			break;
		case 4:
			stack.i[pos>>2] = (IS_64 && dt->kind == HI32) ? d->v.i : (int)(int_val)d;
			break;
		case 8:
			if( !IS_64 || dt->kind == HF64 ) 
				stack.d[pos>>3] = d->v.d;
			else
				stack.i64[pos>>3] = (int_val)d;
			break;
		default:
			hl_error("Invalid callback arg");
		}
		pos += tsize;
	}
	return ((void *(*)(void *, void *, int))hl_callback_entry)(f, &stack, (IS_64?pos>>3:pos>>2));
}

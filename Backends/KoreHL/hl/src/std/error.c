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
#include <hlc.h>
#include <stdarg.h>
#include <string.h>

hl_trap_ctx *hl_current_trap = NULL;
vdynamic *hl_current_exc = NULL;

void *hl_fatal_error( const char *msg, const char *file, int line ) {
	printf("%s(%d) : FATAL ERROR : %s\n",file,line,msg);
#ifdef _DEBUG
	*(int*)NULL = 0;
#else
	exit(0);
#endif
	return NULL;
}

void hl_throw( vdynamic *v ) {
	hl_trap_ctx *t = hl_current_trap;
	hl_current_exc = v;
	hl_current_trap = t->prev;
#ifdef _DEBUG
	if( hl_current_trap == NULL ) *(int*)NULL = 0; // Uncaught exception
#endif
	longjmp(t->buf,1);
}

void hl_rethrow( vdynamic *v ) {
	hl_throw(v);
}

void hl_error_msg( const uchar *fmt, ... ) {
	uchar buf[256];
	vdynamic *d;
	int len;
	va_list args;
	va_start(args, fmt);
	len = uvsprintf(buf,fmt,args);
	va_end(args);
	d = hl_alloc_dynamic(&hlt_bytes);
	d->v.ptr = hl_copy_bytes((vbyte*)buf,(len + 1) << 1);
	hl_throw(d);
}

void hl_fatal_fmt(const char *fmt, ...) {
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsprintf(buf,fmt, args);
	va_end(args);
	hl_fatal(buf);
}

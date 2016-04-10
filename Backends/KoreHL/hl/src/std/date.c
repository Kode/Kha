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
#include <time.h>

#ifdef HL_WIN

static struct tm *localtime_r( time_t *t, struct tm *r ) {
	struct tm *r2 = localtime(t);
	if( r2 == NULL ) return NULL;
	*r = *r2;
	return r;
}

static struct tm *gmtime_r( time_t *t, struct tm *r ) {
	struct tm *r2 = gmtime(t);
	if( r2 == NULL ) return NULL;
	*r = *r2;
	return r;
}

#endif

HL_PRIM int hl_date_now() {
	return (int)time(NULL);
}

HL_PRIM vbyte *hl_date_to_string( int date, int *len ) {
	char buf[127];
	struct tm t;
	time_t d = (time_t)date;
	int size;
	uchar *out;
	if( !localtime_r(&d,&t) )
		hl_error("invalid date");
	size = (int)strftime(buf,127,"%Y-%m-%d %H:%M:%S",&t);
	out = (uchar*)hl_gc_alloc_noptr((size + 1) << 1);
	strtou(out,size,buf);
	out[size] = 0;
	*len = size;
	return (vbyte*)out;
}

HL_PRIM double hl_date_get_time( int date ) {
	return date * 1000.;
}

HL_PRIM int hl_date_from_time( double time ) {
	return (int)(time / 1000.);
}

HL_PRIM int hl_date_from_string( vbyte *b ) {
	uchar *str = (uchar*)b;
	hl_fatal("TODO");
	return *str;
}

HL_PRIM int hl_date_new( int y, int mo, int d, int h, int m, int s ) {
	struct tm t;
	memset(&t,0,sizeof(struct tm));
	t.tm_year = y - 1900;
	t.tm_mon = mo;
	t.tm_mday = d;
	t.tm_hour = h;
	t.tm_min = m;
	t.tm_sec = s;
	t.tm_isdst = -1;
	return (int)mktime(&t);
}

HL_PRIM void hl_date_get_inf( int date, int *y, int *mo, int *day, int *h, int *m, int *s, int *wday ) {
	struct tm t;
	time_t d = (time_t)date;
	if( !localtime_r(&d,&t) )
		hl_error("invalid date");
	if( y ) *y = t.tm_year + 1900;
	if( mo ) *mo = t.tm_mon;
	if( day ) *day = t.tm_mday;
	if( h ) *h = t.tm_hour;
	if( m ) *m = t.tm_min;
	if( s ) *s = t.tm_sec;
	if( wday ) *wday = t.tm_wday;
}

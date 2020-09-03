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

#ifdef HL_CONSOLE
#	include <posix/posix.h>
#else
#	include <time.h>
#endif

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
	time_t d = (time_t)(unsigned)date;
	int size;
	uchar *out;
	if( !localtime_r(&d,&t) )
		hl_error("Invalid date");
	size = (int)strftime(buf,127,"%Y-%m-%d %H:%M:%S",&t);
	out = (uchar*)hl_gc_alloc_noptr((size + 1) << 1);
	hl_from_utf8(out,size,buf);
	*len = size;
	return (vbyte*)out;
}

HL_PRIM double hl_date_get_time( int date ) {
	return ((unsigned)date) * 1000.;
}

HL_PRIM int hl_date_from_time( double time ) {
	return (int)(unsigned int)(time / 1000.);
}

HL_PRIM int hl_date_from_string( vbyte *b, int len ) {
	struct tm t;
	int o = 0;
	const char *str = hl_to_utf8((uchar*)b);
	bool recal = true;
	memset(&t,0,sizeof(struct tm));
	switch( strlen(str) ) {
	case 19:
		sscanf(str,"%4d-%2d-%2d %2d:%2d:%2d",&t.tm_year,&t.tm_mon,&t.tm_mday,&t.tm_hour,&t.tm_min,&t.tm_sec);
		t.tm_isdst = -1;
		break;
	case 8:
		sscanf(str,"%2d:%2d:%2d",&t.tm_hour,&t.tm_min,&t.tm_sec);
		o = t.tm_sec + t.tm_min * 60 + t.tm_hour * 60 * 60;
		recal = false;
		break;
	case 10:
		sscanf(str,"%4d-%2d-%2d",&t.tm_year,&t.tm_mon,&t.tm_mday);
		t.tm_isdst = -1;
		break;
	default:
		hl_error("Invalid date format");
		break;
	}
	if( recal ) {
		t.tm_year -= 1900;
		t.tm_mon--;
		o = (int)mktime(&t);
	}
	return o;
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
	time_t d = (time_t)(unsigned)date;
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

HL_PRIM void hl_date_get_utc_inf( int date, int *y, int *mo, int *day, int *h, int *m, int *s, int *wday ) {
	struct tm t;
	time_t d = (time_t)(unsigned)date;
	if( !gmtime_r(&d,&t) )
		hl_error("invalid date");
	if( y ) *y = t.tm_year + 1900;
	if( mo ) *mo = t.tm_mon;
	if( day ) *day = t.tm_mday;
	if( h ) *h = t.tm_hour;
	if( m ) *m = t.tm_min;
	if( s ) *s = t.tm_sec;
	if( wday ) *wday = t.tm_wday;
}

DEFINE_PRIM(_I32, date_now, _NO_ARG);
DEFINE_PRIM(_BYTES, date_to_string, _I32 _REF(_I32));
DEFINE_PRIM(_F64, date_get_time, _I32);
DEFINE_PRIM(_I32, date_from_time, _F64);
DEFINE_PRIM(_I32, date_from_string, _BYTES _I32);
DEFINE_PRIM(_I32, date_new, _I32 _I32 _I32 _I32 _I32 _I32);
DEFINE_PRIM(_VOID, date_get_inf, _I32 _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32));
DEFINE_PRIM(_VOID, date_get_utc_inf, _I32 _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32));

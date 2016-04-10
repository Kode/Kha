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
#define PCRE_STATIC
#include <pcre.h>

typedef struct _ereg ereg;

static pcre16_extra limit;

struct _ereg {
	void (*finalize)( ereg * );
	pcre16 *p;
	int *matches;
	int nmatches;
	bool matched;
};

static void regexp_finalize( ereg *e ) {
	pcre16_free(e->p);
	free(e->matches);
}

HL_PRIM ereg *regexp_regexp_new_options( vbyte *str, vbyte *opts ) {
	ereg *r;
	const char *error;
	int err_offset;
	int errorcode;
	pcre16 *p;
	uchar *o = (uchar*)opts;
	int options = 0;
	while( *o ) {
		switch( *o++ ) {
		case 'i':
			options |= PCRE_CASELESS;
			break;
		case 's':
			options |= PCRE_DOTALL;
			break;
		case 'm':
			options |= PCRE_MULTILINE;
			break;
		case 'u':
			options |= PCRE_UTF8;
			break;
		case 'g':
			options |= PCRE_UNGREEDY;
			break;
		default:
			return NULL;
		}
	}
	p = pcre16_compile2((PCRE_SPTR16)str,options,&errorcode,&error,&err_offset,NULL);
	if( p == NULL ) {
		hl_buffer *b = hl_alloc_buffer();
		hl_buffer_str(b,USTR("Regexp compilation error : "));
		hl_buffer_cstr(b,error);
		hl_buffer_str(b,USTR(" in "));
		hl_buffer_str(b,(uchar*)str);
		hl_error_msg(USTR("%s"),hl_buffer_content(b,NULL));
	}
	r = (ereg*)hl_gc_alloc_finalizer(sizeof(ereg));
	r->finalize = regexp_finalize;
	r->p = p;
	r->nmatches = 0;
	r->matched = 0;
	pcre16_fullinfo(p,NULL,PCRE_INFO_CAPTURECOUNT,&r->nmatches);
	r->nmatches++;
	r->matches = (int*)malloc(sizeof(int) * 3 * r->nmatches);
	limit.flags = PCRE_EXTRA_MATCH_LIMIT_RECURSION;
	limit.match_limit_recursion = 3500; // adapted based on Windows 1MB stack size
	return r;
}

HL_PRIM int regexp_regexp_matched_pos( ereg *e, int m, int *len ) {
	int start;
	if( !e->matched )
		hl_error("Calling matchedPos() on an unmatched regexp"); 
	if( m < 0 || m >= e->nmatches )
		hl_error_msg(USTR("Matched index %d outside bounds"),m);
	start = e->matches[m*2];
	*len = e->matches[m*2+1] - start;
	return start;
}

HL_PRIM bool regexp_regexp_match( ereg *e, vbyte *s, int pos, int len ) {
	int res = pcre16_exec(e->p,&limit,(PCRE_SPTR16)s,pos+len,pos,0,e->matches,e->nmatches * 3);
	e->matched = res >= 0;
	if( res >= 0 )
		return true;
	if( res != PCRE_ERROR_NOMATCH )
		hl_error("An error occured while running pcre_exec");
	return false;
}


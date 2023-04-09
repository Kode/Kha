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

#define PCRE2_STATIC
#include <pcre2.h>

typedef struct _ereg ereg;

struct _ereg {
	void (*finalize)( ereg * );
	/* The compiled regex code */
	pcre2_code *regex;
	/* Pointer to the allocated memory for match data */
	pcre2_match_data *match_data;
	/* Number of capture groups */
	int n_groups;
	/* Whether the last string was matched successfully */
	bool matched;
};

static void regexp_finalize( ereg *e ) {
	pcre2_code_free(e->regex);
	pcre2_match_data_free(e->match_data);
}

HL_PRIM ereg *hl_regexp_new_options( vbyte *str, vbyte *opts ) {
	ereg *r;
	int error_code;
	size_t error_offset;
	pcre2_code *p;
	uchar *o = (uchar*)opts;
	int options = PCRE2_UCP | PCRE2_UTF | PCRE2_ALT_BSUX | PCRE2_ALLOW_EMPTY_CLASS | PCRE2_MATCH_UNSET_BACKREF;
	while( *o ) {
		switch( *o++ ) {
		case 'i':
			options |= PCRE2_CASELESS;
			break;
		case 's':
			options |= PCRE2_DOTALL;
			break;
		case 'm':
			options |= PCRE2_MULTILINE;
			break;
		case 'u':
			break;
		case 'g':
			options |= PCRE2_UNGREEDY;
			break;
		default:
			return NULL;
		}
	}
	p = pcre2_compile((PCRE2_SPTR)str,PCRE2_ZERO_TERMINATED,options,&error_code,&error_offset,NULL);
	if( p == NULL ) {
		hl_buffer *b = hl_alloc_buffer();
		vdynamic *d = hl_alloc_dynamic(&hlt_bytes);
		PCRE2_UCHAR error_buffer[256];
		pcre2_get_error_message(error_code,error_buffer,sizeof(error_buffer));
		hl_buffer_str(b,USTR("Regexp compilation error : "));
		hl_buffer_str(b,error_buffer);
		hl_buffer_str(b,USTR(" in "));
		hl_buffer_str(b,(uchar*)str);
		d->v.bytes = (vbyte*)hl_buffer_content(b,NULL);
		hl_throw(d);
	}
	r = (ereg*)hl_gc_alloc_finalizer(sizeof(ereg));
	r->finalize = regexp_finalize;
	r->regex = p;
	r->matched = 0;
	r->n_groups = 0;
	pcre2_pattern_info(p,PCRE2_INFO_CAPTURECOUNT,&r->n_groups);
	r->n_groups++;
	r->match_data = pcre2_match_data_create_from_pattern(r->regex,NULL);

	return r;
}

HL_PRIM int hl_regexp_matched_pos( ereg *e, int m, int *len ) {
	int start;
	size_t *matches = pcre2_get_ovector_pointer(e->match_data);
	if( !e->matched )
		hl_error("Calling regexp_matched_pos() on an unmatched regexp");
	if( m < 0 || m >= e->n_groups )
		hl_error("Matched index %d outside bounds",m);
	start = matches[m*2];
	if( len ) *len = matches[m*2+1] - start;
	return start;
}

HL_PRIM int hl_regexp_matched_num( ereg *e ) {
	if( !e->matched )
		return -1;
	else
		return e->n_groups;
}

HL_PRIM bool hl_regexp_match( ereg *e, vbyte *s, int pos, int len ) {
	int res = pcre2_match(e->regex,(PCRE2_SPTR)s,pos+len,pos,PCRE2_NO_UTF_CHECK,e->match_data,NULL);
	e->matched = res >= 0;
	if( res >= 0 )
		return true;
	if( res != PCRE2_ERROR_NOMATCH )
		hl_error("An error occurred while running pcre2_match()");
	return false;
}

#define _EREG _ABSTRACT(ereg)
DEFINE_PRIM( _EREG, regexp_new_options, _BYTES _BYTES);
DEFINE_PRIM( _I32, regexp_matched_pos, _EREG _I32 _REF(_I32));
DEFINE_PRIM( _I32, regexp_matched_num, _EREG );
DEFINE_PRIM( _BOOL, regexp_match, _EREG _BYTES _I32 _I32);

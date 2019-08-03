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

HL_PRIM vbyte *hl_itos( int i, int *len ) {
	uchar tmp[24];
	int k = (int)usprintf(tmp,24,USTR("%d"),i);
	*len = k;
	return hl_copy_bytes((vbyte*)tmp,(k + 1)<<1);
}

HL_PRIM vbyte *hl_ftos( double d, int *len ) {
	uchar tmp[24];
	int k;
	if( d != d ) {
		*len = 3;
		return hl_copy_bytes((vbyte*)USTR("NaN"),8);
	}
	// don't use the last digit (eg 5.1 = 5.09999..996)
	// also cut one more digit for some numbers (eg 86.57 and 85.18) <- to fix since we lose one PI digit
	k = (int)usprintf(tmp,24,USTR("%.15g"),d);
#	if defined(HL_WIN) && _MSC_VER <= 1800
	// fix for window : 1e-5 is printed as 1e-005 whereas it's 1e-05 on other platforms
	// note : this is VS2013 std bug, VS2015 works correctly
	{
		int i;
		for(i=0;i<k;i++)
			if( tmp[i] == 'e' ) {
				if( tmp[i+1] == '+' || tmp[i+1] == '-' ) i++;
				if( tmp[i+1] != '0' || tmp[i+2] != '0' ) break;
				memmove(tmp+i+1,tmp+i+2,(k-(i+1))*2);
				k--;
				break;
			}
	}
#	endif
	*len = k;
	return hl_copy_bytes((vbyte*)tmp,(k + 1) << 1);
}

HL_PRIM vbyte *hl_value_to_string( vdynamic *d, int *len ) {
	if( d == NULL ) {
		*len = 4;
		return (vbyte*)USTR("null");
	}
	switch( d->t->kind ) {
	case HI32:
		return hl_itos(d->v.i,len);
	case HF64:
		return hl_ftos(d->v.d,len);
	default:
		{
			hl_buffer *b = hl_alloc_buffer();
			hl_buffer_val(b, d);
			return (vbyte*)hl_buffer_content(b,len);
		}
	}
}

HL_PRIM int hl_ucs2length( vbyte *str, int pos ) {
	return (int)ustrlen((uchar*)(str + pos));
}

HL_PRIM int hl_utf8_length( const vbyte *s, int pos ) {
	int len = 0;
	s += pos;
	while( true ) {
		unsigned char c = (unsigned)*s;
		len++;
		if( c < 0x80 ) {
			if( c == 0 ) {
				len--;
				break;
			}
			s++;
		} else if( c < 0xC0 )
			return len - 1;
		else if( c < 0xE0 ) {
			if( (s[1]&0x80) == 0 ) return len - 1;
			s += 2;
		} else if( c < 0xF0 ) {
			if( ((s[1]&s[2])&0x80) == 0 ) return len - 1;
			s+=3;
		} else if( c < 0xF8 ) {
			if( ((s[1]&s[2]&s[3])&0x80) == 0 ) return len - 1;
			len++; // surrogate pair
			s+=4;
		} else
			return len;
	}
	return len;
}

HL_PRIM int hl_from_utf8( uchar *out, int outLen, const char *str ) {
	int p = 0;
	unsigned int c, c2, c3;
	while( p++ < outLen ) {
		c = *(unsigned char *)str++;
		if( c < 0x80 ) {
			if( c == 0 ) break;
			// nothing
		} else if( c < 0xE0 ) {
			c = ((c & 0x3F) << 6) | ((*str++)&0x7F);
		} else if( c < 0xF0 ) {
			c2 = (unsigned)*str++;
			c = ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | ((*str++) & 0x7F);
		} else {
			c2 = (unsigned)*str++;
			c3 = (unsigned)*str++;
			c = (((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 & 0x7F) << 6) | ((*str++) & 0x7F)) - 0x10000;
			// surrogate pair
			if( p++ == outLen ) break;
			*out++ = (uchar)((c >> 10) + 0xD800);
			*out++ = (uchar)((c & 0x3FF) | 0xDC00);
			continue;
		}
		*out++ = (uchar)c;
	}
	*out = 0;
	return --p;
}

HL_PRIM uchar *hl_to_utf16( const char *str ) {
	int len = hl_utf8_length((vbyte*)str,0);
	uchar *out = (uchar*)hl_gc_alloc_noptr((len + 1) * sizeof(uchar));
	hl_from_utf8(out,len,str);
	return out;
}

HL_PRIM vbyte* hl_utf8_to_utf16( vbyte *str, int pos, int *size ) {
	int ulen = hl_utf8_length(str, pos);
	uchar *s = (uchar*)hl_gc_alloc_noptr((ulen + 1)*sizeof(uchar));
	hl_from_utf8(s,ulen,(char*)(str+pos));
	*size = ulen << 1;
	return (vbyte*)s;
}

#include "unicase.h"

HL_PRIM vbyte* hl_ucs2_upper( vbyte *str, int pos, int len ) {
	uchar *cstr = (uchar*)(str + pos);
	uchar *out = (uchar*)hl_gc_alloc_noptr((len + 1) * sizeof(uchar));
	int i;
	uchar *cout = out;
	memcpy(out,cstr,len << 1);
	for(i=0;i<len;i++) {
		unsigned int c = *cstr++;
		int up = c >> UL_BITS;
		if( up < UMAX ) {
			unsigned int c2 = UPPER[up][c&((1<<UL_BITS)-1)];
			if( c2 != 0 ) *cout = (uchar)c2;
		}
		cout++;
	}
	*cout = 0;
	return (vbyte*)out;
}

HL_PRIM vbyte* hl_ucs2_lower( vbyte *str, int pos, int len ) {
	uchar *cstr = (uchar*)(str + pos);
	uchar *out = (uchar*)hl_gc_alloc_noptr((len + 1) * sizeof(uchar));
	uchar *cout = out;
	int i;
	memcpy(out,cstr,len << 1);
	for(i=0;i<len;i++) {
		unsigned int c = *cstr++;
		int up = c >> UL_BITS;
		if( up < LMAX ) {
			unsigned int c2 = LOWER[up][c&((1<<UL_BITS)-1)];
			if( c2 != 0 ) *cout = (uchar)c2;
		}
		cout++;
	}
	*cout = 0;
	return (vbyte*)out;
}

HL_PRIM vbyte *hl_utf16_to_utf8( vbyte *str, int len, int *size ) {
	vbyte *out;
	uchar *c = (uchar*)str;
	uchar *end = len == 0 ? NULL : c + len;
	int utf8bytes = 0;
	int p = 0;
	while( c != end ) {
		unsigned int v = (unsigned int)*c;
		if( v == 0 && end == NULL ) break;
		if( v < 0x80 )
			utf8bytes++;
		else if( v < 0x800 )
			utf8bytes += 2;
		else if( v >= 0xD800 && v <= 0xDFFF ) {
			utf8bytes += 4;
			c++;
		} else
			utf8bytes += 3;
		c++;
	}
	out = hl_gc_alloc_noptr(utf8bytes + 1);
	c = (uchar*)str;
	while( c != end ) {
		unsigned int v = (unsigned int)*c;
		if( v < 0x80 ) {
			out[p++] = (vbyte)v;
			if( v == 0 && end == NULL ) break;
		} else if( v < 0x800 ) {
			out[p++] = (vbyte)(0xC0|(v>>6));
			out[p++] = (vbyte)(0x80|(v&63));
		} else if( v >= 0xD800 && v <= 0xDFFF ) {
			int k = ((((int)v - 0xD800) << 10) | (((int)*++c) - 0xDC00)) + 0x10000;
			out[p++] = (vbyte)(0xF0|(k>>18));
			out[p++] = (vbyte)(0x80 | ((k >> 12) & 63));
			out[p++] = (vbyte)(0x80 | ((k >> 6) & 63));
			out[p++] = (vbyte)(0x80 | (k & 63));
		} else {
			out[p++] = (vbyte)(0xE0|(v>>12));
			out[p++] = (vbyte)(0x80|((v>>6)&63));
			out[p++] = (vbyte)(0x80|(v&63));
		}
		c++;
	}
	if( size ) *size = utf8bytes;
	return out;
}

HL_PRIM char *hl_to_utf8( const uchar *bytes ) {
	int size;
	return (char*)hl_utf16_to_utf8((vbyte*)bytes, 0, &size);
}

static void hl_buffer_hex( hl_buffer *b, int c ) {
	static const uchar *hex = USTR("0123456789ABCDEF");
	hl_buffer_char(b,'%');
	hl_buffer_char(b,hex[c>>4]);
	hl_buffer_char(b,hex[c&0xF]);
}

HL_PRIM vbyte *hl_url_encode( vbyte *str, int *len ) {
	hl_buffer *b = hl_alloc_buffer();
	uchar *cstr = (uchar*)str;
	unsigned int sur;
	while( true ) {
		unsigned int c = (unsigned)*cstr++;
		if( c == 0 ) break;
		if( (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.' )
			hl_buffer_char(b,(uchar)c);
		else {
			if( c < 0x80 ) {
				hl_buffer_hex(b,c);
			} else if( c < 0x800 ) {
				hl_buffer_hex(b, 0xC0|(c>>6));
				hl_buffer_hex(b, 0x80|(c&63));
			} else if( c >= 0xD800 && c <= 0xDBFF ) {
				sur = (unsigned)*cstr;
				if( sur >= 0xDC00 && sur < 0xDFFF ) {
					cstr++;
					c = ((((int)c - 0xD800) << 10) | ((int)sur - 0xDC00)) + 0x10000;
					hl_buffer_hex(b, 0xF0|(c>>18));
					hl_buffer_hex(b, 0x80|((c >> 12) & 63));
					hl_buffer_hex(b, 0x80|((c >> 6) & 63));
					hl_buffer_hex(b, 0x80|(c & 63));
				} else {
					hl_buffer_hex(b, 0xE0|(c>>12));
					hl_buffer_hex(b, 0x80|((c>>6)&63));
					hl_buffer_hex(b, 0x80|(c&63));
				}
			} else {
				hl_buffer_hex(b, 0xE0|(c>>12));
				hl_buffer_hex(b, 0x80|((c>>6)&63));
				hl_buffer_hex(b, 0x80|(c&63));
			}
		}
	}
	return (vbyte*)hl_buffer_content(b,len);
}

static uchar decode_hex_char( uchar c ) {
	if( c >= '0' && c <= '9' )
		c -= '0';
	else if( c >= 'a' && c <= 'f' )
		c -= 'a' - 10;
	else if( c >= 'A' && c <= 'F' )
		c -= 'A' - 10;
	else
		return (uchar)-1;
	return c;
}

static uchar decode_hex( uchar **cstr ) {
	uchar *c = *cstr;
	uchar p1 = decode_hex_char(c[0]);
	uchar p2;
	if( p1 == (uchar)-1 ) return p1;
	p2 = decode_hex_char(c[1]);
	if( p2 == (uchar)-1 ) return p2;
	*cstr = c + 2;
	return (p1 << 4) | p2;
}

HL_PRIM vbyte *hl_url_decode( vbyte *str, int *len ) {
	hl_buffer *b = hl_alloc_buffer();
	uchar *cstr = (uchar*)str;
	while( true ) {
		uchar c = *cstr++;
		if( c == 0 )
			return (vbyte*)hl_buffer_content(b,len);
		if( c == '+' )
			c = ' ';
		else if( c == '%' ) {
			uchar p1 = decode_hex(&cstr);
			if( p1 == (uchar)-1 ) {
				hl_buffer_char(b,'%');
				continue;
			}
			if( p1 < 0x80 ) {
				c = p1;
			} else if( p1 < 0xE0 ) {
				uchar p2;
				if( *cstr++ != '%' ) break;
				p2 = decode_hex(&cstr);
				if( p2 < 0 ) break;
				c = ((p1 & 0x3F) << 6) | (p2&0x7F);
			} else if( p1 < 0xF0 ) {
				uchar p2, p3;
				if( *cstr++ != '%' ) break;
				p2 = decode_hex(&cstr);
				if( p2 < 0 ) break;
				if( *cstr++ != '%' ) break;
				p3 = decode_hex(&cstr);
				if( p3 < 0 ) break;
				c = ((p1 & 0x1F) << 12) | ((p2 & 0x7F) << 6) | (p3 & 0x7F);
			} else {
				int k;
				uchar p2, p3, p4;
				if( *cstr++ != '%' ) break;
				p2 = decode_hex(&cstr);
				if( p2 < 0 ) break;
				if( *cstr++ != '%' ) break;
				p3 = decode_hex(&cstr);
				if( p3 < 0 ) break;
				if( *cstr++ != '%' ) break;
				p4 = decode_hex(&cstr);
				if( p4 < 0 ) break;
				k = (((p1 & 0x0F) << 18) | ((p2 & 0x7F) << 12) | ((p3 & 0x7F) << 6) | (p4 & 0x7F)) - 0x10000;
				hl_buffer_char(b,(uchar)((k >> 10) + 0xD800));
				c = (uchar)((k & 0x3FF) | 0xDC00);
			}
		}
		hl_buffer_char(b,c);
	}
	hl_error("Malformed URL encoded");
	return NULL;
}

DEFINE_PRIM(_BYTES,itos,_I32 _REF(_I32));
DEFINE_PRIM(_BYTES,ftos,_F64 _REF(_I32));
DEFINE_PRIM(_BYTES,value_to_string,_DYN _REF(_I32));
DEFINE_PRIM(_I32,ucs2length,_BYTES _I32);
DEFINE_PRIM(_BYTES,utf8_to_utf16,_BYTES _I32 _REF(_I32));
DEFINE_PRIM(_BYTES,utf16_to_utf8,_BYTES _I32 _REF(_I32));
DEFINE_PRIM(_BYTES,ucs2_upper,_BYTES _I32 _I32);
DEFINE_PRIM(_BYTES,ucs2_lower,_BYTES _I32 _I32);
DEFINE_PRIM(_BYTES,url_encode,_BYTES _REF(_I32));
DEFINE_PRIM(_BYTES,url_decode,_BYTES _REF(_I32));


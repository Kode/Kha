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
	uchar tmp[48];
	int k = (int)usprintf(tmp,48,USTR("%.16g"),d); // don't use the last digit (eg 5.1 = 5.09999..996)
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

HL_PRIM int hl_utf8_length( vbyte *s, int pos ) {
	int len = 0;
	s += pos;
	while( true ) {
		unsigned char c = (unsigned)*s;
		len++;
		if( c < 0x7F ) {
			if( c == 0 ) {
				len--;
				break;
			}
			s++;
		} else if( c < 0xC0 )
			return len;
		else if( c < 0xE0 )
			s+=2;
		else if( c < 0xF0 )
			s+=3;
		else if( c < 0xF8 ) {
			len++; // surrogate pair
			s+=4;
		} else
			return len;
	}
	return len;
}

HL_PRIM vbyte* hl_utf8_to_utf16( vbyte *str, int pos, int *size ) {
	int ulen = hl_utf8_length(str, pos);
	uchar *s = (uchar*)hl_gc_alloc_noptr((ulen + 1)*sizeof(uchar));
	uchar *cur = s;
	unsigned int c, c2, c3;
	str += pos;
	while( true ) {
		c = (unsigned)*str++;
		if( c == 0 )
			break;
		else if( c < 0x80 ) {
			// nothing
		} else if( c < 0xE0 ) {
			c = ((c & 0x3F) << 6) | ((*str++)&0x7F);
		} else if( c < 0xF0 ) {
			c2 = (unsigned)*str++;
			c = ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | ((*str++) & 0x7F);
		} else {
			c2 = (unsigned)*str++;
			c3 = (unsigned)*str++;
			c = ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 & 0x7F) << 6) | ((*str++) & 0x7F);
			// surrogate pair
			*cur++ = (uchar)((c >> 10) + 0xD7C0);
			*cur++ = (uchar)((c & 0x3FF) | 0xDC00);
			continue;
		}
		*cur++ = (uchar)c;
	}
	*cur = 0;
	*size = ulen << 1;
	return (vbyte*)s;
}

#include "unicase.c"

HL_PRIM vbyte* hl_ucs2_upper( vbyte *str, int pos, int len ) {
	uchar *cstr = (uchar*)(str + pos);
	uchar *out = (uchar*)hl_gc_alloc_noptr((len + 1) * sizeof(uchar));
	int i;
	uchar *cout = out;
	memcpy(out,cstr,(len + 1) << 1);
	for(i=0;i<len;i++) {
		unsigned int c = *cstr++;
		int up = c >> UL_BITS;
		if( up < UMAX ) {
			unsigned int c2 = UPPER[up][c&((1<<UL_BITS)-1)];
			if( c2 != 0 ) *cout = (uchar)c2;
		}
		cout++;
	}
	return (vbyte*)out;
}

HL_PRIM vbyte* hl_ucs2_lower( vbyte *str, int pos, int len ) {
	uchar *cstr = (uchar*)(str + pos);
	uchar *out = (uchar*)hl_gc_alloc_noptr((len + 1) * sizeof(uchar));
	uchar *cout = out;
	int i;
	memcpy(out,cstr,(len + 1) << 1);
	for(i=0;i<len;i++) {
		unsigned int c = *cstr++;
		int up = c >> UL_BITS;
		if( up < UMAX ) {
			unsigned int c2 = LOWER[up][c&((1<<UL_BITS)-1)];
			if( c2 != 0 ) *cout = (uchar)c2;
		}
		cout++;
	}
	return (vbyte*)out;
}

// TODO : currently it is actually ucs2_to_utf8...
HL_PRIM vbyte *hl_utf16_to_utf8( vbyte *str, int pos, int *size ) {
	vbyte *out;
	uchar *c = (uchar*)(str + pos);
	int utf8bytes = 0;
	int p = 0;
	while( true ) {
		unsigned int v = (unsigned int)*c;
		if( v == 0 ) break;
		if( v < 0x80 )
			utf8bytes++;
		else if( v < 0x800 )
			utf8bytes += 2;
		else
			utf8bytes += 3;
		c++;
	}
	out = hl_gc_alloc_noptr(utf8bytes + 1);
	c = (uchar*)(str + pos);
	while( true ) {
		unsigned int v = (unsigned int)*c;
		if( v < 0x80 ) {
			out[p++] = (vbyte)v;
			if( v == 0 ) break;
		} else if( v < 0x800 ) {
			out[p++] = (vbyte)(0xC0|(v>>6));
			out[p++] = (vbyte)(0x80|(v&63));
		} else {
			out[p++] = (vbyte)(0xE0|(v>>12));
			out[p++] = (vbyte)(0x80|((v>>6)&63));
			out[p++] = (vbyte)(0x80|(v&63));
		}
		c++;
	}
	*size = utf8bytes;
	return out;
}

HL_PRIM vbyte *hl_url_encode( vbyte *str, int *len ) {
	hl_buffer *b = hl_alloc_buffer();
	uchar *cstr = (uchar*)str;
	while( true ) {
		static const uchar *hex = USTR("0123456789ABCDEF");
		unsigned int c = (unsigned)*cstr++;
		if( c == 0 ) break;
		if( (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.' )
			hl_buffer_char(b,(uchar)c);
		else {
			hl_buffer_char(b,'%');
			if( c < 0x80 ) {
				hl_buffer_char(b,hex[c>>4]);
				hl_buffer_char(b,hex[c&0xF]);
			} else if( c < 0x800 ) {
				unsigned int c1 = 0xC0|(c>>6);
				unsigned int c2 = 0x80|(c&63);
				hl_buffer_char(b,hex[c1>>4]);
				hl_buffer_char(b,hex[c1&0xF]);
				hl_buffer_char(b,'%');
				hl_buffer_char(b,hex[c2>>4]);
				hl_buffer_char(b,hex[c2&0xF]);
			} else {
				unsigned int c1 = 0xE0|(c>>12);
				unsigned int c2 = 0x80|((c>>6)&63);
				unsigned int c3 = 0x80|(c&63);
				hl_buffer_char(b,hex[c1>>4]);
				hl_buffer_char(b,hex[c1&0xF]);
				hl_buffer_char(b,'%');
				hl_buffer_char(b,hex[c2>>4]);
				hl_buffer_char(b,hex[c2&0xF]);
				hl_buffer_char(b,'%');
				hl_buffer_char(b,hex[c3>>4]);
				hl_buffer_char(b,hex[c3&0xF]);
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
		return -1;
	return c;
}

static uchar decode_hex( uchar **cstr ) {
	uchar *c = *cstr;
	uchar p1 = decode_hex_char(c[0]);
	uchar p2;
	if( p1 < 0 ) return -1;
	p2 = decode_hex_char(c[1]);
	if( p2 < 0 ) return -1;
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
			if( p1 < 0 ) {
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
			} else
				hl_error("TODO");
		}
		hl_buffer_char(b,c);
	}
	hl_error("Malformed URL encoded");
	return NULL;
}
	

DEFINE_PRIM(_BYTES,hl_itos,_I32 _REF(_I32));
DEFINE_PRIM(_BYTES,hl_ftos,_F64 _REF(_I32));
DEFINE_PRIM(_BYTES,hl_value_to_string,_DYN _REF(_I32));
DEFINE_PRIM(_I32,hl_ucs2length,_BYTES _I32);
DEFINE_PRIM(_BYTES,hl_utf8_to_utf16,_BYTES _I32 _REF(_I32));
DEFINE_PRIM(_BYTES,hl_ucs2_upper,_BYTES _I32 _I32);
DEFINE_PRIM(_BYTES,hl_ucs2_lower,_BYTES _I32 _I32);

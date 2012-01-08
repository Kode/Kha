/* ************************************************************************ */
/*																			*/
/*  Neko Standard Library													*/
/*  Copyright (c)2005 Motion-Twin											*/
/*																			*/
/* This library is free software; you can redistribute it and/or			*/
/* modify it under the terms of the GNU Lesser General Public				*/
/* License as published by the Free Software Foundation; either				*/
/* version 2.1 of the License, or (at your option) any later version.		*/
/*																			*/
/* This library is distributed in the hope that it will be useful,			*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of			*/
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU		*/
/* Lesser General Public License or the LICENSE file for more details.		*/
/*																			*/
/* ************************************************************************ */
#include <hx/CFFI.h>
#include <string.h>

int __string_prims() { return 0; }

/**
	<doc>
	<h1>String Functions</h1>
	<p>
	Some useful functions dealing with string manipulation.
	</p>
	</doc>
**/

/**
	string_split : s:string -> sep:string -> string list
	<doc>split the string [s] using separator [sep]</doc>
**/
static value string_split( value o, value s ) {
	value l, first;
	int ilen;
	int slen;
	int start = 0;
	int pos;
	val_check(s,string);
	val_check(o,string);
	ilen = val_strlen(o);
	slen = val_strlen(s);
	l = alloc_null();
	first = alloc_null();
	for(pos=slen?0:1;pos<=ilen-slen;pos++)
		if( memcmp(val_string(o)+pos,val_string(s),slen) == 0 ) {
			value ss = copy_string(val_string(o)+start,pos-start);
			value l2 = alloc_array(2);
			val_array_set_i(l2,0,ss);
			val_array_set_i(l2,1,alloc_null());
			if( val_is_null(first) )
				first = l2;
			else
				val_array_set_i(l,1,l2);
			l = l2;
			start = pos + slen;
			if( slen )
				pos = start - 1;
		}
	if( ilen > 0 && slen ) {
		value ss = start ? copy_string(val_string(o)+start,ilen-start) : o;
		value l2 = alloc_array(2);
		val_array_set_i(l2,0,ss);
		val_array_set_i(l2,1,alloc_null());
		if( val_is_null(first))
			first = l2;
		else
			val_array_set_i(l,1,l2);
	}
	return first;
}

#define HEX			1
#define HEX_SMALL	2

/**
	sprintf : fmt:string -> params:(any | array) -> string
	<doc>
	Format a string. If only one parameter is needed then it can be
	directly passed, either the parameters need to be stored in an array.
	The following formats are accepted (with corresponding types) :
	<ul>
		<li>[%s] : string</li>
		<li>[%d] [%x] [%X] : int</li>
		<li>[%c] : int in the 0..255 range</li>
		<li>[%b] : bool</li>
		<li>[%f] : float</li>
	</ul>
	</doc>
**/
static value neko_sprintf( value fmt, value params ) {
	const char *last, *cur, *end;
	int count = 0;
	buffer b;
	val_check(fmt,string);
	b = alloc_buffer(0);
	last = val_string(fmt);
	cur = last;
	end = cur + val_strlen(fmt);
	while( cur != end ) {
		if( *cur == '%' ) {
			int width = 0, prec = 0, flags = 0;
			buffer_append_sub(b,last,cur - last);
			cur++;
			while( *cur >= '0' && *cur <= '9' ) {
				width = width * 10 + (*cur - '0');
				cur++;
			}
			if( *cur == '.' ) {
				cur++;
				while( *cur >= '0' && *cur <= '9' ) {
					prec = prec * 10 + (*cur - '0');
					cur++;
				}
			}
			if( *cur == '%' ) {
				buffer_append_sub(b,"%",1);
				cur++;
			} else {
				value param;
				if( count == 0 && !val_is_array(params) ) { // first ?
					param = params;
					count++;
				} else if( !val_is_array(params) || val_array_size(params) <= count )
					return alloc_null();
				else
					param = val_array_i(params,count++);
				switch( *cur ) {
				case 'c':
					{
						int c;
						char cc;
						val_check(param,int);
						c = val_int(param);
						if( c < 0 || c > 255 )
							return alloc_null();
						cc = (char)c;
						buffer_append_sub(b,&cc,1);
					}
					break;
				case 'x':
					flags |= HEX_SMALL;
				case 'X':
					flags |= HEX;
				case 'd':
					{
						char tmp[10];
						int sign = 0;
						int size = 0;
						int tsize;
						int n;
						val_check(param,int);
						n = val_int(param);
						if( !(flags & HEX) && n < 0 ) {
							sign++;
							prec--;
							n = -n;
						} else if( n == 0 )
							tmp[9-size++] = '0';
						if( flags & HEX ) {
							unsigned int nn = (unsigned int)n;
							while( nn > 0 ) {
								int k = nn&15;
								if( k < 10 )
									tmp[9-size++] = k + '0';
								else
									tmp[9-size++] = (k - 10) + ((flags & HEX_SMALL)?'a':'A');
								nn = nn >> 4;
							}
						} else {
							while( n > 0 ) {
								tmp[9-size++] = (n % 10) + '0';
								n = n / 10;
							}
						}
						tsize = (size > prec)?size:prec + sign;
						while( width > tsize ) {
							width--;
							buffer_append_sub(b," ",1);
						}
						if( sign )
							buffer_append_sub(b,"-",1);
						while( prec > size ) {
							prec--;
							buffer_append_sub(b,"0",1);
						}
						buffer_append_sub(b,tmp+10-size,size);
					}
					break;
				case 'f':
					{
						val_check(param,float);
						val_buffer(b,param);
					}
					break;
				case 's':
					{
						int size;
						int tsize;
						val_check(param,string);
						size = val_strlen(param);
						tsize = (size > prec)?size:prec;
						while( width > tsize ) {
							width--;
							buffer_append_sub(b," ",1);
						}
						while( prec > size ) {
							prec--;
							buffer_append_sub(b," ",1);
						}
						buffer_append_sub(b,val_string(param),size);
					}
					break;
				case 'b':
					{
						val_check(param,bool);
						buffer_append_sub(b,val_bool(param)?"true":"false",val_bool(param)?4:5);
					}
					break;
				default:
					return alloc_null();
					break;
				}
			}
			cur++;
			last = cur;
		} else
			cur++;
	}
	buffer_append_sub(b,last,cur - last);
	return buffer_to_string(b);
}

/**
	url_decode : string -> string
	<doc>Decode an url using escaped format</doc>
**/
static value url_decode( value v ) {
	val_check(v,string);
	{
		int pin = 0;
		int pout = 0;
		const char *in = val_string(v);
		int len = val_strlen(v);
		buffer v2 = alloc_buffer_len(len);
		char *out = (char*)buffer_data(v2);
		while( len-- > 0 ) {
			char c = in[pin++];
			if( c == '+' )
				c = ' ';
			else if( c == '%' ) {
				int p1, p2;
				if( len < 2 )
					break;
				p1 = in[pin++];
				p2 = in[pin++];
				len -= 2;
				if( p1 >= '0' && p1 <= '9' )
					p1 -= '0';
				else if( p1 >= 'a' && p1 <= 'f' )
					p1 -= 'a' - 10;
				else if( p1 >= 'A' && p1 <= 'F' )
					p1 -= 'A' - 10;
				else
					continue;
				if( p2 >= '0' && p2 <= '9' )
					p2 -= '0';
				else if( p2 >= 'a' && p2 <= 'f' )
					p2 -= 'a' - 10;
				else if( p2 >= 'A' && p2 <= 'F' )
					p2 -= 'A' - 10;
				else
					continue;
				c = (char)((unsigned char)((p1 << 4) + p2));
			}
			out[pout++] = c;
		}
		out[pout] = 0;
		buffer_set_size(v2,pout);
		return buffer_to_string(v2);
	}
}

/**
	url_encode : string -> string
	<doc>Encode an url using escaped format</doc>
**/
static value url_encode( value v ) {
	val_check(v,string);
	{
		int pin = 0;
		int pout = 0;
		const unsigned char *in = (const unsigned char*)val_string(v);
		static const char *hex = "0123456789ABCDEF";
		int len = val_strlen(v);
		buffer v2 = alloc_buffer_len(len * 3);
		unsigned char *out = (unsigned char*)buffer_data(v2);
		while( len-- > 0 ) {
			unsigned char c = in[pin++];
			if( (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.' )
				out[pout++] = c;
			else {
				out[pout++] = '%';
				out[pout++] = hex[c >> 4];
				out[pout++] = hex[c & 0xF];
			}
		}
		out[pout] = 0;
		buffer_set_size(v2,pout);
		return buffer_to_string(v2);
	}
}

/**
	base_encode : s:string -> base:string -> string
	<doc>
	Encode a string using the specified base.
	The base length must be a power of two.
	</doc>
**/
static value base_encode( value s, value base ) {
	int nbits;
	int len;
	int size;
	int mask;
	unsigned int buf;
	int curbits;
	buffer out;
	unsigned char *cin, *cout, *chars;
	val_check(s,string);
	val_check(base,string);
	len = val_strlen(base);
	cin = (unsigned char *)val_string(s);
	chars = (unsigned char *)val_string(base);
	nbits = 1;
	while( len > 1 << nbits )
		nbits++;
	if( nbits > 8 || len != 1 << nbits )
		return alloc_null();
	size = (val_strlen(s) * 8 + nbits - 1) / nbits;
	out = alloc_buffer_len(size);
	cout = (unsigned char *)buffer_data(out);
	buf = 0;
	curbits = 0;
	mask = ((1 << nbits) - 1);
	while( size-- > 0 ) {
		while( curbits < nbits ) {
			curbits += 8;
			buf <<= 8;
			buf |= *cin++;
		}
		curbits -= nbits;
		*cout++ = chars[(buf >> curbits) & mask];
	}
	return buffer_to_string(out);
}

/**
	base_decode : s:string -> base:string -> string
	<doc>
	Decode a string encode in the specified base.
	The base length must be a power of two.
	</doc>
**/
static value base_decode( value s, value base ) {
	int nbits;
	int len;
	int size;
	unsigned int buf;
	int curbits;
	buffer out;
	int i;
	int tbl[256];
	unsigned char *cin, *cout, *chars;
	val_check(s,string);
	val_check(base,string);
	len = val_strlen(base);
	cin = (unsigned char *)val_string(s);
	chars = (unsigned char *)val_string(base);
	nbits = 1;
	while( len > 1 << nbits )
		nbits++;
	if( nbits > 8 || len != 1 << nbits )
		return alloc_null();
	for(i=0;i<256;i++)
		tbl[i] = -1;
	for(i=0;i<len;i++)
		tbl[chars[i]] = i;
	size = (val_strlen(s) * nbits) / 8;
	out = alloc_buffer_len(size);
	cout = (unsigned char *)buffer_data(out);
	buf = 0;
	curbits = 0;
	while( size-- > 0 ) {
		while( curbits < 8 ) {
			curbits += nbits;
			buf <<= nbits;
			i = tbl[*cin++];
			if( i == -1 )
				return alloc_null();
			buf |= i;
		}
		curbits -= 8;
		*cout++ = (buf >> curbits) & 0xFF;
	}
	return buffer_to_string(out);
}

#define neko_sprintf__2 sprintf__2
DEFINE_PRIM(neko_sprintf,2);
DEFINE_PRIM(string_split,2);
DEFINE_PRIM(url_decode,1);
DEFINE_PRIM(url_encode,1);
DEFINE_PRIM(base_encode,2);
DEFINE_PRIM(base_decode,2);

/* ************************************************************************ */

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
#include <memory.h>


#ifdef HXCPP
#define NULL_VAL null()
#else
#define NULL_VAL NULL
#endif

#ifndef NEKO_WINDOWS
#  include <strings.h>
#  undef strcmpi
#  define strcmpi(a,b) strcasecmp(a,b)
#else
#	include <string.h>
#endif

int __xml_prims() { return 0; }

#define ERROR(msg)	xml_error(xml,p,line,msg);

// -------------- parsing --------------------------

typedef enum {
	IGNORE_SPACES,
	BEGIN,
	BEGIN_NODE,
	TAG_NAME,
	BODY,
	ATTRIB_NAME,
	EQUALS,
	ATTVAL_BEGIN,
	ATTRIB_VAL,
	CHILDS,
	CLOSE,
	WAIT_END,
	WAIT_END_RET,
	PCDATA,
	HEADER,
	COMMENT,
	DOCTYPE,
	CDATA,
} STATE;

extern field id_pcdata;
extern field id_xml;
extern field id_done;
extern field id_comment;
extern field id_cdata;
extern field id_doctype;

static void xml_error( const char *xml, const char *p, int *line, const char *msg ) {
	buffer b = alloc_buffer("Xml parse error : ");
	int l = (int)strlen(p);
	int nchars = 30;
	buffer_append(b,msg);
	buffer_append(b," at line ");
	val_buffer(b,alloc_int(*line));
	buffer_append(b," : ");
	if( p != xml )
		buffer_append(b,"...");
	buffer_append_sub(b,p,(l < nchars)?l:nchars);
	if( l > nchars )
		buffer_append(b,"...");
	if( l == 0 )
		buffer_append(b,"<eof>");
	bfailure(b);
}

static bool is_valid_char( int c ) {
	return ( c >= 'a' && c <= 'z' ) || ( c >= 'A' && c <= 'Z' ) || ( c >= '0' && c <= '9' ) || c == ':' || c == '.' || c == '_' || c == '-';
}

static void do_parse_xml( const char *xml, const char **lp, int *line, value callb, const char *parentname ) {
	STATE state = BEGIN;
	STATE next = BEGIN;
	field aname = (field)0;
	value attribs = NULL_VAL;
	value nodename = NULL_VAL;
	const char *start = NULL;
	const char *p = *lp;
	char c = *p;
	int nsubs = 0, nbrackets = 0;
	gc_safe_point();
	while( c ) {
		switch( state ) {
		case IGNORE_SPACES:
			switch( c ) {
			case '\n':
			case '\r':
			case '\t':
			case ' ':
				break;
			default:
				state = next;
				continue;
			}
			break;
		case BEGIN:
			switch( c ) {
			case '<':
				state = IGNORE_SPACES;
				next = BEGIN_NODE;
				break;
			default:
				start = p;
				state = PCDATA;
				continue;
			}
			break;
		case PCDATA:
			if( c == '<' ) {
				val_ocall1(callb,id_pcdata,copy_string(start,p-start));
				nsubs++;
				state = IGNORE_SPACES;
				next = BEGIN_NODE;
			}
			break;
		case CDATA:
			if( c == ']' && p[1] == ']' && p[2] == '>' ) {
				val_ocall1(callb,id_cdata,copy_string(start,p-start));
				nsubs++;
				p += 2;
				state = BEGIN;
			}
			break;
		case BEGIN_NODE:
			switch( c ) {
			case '!':
				if( p[1] == '[' ) {
					p += 2;
					if( (p[0] != 'C' && p[0] != 'c') ||
						(p[1] != 'D' && p[1] != 'd') ||
						(p[2] != 'A' && p[2] != 'a') ||
						(p[3] != 'T' && p[3] != 't') ||
						(p[4] != 'A' && p[4] != 'a') ||
						(p[5] != '[') )
						ERROR("Expected <![CDATA[");
					p += 5;
					state = CDATA;
					start = p + 1;
					break;
				}
				if( p[1] == 'D' || p[1] == 'd' ) {
					if( (p[2] != 'O' && p[2] != 'o') ||
						(p[3] != 'C' && p[3] != 'c') ||
						(p[4] != 'T' && p[4] != 't') ||
						(p[5] != 'Y' && p[5] != 'y') ||
						(p[6] != 'P' && p[6] != 'p') ||
						(p[7] != 'E' && p[7] != 'e') )
						ERROR("Expected <!DOCTYPE");
					p += 7;
					state = DOCTYPE;
					start = p + 1;
					break;
				}
				if( p[1] != '-' || p[2] != '-' )
					ERROR("Expected <!--");
				p += 2;
				state = COMMENT;
				start = p + 1;
				break;
			case '?':
				state = HEADER;
				start = p;
				break;
			case '/':
				if( parentname == NULL )
					ERROR("Expected node name");
				start = p + 1;
				state = IGNORE_SPACES;
				next = CLOSE;
				break;
			default:
				state = TAG_NAME;
				start = p;
				continue;
			}
			break;
		case TAG_NAME:
			if( !is_valid_char(c) ) {
				if( p == start )
					ERROR("Expected node name");
				nodename = copy_string(start,p-start);
				attribs = alloc_empty_object();
				state = IGNORE_SPACES;
				next = BODY;
				continue;
			}
			break;
		case BODY:
			switch( c ) {
			case '/':
				state = WAIT_END;
				nsubs++;
				val_ocall2(callb,id_xml,nodename,attribs);
				break;
			case '>':
				state = CHILDS;
				nsubs++;
				val_ocall2(callb,id_xml,nodename,attribs);
				break;
			default:
				state = ATTRIB_NAME;
				start = p;
				continue;
			}
			break;
		case ATTRIB_NAME:
			if( !is_valid_char(c) ) {
				value tmp;
				if( start == p )
					ERROR("Expected attribute name");
				tmp = copy_string(start,p-start);
				aname = val_id(val_string(tmp));
				if( !val_is_null(val_field(attribs,aname)) )
					ERROR("Duplicate attribute");
				state = IGNORE_SPACES;
				next = EQUALS;
				continue;
			}
			break;
		case EQUALS:
			switch( c ) {
			case '=':
				state = IGNORE_SPACES;
				next = ATTVAL_BEGIN;
				break;
			default:
				ERROR("Expected =");
			}
			break;
		case ATTVAL_BEGIN:
			switch( c ) {
			case '"':
			case '\'':
				state = ATTRIB_VAL;
				start = p;
				break;
			default:
				ERROR("Expected \"");
			}
			break;
		case ATTRIB_VAL:
			if( c == *start ) {
				value aval = copy_string(start+1,p-start-1);
				alloc_field(attribs,aname,aval);
				state = IGNORE_SPACES;
				next = BODY;
			}
			break;
		case CHILDS:
			*lp = p;
			do_parse_xml(xml,lp,line,callb,val_string(nodename));
			p = *lp;
			start = p;
			state = BEGIN;
			break;
		case WAIT_END:
			switch( c ) {
			case '>':
				val_ocall0(callb,id_done);
				state = BEGIN;
				break;
			default :
				ERROR("Expected >");
			}
			break;
		case WAIT_END_RET:
			switch( c ) {
			case '>':
				if( nsubs == 0 )
					val_ocall1(callb,id_pcdata,alloc_string(""));
				val_ocall0(callb,id_done);
				*lp = p;
				return;
			default :
				ERROR("Expected >");
			}
			break;
		case CLOSE:
			if( !is_valid_char(c) ) {
				if( start == p )
					ERROR("Expected node name");
				{
					value v = copy_string(start,p - start);
					if( strcmpi(parentname,val_string(v)) != 0 ) {
						buffer b = alloc_buffer("Expected </");
						buffer_append(b,parentname);
						buffer_append(b,">");
						ERROR(buffer_data(b));
					}
				}
				state = IGNORE_SPACES;
				next = WAIT_END_RET;
				continue;
			}
			break;
		case COMMENT:
			if( c == '-' && p[1] == '-' && p[2] == '>' ) {
				val_ocall1(callb,id_comment,copy_string(start,p-start));
				p += 2;
				state = BEGIN;
			}
			break;
		case DOCTYPE:
			if( c == '[' )
				nbrackets++;
			else if( c == ']' )
				nbrackets--;
			else if( c == '>' && nbrackets == 0 ) {
				val_ocall1(callb,id_doctype,copy_string(start,p-start));
				state = BEGIN;
			}
			break;
		case HEADER:
			if( c == '?' && p[1] == '>' ) {
				p++;
				val_ocall1(callb,id_comment,copy_string(start,p-start));
				state = BEGIN;
			}
			break;
		}
		c = *++p;
		if( c == '\n' )
			(*line)++;
	}
	if( state == BEGIN ) {
		start = p;
		state = PCDATA;
	}
	if( parentname == NULL && state == PCDATA ) {
		if( p != start || nsubs == 0 )
			val_ocall1(callb,id_pcdata,copy_string(start,p-start));
		return;
	}
	ERROR("Unexpected end");
}

// ----------------------------------------------

/**
	<doc>
	<h1>Xml</h1>
	<p>
	The standard event-driven XML parser.
	</p>
	</doc>
**/

/**
	parse_xml : xml:string -> events:object -> void
	<doc>
	The [parse_xml] parse a string and for each parsed element call the
	corresponding object method in [events] :
	<ul>
	<li>[void xml( name : string, attribs : object)] when an XML node is found</li>
	<li>[void done()] when an XML node is closed</li>
	<li>[void pcdata(string)] when PCData chars found</li>
	<li>[void cdata(string)] when a CData session is found</li>
	<li>[void comment(string)] when some comment or special header is found</li>
	</ul>
	You can then implement the events so they build the appropriate XML data
	structure needed by your language.
	</doc>
**/
static value parse_xml( value str, value callb ) {
	const char *p;
	int line = 0;
	val_check(str,string);
	val_check(callb,object);
	p = val_string(str);
	// skip BOM
	if( p[0] == (char)0xEF && p[1] == (char)0xBB && p[2] == (char)0xBF )
		p += 3;
	do_parse_xml(p,&p,&line,callb,NULL);
	return alloc_bool(true);
}

DEFINE_PRIM(parse_xml,2);

/* ************************************************************************ */

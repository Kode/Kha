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
#include <stdio.h>
#ifdef HL_WIN
#	include <windows.h>
#	define fopen(name,mode) _wfopen(name,mode)
#	define HL_UFOPEN
#endif

typedef struct _hl_fdesc hl_fdesc;
struct _hl_fdesc {
	void (*finalize)( hl_fdesc * );
	FILE *f;
};

static void fdesc_finalize( hl_fdesc *f ) {
	if( f->f ) fclose(f->f);
}

hl_fdesc *hl_file_open( vbyte *name, int mode, bool binary ) {
#	ifdef HL_UFOPEN
	static const uchar *MODES[] = { USTR("r"), USTR("w"), USTR("a"), NULL, USTR("rb"), USTR("wb"), USTR("ab") };
	FILE *f = fopen((uchar*)name,MODES[mode|(binary?4:0)]);
#	else
	static const char *MODES[] = { "r", "w", "a", NULL, "rb", "wb", "ab" };
	FILE *f = fopen((char*)name,MODES[mode|(binary?4:0)]);
#	endif
	hl_fdesc *fd;
	if( f == NULL ) return NULL;
	fd = (hl_fdesc*)hl_gc_alloc_finalizer(sizeof(hl_fdesc));
	fd->finalize = fdesc_finalize;
	fd->f = f;
	return fd;
}

void hl_file_close( hl_fdesc *f ) {	
	if( f->f ) fclose(f->f);
	f->f = NULL;
}

int hl_file_write( hl_fdesc *f, vbyte *buf, int pos, int len ) {
	return (int)fwrite(buf+pos,1,len,f->f);
}

int hl_file_read( hl_fdesc *f, vbyte *buf, int pos, int len ) {
	return (int)fread((char*)buf+pos,1,len,f->f);
}

bool hl_file_write_char( hl_fdesc *f, int c ) {
	unsigned char cc = (unsigned char)c;
	return fwrite(&cc,1,1,f->f) == 1;
}

int hl_file_read_char( hl_fdesc *f ) {
	unsigned char cc;
	if( fread(&cc,1,1,f->f) != 1 )
		return -2;
	return cc;
}

bool hl_file_seek( hl_fdesc *f, int pos, int kind ) {
	return fseek(f->f,pos,kind) == 0;
}

int hl_file_tell( hl_fdesc *f ) {
	return ftell(f->f);
}

bool hl_file_eof( hl_fdesc *f ) {
	return feof(f->f);
}

bool hl_file_flush( hl_fdesc *f ) {
	return fflush( f->f ) == 0;
}

#define MAKE_STDIO(k) \
	hl_fdesc *hl_file_##k() { \
		hl_fdesc *f; \
		f = (hl_fdesc*)hl_gc_alloc_noptr(sizeof(hl_fdesc)); \
		f->f = k; \
		f->finalize = NULL; \
		return f; \
	}

MAKE_STDIO(stdin);
MAKE_STDIO(stdout);
MAKE_STDIO(stderr);

vbyte *hl_file_contents( vbyte *name, int *size ) {
	int len;
	int p = 0;
	vbyte *content;
#	ifdef HL_UFOPEN
	FILE *f = fopen((uchar*)name,USTR("rb"));
#	else
	FILE *f = fopen((char*)name,"rb");
#	endif
	if( f == NULL )
		return NULL;
	fseek(f,0,SEEK_END);
	len = ftell(f);
	*size = len;
	fseek(f,0,SEEK_SET);
	content = (vbyte*)hl_gc_alloc_noptr(len+1);
	content[len] = 0; // final 0 for UTF8
	while( len > 0 ) {
		int d = (int)fread((char*)content + p,1,len,f);
		if( d <= 0 ) {
			fclose(f);
			return NULL;
		}
		p += d;
		len -= d;
	}
	fclose(f);
	return content;
}

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
#if defined(__GNUC__) && !defined(__APPLE__)
#	define _FILE_OFFSET_BITS 64
#endif

#include <hl.h>
#include <stdio.h>
#ifdef HL_CONSOLE
#	include <posix/posix.h>
#endif
#ifdef HL_WIN
#ifdef HL_WIN_DESKTOP
#	include <windows.h>
#	include <io.h>
#	include <fcntl.h>
#else
#	include<xdk.h>
#endif
#	define fopen(name,mode) _wfopen(name,mode)
#	define HL_UFOPEN
#endif

#ifdef HL_WIN_DESKTOP
#	define SET_IS_STD(f,b) (f)->is_std = b
#else
#	define SET_IS_STD(f,b)
#endif

typedef struct _hl_fdesc hl_fdesc;
struct _hl_fdesc {
	void (*finalize)( hl_fdesc * );
	FILE *f;
#	ifdef HL_WIN_DESKTOP
	bool is_std;
#	endif
};

static void fdesc_finalize( hl_fdesc *f ) {
	if( f->f ) fclose(f->f);
}

HL_PRIM hl_fdesc *hl_file_open( vbyte *name, int mode, bool binary ) {
#	ifdef HL_UFOPEN
	static const uchar *MODES[] = { USTR("r"), USTR("w"), USTR("a"), USTR("r+"), USTR("rb"), USTR("wb"), USTR("ab"), USTR("rb+") };
	FILE *f = fopen((uchar*)name,MODES[mode|(binary?4:0)]);
#	else
	static const char *MODES[] = { "r", "w", "a", "r+", "rb", "wb", "ab", "rb+" };
	FILE *f = fopen((char*)name,MODES[mode|(binary?4:0)]);
#	endif
	hl_fdesc *fd;
	if( f == NULL ) return NULL;
	fd = (hl_fdesc*)hl_gc_alloc_finalizer(sizeof(hl_fdesc));
	fd->finalize = fdesc_finalize;
	fd->f = f;
	SET_IS_STD(fd, false);
	return fd;
}

HL_PRIM bool hl_file_is_locked( vbyte *name ) {
#	ifdef HL_WIN
	HANDLE h = CreateFile((uchar*)name,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
	if( h == INVALID_HANDLE_VALUE ) return true;
	CloseHandle(h);
	return false;
#	else
	return false;
#	endif
}

HL_PRIM void hl_file_close( hl_fdesc *f ) {
	if( !f ) return;
	if( f->f ) fclose(f->f);
	f->f = NULL;
	f->finalize = NULL;
}

HL_PRIM int hl_file_write( hl_fdesc *f, vbyte *buf, int pos, int len ) {
	int ret;
	if( !f ) return -1;
	hl_blocking(true);
#	ifdef HL_WIN_DESKTOP
	if( f->is_std ) {
		// except utf8, handle the case where it's not \0 terminated
		uchar *out = (uchar*)malloc((len+1)*2);
		vbyte prev = buf[pos+len-1];
		if( buf[pos+len] ) buf[pos+len-1] = 0;
		int olen = hl_from_utf8(out,len,(const char*)(buf+pos));
		buf[pos+len-1] = prev;
		_setmode(fileno(f->f),_O_U8TEXT);
		ret = _write(fileno(f->f),out,olen<<1);
		_setmode(fileno(f->f),_O_TEXT);
		if( ret > 0 ) ret = len;
		free(out);
	} else
#	endif
	ret = (int)fwrite(buf+pos,1,len,f->f);
	hl_blocking(false);
	return ret;
}

HL_PRIM int hl_file_read( hl_fdesc *f, vbyte *buf, int pos, int len ) {
	int ret;
	if( !f ) return -1;
	hl_blocking(true);
	ret = (int)fread((char*)buf+pos,1,len,f->f);
	hl_blocking(false);
	return ret;
}

HL_PRIM bool hl_file_write_char( hl_fdesc *f, int c ) {
	size_t ret;
	unsigned char cc = (unsigned char)c;
	if( !f ) return false;
	hl_blocking(true);
#	ifdef HL_WIN_DESKTOP
	if( f->is_std ) {
		uchar wcc = cc;
		_setmode(fileno(f->f),_O_U8TEXT);
		ret = _write(fileno(f->f),&wcc,2);
		_setmode(fileno(f->f),_O_TEXT);
		if( ret > 0 ) ret = 1;
	} else
#	endif
	ret = fwrite(&cc,1,1,f->f);
	hl_blocking(false);
	return ret == 1;
}

HL_PRIM int hl_file_read_char( hl_fdesc *f ) {
	unsigned char cc;
	hl_blocking(true);
	if( !f || fread(&cc,1,1,f->f) != 1 ) {
		hl_blocking(false);
		return -2;
	}
	hl_blocking(false);
	return cc;
}

HL_PRIM bool hl_file_seek( hl_fdesc *f, int pos, int kind ) {
	if( !f ) return false;
	return fseek(f->f,pos,kind) == 0;
}

HL_PRIM int hl_file_tell( hl_fdesc *f ) {
	if( !f ) return -1;
	return (int)ftell(f->f);
}

HL_PRIM bool hl_file_seek2( hl_fdesc *f, double pos, int kind ) {
	if( !f ) return false;
#	ifdef HL_WIN
	return _fseeki64(f->f,(__int64)pos,kind) == 0;
#	else
	return fseek(f->f,(int64)pos,kind) == 0;
#	endif
}

HL_PRIM double hl_file_tell2( hl_fdesc *f ) {
	if( !f ) return -1;
#	ifdef HL_WIN
	return (double)_ftelli64(f->f);
#	else
	return (double)ftell(f->f);
#	endif
}

HL_PRIM bool hl_file_eof( hl_fdesc *f ) {
	if( !f ) return true;
	return (bool)feof(f->f);
}

HL_PRIM bool hl_file_flush( hl_fdesc *f ) {
	int ret;
	if( !f ) return false;
	hl_blocking(true);
	ret = fflush( f->f );
	hl_blocking(false);
	return ret == 0;
}

#define MAKE_STDIO(k) \
	HL_PRIM hl_fdesc *hl_file_##k() { \
		hl_fdesc *f; \
		f = (hl_fdesc*)hl_gc_alloc_noptr(sizeof(hl_fdesc)); \
		f->f = k; \
		f->finalize = NULL; \
		SET_IS_STD(f, true); \
		return f; \
	}

MAKE_STDIO(stdin);
MAKE_STDIO(stdout);
MAKE_STDIO(stderr);

HL_PRIM vbyte *hl_file_contents( vbyte *name, int *size ) {
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
	hl_blocking(true);
	fseek(f,0,SEEK_END);
	len = ftell(f);
	if( size ) *size = len;
	fseek(f,0,SEEK_SET);
	hl_blocking(false);
	content = (vbyte*)hl_gc_alloc_noptr(size ? len : len+1);
	hl_blocking(true);
	if( !size ) content[len] = 0; else if( !len ) content = (vbyte*)""; // final 0 for UTF8
	while( len > 0 ) {
		int d = (int)fread((char*)content + p,1,len,f);
		if( d <= 0 ) {
			hl_blocking(false);
			fclose(f);
			return NULL;
		}
		p += d;
		len -= d;
	}
	fclose(f);
	hl_blocking(false);
	return content;
}

#define _FILE _ABSTRACT(hl_fdesc)
DEFINE_PRIM(_FILE, file_open, _BYTES _I32 _BOOL);
DEFINE_PRIM(_VOID, file_close, _FILE);
DEFINE_PRIM(_I32, file_write, _FILE _BYTES _I32 _I32);
DEFINE_PRIM(_I32, file_read, _FILE _BYTES _I32 _I32);
DEFINE_PRIM(_BOOL, file_write_char, _FILE _I32);
DEFINE_PRIM(_I32, file_read_char, _FILE);
DEFINE_PRIM(_BOOL, file_seek, _FILE _I32 _I32);
DEFINE_PRIM(_I32, file_tell, _FILE);
DEFINE_PRIM(_BOOL, file_seek2, _FILE _F64 _I32);
DEFINE_PRIM(_F64, file_tell2, _FILE);
DEFINE_PRIM(_BOOL, file_eof, _FILE);
DEFINE_PRIM(_BOOL, file_flush, _FILE);
DEFINE_PRIM(_FILE, file_stdin, _NO_ARG);
DEFINE_PRIM(_FILE, file_stdout, _NO_ARG);
DEFINE_PRIM(_FILE, file_stderr, _NO_ARG);
DEFINE_PRIM(_BYTES, file_contents, _BYTES _REF(_I32));
DEFINE_PRIM(_BOOL, file_is_locked, _BYTES);


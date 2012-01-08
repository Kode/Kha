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
#include <stdio.h>
#include <string>
#ifdef NEKO_WINDOWS
#	include <windows.h>
#endif

/**
	<doc>
	<h1>File</h1>
	<p>
	The file api can be used for different kind of file I/O.
	</p>
	</doc>
**/

int __file_prims() { return 0; }

#if ANDROID
typedef std::string Filename;
typedef char FilenameChar;
#define val_filename val_string
#define alloc_filename alloc_string

#define MAKE_STDIO(k) \
	static value file_##k() { \
		fio *f; \
		f = new fio(#k,k); \
		value result = alloc_abstract(k_file,f); \
		val_gc(result,free_stdfile); \
		return result; \
	} \
	DEFINE_PRIM(file_##k,0);


#else
typedef std::wstring Filename;
typedef wchar_t FilenameChar;
#define val_filename val_wstring
#define alloc_filename alloc_wstring

#define MAKE_STDIO(k) \
	static value file_##k() { \
		fio *f; \
		f = new fio(L###k,k); \
		value result = alloc_abstract(k_file,f); \
		val_gc(result,free_stdfile); \
		return result; \
	} \
	DEFINE_PRIM(file_##k,0);


#endif

struct fio
{
   fio(const FilenameChar *inName, FILE *inFile=0) : io(inFile), name(inName) { }
   ~fio() { }

   void close()
   {
      if (io)
      {
         fclose(io);
         io = 0;
      }
   }
 
   Filename name;
   FILE         *io;
};

#define val_file(o)	((fio *)val_data(o))

static void free_file( value v )
{
	fio *file =  val_file(v);
	file->close();
	delete file;
	val_gc(v,NULL);
}

static void free_stdfile( value v )
{
        // Delete, but do not close...
	fio *file =  val_file(v);
	delete file;
	val_gc(v,NULL);
}




DECLARE_KIND(k_file);

static void file_error( const char *msg, fio *f, bool delete_f = false ) {
	gc_exit_blocking();
	value a = alloc_array(2);
	val_array_set_i(a,0,alloc_string(msg));
	val_array_set_i(a,1,alloc_filename(f->name.c_str()));
	if (delete_f)
		delete f;
	val_throw(a);
}

/**
	file_open : f:string -> r:string -> 'file
	<doc>
	Call the C function [fopen] with the file path and access rights. 
	Return the opened file or throw an exception if the file couldn't be open.
	</doc>
**/
static value file_open( value name, value r ) {
	val_check(name,string);
	val_check(r,string);
	fio *f = new fio(val_filename(name));
        const char *fname = val_string(name);
        const char *mode = val_string(r);
	gc_enter_blocking();
	f->io = fopen(fname,mode);
	if( f->io == NULL )
        {
		file_error("file_open",f,true);
        }
	gc_exit_blocking();
	value result =  alloc_abstract(k_file,f);
        val_gc(result,free_file);
	return result;
}

/**
	file_close : 'file -> void
	<doc>Close an file. Any other operations on this file will fail</doc> 
**/
static value file_close( value o ) {	
	fio *f;
	val_check_kind(o,k_file);
	f = val_file(o);
	f->close();
	return alloc_bool(true);
}

/**
	file_name : 'file -> string
	<doc>Return the name of the file which was opened</doc>
**/
static value file_name( value o ) {
	val_check_kind(o,k_file);
	return alloc_filename(val_file(o)->name.c_str());
}

/**
	file_write : 'file -> s:string -> p:int -> l:int -> int
	<doc>
	Write up to [l] chars of string [s] starting at position [p]. 
	Returns the number of chars written which is >= 0.
	</doc>
**/
static value file_write( value o, value s, value pp, value n ) {
	int p, len;
	int buflen;
	fio *f;
	val_check_kind(o,k_file);
	val_check(s,buffer);
	buffer buf = val_to_buffer(s);
	buflen = buffer_size(buf);
	val_check(pp,int);
	val_check(n,int);
	f = val_file(o);
	p = val_int(pp);
	len = val_int(n);
	if( p < 0 || len < 0 || p > buflen || p + len > buflen )
		return alloc_null();

	gc_enter_blocking();
	while( len > 0 ) {
		int d;
		POSIX_LABEL(file_write_again);
		d = (int)fwrite(buffer_data(buf)+p,1,len,f->io);
		if( d <= 0 ) {
			HANDLE_FINTR(f->io,file_write_again);
			file_error("file_write",f);
		}
		p += d;
		len -= d;
	}
	gc_exit_blocking();
	return n;
}

/**
	file_read : 'file -> s:string -> p:int -> l:int -> int
	<doc>
	Read up to [l] chars into the string [s] starting at position [p].
	Returns the number of chars readed which is > 0 (or 0 if l == 0).
	</doc>
**/
static value file_read( value o, value s, value pp, value n ) {
	fio *f;
	int p;
	int len;
	int buf_len;
	val_check_kind(o,k_file);
	val_check(s,buffer);
	buffer buf = val_to_buffer(s);
	buf_len = buffer_size(buf);
	val_check(pp,int);
	val_check(n,int);
	f = val_file(o);
	p = val_int(pp);
	len = val_int(n);
	if( p < 0 || len < 0 || p > buf_len || p + len > buf_len )
		return alloc_null();
	gc_enter_blocking();
	while( len > 0 ) {
		int d;
		POSIX_LABEL(file_read_again);
		d = (int)fread(buffer_data(buf)+p,1,len,f->io);
		if( d <= 0 ) {
			int size = val_int(n) - len;
			HANDLE_FINTR(f->io,file_read_again);
			if( size == 0 )
				file_error("file_read",f);
			return alloc_int(size);
		}
		p += d;
		len -= d;
	}
	gc_exit_blocking();
	return n;
}

/**
	file_write_char : 'file -> c:int -> void
	<doc>Write the char [c]. Error if [c] outside of the range 0..255</doc>
**/
static value file_write_char( value o, value c ) {
	unsigned char cc;
	fio *f;
	val_check(c,int);
	val_check_kind(o,k_file);
	if( val_int(c) < 0 || val_int(c) > 255 )
		return alloc_null();
	cc = (char)val_int(c);
	f = val_file(o);
	gc_enter_blocking();
	POSIX_LABEL(write_char_again);
	if( fwrite(&cc,1,1,f->io) != 1 ) {
		HANDLE_FINTR(f->io,write_char_again);
		file_error("file_write_char",f);
	}
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	file_read_char : 'file -> int
	<doc>Read a char from the file. Exception on error</doc>
**/
static value file_read_char( value o ) {
	unsigned char cc;
	fio *f;
	val_check_kind(o,k_file);
	f = val_file(o);
	gc_enter_blocking();
	POSIX_LABEL(read_char_again);
	if( fread(&cc,1,1,f->io) != 1 ) {
		HANDLE_FINTR(f->io,read_char_again);
		file_error("file_read_char",f);
	}
	gc_exit_blocking();
	return alloc_int(cc);
}

/**
	file_seek : 'file -> pos:int -> mode:int -> void
	<doc>Use [fseek] to move the file pointer.</doc>
**/
static value file_seek( value o, value pos, value kind ) {
	fio *f;
	val_check_kind(o,k_file);
	val_check(pos,int);
	val_check(kind,int);
	f = val_file(o);
	gc_enter_blocking();
	if( fseek(f->io,val_int(pos),val_int(kind)) != 0 )
		file_error("file_seek",f);
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	file_tell : 'file -> int
	<doc>Return the current position in the file</doc>
**/
static value file_tell( value o ) {
	int p;
	fio *f;
	val_check_kind(o,k_file);
	f = val_file(o);
	gc_enter_blocking();
	p = ftell(f->io);
	if( p == -1 )
		file_error("file_tell",f);
	gc_exit_blocking();
	return alloc_int(p);
}

/**
	file_eof : 'file -> bool
	<doc>Tell if we have reached the end of the file</doc>
**/
static value file_eof( value o ) {
	val_check_kind(o,k_file);
	return alloc_bool( feof(val_file(o)->io) );
}

/**
	file_flush : 'file -> void
	<doc>Flush the file buffer</doc>
**/
static value file_flush( value o ) {
	fio *f;
	val_check_kind(o,k_file);
	f = val_file(o);
	gc_enter_blocking();
	if( fflush( f->io ) != 0 )
		file_error("file_flush",f);
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	file_contents : f:string -> string
	<doc>Read the content of the file [f] and return it.</doc>
**/
static value file_contents( value name ) {
	buffer s;
	int len;
	int p;
	val_check(name,string);
	fio f(val_filename(name));
        const char *fname = val_string(name);
	gc_enter_blocking();
	f.io = fopen(fname,"rb");
	if( f.io == NULL )
		file_error("file_contents",&f);
	fseek(f.io,0,SEEK_END);
	len = ftell(f.io);
	fseek(f.io,0,SEEK_SET);
	gc_exit_blocking();
	s = alloc_buffer_len(len);
	p = 0;
	gc_enter_blocking();
	while( len > 0 ) {
		int d;
		POSIX_LABEL(file_contents);
		d = (int)fread((char*)buffer_data(s)+p,1,len,f.io);
		if( d <= 0 ) {
			HANDLE_FINTR(f.io,file_contents);
			fclose(f.io);
			file_error("file_contents",&f);
		}
		p += d;
		len -= d;
	}	
	fclose(f.io);
	gc_exit_blocking();
	return buffer_val(s);
}


/**
	file_stdin : void -> 'file
	<doc>The standard input</doc>
**/
MAKE_STDIO(stdin);
/**
	file_stdout : void -> 'file
	<doc>The standard output</doc>
**/
MAKE_STDIO(stdout);
/**
	file_stderr : void -> 'file
	<doc>The standard error output</doc>
**/
MAKE_STDIO(stderr);

DEFINE_PRIM(file_open,2);
DEFINE_PRIM(file_close,1);
DEFINE_PRIM(file_name,1);
DEFINE_PRIM(file_write,4);
DEFINE_PRIM(file_read,4);
DEFINE_PRIM(file_write_char,2);
DEFINE_PRIM(file_read_char,1);
DEFINE_PRIM(file_seek,3);
DEFINE_PRIM(file_tell,1);
DEFINE_PRIM(file_eof,1);
DEFINE_PRIM(file_flush,1);
DEFINE_PRIM(file_contents,1);

/* ************************************************************************ */

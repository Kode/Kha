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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <locale.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifdef HL_WIN
#	include <windows.h>
#	include <direct.h>
#	include <conio.h>
#	define getenv _wgetenv
#	define putenv _wputenv
#	define getcwd(buf,size) (void*)(int_val)GetCurrentDirectoryW(size,buf)
#	define chdir	!SetCurrentDirectoryW
#	define system	_wsystem
typedef struct _stat32 pstat;
#	define stat		_wstat32
#	define unlink	_wunlink
#	define rename	_wrename
#	define mkdir(path,mode)	_wmkdir(path)
#	define rmdir	_wrmdir
#else
#	include <errno.h>
#	include <unistd.h>
#	include <dirent.h>
#	include <limits.h>
#	include <termios.h>
#	include <sys/time.h>
#	include <sys/times.h>
#	include <sys/wait.h>
#	include <locale.h>
#	define HL_UTF8PATH
typedef struct stat pstat;
#endif

#ifdef HL_UTF8PATH
typedef char pchar;
#define pstrchr strchr
#define pstrlen	strlen
#else
typedef uchar pchar;
#define pstrchr wcschr
#define pstrlen	ustrlen
#endif

#ifdef HL_MAC
#	include <sys/syslimits.h>
#	include <limits.h>
#	include <mach-o/dyld.h>
#endif

#ifndef CLK_TCK
#	define CLK_TCK	100
#endif

static pchar *pstrdup( const pchar *s, int len ) {
	pchar *ret;
	if( len < 0 ) len = (int)pstrlen(s);
	ret = (pchar*)hl_copy_bytes((vbyte*)s,sizeof(pchar)*(len+1));;
	ret[len] = 0;
	return ret;
}

HL_PRIM bool hl_sys_utf8_path() {
#ifdef HL_UTF8_PATH
	return true;
#else
	return false;
#endif
}

HL_PRIM vbyte *hl_sys_string() {
#if defined(HL_WIN) || defined(HL_CYGWIN) || defined(HL_MINGW)
	return (vbyte*)USTR("Windows");
#elif defined(HL_GNUKBSD)
	return (vbyte*)USTR("GNU/kFreeBSD");
#elif defined(HL_LINUX)
	return (vbyte*)USTR("Linux");
#elif defined(HL_BSD)
	return (vbyte*)USTR("BSD");
#elif defined(HL_MAC)
	return (vbyte*)USTR("Mac");
#else
#error Unknow system string
#endif
}

HL_PRIM void hl_sys_print( vbyte *msg ) {
	uprintf(USTR("%s"),(uchar*)msg);
}

HL_PRIM void hl_sys_exit( int code ) {
	exit(code);
}

HL_PRIM double hl_sys_time() {
#ifdef HL_WIN
#define EPOCH_DIFF	(134774*24*60*60.0)
	SYSTEMTIME t;
	FILETIME ft;
    ULARGE_INTEGER ui;
	GetSystemTime(&t);
	if( !SystemTimeToFileTime(&t,&ft) )
		return 0.;
    ui.LowPart = ft.dwLowDateTime;
    ui.HighPart = ft.dwHighDateTime;
	return ((double)ui.QuadPart) / 10000000.0 - EPOCH_DIFF;
#else
	struct timeval tv;
	if( gettimeofday(&tv,NULL) != 0 )
		return 0.;
	return tv.tv_sec + ((double)tv.tv_usec) / 1000000.0;
#endif
}

HL_PRIM int hl_random( int max ) {
	if( max <= 0 ) return 0;
	return rand() % max;
}

vbyte *hl_sys_get_env( vbyte *v ) {
	return (vbyte*)getenv((pchar*)v);
}

bool hl_sys_put_env( vbyte *e, vbyte *v ) {
#ifdef HL_WIN
	hl_buffer *b = hl_alloc_buffer();
	hl_buffer_str(b,(uchar*)e);
	hl_buffer_char(b,'=');
	if( v ) hl_buffer_str(b,(uchar*)v);
	return putenv(hl_buffer_content(b,NULL)) == 0;
#else
	if( v == NULL ) return unsetenv((char*)e) == 0;
	return setenv((char*)e,(char*)v,1) == 0;
#endif
}

#ifdef HL_MAC
#	define environ (*_NSGetEnviron())
#endif

#ifdef HL_WIN
#	undef environ
#	define environ _wenviron
#else
extern char **environ;
#endif

varray *hl_sys_env() {
	varray *a;
	pchar **e = environ;
	pchar **arr;
	int count = 0;
	while( *e ) {
		pchar *x = pstrchr(*e,'=');
		if( x == NULL ) {
			e++;
			continue;
		}
		count++;
	}
	a = hl_alloc_array(&hlt_bytes,count*2);
	e = environ;
	arr = hl_aptr(a,pchar*);
	while( *e ) {
		pchar *x = pstrchr(*e,'=');
		if( x == NULL ) {
			e++;
			continue;
		}
		*arr++ = pstrdup(*e,(int)(x - *e));
		*arr++ = pstrdup(x,-1);
		e++;
	}
	return a;
}


void hl_sys_sleep( double f ) {
#ifdef HL_WIN
	Sleep((DWORD)(f * 1000));
#else
	struct timespec t;
	t.tv_sec = (int)f;
	t.tv_nsec = (int)((f - t.tv_sec) * 1e9);
	nanosleep(&t,NULL);
#endif
}

bool hl_sys_set_time_locale( vbyte *l ) {
#ifdef HL_POSIX
	locale_t lc, old;
	lc = newlocale(LC_TIME_MASK,(char*)l,NULL);
	if( lc == NULL ) return false;
	old = uselocale(lc);
	if( old == NULL ) {
		freelocale(lc);
		return false;
	}
	if( old != LC_GLOBAL_LOCALE )
		freelocale(old);
	return true;
#else
	return setlocale(LC_TIME,(char*)l) != NULL;
#endif
}


vbyte *hl_sys_get_cwd() {
	pchar buf[256];
	int l;
	if( getcwd(buf,256) == NULL )
		return NULL;
	l = (int)pstrlen(buf);
	if( buf[l-1] != '/' && buf[l-1] != '\\' ) {
		buf[l] = '/';
		buf[l+1] = 0;
	}
	return (vbyte*)pstrdup(buf,-1);
}

bool hl_sys_set_cwd( vbyte *dir ) {
	return chdir((pchar*)dir) == 0;
}

bool hl_sys_is64() {
#ifdef HL_64
	return true;
#else
	return false;
#endif
}

int hl_sys_command( vbyte *cmd ) {
#ifdef HL_WIN
	return system((pchar*)cmd);
#else
	int status = system((pchar*)cmd);
	return WEXITSTATUS(status) | (WTERMSIG(status) << 8);
#endif
}

bool hl_sys_exists( vbyte *path ) {
	pstat st;
	return stat((pchar*)path,&st) == 0;
}

bool hl_sys_delete( vbyte *path ) {
	return unlink((pchar*)path) == 0;
}

bool hl_sys_rename( vbyte *path, vbyte *newname ) {
	return rename((pchar*)path,(pchar*)newname) == 0;
}

varray *hl_sys_stat( vbyte *path ) {
	pstat s;
	varray *a;
	int *i;
	if( stat((pchar*)path,&s) != 0 )
		return NULL;
	a = hl_alloc_array(&hlt_i32,12);
	i = hl_aptr(a,int);
	*i++ = s.st_gid;
	*i++ = s.st_uid;
	*i++ = s.st_atime;
	*i++ = s.st_mtime;
	*i++ = s.st_ctime;
	*i++ = s.st_size;
	*i++ = s.st_dev;
	*i++ = s.st_ino;
	*i++ = s.st_nlink;
	*i++ = s.st_rdev;
	*i++ = s.st_mode;
	return a;
}

bool hl_sys_is_dir( vbyte *path ) {
	pstat s;
	if( stat((pchar*)path,&s) != 0 )
		return false;
	return (s.st_mode & S_IFDIR) != 0;
}

bool hl_sys_create_dir( vbyte *path, int mode ) {
	return mkdir((pchar*)path,mode) == 0;
}

bool hl_sys_remove_dir( vbyte *path ) {
	return rmdir((pchar*)path) == 0;
}

double hl_sys_cpu_time() {
#ifdef HL_WIN
	FILETIME unused;
	FILETIME stime;
	FILETIME utime;
	if( !GetProcessTimes(GetCurrentProcess(),&unused,&unused,&stime,&utime) )
		return 0.;
	return ((double)(utime.dwHighDateTime+stime.dwHighDateTime)) * 65.536 * 6.5536 + (((double)utime.dwLowDateTime + (double)stime.dwLowDateTime) / 10000000);
#else
	struct tms t;
	times(&t);
	return ((double)(t.tms_utime + t.tms_stime)) / CLK_TCK;
#endif
}

double hl_sys_thread_cpu_time() {
#if defined(HL_WIN)
	FILETIME unused;
	FILETIME utime;
	if( !GetThreadTimes(GetCurrentThread(),&unused,&unused,&unused,&utime) )
		return 0.;
	return ((double)utime.dwHighDateTime) * 65.536 * 6.5536 + (((double)utime.dwLowDateTime) / 10000000);
#elif defined(HL_MAC)
	hl_error("sys_thread_cpu_time not implemented on OSX");
	return 0.;
#else
	struct timespec t;
	if( clock_gettime(CLOCK_THREAD_CPUTIME_ID,&t) )
		return 0.;
	return t.tv_sec + t.tv_nsec * 1e-9;
#endif
}

varray *hl_sys_read_dir( vbyte *_path ) {
	pchar *path = (pchar*)_path;
	int count = 0;
	int pos = 0;
	varray *a = NULL;
	pchar **current = NULL;

#ifdef HL_WIN
	WIN32_FIND_DATAW d;
	HANDLE handle;
	hl_buffer *b = hl_alloc_buffer();
	int len = (int)pstrlen(path);
	hl_buffer_str(b,path);
	if( len && path[len-1] != '/' && path[len-1] != '\\' )
		hl_buffer_str(b,USTR("/*.*"));
	else
		hl_buffer_str(b,USTR("*.*"));
	path = hl_buffer_content(b,NULL);
	handle = FindFirstFileW(path,&d);
	if( handle == INVALID_HANDLE_VALUE )
		return NULL;
	while( true ) {
		// skip magic dirs
		if( d.cFileName[0] != '.' || (d.cFileName[1] != 0 && (d.cFileName[1] != '.' || d.cFileName[2] != 0)) ) {
			if( pos == count ) {
				int ncount = count == 0 ? 16 : count * 2;
				varray *narr = hl_alloc_array(&hlt_bytes,count);
				pchar **ncur = hl_aptr(narr,pchar*);
				memcpy(ncur,current,count*sizeof(void*));
				current = ncur;
				a = narr;
				count = ncount;
			}
			current[pos++] = pstrdup(d.cFileName,-1);
		}
		if( !FindNextFileW(handle,&d) )
			break;
	}
	FindClose(handle);
#else
	DIR *d;
	struct dirent *e;
	d = opendir(path);
	if( d == NULL )
		return NULL;
	while( true ) {
		e = readdir(d);
		if( e == NULL )
			break;
		// skip magic dirs
		if( e->d_name[0] == '.' && (e->d_name[1] == 0 || (e->d_name[1] == '.' && e->d_name[2] == 0)) )
			continue;
		if( pos == count ) {
			int ncount = count == 0 ? 16 : count * 2;
			varray *narr = hl_alloc_array(&hlt_bytes,count);
			pchar **ncur = hl_aptr(narr,pchar*);
			memcpy(ncur,current,count*sizeof(void*));
			current = ncur;
			a = narr;
			count = ncount;
		}
		current[pos++] = pstrdup(e->d_name,-1);
	}
	closedir(d);
#endif
	if( a == NULL ) a = hl_alloc_array(&hlt_bytes,0);
	a->size = pos;
	return a;
}

vbyte *hl_sys_full_path( vbyte *path ) {
#ifdef HL_WIN
	pchar buf[MAX_PATH+1];
	if( GetFullPathNameW((pchar*)path,MAX_PATH+1,buf,NULL) == 0 )
		return NULL;
	return (vbyte*)pstrdup(buf,-1);
#else
	pchar buf[PATH_MAX];
	if( realpath((pchar*)path,buf) == NULL )
		return NULL;
	return (vbyte*)pstrdup(buf,-1);
#endif
}

vbyte *hl_sys_exe_path() {
#if defined(HL_WIN)
	pchar path[MAX_PATH];
	if( GetModuleFileNameW(NULL,path,MAX_PATH) == 0 )
		return NULL;
	return (vbyte*)pstrdup(path,-1);
#elif defined(HL_MAC)
	pchar path[PATH_MAX+1];
	uint32_t path_len = PATH_MAX;
	if( _NSGetExecutablePath(path, &path_len) )
		return NULL;
	return (vbyte*)pstrdup(path,-1);
#else
	const pchar *p = getenv("_");
	if( p != NULL )
		return (vbyte*)pstrdup(p,-1);
	{
		pchar path[PATH_MAX];
		int length = readlink("/proc/self/exe", path, sizeof(path));
		if( length < 0 )
			return NULL;
	    path[length] = '\0';
		return (vbyte*)pstrdup(path,-1);
	}
#endif
}

int hl_sys_get_char( bool b ) {
#	ifdef HL_WIN
	return b?getche():getch();
#	else
	// took some time to figure out how to do that
	// without relying on ncurses, which clear the
	// terminal on initscr()
	int c;
	struct termios term, old;
	tcgetattr(fileno(stdin), &old);
	term = old;
	cfmakeraw(&term);
	tcsetattr(fileno(stdin), 0, &term);
	c = getchar();
	tcsetattr(fileno(stdin), 0, &old);
	if( b ) fputc(c,stdout);
	return c;
#	endif
}

#ifndef HL_JIT

#include <hlc.h>
#if defined(HL_VCC) && defined(_DEBUG)
#	include <crtdbg.h>
#else
#	define _CrtSetDbgFlag(x)
#endif

extern void hl_entry_point();

static char **sys_args;
static int sys_nargs;

varray *hl_sys_args() {
	varray *a = hl_alloc_array(&hlt_bytes,sys_nargs);
	int i;
	for(i=0;i<sys_nargs;i++)
		hl_aptr(a,char*)[i] = sys_args[i];
	return a;
}

extern void run_kore();

int kore( int argc, char **argv ) {
	hl_trap_ctx ctx;
	vdynamic *exc;
	sys_args = argv + 1;
	sys_nargs = argc - 1;
	_CrtSetDbgFlag ( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_DELAY_FREE_MEM_DF /*| _CRTDBG_LEAK_CHECK_DF | _CRTDBG_CHECK_ALWAYS_DF*/ );
	hlc_trap(ctx,exc,on_exception);
	hl_entry_point();
	run_kore();
	return 0;
on_exception:
	uprintf(USTR("Uncaught exception: %s\n"),hl_to_string(exc));
	return 1;
}

#endif

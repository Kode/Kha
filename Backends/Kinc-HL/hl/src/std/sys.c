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

#ifdef HL_CONSOLE
#	include <posix/posix.h>
#endif
#if !defined(HL_CONSOLE) || defined(HL_WIN_DESKTOP)
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <locale.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#if defined(HL_WIN)
#	include <windows.h>
#	include <direct.h>
#	include <conio.h>
#	include <fcntl.h>
#	include <io.h>
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
#	include <limits.h>
#	include <sys/time.h>
#	include <dirent.h>
#	include <termios.h>
#	include <sys/times.h>
#	include <sys/wait.h>
#	include <locale.h>
#	define HL_UTF8PATH
typedef struct stat pstat;
#endif

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
#ifdef HL_UTF8PATH
	return true;
#else
	return false;
#endif
}

HL_PRIM vbyte *hl_sys_string() {
#if defined(HL_CONSOLE)
	return (vbyte*)sys_platform_name();
#elif defined(HL_WIN) || defined(HL_CYGWIN) || defined(HL_MINGW)
	return (vbyte*)USTR("Windows");
#elif defined(HL_BSD)
	return (vbyte*)USTR("BSD");
#elif defined(HL_MAC)
	return (vbyte*)USTR("Mac");
#elif defined(HL_IOS)
	return (vbyte*)USTR("iOS");
#elif defined(HL_TVOS)
	return (vbyte*)USTR("tvOS");
#elif defined(HL_ANDROID)
	return (vbyte*)USTR("Android");
#elif defined(HL_GNUKBSD)
	return (vbyte*)USTR("GNU/kFreeBSD");
#elif defined(HL_LINUX)
	return (vbyte*)USTR("Linux");
#else
#error Unknown system string
#endif
}

HL_PRIM vbyte *hl_sys_locale() {
#if defined(HL_WIN_DESKTOP)
	wchar_t loc[LOCALE_NAME_MAX_LENGTH];
	int len = GetSystemDefaultLocaleName(loc,LOCALE_NAME_MAX_LENGTH);
	return len == 0 ? NULL : hl_copy_bytes((vbyte*)loc,(len+1)*2);
#elif defined(HL_CONSOLE)
	return (vbyte*)sys_get_user_lang();
#else
	return (vbyte*)getenv("LANG");
#endif
}

#define PR_WIN_UTF8 1
#define PR_AUTO_FLUSH 2
static int print_flags = PR_AUTO_FLUSH;

HL_PRIM int hl_sys_set_flags( int flags ) {
	return print_flags = flags;
}

HL_PRIM void hl_sys_print( vbyte *msg ) {
	hl_blocking(true);
#	ifdef HL_XBO
	OutputDebugStringW((LPCWSTR)msg);
#	else	
#	ifdef HL_WIN_DESKTOP
	if( print_flags & PR_WIN_UTF8 ) _setmode(_fileno(stdout),_O_U8TEXT);
#	endif
	uprintf(USTR("%s"),(uchar*)msg);
	if( print_flags & PR_AUTO_FLUSH ) fflush(stdout);
#	ifdef HL_WIN_DESKTOP
	if( print_flags & PR_WIN_UTF8 ) _setmode(_fileno(stdout),_O_TEXT);
#	endif

#	endif
	hl_blocking(false);
}


static void *f_before_exit = NULL;
static void *f_profile_event = NULL;
HL_PRIM void hl_setup_profiler( void *profile_event, void *before_exit ) {
	f_before_exit = before_exit;
	f_profile_event = profile_event;
}

HL_PRIM void hl_sys_profile_event( int code, vbyte *data, int dataLen ) {
	if( f_profile_event ) ((void(*)(int,vbyte*,int))f_profile_event)(code,data,dataLen);
}

HL_PRIM void hl_sys_exit( int code ) {
	if( f_before_exit ) ((void(*)())f_before_exit)();
	exit(code);
}

#ifdef HL_DEBUG_REPRO
static double CURT = 0;
#endif

HL_PRIM double hl_sys_time() {
#ifdef HL_DEBUG_REPRO
	CURT += 0.001;
	return CURT;
#endif
#ifdef HL_WIN
	#define EPOCH_DIFF	(134774*24*60*60.0)
	static double time_diff = 0.;
	static double freq = 0.;
	LARGE_INTEGER time;

	if( freq == 0 ) {
		QueryPerformanceFrequency(&time);
		freq = (double)time.QuadPart;
	}
	QueryPerformanceCounter(&time);
	if( time_diff == 0 ) {
		FILETIME ft;
		LARGE_INTEGER start_time;
		GetSystemTimeAsFileTime(&ft);
		start_time.LowPart = ft.dwLowDateTime;
		start_time.HighPart = ft.dwHighDateTime;
		time_diff = (((double)start_time.QuadPart) / 10000000.0) - (((double)time.QuadPart) / freq) - EPOCH_DIFF;
	}
	return time_diff + ((double)time.QuadPart) / freq;
#else
	struct timeval tv;
	if( gettimeofday(&tv,NULL) != 0 )
		return 0.;
	return tv.tv_sec + ((double)tv.tv_usec) / 1000000.0;
#endif
}

HL_PRIM vbyte *hl_sys_get_env( vbyte *v ) {
	return (vbyte*)getenv((pchar*)v);
}

HL_PRIM bool hl_sys_put_env( vbyte *e, vbyte *v ) {
#if defined(HL_WIN)
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

#ifdef HL_WIN_DESKTOP
#	undef environ
#	define environ _wenviron
#else
extern pchar **environ;
#endif

HL_PRIM varray *hl_sys_env() {
	varray *a;
	pchar **e = environ;
	pchar **arr;
	int count = 0;
#	ifdef HL_WIN_DESKTOP
	if( e == NULL ) {
		_wgetenv(L"");
		e = environ;
	}
#	endif
	while( *e ) {
		pchar *x = pstrchr(*e,'=');
		if( x == NULL ) {
			e++;
			continue;
		}
		count++;
		e++;
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
		*arr++ = pstrdup(x+1,-1);
		e++;
	}
	return a;
}


HL_PRIM void hl_sys_sleep( double f ) {
	hl_blocking(true);
#if defined(HL_WIN)
	Sleep((DWORD)(f * 1000));
#else
	struct timespec t;
	t.tv_sec = (int)f;
	t.tv_nsec = (int)((f - t.tv_sec) * 1e9);
	nanosleep(&t,NULL);
#endif
	hl_blocking(false);
}

HL_PRIM bool hl_sys_set_time_locale( vbyte *l ) {
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


HL_PRIM vbyte *hl_sys_get_cwd() {
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

HL_PRIM bool hl_sys_set_cwd( vbyte *dir ) {
	return chdir((pchar*)dir) == 0;
}

HL_PRIM bool hl_sys_is64() {
#ifdef HL_64
	return true;
#else
	return false;
#endif
}

HL_PRIM int hl_sys_command( vbyte *cmd ) {
#if defined(HL_WIN)
	int ret;
	hl_blocking(true);
	ret = system((pchar*)cmd);
	hl_blocking(false);
	return ret;
#else
	int status;
	hl_blocking(true);
#if defined(HL_IOS) || defined(HL_TVOS)
	status = 0;
	hl_error("hl_sys_command() not available on this platform");
#else
	status = system((pchar*)cmd);
#endif
	hl_blocking(false);
	return WEXITSTATUS(status) | (WTERMSIG(status) << 8);
#endif
}

HL_PRIM bool hl_sys_exists( vbyte *path ) {
	pstat st;
	return stat((pchar*)path,&st) == 0;
}

HL_PRIM bool hl_sys_delete( vbyte *path ) {
	return unlink((pchar*)path) == 0;
}

HL_PRIM bool hl_sys_rename( vbyte *path, vbyte *newname ) {
	return rename((pchar*)path,(pchar*)newname) == 0;
}

HL_PRIM varray *hl_sys_stat( vbyte *path ) {
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

HL_PRIM bool hl_sys_is_dir( vbyte *path ) {
	pstat s;
	if( stat((pchar*)path,&s) != 0 )
		return false;
	return (s.st_mode & S_IFDIR) != 0;
}

HL_PRIM bool hl_sys_create_dir( vbyte *path, int mode ) {
	return mkdir((pchar*)path,mode) == 0;
}

HL_PRIM bool hl_sys_remove_dir( vbyte *path ) {
	return rmdir((pchar*)path) == 0;
}

HL_PRIM int hl_sys_getpid() {
#ifdef HL_WIN
	return GetCurrentProcessId();
#else
	return getpid();
#endif
}

HL_PRIM double hl_sys_cpu_time() {
#if defined(HL_WIN)
	FILETIME unused;
	FILETIME stime;
	FILETIME utime;
	if( !GetProcessTimes(GetCurrentProcess(),&unused,&unused,&stime,&utime) )
		return 0.;
	return ((double)(utime.dwHighDateTime+stime.dwHighDateTime)) * 65.536 * 6.5536 + (((double)utime.dwLowDateTime + (double)stime.dwLowDateTime) / 10000000);
#else
	struct tms t = {0};
	times(&t);
	return ((double)(t.tms_utime + t.tms_stime)) / CLK_TCK;
#endif
}

HL_PRIM double hl_sys_thread_cpu_time() {
#if defined(HL_WIN)
	FILETIME unused;
	FILETIME utime;
	if( !GetThreadTimes(GetCurrentThread(),&unused,&unused,&unused,&utime) )
		return 0.;
	return ((double)utime.dwHighDateTime) * 65.536 * 6.5536 + (((double)utime.dwLowDateTime) / 10000000);
#elif defined(HL_MAC) || defined(HL_CONSOLE)
	hl_error("sys_thread_cpu_time not implemented on this platform");
	return 0.;
#else
	struct timespec t;
	if( clock_gettime(CLOCK_THREAD_CPUTIME_ID,&t) )
		return 0.;
	return t.tv_sec + t.tv_nsec * 1e-9;
#endif
}

HL_PRIM varray *hl_sys_read_dir( vbyte *_path ) {
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
				varray *narr = hl_alloc_array(&hlt_bytes,ncount);
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
			varray *narr = hl_alloc_array(&hlt_bytes,ncount);
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

HL_PRIM vbyte *hl_sys_full_path( vbyte *path ) {
#if defined(HL_WIN)
	pchar out[MAX_PATH+1];
	int len, i, last;
	HANDLE handle;
	WIN32_FIND_DATA data;
	const char sep = '\\';
	if( GetFullPathNameW((pchar*)path,MAX_PATH+1,out,NULL) == 0 )
		return NULL;
	len = (int)ustrlen(out);
	i = 0;

	if (len >= 2 && out[1] == ':') {
		// convert drive letter to uppercase
		if (out[0] >= 'a' && out[0] <= 'z')
			out[0] += (pchar)('A' - 'a');
		if (len >= 3 && out[2] == sep)
			i = 3;
		else
			i = 2;
	}

	last = i;

	while (i < len) {
		// skip until separator
		while (i < len && out[i] != sep)
			i++;

		// temporarily strip string to last found component
		out[i] = 0;

		// get actual file/dir name with proper case
		if ((handle = FindFirstFileW(out, &data)) != INVALID_HANDLE_VALUE) {
			// replace the component with proper case
			memcpy(out + last, data.cFileName, i - last);
			FindClose(handle);
		}

		// if we're not at the end, restore the path
		if (i < len)
			out[i] = sep;

		// advance
		i++;
		last = i;
	}
	return (vbyte*)pstrdup(out,len);
#else
	pchar buf[PATH_MAX];
	if( realpath((pchar*)path,buf) == NULL )
		return NULL;
	return (vbyte*)pstrdup(buf,-1);
#endif
}

HL_PRIM vbyte *hl_sys_exe_path() {
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
#elif defined(HL_CONSOLE)
	return sys_exe_path();
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

HL_PRIM int hl_sys_get_char( bool b ) {
#	if defined(HL_WIN_DESKTOP)
	return b?getche():getch();
#	elif defined(HL_CONSOLE)
	return -1;
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

static pchar **sys_args;
static int sys_nargs;

HL_PRIM varray *hl_sys_args() {
	varray *a = hl_alloc_array(&hlt_bytes,sys_nargs);
	int i;
	for(i=0;i<sys_nargs;i++)
		hl_aptr(a,pchar*)[i] = sys_args[i];
	return a;
}

static void *hl_file = NULL;

HL_PRIM void hl_sys_init(void **args, int nargs, void *hlfile) {
	sys_args = (pchar**)args;
	sys_nargs = nargs;
	hl_file = hlfile;
#	ifdef HL_WIN_DESKTOP
	setlocale(LC_CTYPE, ""); // printf to current locale
#	endif
}

HL_PRIM vbyte *hl_sys_hl_file() {
	return (vbyte*)hl_file;
}

static void *reload_fun = NULL;
static void *reload_param = NULL;
HL_PRIM void hl_setup_reload_check( void *freload, void *param ) {
	reload_fun = freload;
	reload_param = param;
}

HL_PRIM bool hl_sys_check_reload() {
	return reload_fun && ((bool(*)(void*))reload_fun)(reload_param);
}

#ifndef HL_MOBILE
const char *hl_sys_special( const char *key ) {
	 hl_error("Unknown sys_special key");
	 return NULL;
}
DEFINE_PRIM(_BYTES, sys_special, _BYTES);
#endif

DEFINE_PRIM(_BYTES, sys_hl_file, _NO_ARG);
DEFINE_PRIM(_BOOL, sys_utf8_path, _NO_ARG);
DEFINE_PRIM(_BYTES, sys_string, _NO_ARG);
DEFINE_PRIM(_BYTES, sys_locale, _NO_ARG);
DEFINE_PRIM(_VOID, sys_print, _BYTES);
DEFINE_PRIM(_VOID, sys_exit, _I32);
DEFINE_PRIM(_F64, sys_time, _NO_ARG);
DEFINE_PRIM(_BYTES, sys_get_env, _BYTES);
DEFINE_PRIM(_BOOL, sys_put_env, _BYTES _BYTES);
DEFINE_PRIM(_ARR, sys_env, _NO_ARG);
DEFINE_PRIM(_VOID, sys_sleep, _F64);
DEFINE_PRIM(_BOOL, sys_set_time_locale, _BYTES);
DEFINE_PRIM(_BYTES, sys_get_cwd, _NO_ARG);
DEFINE_PRIM(_BOOL, sys_set_cwd, _BYTES);
DEFINE_PRIM(_BOOL, sys_is64, _NO_ARG);
DEFINE_PRIM(_I32, sys_command, _BYTES);
DEFINE_PRIM(_BOOL, sys_exists, _BYTES);
DEFINE_PRIM(_BOOL, sys_delete, _BYTES);
DEFINE_PRIM(_BOOL, sys_rename, _BYTES _BYTES);
DEFINE_PRIM(_ARR, sys_stat, _BYTES);
DEFINE_PRIM(_BOOL, sys_is_dir, _BYTES);
DEFINE_PRIM(_BOOL, sys_create_dir, _BYTES _I32);
DEFINE_PRIM(_BOOL, sys_remove_dir, _BYTES);
DEFINE_PRIM(_F64, sys_cpu_time, _NO_ARG);
DEFINE_PRIM(_F64, sys_thread_cpu_time, _NO_ARG);
DEFINE_PRIM(_ARR, sys_read_dir, _BYTES);
DEFINE_PRIM(_BYTES, sys_full_path, _BYTES);
DEFINE_PRIM(_BYTES, sys_exe_path, _NO_ARG);
DEFINE_PRIM(_I32, sys_get_char, _BOOL);
DEFINE_PRIM(_ARR, sys_args, _NO_ARG);
DEFINE_PRIM(_I32, sys_getpid, _NO_ARG);
DEFINE_PRIM(_BOOL, sys_check_reload, _NO_ARG);
DEFINE_PRIM(_VOID, sys_profile_event, _I32 _BYTES _I32);
DEFINE_PRIM(_I32, sys_set_flags, _I32);

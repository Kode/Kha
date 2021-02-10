/*
 * Copyright (C)2015-2016 Haxe Foundation
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
#include <hlmodule.h>

#ifdef HL_WIN
#	include <locale.h>
typedef uchar pchar;
#define pprintf(str,file)	uprintf(USTR(str),file)
#define pfopen(file,ext) _wfopen(file,USTR(ext))
#define pcompare wcscmp
#define ptoi(s)	wcstol(s,NULL,10)
#define PSTR(x) USTR(x)
#else
#	include <sys/stat.h>
typedef char pchar;
#define pprintf printf
#define pfopen fopen
#define pcompare strcmp
#define ptoi atoi
#define PSTR(x) x
#endif

typedef struct {
	hl_code *code;
	hl_module *m;
	vdynamic *ret;
	pchar *file;
	int file_time;
} main_context;

static int pfiletime( pchar *file )	{
#ifdef HL_WIN
	struct _stat32 st;
	_wstat32(file,&st);
	return (int)st.st_mtime;
#else
	struct stat st;
	stat(file,&st);
	return (int)st.st_mtime;
#endif
}

static hl_code *load_code( const pchar *file, char **error_msg, bool print_errors ) {
	hl_code *code;
	FILE *f = pfopen(file,"rb");
	int pos, size;
	char *fdata;
	if( f == NULL ) {
		if( print_errors ) pprintf("File not found '%s'\n",file);
		return NULL;
	}
	fseek(f, 0, SEEK_END);
	size = (int)ftell(f);
	fseek(f, 0, SEEK_SET);
	fdata = (char*)malloc(size);
	pos = 0;
	while( pos < size ) {
		int r = (int)fread(fdata + pos, 1, size-pos, f);
		if( r <= 0 ) {
			if( print_errors ) pprintf("Failed to read '%s'\n",file);
			return NULL;
		}
		pos += r;
	}
	fclose(f);
	code = hl_code_read((unsigned char*)fdata, size, error_msg);
	free(fdata);
	return code;
}

static bool check_reload( main_context *m ) {
	int time = pfiletime(m->file);
	bool changed;
	if( time == m->file_time )
		return false;
	char *error_msg = NULL;
	hl_code *code = load_code(m->file, &error_msg, false);
	if( code == NULL )
		return false;
	changed = hl_module_patch(m->m, code);
	m->file_time = time;
	hl_code_free(code);
	return changed;
}

#ifdef HL_VCC
// this allows some runtime detection to switch to high performance mode
__declspec(dllexport) DWORD NvOptimusEnablement = 1;
__declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1;
#endif

#if defined(HL_LINUX) || defined(HL_MAC)
#include <signal.h>
static void handle_signal( int signum ) {
	signal(signum, SIG_DFL);
	printf("SIGNAL %d\n",signum);
	hl_dump_stack();
	fflush(stdout);
	raise(signum);
}
static void setup_handler() {
	struct sigaction act;
	act.sa_sigaction = NULL;
	act.sa_handler = handle_signal;
	act.sa_flags = 0;
	sigemptyset(&act.sa_mask);
	signal(SIGPIPE, SIG_IGN);
	sigaction(SIGSEGV,&act,NULL);
	sigaction(SIGTERM,&act,NULL);
}
#else
static void setup_handler() {
}
#endif

#ifdef HL_WIN
int wmain(int argc, pchar *argv[]) {
#else
int main(int argc, pchar *argv[]) {
#endif
	static vclosure cl;
	pchar *file = NULL;
	char *error_msg = NULL;
	int debug_port = -1;
	bool debug_wait = false;
	bool hot_reload = false;
	int profile_count = -1;
	main_context ctx;
	bool isExc = false;
	int first_boot_arg = -1;
	argv++;
	argc--;

	while( argc ) {
		pchar *arg = *argv++;
		argc--;
		if( pcompare(arg,PSTR("--debug")) == 0 ) {
			if( argc-- == 0 ) break;
			debug_port = ptoi(*argv++);
			continue;
		}
		if( pcompare(arg,PSTR("--debug-wait")) == 0 ) {
			debug_wait = true;
			continue;
		}
		if( pcompare(arg,PSTR("--version")) == 0 ) {
			printf("%d.%d.%d",HL_VERSION>>16,(HL_VERSION>>8)&0xFF,HL_VERSION&0xFF);
			return 0;
		}
		if( pcompare(arg,PSTR("--hot-reload")) == 0 ) {
			hot_reload = true;
			continue;
		}
		if( pcompare(arg,PSTR("--profile")) == 0 ) {
			if( argc-- == 0 ) break;
			profile_count = ptoi(*argv++);
			continue;
		}
		if( *arg == '-' || *arg == '+' ) {
			if( first_boot_arg < 0 ) first_boot_arg = argc + 1;
			// skip value
			if( argc && **argv != '+' && **argv != '-' ) {
				argc--;
				argv++;
			}
			continue;
		}
		file = arg;
		break;
	}
	if( file == NULL ) {
		FILE *fchk;
		file = PSTR("hlboot.dat");
		fchk = pfopen(file,"rb");
		if( fchk == NULL ) {
			printf("HL/JIT %d.%d.%d (c)2015-2020 Haxe Foundation\n  Usage : hl [--debug <port>] [--debug-wait] <file>\n",HL_VERSION>>16,(HL_VERSION>>8)&0xFF,HL_VERSION&0xFF);
			return 1;
		}
		fclose(fchk);
		if( first_boot_arg >= 0 ) {
			argv -= first_boot_arg;
			argc = first_boot_arg;
		}
	}
	hl_global_init();
	hl_sys_init((void**)argv,argc,file);
	hl_register_thread(&ctx);
	ctx.file = file;
	ctx.code = load_code(file, &error_msg, true);
	if( ctx.code == NULL ) {
		if( error_msg ) printf("%s\n", error_msg);
		return 1;
	}
	ctx.m = hl_module_alloc(ctx.code);
	if( ctx.m == NULL )
		return 2;
	if( !hl_module_init(ctx.m,hot_reload) )
		return 3;
	if( hot_reload ) {
		ctx.file_time = pfiletime(ctx.file);
		hl_setup_reload_check(check_reload,&ctx);
	}
	hl_code_free(ctx.code);
	if( debug_port > 0 && !hl_module_debug(ctx.m,debug_port,debug_wait) ) {
		fprintf(stderr,"Could not start debugger on port %d",debug_port);
		return 4;
	}
	cl.t = ctx.code->functions[ctx.m->functions_indexes[ctx.m->code->entrypoint]].type;
	cl.fun = ctx.m->functions_ptrs[ctx.m->code->entrypoint];
	cl.hasValue = 0;
	setup_handler();
	hl_profile_setup(profile_count);
	ctx.ret = hl_dyn_call_safe(&cl,NULL,0,&isExc);
	hl_profile_end();
	if( isExc ) {
		varray *a = hl_exception_stack();
		int i;
		uprintf(USTR("Uncaught exception: %s\n"), hl_to_string(ctx.ret));
		for(i=0;i<a->size;i++)
			uprintf(USTR("Called from %s\n"), hl_aptr(a,uchar*)[i]);
		hl_debug_break();
		hl_global_free();
		return 1;
	}
	hl_module_free(ctx.m);
	hl_free(&ctx.code->alloc);
	hl_global_free();
	return 0;
}


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
typedef char pchar;
#define pprintf printf
#define pfopen fopen
#define pcompare strcmp
#define ptoi atoi
#define PSTR(x) x
#endif

static hl_code *load_code( const pchar *file ) {
	hl_code *code;
	FILE *f = pfopen(file,"rb");
	int pos, size;
	char *fdata;
	if( f == NULL ) {
		pprintf("File not found '%s'\n",file);
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
			pprintf("Failed to read '%s'\n",file);
			return NULL;
		}
		pos += r;
	}
	fclose(f);
	code = hl_code_read((unsigned char*)fdata, size);
	free(fdata);
	return code;
}

#ifdef HL_VCC
// this allows some runtime detection to switch to high performance mode
__declspec(dllexport) DWORD NvOptimusEnablement = 1;
__declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1;
#endif

#ifdef HL_WIN
int wmain(int argc, pchar *argv[]) {
#else
int main(int argc, pchar *argv[]) {
#endif
	pchar *file = NULL;
	int debug_port = -1;
	bool debug_wait = false;
	struct {
		hl_code *code;
		hl_module *m;
		vdynamic *ret;
		vclosure c;
	} ctx;
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
			printf("%d.%d.%d",HL_VERSION>>8,(HL_VERSION>>4)&15,HL_VERSION&15);
			return 0;
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
			printf("HL/JIT %d.%d.%d (c)2015-2018 Haxe Foundation\n  Usage : hl [--debug <port>] [--debug-wait] <file>\n",HL_VERSION>>8,(HL_VERSION>>4)&15,HL_VERSION&15);
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
	ctx.code = load_code(file);
	if( ctx.code == NULL )
		return 1;
	ctx.m = hl_module_alloc(ctx.code);
	if( ctx.m == NULL )
		return 2;
	if( !hl_module_init(ctx.m) )
		return 3;
	hl_code_free(ctx.code);
	if( debug_port > 0 && !hl_module_debug(ctx.m,debug_port,debug_wait) ) {
		fprintf(stderr,"Could not start debugger on port %d",debug_port);
		return 4;
	}
	ctx.c.t = ctx.code->functions[ctx.m->functions_indexes[ctx.m->code->entrypoint]].type;
	ctx.c.fun = ctx.m->functions_ptrs[ctx.m->code->entrypoint];
	ctx.c.hasValue = 0;
	ctx.ret = hl_dyn_call_safe(&ctx.c,NULL,0,&isExc);
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


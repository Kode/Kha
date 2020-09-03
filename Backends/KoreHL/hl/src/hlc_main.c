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
#include <hlc.h>

#if defined(HL_MOBILE) && defined(sdl__Sdl__val)
#   include <SDL_main.h>
#endif

#ifdef HL_WIN_DESKTOP
# ifndef CONST
#	define CONST
# endif
#	pragma warning(disable:4091)
#if !defined(HL_MINGW)
#	include <DbgHelp.h>
#else
#	include <dbghelp.h>
#endif
#	pragma comment(lib, "Dbghelp.lib")
#	undef CONST
#endif

#ifdef HL_CONSOLE
extern void sys_global_init();
extern void sys_global_exit();
#else
#define sys_global_init()
#define sys_global_exit()
#endif


#ifdef HL_VCC
#	include <crtdbg.h>
#else
#	define _CrtSetDbgFlag(x)
#	define _CrtCheckMemory()
#endif

static uchar *hlc_resolve_symbol( void *addr, uchar *out, int *outSize ) {
#ifdef HL_WIN_DESKTOP
	static HANDLE stack_process_handle = NULL;
	DWORD64 index;
	IMAGEHLP_LINEW64 line;
	struct {
		SYMBOL_INFOW sym;
		uchar buffer[256];
	} data;
	data.sym.SizeOfStruct = sizeof(data.sym);
	data.sym.MaxNameLen = 255;
	if( !stack_process_handle ) {
		stack_process_handle = GetCurrentProcess();
		SymSetOptions(SYMOPT_LOAD_LINES);
		SymInitialize(stack_process_handle,NULL,(BOOL)1);
	}
	if( SymFromAddrW(stack_process_handle,(DWORD64)(int_val)addr,&index,&data.sym) ) {
		DWORD offset = 0;
		line.SizeOfStruct = sizeof(line);
		line.FileName = USTR("\\?");
		line.LineNumber = 0;
		SymGetLineFromAddrW64(stack_process_handle, (DWORD64)(int_val)addr, &offset, &line);
		*outSize = usprintf(out,*outSize,USTR("%s(%s:%d)"),data.sym.Name,wcsrchr(line.FileName,'\\')+1,(int)line.LineNumber);
		return out;
	}
#endif
	return NULL;
}

static int hlc_capture_stack( void **stack, int size ) {
	int count = 0;
#	ifdef HL_WIN_DESKTOP
	count = CaptureStackBackTrace(2, size, stack, NULL) - 8; // 8 startup
	if( count < 0 ) count = 0;
#	endif
	return count;
}

#if defined( HL_VCC )
static int throw_handler( int code ) {
	#if !defined(HL_XBO)
	switch( code ) {
	case EXCEPTION_ACCESS_VIOLATION: hl_error("Access violation");
	case EXCEPTION_STACK_OVERFLOW: hl_error("Stack overflow");
	default: hl_error("Unknown runtime error");
	}
	return EXCEPTION_CONTINUE_SEARCH;
	#else
	return 0;
	#endif
}
#endif

int kickstart(int argc, char *argv[]) {
	vdynamic *ret;
	bool isExc = false;
	hl_type_fun tf = { 0 };
	hl_type clt = { 0 };
	vclosure cl = { 0 };
	sys_global_init();
	hl_global_init();
	hl_register_thread(&ret);
	hl_setup_exception(hlc_resolve_symbol,hlc_capture_stack);
	hl_setup_callbacks(hlc_static_call, hlc_get_wrapper);
	hl_sys_init((void**)(argv + 1),argc - 1,NULL);
	tf.ret = &hlt_void;
	clt.kind = HFUN;
	clt.fun = &tf;
	cl.t = &clt;
	cl.fun = hl_entry_point;
	ret = hl_dyn_call_safe(&cl, NULL, 0, &isExc);
	if( isExc ) {
		varray *a = hl_exception_stack();
		int i;
		uprintf(USTR("Uncaught exception: %s\n"), hl_to_string(ret));
		for (i = 0; i<a->size; i++)
			uprintf(USTR("Called from %s\n"), hl_aptr(a, uchar*)[i]);
	}
	hl_global_free();
	sys_global_exit();
	return (int)isExc;
}

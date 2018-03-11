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

#ifdef _WIN32
#	pragma warning(disable:4091)
#	include <DbgHelp.h>
#	pragma comment(lib, "Dbghelp.lib")
#endif

#ifdef HL_CONSOLE
extern void sys_global_init();
extern void sys_global_exit();
#endif


#ifdef HL_VCC
#	include <crtdbg.h>
#else
#	define _CrtSetDbgFlag(x)
#	define _CrtCheckMemory()
#endif

static uchar *hlc_resolve_symbol( void *addr, uchar *out, int *outSize ) {
#ifdef _WIN32
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
		SymInitialize(stack_process_handle,NULL,TRUE);
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
#	ifdef _WIN32
	count = CaptureStackBackTrace(2, size, stack, NULL) - 8; // 8 startup
	if( count < 0 ) count = 0;
#	endif
	return count;
}

#ifdef HL_VCC
static int throw_handler( int code ) {
	switch( code ) {
	case EXCEPTION_ACCESS_VIOLATION: hl_error("Access violation");
	case EXCEPTION_STACK_OVERFLOW: hl_error("Stack overflow");
	default: hl_error("Unknown runtime error");
	}
	return EXCEPTION_CONTINUE_SEARCH;
}
#endif

#ifdef KOREC
extern void run_kore();
int kore(int argc, char *argv[]) {
#else
	#ifdef HL_WIN
	int wmain(int argc, uchar *argv[]) {
	#else
	int main(int argc, char *argv[]) {
	#endif
#endif

	hl_trap_ctx ctx;
	vdynamic *exc;
#	ifdef HL_CONSOLE
	sys_global_init();
#	endif
	hl_global_init(&ctx);
	hl_setup_exception(hlc_resolve_symbol,hlc_capture_stack);
	hl_setup_callbacks(hlc_static_call, hlc_get_wrapper);
	hl_sys_init((void**)(argv + 1),argc - 1,NULL);
	hl_trap(ctx, exc, on_exception);
#	ifdef HL_VCC
	__try {
#	endif
	hl_entry_point();
#	ifdef KOREC
	run_kore();
#	endif
#	ifdef HL_VCC
	} __except( throw_handler(GetExceptionCode()) ) {}
#	endif
	hl_global_free();
	return 0;
on_exception:
	{
		varray *a = hl_exception_stack();
		int i;
		uprintf(USTR("Uncaught exception: %s\n"), hl_to_string(exc));
		for(i=0;i<a->size;i++)
			uprintf(USTR("Called from %s\n"), hl_aptr(a,uchar*)[i]);
		hl_debug_break();
	}
	hl_global_free();
#	ifdef HL_CONSOLE
	sys_global_exit();
#	endif
	return 1;
}

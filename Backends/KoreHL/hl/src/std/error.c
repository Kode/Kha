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
#include <stdarg.h>
#include <string.h>

HL_PRIM hl_trap_ctx *hl_current_trap = NULL;
HL_PRIM vdynamic *hl_current_exc = NULL;
HL_PRIM vdynamic **hl_debug_exc = NULL;

static void *stack_trace[0x1000];
static int stack_count = 0;
static bool exc_rethrow = false;

HL_PRIM void *hl_fatal_error( const char *msg, const char *file, int line ) {
	hl_blocking(true);
#	ifdef _WIN32
    HWND consoleWnd = GetConsoleWindow();
    DWORD pid;
    GetWindowThreadProcessId(consoleWnd, &pid);
    if( consoleWnd == NULL || GetActiveWindow() != NULL || GetCurrentProcessId() == pid ) MessageBoxA(NULL,msg,"Fatal Error", MB_OK | MB_ICONERROR);
#	endif
	printf("%s(%d) : FATAL ERROR : %s\n",file,line,msg);
	hl_blocking(false);
	hl_debug_break();
	exit(1);
	return NULL;
}

typedef uchar *(*resolve_symbol_type)( void *addr, uchar *out, int *outSize );
typedef int (*capture_stack_type)( void **stack, int size );

static resolve_symbol_type resolve_symbol_func = NULL;
static capture_stack_type capture_stack_func = NULL;
static vclosure *hl_error_handler = NULL;

int hl_internal_capture_stack( void **stack, int size ) {
	return capture_stack_func(stack,size);
}

HL_PRIM uchar *hl_resolve_symbol( void *addr, uchar *out, int *outSize ) {
	return resolve_symbol_func(addr, out, outSize);
}

static void (*throw_jump)( jmp_buf, int ) = NULL;

HL_PRIM void hl_setup_longjump( void *j ) {
	throw_jump = j;
}

HL_PRIM void hl_setup_exception( void *resolve_symbol, void *capture_stack ) {
	resolve_symbol_func = resolve_symbol;
	capture_stack_func = capture_stack;
}

HL_PRIM void hl_set_error_handler( vclosure *d ) {
	if( d == hl_error_handler )
		return;
	hl_error_handler = d;
	if( d )
		hl_add_root(&hl_error_handler);
	else
		hl_remove_root(&hl_error_handler);
}

HL_PRIM void hl_throw( vdynamic *v ) {
	hl_trap_ctx *t = hl_current_trap;
	if( exc_rethrow )
		exc_rethrow = false;
	else
		stack_count = capture_stack_func(stack_trace, 0x1000);
	hl_current_exc = v;
	hl_current_trap = t->prev;
	if( hl_current_trap == NULL ) {
		hl_debug_exc = &v;
		hl_debug_break();
		hl_debug_exc = NULL;
		if( hl_error_handler ) hl_dyn_call(hl_error_handler,&v,1);
	}
	if( throw_jump == NULL ) throw_jump = longjmp;
	throw_jump(t->buf,1);
}

HL_PRIM void hl_dump_stack() {
	void *stack[0x1000];
	int count = capture_stack_func(stack, 0x1000);
	int i;
	for(i=0;i<count;i++) {
		void *addr = stack[i];
		uchar sym[512];
		int size = 512;
		uchar *str = resolve_symbol_func(addr, sym, &size);
		if( str == NULL ) {
			int iaddr = (int)(int_val)addr;
			usprintf(sym,512,USTR("@0x%X"),iaddr);
			str = sym;
		}
		uprintf(USTR("%s\n"),str);
	}
}


HL_PRIM varray *hl_exception_stack() {
	varray *a = hl_alloc_array(&hlt_bytes, stack_count);
	int i;
	for(i=0;i<stack_count;i++) {
		void *addr = stack_trace[i];
		uchar sym[512];
		int size = 512;
		uchar *str = resolve_symbol_func(addr, sym, &size);
		if( str == NULL ) {
			int iaddr = (int)(int_val)addr;
			str = sym;
			size = usprintf(str,512,USTR("@0x%X"),iaddr);
		}
		hl_aptr(a,vbyte*)[i] = hl_copy_bytes((vbyte*)str,sizeof(uchar)*(size+1));
	}
	return a;
}

HL_PRIM void hl_rethrow( vdynamic *v ) {
	exc_rethrow = true;
	hl_throw(v);
}

HL_PRIM void hl_error_msg( const uchar *fmt, ... ) {
	uchar buf[256];
	vdynamic *d;
	int len;
	va_list args;
	va_start(args, fmt);
	len = uvsprintf(buf,fmt,args);
	va_end(args);
	d = hl_alloc_dynamic(&hlt_bytes);
	d->v.ptr = hl_copy_bytes((vbyte*)buf,(len + 1) << 1);
	hl_throw(d);
}

HL_PRIM void hl_fatal_fmt( const char *file, int line, const char *fmt, ...) {
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsprintf(buf,fmt, args);
	va_end(args);
	hl_fatal_error(buf,file,line);
}

HL_PRIM void hl_breakpoint() {
	hl_debug_break();
}

#ifdef HL_LINUX__
#include <signal.h>
static int debugger_present = -1;
static void _sigtrap_handler(int signum) {
	debugger_present = 0;
	signal(SIGTRAP,SIG_DFL);
}
#endif

HL_PRIM bool hl_detect_debugger() {
#	if defined(HL_WIN)
	return (bool)IsDebuggerPresent();
#	elif defined(HL_LINUX__)
	if( debugger_present == -1 ) {
		debugger_present = 1;
		signal(SIGTRAP,_sigtrap_handler);
		raise(SIGTRAP);
	}
	return (bool)debugger_present;
#	else
	return false;
#	endif
}

HL_PRIM void hl_assert() {
	hl_debug_break();
	hl_error("Assert");
}

#define _SYMBOL _ABSTRACT(hl_symbol)

DEFINE_PRIM(_ARR,exception_stack,_NO_ARG);
DEFINE_PRIM(_VOID,set_error_handler,_FUN(_VOID,_DYN));
DEFINE_PRIM(_VOID,breakpoint,_NO_ARG);
DEFINE_PRIM(_BYTES,resolve_symbol, _SYMBOL _BYTES _REF(_I32));

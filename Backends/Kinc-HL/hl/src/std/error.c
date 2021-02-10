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

#ifdef HL_CONSOLE
#include <posix/posix.h>
#endif

HL_PRIM void *hl_fatal_error( const char *msg, const char *file, int line ) {
	hl_blocking(true);
#	ifdef HL_WIN_DESKTOP
    HWND consoleWnd = GetConsoleWindow();
    DWORD pid;
    GetWindowThreadProcessId(consoleWnd, &pid);
    if( consoleWnd == NULL || GetActiveWindow() != NULL || GetCurrentProcessId() == pid ) {
		char buf[256];
		sprintf(buf,"%s\n\n%s(%d)",msg,file,line);
		MessageBoxA(NULL,buf,"Fatal Error", MB_OK | MB_ICONERROR);
	}
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
	hl_thread_info *t = hl_get_thread();
	t->trap_uncaught = t->trap_current;
	t->exc_handler = d;
}

static bool break_on_trap( hl_thread_info *t, hl_trap_ctx *trap, vdynamic *v ) {
	while( true ) {
		if( trap == NULL || trap == t->trap_uncaught || t->trap_current == NULL ) return true;
		if( !trap->tcheck || !v ) return false;
		hl_type *ot = ((hl_type**)trap->tcheck)[1]; // it's an obj with first field is a hl_type
		if( !ot || hl_safe_cast(v->t,ot) ) return false;
		trap = trap->prev;
	}
	return false;
}

HL_PRIM void hl_throw( vdynamic *v ) {
	hl_thread_info *t = hl_get_thread();
	hl_trap_ctx *trap = t->trap_current;
	bool call_handler = false;
	if( !(t->flags & HL_EXC_RETHROW) )
		t->exc_stack_count = capture_stack_func(t->exc_stack_trace, HL_EXC_MAX_STACK);
	t->exc_value = v;
	t->trap_current = trap->prev;
	call_handler = trap == t->trap_uncaught || t->trap_current == NULL;
	if( (t->flags&HL_EXC_CATCH_ALL) || break_on_trap(t,trap,v) ) {
		if( trap == t->trap_uncaught ) t->trap_uncaught = NULL;
		t->flags |= HL_EXC_IS_THROW;
		hl_debug_break();
		t->flags &= ~HL_EXC_IS_THROW;
	}
	t->flags &= ~HL_EXC_RETHROW;
	if( t->exc_handler && call_handler ) hl_dyn_call_safe(t->exc_handler,&v,1,&call_handler);
	if( throw_jump == NULL ) throw_jump = longjmp;
	throw_jump(trap->buf,1);
	HL_UNREACHABLE;
}

HL_PRIM void hl_null_access() {
	hl_error("Null access");
	HL_UNREACHABLE;
}

HL_PRIM void hl_throw_buffer( hl_buffer *b ) {
	vdynamic *d = hl_alloc_dynamic(&hlt_bytes);	
	d->v.ptr = hl_buffer_content(b,NULL);
	hl_throw(d);
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
	fflush(stdout);
}

HL_PRIM varray *hl_exception_stack() {
	hl_thread_info *t = hl_get_thread();
	varray *a = hl_alloc_array(&hlt_bytes, t->exc_stack_count);
	int i, pos = 0;
	for(i=0;i<t->exc_stack_count;i++) {
		void *addr = t->exc_stack_trace[i];
		uchar sym[512];
		int size = 512;
		uchar *str = resolve_symbol_func(addr, sym, &size);
		if( str == NULL ) continue;
		hl_aptr(a,vbyte*)[pos++] = hl_copy_bytes((vbyte*)str,sizeof(uchar)*(size+1));
	}
	a->size = pos;
	return a;
}

HL_PRIM void hl_rethrow( vdynamic *v ) {
	hl_get_thread()->flags |= HL_EXC_RETHROW;
	hl_throw(v);
}

HL_PRIM vdynamic *hl_alloc_strbytes( const uchar *fmt, ... ) {
	uchar _buf[256];
	vdynamic *d;
	int len;
	uchar *buf = _buf;
	int bsize = sizeof(_buf) / sizeof(uchar);
	va_list args;
	while( true ) {
		va_start(args, fmt);
		len = uvszprintf(buf,bsize,fmt,args);
		va_end(args);
		if( (len + 2) << 1 < bsize ) break;
		if( buf != _buf ) free(buf);
		bsize <<= 1;
		buf = (uchar*)malloc(bsize * sizeof(uchar));
	}
	d = hl_alloc_dynamic(&hlt_bytes);
	d->v.ptr = hl_copy_bytes((vbyte*)buf,(len + 1) << 1);
	if( buf != _buf ) free(buf);
	return d;
}

HL_PRIM void hl_fatal_fmt( const char *file, int line, const char *fmt, ...) {
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsprintf(buf,fmt, args);
	va_end(args);
	hl_fatal_error(buf,file,line);
}

#ifdef HL_VCC
#	pragma optimize( "", off )
#endif
HL_PRIM HL_NO_OPT void hl_breakpoint() {
	hl_debug_break();
}
#ifdef HL_VCC
#	pragma optimize( "", on )
#endif

#ifdef HL_LINUX__
#include <signal.h>
static int debugger_present = -1;
static void _sigtrap_handler(int signum) {
	debugger_present = 0;
	signal(SIGTRAP,SIG_DFL);
}
#endif

#ifdef HL_MAC
	extern bool is_debugger_attached(void);
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
#	elif defined(HL_MAC)
	return is_debugger_attached();
#	else
	return false;
#	endif
}

#ifdef HL_VCC
#	pragma optimize( "", off )
#endif
HL_PRIM HL_NO_OPT void hl_assert() {
	hl_debug_break();
	hl_error("assert");
}
#ifdef HL_VCC
#	pragma optimize( "", on )
#endif

#define _SYMBOL _ABSTRACT(hl_symbol)

DEFINE_PRIM(_ARR,exception_stack,_NO_ARG);
DEFINE_PRIM(_VOID,set_error_handler,_FUN(_VOID,_DYN));
DEFINE_PRIM(_VOID,breakpoint,_NO_ARG);
DEFINE_PRIM(_BYTES,resolve_symbol, _SYMBOL _BYTES _REF(_I32));

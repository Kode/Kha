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
#ifdef HL_LINUX
#	include <sys/ptrace.h>
#	include <sys/wait.h>
#	include <sys/user.h>
#	include <signal.h>
#	define USE_PTRACE
#endif

#ifdef HL_MAC
#	include <mdbg/mdbg.h>

static int get_reg( int r ) {
	switch( r ) {
		case 0: return REG_RSP;
		case 1: return REG_RBP;
		case 2: return REG_RIP;
		case 3: return REG_RFLAGS;
		case 4: return REG_DR0 + (r-4);
	}
	return -1;
}
#endif

#if defined(HL_WIN)
static HANDLE last_process = NULL, last_thread = NULL;
static int last_pid = -1;
static int last_tid = -1;
static HANDLE OpenPID( int pid ) {
	if( pid == last_pid )
		return last_process;
	CloseHandle(last_process);
	last_pid = pid;
	last_process = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
	return last_process;
}
static HANDLE OpenTID( int tid ) {
	if( tid == last_tid )
		return last_thread;
	CloseHandle(last_thread);
	last_tid = tid;
	last_thread = OpenThread(THREAD_ALL_ACCESS, FALSE, tid);
	return last_thread;
}
static void CleanHandles() {
	last_pid = -1;
	last_tid = -1;
	CloseHandle(last_process);
	CloseHandle(last_thread);
	last_process = NULL;
	last_thread = NULL;
}
#endif

HL_API bool hl_debug_start( int pid ) {
#	if defined(HL_WIN)
	last_pid = -1;
	return (bool)DebugActiveProcess(pid);
#	elif defined(HL_MAC)
	return mdbg_session_attach(pid);
#	elif defined(USE_PTRACE)
	return ptrace(PTRACE_ATTACH,pid,0,0) >= 0;
#	else
	return false;
#	endif
}

HL_API bool hl_debug_stop( int pid ) {
#	if defined(HL_WIN)
	BOOL b = DebugActiveProcessStop(pid);
	CleanHandles();
	return (bool)b;
#	elif defined(HL_MAC)
	return mdbg_session_detach(pid);
#	elif defined(USE_PTRACE)
	return ptrace(PTRACE_DETACH,pid,0,0) >= 0;
#	else
	return false;
#	endif
}

HL_API bool hl_debug_breakpoint( int pid ) {
#	if defined(HL_WIN)
	return (bool)DebugBreakProcess(OpenPID(pid));
#	elif defined(HL_MAC)
	return mdbg_session_pause(pid);
#	elif defined(USE_PTRACE)
	return kill(pid,SIGTRAP) == 0;
#	else
	return false;
#	endif
}

HL_API bool hl_debug_read( int pid, vbyte *addr, vbyte *buffer, int size ) {
#	if defined(HL_WIN)
	return (bool)ReadProcessMemory(OpenPID(pid),addr,buffer,size,NULL);
#	elif defined(HL_MAC)
	return mdbg_read_memory(pid, addr, buffer, size);
#	elif defined(USE_PTRACE)
	while( size ) {
		long v = ptrace(PTRACE_PEEKDATA,pid,addr,0);
		if( size >= sizeof(long) )
			*(long*)buffer = v;
		else {
			memcpy(buffer,&v,size);
			break;
		}
		addr += sizeof(long);
		size -= sizeof(long);
		buffer += sizeof(long);
	}
	return true;
#	else
	return false;
#	endif
}

HL_API bool hl_debug_write( int pid, vbyte *addr, vbyte *buffer, int size ) {
#	if defined(HL_WIN)
	return (bool)WriteProcessMemory(OpenPID(pid),addr,buffer,size,NULL);
#	elif defined(HL_MAC)
	return mdbg_write_memory(pid, addr, buffer, size);
#	elif defined(USE_PTRACE)
	while( size ) {
		int sz = size >= sizeof(long) ? sizeof(long) : size;
		long v = *(long*)buffer;
		if( sz != sizeof(long) ) {
			long cur = ptrace(PTRACE_PEEKDATA,pid,addr);
			memcpy((char*)&v+sz,(char*)&cur+sz,sizeof(long)-sz);
		}
		if( ptrace(PTRACE_POKEDATA,pid,addr,v) < 0 )
			return false;
		addr += sz;
		size -= sz;
		buffer += sz;
	}
	return true;
#	else
	return false;
#	endif
}

HL_API bool hl_debug_flush( int pid, vbyte *addr, int size ) {
#	if defined(HL_WIN)
	return (bool)FlushInstructionCache(OpenPID(pid),addr,size);
#	elif defined(HL_MAC)
	return true;
#	elif defined(USE_PTRACE)
	return true;
#	else
	return false;
#	endif
}

#ifdef USE_PTRACE
static void *get_reg( int r ) {
		struct user_regs_struct *regs = NULL;
		struct user *user = NULL;
		switch( r ) {
#		ifdef HL_64
		case 0: return &regs->rsp;
		case 1: return &regs->rbp;
		case 2: return &regs->rip;
#		else
		case 0: return &regs->esp;
		case 1: return &regs->ebp;
		case 2: return &regs->eip;
#		endif
		case 3: return &regs->eflags;
		default: return &user->u_debugreg[r-4];
		}
		return NULL;
}
#endif

HL_API int hl_debug_wait( int pid, int *thread, int timeout ) {
#	if defined(HL_WIN)
	DEBUG_EVENT e;
	if( !WaitForDebugEvent(&e,timeout) )
		return -1;
	*thread = e.dwThreadId;
	switch( e.dwDebugEventCode ) {
	case EXCEPTION_DEBUG_EVENT:
		switch( e.u.Exception.ExceptionRecord.ExceptionCode ) {
		case EXCEPTION_BREAKPOINT:
		case 0x4000001F: // STATUS_WX86_BREAKPOINT
			return 1;
		case EXCEPTION_SINGLE_STEP:
		case 0x4000001E: // STATUS_WX86_SINGLE_STEP
			return 2;
		case 0x406D1388: // MS_VC_EXCEPTION (see SetThreadName)
			ContinueDebugEvent(e.dwProcessId, e.dwThreadId, DBG_CONTINUE);
			break;
		case 0xE06D7363: // C++ EH EXCEPTION
		case 0x6BA: // File Dialog EXCEPTION
			ContinueDebugEvent(e.dwProcessId, e.dwThreadId, DBG_EXCEPTION_NOT_HANDLED);
			break;
		case EXCEPTION_STACK_OVERFLOW:
			return 5;
		default:
			return 3;
		}
	case EXIT_PROCESS_DEBUG_EVENT:
		return 0;
	default:
		ContinueDebugEvent(e.dwProcessId, e.dwThreadId, DBG_CONTINUE);
		break;
	}
	return 4;
#	elif defined(HL_MAC)
	return mdbg_session_wait(pid, thread, timeout);
#	elif defined(USE_PTRACE)
	int status;
	int ret = waitpid(pid,&status,0);
	//printf("WAITPID=%X %X\n",ret,status);
	*thread = ret;
	if( WIFEXITED(status) )
		return 0;
	if( WIFSTOPPED(status) ) {
		int sig = WSTOPSIG(status);
		//printf(" STOPSIG=%d\n",sig);
		if( sig == SIGSTOP || sig == SIGTRAP )
			return 1;
		return 3;
	}
	return 4;
#	else
	return 0;
#	endif
}

HL_API bool hl_debug_resume( int pid, int thread ) {
#	if defined(HL_WIN)
	return (bool)ContinueDebugEvent(pid, thread, DBG_CONTINUE);
#	elif defined(HL_MAC)
	return mdbg_session_resume(pid);
#	elif defined(USE_PTRACE)
	return ptrace(PTRACE_CONT,pid,0,0) >= 0;
#	else
	return false;
#	endif
}

#ifdef HL_WIN
#define DefineGetReg(type,GetFun) \
	REGDATA *GetFun( type *c, int reg ) { \
		switch( reg ) { \
		case 0: return GET_REG(sp); \
		case 1: return GET_REG(bp); \
		case 2: return GET_REG(ip); \
		case 4: return &c->Dr0; \
		case 5: return &c->Dr1; \
		case 6: return &c->Dr2; \
		case 7: return &c->Dr3; \
		case 8: return &c->Dr6; \
		case 9: return &c->Dr7; \
		default: return GET_REG(ax); \
		} \
	}

#define GET_REG(x)	&c->E##x
#define REGDATA		DWORD

#ifdef HL_64
DefineGetReg(WOW64_CONTEXT,GetContextReg32);
#	undef GET_REG
#	undef REGDATA
#	define GET_REG(x)	&c->R##x
#	define REGDATA		DWORD64
#	endif

DefineGetReg(CONTEXT,GetContextReg);

#endif

HL_API void *hl_debug_read_register( int pid, int thread, int reg, bool is64 ) {
#	if defined(HL_WIN)
#	ifdef HL_64
	if( !is64 ) {
		WOW64_CONTEXT c;
		c.ContextFlags = CONTEXT_FULL | CONTEXT_DEBUG_REGISTERS;
		if( !Wow64GetThreadContext(OpenTID(thread),&c) )
			return NULL;
		if( reg == 3 )
			return (void*)(int_val)c.EFlags;
		return (void*)(int_val)*GetContextReg32(&c,reg);
	}
#	else
	if( is64 ) return NULL;
#	endif
	CONTEXT c;
	c.ContextFlags = CONTEXT_FULL | CONTEXT_DEBUG_REGISTERS;
	if( !GetThreadContext(OpenTID(thread),&c) )
		return NULL;
	if( reg == 3 )
		return (void*)(int_val)c.EFlags;
	return (void*)*GetContextReg(&c,reg);
#	elif defined(HL_MAC)
	return mdbg_read_register(pid, thread, get_reg(reg), is64);
#	elif defined(USE_PTRACE)
	return (void*)ptrace(PTRACE_PEEKUSER,thread,get_reg(reg),0);
#	else
	return NULL;
#	endif
}

HL_API bool hl_debug_write_register( int pid, int thread, int reg, void *value, bool is64 ) {
#	if defined(HL_WIN)
#	ifdef HL_64
	if( !is64 ) {
		WOW64_CONTEXT c;
		c.ContextFlags = CONTEXT_FULL | CONTEXT_DEBUG_REGISTERS;
		if( !Wow64GetThreadContext(OpenTID(thread),&c) )
			return false;
		if( reg == 3 )
			c.EFlags = (int)(int_val)value;
		else
			*GetContextReg32(&c,reg) = (DWORD)(int_val)value;
		return (bool)Wow64SetThreadContext(OpenTID(thread),&c);
	}
#	else
	if( is64 ) return false;
#	endif
	CONTEXT c;
	c.ContextFlags = CONTEXT_FULL | CONTEXT_DEBUG_REGISTERS;
	if( !GetThreadContext(OpenTID(thread),&c) )
		return false;
	if( reg == 3 )
		c.EFlags = (int)(int_val)value;
	else
		*GetContextReg(&c,reg) = (REGDATA)value;
	return (bool)SetThreadContext(OpenTID(thread),&c);
#	elif defined(HL_MAC)
	return mdbg_write_register(pid, thread, get_reg(reg), value, is64);
#	elif defined(USE_PTRACE)
	return ptrace(PTRACE_POKEUSER,thread,get_reg(reg),value) >= 0;
#	else
	return false;
#	endif
}

DEFINE_PRIM(_BOOL, debug_start, _I32);
DEFINE_PRIM(_VOID, debug_stop, _I32);
DEFINE_PRIM(_BOOL, debug_breakpoint, _I32);
DEFINE_PRIM(_BOOL, debug_read, _I32 _BYTES _BYTES _I32);
DEFINE_PRIM(_BOOL, debug_write, _I32 _BYTES _BYTES _I32);
DEFINE_PRIM(_BOOL, debug_flush, _I32 _BYTES _I32);
DEFINE_PRIM(_I32, debug_wait, _I32 _REF(_I32) _I32);
DEFINE_PRIM(_BOOL, debug_resume, _I32 _I32);
DEFINE_PRIM(_BYTES, debug_read_register, _I32 _I32 _I32 _BOOL);
DEFINE_PRIM(_BOOL, debug_write_register, _I32 _I32 _I32 _BYTES _BOOL);


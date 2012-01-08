/* ************************************************************************ */
/*                                                         */
/*  Neko Standard Library                                       */
/*  Copyright (c)2005-2007 Motion-Twin                              */
/*                                                         */
/* This library is free software; you can redistribute it and/or         */
/* modify it under the terms of the GNU Lesser General Public            */
/* License as published by the Free Software Foundation; either            */
/* version 2.1 of the License, or (at your option) any later version.      */
/*                                                         */
/* This library is distributed in the hope that it will be useful,         */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of         */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                         */
/* ************************************************************************ */
#include <hx/CFFI.h>

#ifdef NEKO_WINDOWS
#   include <windows.h>
#else
#   include <sys/types.h>
#   include <unistd.h>
#   include <memory.h>
#   include <errno.h>
#   ifdef  ANDROID
#      include <sys/wait.h>
#   elif !defined(NEKO_MAC)
#      include <wait.h>
#   endif
#endif

#include <stdio.h>
#include <stdlib.h>

int __process_prims() { return 0; }

typedef struct {
#ifdef NEKO_WINDOWS
   HANDLE oread;
   HANDLE eread;
   HANDLE iwrite;
   PROCESS_INFORMATION pinf;
#else
   int oread;
   int eread;
   int iwrite;
   int pid;
#endif
} vprocess;

DEFINE_KIND(k_process);

#define val_process(v)   ((vprocess*)val_data(v))

/**
   <doc>
   <h1>Process</h1>
   <p>
   An API for starting and communication with sub processes.
   </p>
   </doc>
**/
#ifndef NEKO_WINDOWS
static int do_close( int fd ) {
   POSIX_LABEL(close_again);
   if( close(fd) != 0 ) {
      HANDLE_EINTR(close_again);
      return 1;
   }
   return 0;
}
#endif

static void free_process( value vp ) {
   vprocess *p = val_process(vp);
#   ifdef NEKO_WINDOWS
   CloseHandle(p->eread);
   CloseHandle(p->oread);
   CloseHandle(p->iwrite);
   CloseHandle(p->pinf.hProcess);
   CloseHandle(p->pinf.hThread);
#   else
   do_close(p->eread);
   do_close(p->oread);
   do_close(p->iwrite);
#   endif
        free(p);
}

/**
   process_run : cmd:string -> args:string array -> 'process
   <doc>
   Start a process using a command and the specified arguments.
   </doc>
**/
static value process_run( value cmd, value vargs ) {
   int i;
   vprocess *p;
   val_check(cmd,string);
   val_check(vargs,array);
#   ifdef NEKO_WINDOWS
   {       
      SECURITY_ATTRIBUTES sattr;      
      STARTUPINFOW sinf;
      HANDLE proc = GetCurrentProcess();
      HANDLE oread,eread,iwrite;
      // creates commandline
      buffer b = alloc_buffer("\"");
      val_buffer(b,cmd);
      buffer_append(b,"\"");

      int n = val_array_size(vargs);
      for(i=0;i<n;i++) {
         value v = val_array_i(vargs,i);
         val_check(v,string);
         buffer_append(b," \"");
         val_buffer(b,v);
         buffer_append(b,"\"");
      }
      wchar_t *name = val_dup_wstring(buffer_to_string(b));
      gc_enter_blocking();
      p = (vprocess*)malloc(sizeof(vprocess));
      // startup process
      sattr.nLength = sizeof(sattr);
      sattr.bInheritHandle = TRUE;
      sattr.lpSecurityDescriptor = NULL;
      memset(&sinf,0,sizeof(sinf));
      sinf.cb = sizeof(sinf);
      sinf.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
      sinf.wShowWindow = SW_NORMAL;
      CreatePipe(&oread,&sinf.hStdOutput,&sattr,0);
      CreatePipe(&eread,&sinf.hStdError,&sattr,0);
      CreatePipe(&sinf.hStdInput,&iwrite,&sattr,0);
      DuplicateHandle(proc,oread,proc,&p->oread,0,FALSE,DUPLICATE_SAME_ACCESS);
      DuplicateHandle(proc,eread,proc,&p->eread,0,FALSE,DUPLICATE_SAME_ACCESS);
      DuplicateHandle(proc,iwrite,proc,&p->iwrite,0,FALSE,DUPLICATE_SAME_ACCESS);
      CloseHandle(oread);
      CloseHandle(eread);
      CloseHandle(iwrite);
      //printf("Cmd %s\n",val_string(cmd));
      if( !CreateProcessW(NULL,name,NULL,NULL,TRUE,0,NULL,NULL,&sinf,&p->pinf) )
      {
         free(p);
         gc_exit_blocking();
			val_throw(alloc_null());
         return alloc_null();
      }
      // close unused pipes
      CloseHandle(sinf.hStdOutput);
      CloseHandle(sinf.hStdError);
      CloseHandle(sinf.hStdInput);
      gc_exit_blocking();
   }
#else
   char **argv = (char**)malloc(sizeof(char*)*(val_array_size(vargs)+2));

   argv[0] = strdup(val_string(cmd));
   for(i=0;i<val_array_size(vargs);i++) {
      value v = val_array_i(vargs,i);
      val_check(v,string);
      argv[i+1] = strdup(val_string(v));
   }
   argv[i+1] = NULL;
   int input[2], output[2], error[2];
   if( pipe(input) || pipe(output) || pipe(error) )
      return alloc_null();
   p = (vprocess*)malloc(sizeof(vprocess));
   p->pid = fork();
   if( p->pid == -1 )
      return alloc_null();
   gc_enter_blocking();
   // child
   if( p->pid == 0 ) {
      close(input[1]);
      close(output[0]);
      close(error[0]);
      dup2(input[0],0);
      dup2(output[1],1);
      dup2(error[1],2);
      execvp(val_string(cmd),argv);
      fprintf(stderr,"Command not found : %s\n",val_string(cmd));
      exit(1);
   }
   // parent
   for(i=0;i<=val_array_size(vargs);i++)
           free(argv[i]);
        free(argv);
   do_close(input[0]);
   do_close(output[1]);
   do_close(error[1]);
   p->iwrite = input[1];
   p->oread = output[0];
   p->eread = error[0];
   gc_exit_blocking();
#   endif
   {
      value vp = alloc_abstract(k_process,p);
      val_gc(vp,free_process);
      return vp;
   }
}

// CPP streams are byte-based, not char based ...
#define CHECK_ARGS()   \
   vprocess *p; \
   buffer buf; \
   val_check_kind(vp,k_process); \
   val_check(str,buffer); \
   buf = val_to_buffer(str); \
   val_check(pos,int); \
   val_check(len,int); \
   if( val_int(pos) < 0 || val_int(len) < 0 || val_int(pos) + val_int(len) > buffer_size(buf) ) \
      return alloc_null(); \
   p = val_process(vp); \


/**
   process_stdout_read : 'process -> buf:string -> pos:int -> len:int -> int
   <doc>
   Read up to [len] bytes in [buf] starting at [pos] from the process stdout.
   Returns the number of bytes readed this way. Raise an exception if this
   process stdout is closed and no more data is available for reading.

        For hxcpp, the input buffer is in bytes, not characters
   </doc>
**/
static value process_stdout_read( value vp, value str, value pos, value len ) {
   CHECK_ARGS();
   gc_enter_blocking();
#   ifdef NEKO_WINDOWS
   {
      DWORD nbytes;
      if( !ReadFile(p->oread,buffer_data(buf)+val_int(pos),val_int(len),&nbytes,NULL) )
      {
         gc_exit_blocking();
         return alloc_null();
      }
      gc_exit_blocking();
      return alloc_int(nbytes);
   }
#   else
   int nbytes = read(p->oread,buffer_data(buf) + val_int(pos),val_int(len));
   if( nbytes <= 0 )
   {
      gc_exit_blocking();
      alloc_null();
   }
   gc_exit_blocking();
   return alloc_int(nbytes);
#   endif
}

/**
   process_stderr_read : 'process -> buf:string -> pos:int -> len:int -> int
   <doc>
   Read up to [len] bytes in [buf] starting at [pos] from the process stderr.
   Returns the number of bytes readed this way. Raise an exception if this
   process stderr is closed and no more data is available for reading.
   </doc>
**/
static value process_stderr_read( value vp, value str, value pos, value len ) {
   CHECK_ARGS();

   gc_enter_blocking();
#   ifdef NEKO_WINDOWS
   DWORD nbytes;
   if( !ReadFile(p->eread,buffer_data(buf)+val_int(pos),val_int(len),&nbytes,NULL) )
#   else
   int nbytes = read(p->eread,buffer_data(buf)+val_int(pos),val_int(len));
   if( nbytes <= 0 )
#   endif
   {
      gc_exit_blocking();
      return alloc_null();
   }
   gc_exit_blocking();
   return alloc_int(nbytes);
}

/**
   process_stdin_write : 'process -> buf:string -> pos:int -> len:int -> int
   <doc>
   Write up to [len] bytes from [buf] starting at [pos] to the process stdin.
   Returns the number of bytes writen this way. Raise an exception if this
   process stdin is closed.
   </doc>
**/
static value process_stdin_write( value vp, value str, value pos, value len ) {
   CHECK_ARGS();
   gc_enter_blocking();
#   ifdef NEKO_WINDOWS
   DWORD nbytes;
   if( !WriteFile(p->iwrite,buffer_data(buf)+val_int(pos),val_int(len),&nbytes,NULL) )
#   else
   int nbytes = write(p->iwrite,buffer_data(buf)+val_int(pos),val_int(len));
   if( nbytes == -1 )
#   endif
   {
      gc_exit_blocking();
      return alloc_null();
   }
   gc_exit_blocking();
   return alloc_int(nbytes);
}

/**
   process_stdin_close : 'process -> void
   <doc>
   Close the process standard input.
   </doc>
**/
static value process_stdin_close( value vp ) {
   vprocess *p;
   val_check_kind(vp,k_process);
   p = val_process(vp);
#   ifdef NEKO_WINDOWS
   if( !CloseHandle(p->iwrite) )
      return alloc_null();
#   else
   if( do_close(p->iwrite) )
      return alloc_null();
   p->iwrite = -1;
#   endif
   return val_null;
}

/**
   process_exit : 'process -> int
   <doc>
   Wait until the process terminate, then returns its exit code.
   </doc>
**/
static value process_exit( value vp ) {
   vprocess *p;
   val_check_kind(vp,k_process);
   p = val_process(vp);
   gc_enter_blocking();
#   ifdef NEKO_WINDOWS
   {
      DWORD rval;
      WaitForSingleObject(p->pinf.hProcess,INFINITE);
      gc_exit_blocking();
      if( !GetExitCodeProcess(p->pinf.hProcess,&rval) )
         return alloc_null();
      return alloc_int(rval);
   }
#   else
   int rval;
   while( waitpid(p->pid,&rval,0) != p->pid ) {
      if( errno == EINTR )
         continue;
      gc_exit_blocking();
      return alloc_null();
   }
   gc_exit_blocking();
   if( !WIFEXITED(rval) )
      return alloc_null();
   return alloc_int(WEXITSTATUS(rval));
#   endif
}

/**
   process_pid : 'process -> int
   <doc>
   Returns the process id.
   </doc>
**/
static value process_pid( value vp ) {
   vprocess *p;
   val_check_kind(vp,k_process);
   p = val_process(vp);
#   ifdef NEKO_WINDOWS
   return alloc_int(p->pinf.dwProcessId);
#   else
   return alloc_int(p->pid);
#   endif
}

/**
   process_close : 'process -> void
   <doc>
   Close the process I/O.
   </doc>
**/
static value process_close( value vp ) {   
   val_check_kind(vp,k_process);
   free_process(vp);
   val_gc(vp,NULL);
   return val_null;
}

DEFINE_PRIM(process_run,2);
DEFINE_PRIM(process_stdout_read,4);
DEFINE_PRIM(process_stderr_read,4);
DEFINE_PRIM(process_stdin_close,1);
DEFINE_PRIM(process_stdin_write,4);
DEFINE_PRIM(process_exit,1);
DEFINE_PRIM(process_pid,1);
DEFINE_PRIM(process_close,1);

/* ************************************************************************ */

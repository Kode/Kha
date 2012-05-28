#include <hxcpp.h>
#include <stdio.h>

#if defined(HXCPP_DEBUG) && defined(HXCPP_DEBUG_HOST)

#include <hx/OS.h>

#ifdef NEKO_WINDOWS
#	include <winsock2.h>
#	define FDSIZE(n)	(sizeof(u_int) + (n) * sizeof(SOCKET))
#	define SHUT_WR		SD_SEND
#	define SHUT_RD		SD_RECEIVE
#	define SHUT_RDWR	SD_BOTH
	static bool init_done = false;
	static WSADATA gInitData;
#pragma comment(lib, "Ws2_32.lib")

#else
#	include <sys/types.h>
#	include <sys/socket.h>
#	include <sys/time.h>
#	include <netinet/in.h>
#	include <arpa/inet.h>
#	include <unistd.h>
#	include <netdb.h>
#	include <fcntl.h>
#	include <errno.h>
#	include <stdio.h>
#	include <poll.h>
	typedef int SOCKET;
#	define closesocket close
#	define SOCKET_ERROR (-1)
#	define INVALID_SOCKET (-1)
#endif

#include <string>

#endif


#include <hx/Thread.h>

#ifdef HXCPP_DEBUG

#ifdef HX_WINDOWS
#include <windows.h>
#include <stdio.h>
#endif

#ifdef ANDROID
#include <android/log.h>
#endif


void __hx_stack_set_last_exception();

namespace hx
{


#if defined(HXCPP_DEBUG_HOST)

bool   gTried = false;
bool   gDBGTrace = false;
SOCKET gDBGSocket = INVALID_SOCKET;
fd_set gDBGSocketSet;
timeval gNoWait = { 0,0 };


enum
{
   dbgCONT  = 'c',
   dbgBREAK = 'X',
   dbgTRACE = 't',
   dbgNOTRACE = 'n',
   dbgSTEP = 's',

   dbgWHERE = 'w',
   dbgKILL = 'k',


   rspRESULT = 's',
   rspDATA = 'd',
   rspINFO = 'i',
};

int gDBGState = dbgCONT;


int DbgReadByte(bool &ioOk)
{
   unsigned char result;
   if (recv(gDBGSocket, (char *)&result,1,0)!=1)
   {
      ioOk = false;
      return 0;
   }
   return result;
}


void DbgWriteString(const std::string &inMessage)
{
   int len = inMessage.size();
   send(gDBGSocket,(char *)&len,4,0);
   if (len)
      send(gDBGSocket,inMessage.c_str(),len,0);
}


void DbgWriteData(const std::string &inMessage)
{
   char code = rspDATA;
   send(gDBGSocket,(char *)&code,1,0);
   DbgWriteString(inMessage);
}


void DbgWriteInfo(const std::string &inMessage)
{
   char code = rspINFO;
   send(gDBGSocket,(char *)&code,1,0);
   DbgWriteString(inMessage);
}




void DbgWriteResponse(const std::string &inMessage)
{
   char code = rspRESULT;
   send(gDBGSocket,(char *)&code,1,0);
   DbgWriteString(inMessage);
}



void DbgSocketLost()
{
   printf("Debug socket lost");
   gDBGSocket = INVALID_SOCKET;
}


void DbgWhere();
void DbgTrace();
void DbgWaitLoop();

void DbgRunCommand(int command,bool waitOnBreak)
{
   printf("Command : %d\n", command);
   bool inWait = gDBGState == dbgBREAK;
   if (command==dbgBREAK)
   {
      gDBGState = dbgBREAK;
      DbgWriteResponse("State - break");
   }
   else if (command==dbgCONT)
   {
      gDBGState = dbgCONT;
      DbgWriteResponse("State - cont");
   }
   else if (command==dbgWHERE)
   {
      if (gDBGState==dbgCONT)
      {
         DbgWriteResponse("Must be stopped to use 'where'");
      }
      else
      {
         DbgWhere();
         DbgWriteResponse("- end of stack -");
      }
   }
   else if (command==dbgKILL)
   {
      exit(1);
   }
   else if (command==dbgTRACE)
   {
      gDBGTrace = true;
      DbgWriteResponse("trace on");
   }
   else if (command==dbgNOTRACE)
   {
      gDBGTrace = false;
      DbgWriteResponse("trace off");
   }
   else
   {
      DbgWriteResponse("Unknown command?");
   }

   if (waitOnBreak & gDBGState==dbgBREAK)
     DbgWaitLoop();
}


void DbgWaitLoop()
{
   bool ok = true;
   while(gDBGState == dbgBREAK && ok)
   {
       printf("Waiting for command...\n");
       int command = DbgReadByte(ok);
       if (!ok)
       {
          DbgSocketLost();
          return;
       }
       DbgRunCommand(command,false);
   }
}


bool DbgInit()
{
   if (!gTried)
   {
      gTried = true;
      #ifdef NEKO_WINDOWS
      WSAStartup(MAKEWORD(2,0),&gInitData);
      #endif
      gDBGSocket = socket(AF_INET,SOCK_STREAM,0);
      if (gDBGSocket != INVALID_SOCKET)
      {
         #ifdef NEKO_MAC
         setsockopt(gDBGSocket,SOL_SOCKET,SO_NOSIGPIPE,NULL,0);
         #endif
         #ifdef NEKO_POSIX
         // we don't want sockets to be inherited in case of exec
         {
         int old = fcntl(gDBGSocket,F_GETFD,0);
         if ( old >= 0 )
            fcntl(gDBGSocket,F_SETFD,old|FD_CLOEXEC);
         }
         #endif

 
         char host[] = HXCPP_DEBUG_HOST;
         char *sep = host;
         while(*sep && *sep!=':') sep++;
         int port = 80;
         if (*sep)
         {
            port = atoi(sep+1);
            *sep = '\0';
         }

         struct sockaddr_in addr;
         memset(&addr,0,sizeof(addr));
         addr.sin_family = AF_INET;
         addr.sin_addr.s_addr = inet_addr(host);
         addr.sin_port = htons( port );

         #ifdef ANDROID
         __android_log_print(ANDROID_LOG_ERROR, "HXCPPDBG",
              "DBG seeking connection to %s : %d", host, port );
         #else
         printf( "DBG seeking connection to %s : %d\n", host, port );
         #endif

         int result =  connect(gDBGSocket,(struct sockaddr*)&addr,sizeof(addr));
         if (result != 0 )
         {
            #ifdef HX_WINDOWS
            printf("Unable to connect to server: %ld\n", WSAGetLastError());
            #else
            printf("Unable to connect to server: %d\n", errno );
            #endif
            gDBGSocket = INVALID_SOCKET;
         }
         else
         {
            FD_ZERO(&gDBGSocketSet);
         }
      }
      #ifdef ANDROID
      __android_log_print(ANDROID_LOG_ERROR, "HXCPPDBG",
           "DBG connection %s", gDBGSocket==INVALID_SOCKET?"BAD":"GOOD");
      #else
      printf( "DBG connection %s\n", gDBGSocket==INVALID_SOCKET?"BAD":"GOOD");
      #endif

      if (gDBGSocket!=INVALID_SOCKET)
      {
         bool ok = false;
         int command  = DbgReadByte(ok);
         DbgRunCommand(command,true);
      }
   }

   return gDBGSocket!=INVALID_SOCKET;
}

void CheckDBG()
{
   if (DbgInit())
   {
      FD_SET(gDBGSocket,&gDBGSocketSet);
      if (select((int)(gDBGSocket+1), &gDBGSocketSet,0,0,&gNoWait)>0)
      {
         // Got something to read...
         bool ok = true;
         int val = DbgReadByte(ok);
         if (!ok)
         {
            DbgSocketLost();
            return;
         }

         DbgRunCommand(val,true);
      }
   }
   if (gDBGTrace)
   {
      DbgTrace();
   }
}

#endif // HXCPP_DEBUG_HOST



void CriticalError(const String &inErr)
{
   __hx_stack_set_last_exception();
   __hx_dump_stack();

   #ifdef HX_UTF8_STRINGS
   fprintf(stderr,"Critical Error: %s\n", inErr.__s);
   #else
   fprintf(stderr,"Critical Error: %S\n", inErr.__s);
   #endif

   #ifdef HX_WINDOWS
      #ifdef HX_UTF8_STRINGS
      MessageBoxA(0,inErr.__s,"Critial Error - program must terminate",MB_ICONEXCLAMATION|MB_OK);
      #else
      MessageBoxW(0,inErr.__s,L"Critial Error - program must terminate",MB_ICONEXCLAMATION|MB_OK);
      #endif
   #endif
   // Good when using gdb...
   // *(int *)0=0;
   exit(1);
}

struct CallLocation
{
   const char *mFunction;
   const char *mFile;
   int        mLine; 
};

struct CallStack
{
   enum { StackSize = 1000 };

   CallStack()
   {
      mSize = 0;
      mLastException = 0;
   }
   void Push(const char *inName)
   {
      mSize++;
      mLastException = 0;
      if (mSize<StackSize)
      {
          mLocations[mSize].mFunction = inName;
          mLocations[mSize].mFile = "?";
          mLocations[mSize].mLine = 0;
      }
   }
   void Pop() { --mSize; }
   void SetSrcPos(const char *inFile, int inLine)
   {
      if (mSize<StackSize)
      {
          mLocations[mSize].mFile = inFile;
          mLocations[mSize].mLine = inLine;
      }
      #ifdef HXCPP_DEBUG_HOST
      CheckDBG();
      #endif
   }
   void SetLastException()
   {
      mLastException = mSize;
   }
   void Dump()
   {
      for(int i=1;i<=mLastException && i<StackSize;i++)
      {
         CallLocation loc = mLocations[i];
         #ifdef ANDROID
         if (loc.mFunction==0)
             __android_log_print(ANDROID_LOG_ERROR, "HXCPP", "Called from CFunction\n");
         else
             __android_log_print(ANDROID_LOG_ERROR, "HXCPP", "Called from %s, %s %d\n", loc.mFunction, loc.mFile, loc.mLine );
         #else
         if (loc.mFunction==0)
            printf("Called from CFunction\n");
         else
            printf("Called from %s, %s %d\n", loc.mFunction, loc.mFile, loc.mLine );
         #endif
      }
      if (mLastException >= StackSize)
      {
         printf("... %d functions missing ...\n", mLastException + 1 - StackSize);
      }
   }
   #ifdef HXCPP_DEBUG_HOST
   void Where()
   {
      int last = mSize + 1;
      if (mLastException!=0 && mLastException<last)
         last = mLastException;
      if (last>StackSize)
         last = StackSize;
      for(int i=1;i<=mSize && i<StackSize;i++)
      {
         CallLocation loc = mLocations[i];
         if (loc.mFunction==0)
             DbgWriteData("CFunction\n");
         else
         {
            char buf[2048];
            sprintf(buf,"%s @  %s:%d\n", loc.mFunction, loc.mFile, loc.mLine );
            DbgWriteData(buf);
         }
      }
   }

   void Trace()
   {
      int last = mSize;
      //if (mLastException>0 && mLastException<last)
      //   last = mLastException;
      if (last>StackSize)
         last = StackSize-1;
    
      CallLocation loc = mLocations[last];
      char buf[2048];
      sprintf(buf,"%s @  %s:%d", loc.mFunction, loc.mFile, loc.mLine );
      DbgWriteInfo(buf);
   }
   #endif


   int mSize;
   int mLastException;
   CallLocation mLocations[StackSize];
};


TLSData<CallStack> tlsCallStack;
CallStack *GetCallStack()
{
   CallStack *result =  tlsCallStack.Get();
   if (!result)
   {
      result = new CallStack();
      tlsCallStack.Set(result);
   }
   return result;
}

#ifdef HXCPP_DEBUG_HOST
void DbgWhere()
{
   hx::GetCallStack()->Where();
}

void DbgTrace()
{
   hx::GetCallStack()->Trace();
}
#
#endif
 



}

__AutoStack::__AutoStack(const char *inName)
{
   hx::GetCallStack()->Push(inName);
}

__AutoStack::~__AutoStack()
{
   hx::GetCallStack()->Pop();
}

void __hx_set_source_pos(const char *inFile, int inLine)
{
   hx::GetCallStack()->SetSrcPos(inFile,inLine);
}

void __hx_dump_stack()
{
   hx::GetCallStack()->Dump();
}

void __hx_stack_set_last_exception()
{
   hx::GetCallStack()->SetLastException();
}


#else

void __hx_dump_stack()
{
   //printf("No stack in release mode.\n");
}

#endif

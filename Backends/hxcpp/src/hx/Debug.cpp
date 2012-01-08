#include <hxcpp.h>
#include <hx/Thread.h>

#ifdef HXCPP_DEBUG

#ifdef HX_WINDOWS
#include <windows.h>
#endif

#ifdef ANDROID
#include <android/log.h>
#endif


void __hx_stack_set_last_exception();

namespace hx
{

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
      mLastException;
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


   int mSize;
   int mLastException;
   CallLocation mLocations[StackSize];
};


#ifdef HXCPP_MULTI_THREADED
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


#else
CallStack *gStack = 0;
CallStack *GetCallStack()
{
   if (!gStack) gStack = new CallStack();
   return gStack;
}
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

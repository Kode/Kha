#include <hxcpp.h>

#include <map>
#include <vector>
#include <set>


#ifdef _WIN32

#define GC_WIN32_THREADS
#include <time.h>

#endif


#include "RedBlack.h"

namespace hx
{

void *Object::operator new( size_t inSize, bool inContainer )
{
   return InternalNew(inSize,true);
}

}


void *String::operator new( size_t inSize )
{
   return hx::InternalNew(inSize,false);
}


void __hxcpp_collect()
{
	hx::InternalCollect();
}



namespace hx
{

void GCAddFinalizer(hx::Object *v, finalizer f)
{
   if (v)
   {
      throw Dynamic(HX_CSTRING("Add finalizer error"));
   }
}



HX_CHAR *NewString(int inLen)
{
   HX_CHAR *result =  (HX_CHAR *)hx::InternalNew( (inLen+1)*sizeof(HX_CHAR), false );
   result[inLen] = '\0';
   return result;

}

void *NewGCBytes(void *inData,int inSize)
{
   void *result =  hx::InternalNew(inSize,false);
   if (inData)
   {
      memcpy(result,inData,inSize);
   }
   return result;
}


void *NewGCPrivate(void *inData,int inSize)
{
   void *result =  InternalNew(inSize,false);
   if (inData)
   {
      memcpy(result,inData,inSize);
   }
   return result;
}


void *GCRealloc(void *inData,int inSize)
{
   return InternalRealloc(inData,inSize);
}


// Put this function here so we can be reasonablly sure that "this" register and
// the 4 registers that may be used to pass args are on the stack.
int RegisterCapture::Capture(int *inTopOfStack,int **inBuf,int &outSize,int inMaxSize, int *inBottom)
{
	int size = ( (char *)inTopOfStack - (char *)inBottom )/sizeof(void *);
	if (size>inMaxSize)
		size = inMaxSize;
	outSize = size;
	if (size>0)
	   memcpy(inBuf,inBottom,size*sizeof(void*));
	return 1;
}


RegisterCapture *gRegisterCaptureInstance = 0;
RegisterCapture *RegisterCapture::Instance()
{
	if (!gRegisterCaptureInstance)
		gRegisterCaptureInstance = new RegisterCapture();
	return gRegisterCaptureInstance;
}


} // end namespace hx




void __hxcpp_enable(bool inEnable)
{
	hx::InternalEnableGC(inEnable);
}



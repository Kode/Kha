#ifndef HX_CFFI_LOADER_H
#define HX_CFFI_LOADER_H

#ifdef ANDROID
#include <android/log.h>
#endif


#ifdef NEKO_WINDOWS
#include <windows.h>
#include <stdio.h>
// Stoopid windows ...
#ifdef RegisterClass
#undef RegisterClass
#endif
#ifdef abs
#undef abs
#endif

#else // NOT NEKO_WINDOWS

#ifdef NEKO_LINUX
#define EXT "dso"
#define NEKO_EXT "so"
//#define __USE_GNU 1
#else
#ifdef ANDROID
#define EXT "so"
#else
#include <mach-o/dyld.h>
#define EXT "dylib"
#define NEKO_EXT "dylib"
#endif
#endif

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>


#endif



typedef void *(*ResolveProc)(const char *inName);
static ResolveProc sResolveProc = 0;

#ifdef ANDROID
extern "C" {
EXPORT void hx_set_loader(ResolveProc inProc)
{
   __android_log_print(ANDROID_LOG_INFO, "haxe plugin", "Got Load Proc %08x", inProc );
   sResolveProc = inProc;
}
}
#endif



#ifdef STATIC_LINK

extern "C" void * hx_cffi(const char *inName);
#define LoadFunc hx_cffi

#else  // Dynamic link



#ifdef NEKO_COMPATIBLE
//-------- NEKO Interface -----------------------------------------------------
namespace
{

#include <hx/NekoFunc.h>


void *sNekoDllHandle = 0;

void *LoadNekoFunc(const char *inName)
{
   static bool tried = false;
   if (tried && !sNekoDllHandle)
       return 0;
   tried = true;

   if (!sNekoDllHandle)
   {
      #if HX_WINDOWS
      sNekoDllHandle = GetModuleHandle("neko.dll");
      #else
      sNekoDllHandle = dlopen("libneko." NEKO_EXT, RTLD_NOW);
      // Look for libneko.so.0 too ...
      if (!sNekoDllHandle)
         sNekoDllHandle = dlopen("libneko." NEKO_EXT ".0", RTLD_NOW);
      #endif
  
      if (!sNekoDllHandle)
      {
         fprintf(stderr,"Could not link to neko.\n");
         return 0;
      }
   }


   #if HX_WINDOWS
   void *result = GetProcAddress((HMODULE)sNekoDllHandle,inName);
   #else
   void *result = dlsym(sNekoDllHandle,inName);
   #endif

   //printf(" %s = %p\n", inName, result );
   return result;
}


static int __a_id = 0;
static int __s_id = 0;
static int length_id = 0;

neko_value *gNeko2HaxeString = 0;
neko_value *gNekoNewArray = 0;
neko_value gNekoNull = 0;
neko_value gNekoTrue = 0;
neko_value gNekoFalse = 0;


/*


*/

void *DynamicNekoLoader(const char *inName);

typedef neko_value (*alloc_object_func)(neko_value);
typedef neko_value (*alloc_string_func)(const char *);
typedef neko_value (*val_call1_func)(neko_value,neko_value);
typedef neko_value (*val_field_func)(neko_value,int);
typedef neko_value *(*alloc_root_func)(int);
typedef char *(*alloc_private_func)(int);
typedef neko_value (*copy_string_func)(const char *,int);
typedef int (*val_id_func)(const char *);
typedef neko_buffer (*alloc_buffer_func)(const char *);
typedef void (*buffer_append_sub_func)(neko_buffer,const char *,int);
typedef void (*fail_func)(neko_value,const char *,int);
typedef neko_value (*alloc_array_func)(unsigned int);

static alloc_object_func dyn_alloc_object = 0;
static alloc_string_func dyn_alloc_string = 0;
static val_call1_func dyn_val_call1 = 0;
static val_field_func dyn_val_field = 0;
static alloc_root_func dyn_alloc_root = 0;
static alloc_private_func dyn_alloc_private = 0;
static copy_string_func dyn_copy_string = 0;
static val_id_func dyn_val_id = 0;
static alloc_buffer_func dyn_alloc_buffer = 0;
static fail_func dyn_fail = 0;
static buffer_append_sub_func dyn_buffer_append_sub = 0;
static alloc_array_func dyn_alloc_array = 0;


neko_value api_alloc_string(const char *inString)
{
   neko_value neko_string = dyn_alloc_string(inString);
   if (gNeko2HaxeString)
      return dyn_val_call1(*gNeko2HaxeString,neko_string);
   return neko_string;
}


#define NOT_IMPLEMNETED(func) dyn_fail(api_alloc_string("NOT Implemented:" func),__FILE__,__LINE__)

void * api_empty() { return 0; }

bool api_val_bool(neko_value  arg1) { return arg1==gNekoTrue; }
int api_val_int(neko_value  arg1) { return neko_val_int(arg1); }
double api_val_float(neko_value  arg1) { return *(double *)( ((char *)arg1) + 4 ); }
double api_val_number(neko_value  arg1) { return neko_val_is_int(arg1) ? neko_val_int(arg1) : api_val_float(arg1); }


neko_value api_alloc_bool(bool arg1) { return arg1 ? gNekoTrue : gNekoFalse; }
neko_value api_alloc_int(int arg1) { return neko_alloc_int(arg1); }
neko_value api_alloc_empty_object()
{
   return dyn_alloc_object(gNekoNull);
}

const char * api_val_string(neko_value  arg1)
{
	if (neko_val_is_string(arg1))
	   return neko_val_string(arg1);

	neko_value s = dyn_val_field(arg1,__s_id);

	return neko_val_string(s);
}


double  api_val_field_numeric(neko_value  arg1,int arg2)
{
	neko_value field = dyn_val_field(arg1, arg2);
	if (neko_val_is_number(field))
		return api_val_number(field);
	if (field==gNekoTrue)
      return 1;
	return 0;
}




// Byte arrays
neko_buffer api_val_to_buffer(neko_value  arg1) { return dyn_alloc_buffer(api_val_string(arg1)); } 


neko_buffer api_alloc_buffer_len(int inLen)
{
	char *s=dyn_alloc_private(inLen+1);
	memset(s,' ',inLen);
	s[inLen] = 0;
	neko_buffer b = dyn_alloc_buffer(s);
	return b;
}


int api_buffer_size(neko_buffer inBuffer) { NOT_IMPLEMNETED("api_buffer_size"); return 0; }

void api_buffer_set_size(neko_buffer inBuffer,int inLen) { NOT_IMPLEMNETED("api_buffer_set_size"); }


void api_buffer_append_char(neko_buffer inBuffer,int inChar)
{
	char buf[2] = { inChar, '\0' };
	dyn_buffer_append_sub(inBuffer,buf,1);
}

char * api_buffer_data(neko_buffer inBuffer) { NOT_IMPLEMNETED("api_buffer_data"); return 0; }

int api_val_strlen(neko_value  arg1)
{
	if (neko_val_is_string(arg1))
	   return neko_val_strlen(arg1);


	neko_value l =  dyn_val_field(arg1,length_id);
	if (neko_val_is_int(l))
		return api_val_int(l);
	return 0;
}



const wchar_t *api_val_wstring(neko_value  arg1)
{

	int len = api_val_strlen(arg1);
	unsigned char *ptr = (unsigned char *)api_val_string(arg1);
	wchar_t *result = (wchar_t *)dyn_alloc_private((len+1)*sizeof(wchar_t));
	for(int i=0;i<len;i++)
		result[i] = ptr[i];
	result[len] = 0;
	return result;
}

wchar_t * api_val_dup_wstring(neko_value inVal)
{
	return (wchar_t *)api_val_wstring(inVal);
}



char * api_val_dup_string(neko_value inVal)
{

	int len = api_val_strlen(inVal);
	const char *ptr = api_val_string(inVal);
	char *result = dyn_alloc_private(len+1);
	memcpy(result,ptr,len);
	result[len] = '\0';
	return result;
}

neko_value api_alloc_string_len(const char *inStr,int inLen)
{
	if (gNeko2HaxeString)
		return dyn_val_call1(*gNeko2HaxeString,dyn_copy_string(inStr,inLen));
   return dyn_copy_string(inStr,inLen);
}


neko_value api_alloc_wstring_len(const wchar_t *inStr,int inLen)
{
	char *result = dyn_alloc_private(inLen+1);
	for(int i=0;i<inLen;i++)
		result[i] = inStr[i];
	result[inLen] = 0;
   return api_alloc_string_len(result,inLen);
}





int api_val_type(neko_value  arg1)
{
	int t=neko_val_type(arg1);

	if (t==VAL_OBJECT)
	{
		neko_value __a = dyn_val_field(arg1,__a_id);
		if (neko_val_is_array(__a))
			return valtArray;
		neko_value __s = dyn_val_field(arg1,__s_id);
		if (neko_val_is_string(__s))
			return valtString;
	}
	if (t<7)
		return (ValueType)t;
	if (t==VAL_ABSTRACT)
		return valtAbstractBase;

	if (t==VAL_PRIMITIVE || t==VAL_JITFUN)
		return valtFunction;
	if (t==VAL_32_BITS || t==VAL_INT)
		return valtInt;
	return valtNull;
}

neko_value *api_alloc_root()
{
   return dyn_alloc_root(1);
}


void * api_val_to_kind(neko_value  arg1,neko_vkind arg2)
{
	neko_vkind k = (neko_vkind)neko_val_kind(arg1);
	if (k!=arg2)
		return 0;
	return neko_val_data(arg1);
}


int api_alloc_kind()
{
	static int id = 1;
	int result = id;
	id += 4;
	return result;
}
neko_value api_alloc_null() { return gNekoNull; }


void api_hx_error()
{
   dyn_fail(dyn_alloc_string("An unknown error has occurred."),"",1);
}

void * api_val_data(neko_value  arg1) { return neko_val_data(arg1); }

// Array access - generic
int api_val_array_size(neko_value  arg1)
{
	if (neko_val_is_array(arg1))
	   return neko_val_array_size(arg1);
	neko_value l = dyn_val_field(arg1,length_id);
	return neko_val_int(l);
}


neko_value  api_val_array_i(neko_value  arg1,int arg2)
{
	if (neko_val_is_array(arg1))
	   return neko_val_array_ptr(arg1)[arg2];
	return neko_val_array_ptr(dyn_val_field(arg1,__a_id))[arg2];
}

void api_val_array_set_i(neko_value  arg1,int arg2,neko_value inVal)
{
	if (!neko_val_is_array(arg1))
		arg1 = dyn_val_field(arg1,__a_id);
	neko_val_array_ptr(arg1)[arg2] = inVal;
}

void api_val_array_set_size(neko_value  arg1,int inLen)
{
	NOT_IMPLEMNETED("api_val_array_set_size");
}

void api_val_array_push(neko_value  arg1,neko_value inValue)
{
	NOT_IMPLEMNETED("api_val_array_push");
}


neko_value  api_alloc_array(int arg1)
{
   if (!gNekoNewArray)
	   return dyn_alloc_array(arg1);
	return dyn_val_call1(*gNekoNewArray,neko_alloc_int(arg1));
}


neko_value * api_val_array_value(neko_value  arg1)
{
	if (neko_val_is_array(arg1))
	   return neko_val_array_ptr(arg1);
	return neko_val_array_ptr(dyn_val_field(arg1,__a_id));
}

neko_value  api_val_call0_traceexcept(neko_value  arg1)
{
	NOT_IMPLEMNETED("api_val_call0_traceexcept");
	return gNekoNull;
}




#define IMPLEMENT_HERE(x) if (!strcmp(inName,#x)) return (void *)api_##x;
#define IGNORE_API(x) if (!strcmp(inName,#x)) return (void *)api_empty;


void *DynamicNekoLoader(const char *inName)
{
   IMPLEMENT_HERE(alloc_kind)
   IMPLEMENT_HERE(alloc_null)
   IMPLEMENT_HERE(val_to_kind)
   if (!strcmp(inName,"hx_fail"))
      return LoadNekoFunc("_neko_failure");
   IMPLEMENT_HERE(val_type)
   IMPLEMENT_HERE(val_bool)
   IMPLEMENT_HERE(val_int)
   IMPLEMENT_HERE(val_float)
   IMPLEMENT_HERE(val_number)
   IMPLEMENT_HERE(val_field_numeric)
   IMPLEMENT_HERE(alloc_bool)
   IMPLEMENT_HERE(alloc_int)
   IMPLEMENT_HERE(alloc_empty_object)
   IMPLEMENT_HERE(alloc_root)

   IGNORE_API(gc_enter_blocking)
   IGNORE_API(gc_exit_blocking)
   IGNORE_API(gc_safe_point)
   IGNORE_API(gc_add_root)
   IGNORE_API(gc_remove_root)
   IGNORE_API(gc_set_top_of_stack)
   IGNORE_API(create_root)
   IGNORE_API(query_root)
   IGNORE_API(destroy_root)
   IGNORE_API(hx_register_prim)
   IGNORE_API(val_array_int)
   IGNORE_API(val_array_double)
   IGNORE_API(val_array_bool)

   if (!strcmp(inName,"hx_alloc"))
      return LoadNekoFunc("neko_alloc");
   if (!strcmp(inName,"val_gc_ptr"))
      return LoadNekoFunc("neko_val_gc");

   if (!strcmp(inName,"buffer_val"))
      return LoadNekoFunc("neko_buffer_to_string");

   IMPLEMENT_HERE(val_strlen)
   IMPLEMENT_HERE(val_wstring)
   IMPLEMENT_HERE(val_string)
   IMPLEMENT_HERE(alloc_string)
   IMPLEMENT_HERE(val_dup_wstring)
   IMPLEMENT_HERE(val_dup_string)
   IMPLEMENT_HERE(alloc_string_len)
   IMPLEMENT_HERE(alloc_wstring_len)

   IMPLEMENT_HERE(val_to_buffer)
   IMPLEMENT_HERE(alloc_buffer_len)
   IMPLEMENT_HERE(buffer_size)
   IMPLEMENT_HERE(buffer_set_size)
   IMPLEMENT_HERE(buffer_append_char)
   IMPLEMENT_HERE(buffer_data)

   IMPLEMENT_HERE(hx_error)
   IMPLEMENT_HERE(val_array_i)
   IMPLEMENT_HERE(val_array_size)
   IMPLEMENT_HERE(val_data)
   IMPLEMENT_HERE(val_array_set_i)
   IMPLEMENT_HERE(val_array_set_size)
   IMPLEMENT_HERE(val_array_push)
   IMPLEMENT_HERE(alloc_array)
   IMPLEMENT_HERE(val_array_value)

   IMPLEMENT_HERE(val_call0_traceexcept)


   char buffer[100];
   strcpy(buffer,"neko_");
   strcat(buffer,inName);
   void *result = LoadNekoFunc(buffer);
   if (result)
      return result;

	return 0;
}


ResolveProc InitDynamicNekoLoader()
{
   static bool init = false;
   if (!init)
   {
      dyn_alloc_private = (alloc_private_func)LoadNekoFunc("neko_alloc_private");
      dyn_alloc_object = (alloc_object_func)LoadNekoFunc("neko_alloc_object");
      dyn_alloc_string = (alloc_string_func)LoadNekoFunc("neko_alloc_string");
      dyn_val_call1 = (val_call1_func)LoadNekoFunc("neko_val_call1");
      dyn_val_field = (val_field_func)LoadNekoFunc("neko_val_field");
      dyn_alloc_root = (alloc_root_func)LoadNekoFunc("neko_alloc_root");
      dyn_copy_string = (copy_string_func)LoadNekoFunc("neko_copy_string");
      dyn_val_id = (val_id_func)LoadNekoFunc("neko_val_id");
      dyn_alloc_buffer = (alloc_buffer_func)LoadNekoFunc("neko_alloc_buffer");
      dyn_fail = (fail_func)LoadNekoFunc("_neko_failure");
      dyn_buffer_append_sub = (buffer_append_sub_func)LoadNekoFunc("neko_buffer_append_sub");
      dyn_alloc_array = (alloc_array_func)LoadNekoFunc("neko_alloc_array");
      init = true;
   }

   if (!dyn_val_id)
     return 0;


   __a_id = dyn_val_id("__a");
   __s_id = dyn_val_id("__s");
   length_id = dyn_val_id("length");

   return DynamicNekoLoader;
}


neko_value neko_init(neko_value inNewString,neko_value inNewArray,neko_value inNull, neko_value inTrue, neko_value inFalse)
{
   InitDynamicNekoLoader();

   gNekoNull = inNull;
   gNekoTrue = inTrue;
   gNekoFalse = inFalse;

   gNeko2HaxeString = dyn_alloc_root(1);
   *gNeko2HaxeString = inNewString;
   gNekoNewArray = dyn_alloc_root(1);
   *gNekoNewArray = inNewArray;

   return gNekoNull;
}



} // end anon namespace

// -----------------------------------------------------------------------------


#endif // NEKO_COMPATIBLE




#ifdef NEKO_WINDOWS

 
void *LoadFunc(const char *inName)
{
   static char *modules[] = { 0, "hxcpp", "hxcpp-debug" };
   for(int i=0; i<3 && sResolveProc==0; i++)
   {
      HMODULE handle = GetModuleHandleA(modules[i]);
      if (handle)
      {
         sResolveProc = (ResolveProc)GetProcAddress(handle,"hx_cffi");
         if (sResolveProc==0)
            FreeLibrary(handle);
      }
   }

   #ifdef NEKO_COMPATIBLE
   if (sResolveProc==0)
   {
      sResolveProc = InitDynamicNekoLoader();
   }
   #endif

   if (sResolveProc==0)
   {
      fprintf(stderr,"Could not link plugin to process (hxCFFILoader.h %d)\n",__LINE__);
      exit(1);
   }
   return sResolveProc(inName);
}

#else // not windows


void *LoadFunc(const char *inName)
{
#ifndef ANDROID
   if (sResolveProc==0)
   {
      sResolveProc = (ResolveProc)dlsym(RTLD_DEFAULT,"hx_cffi");
   }

   #ifdef NEKO_COMPATIBLE
   if (sResolveProc==0)
   {
      sResolveProc = InitDynamicNekoLoader();
   }
   #endif



#endif // !Android

   if (sResolveProc==0)
   {
      #ifdef ANDROID
      __android_log_print(ANDROID_LOG_ERROR, "CFFILoader.h", "Could not API %s", inName);
      return 0;
      #else
      fprintf(stderr,"Could not link plugin to process (hxCFFILoader.h %d)\n",__LINE__);
      exit(1);
      #endif
   }
   return sResolveProc(inName);
}

#undef EXT

#endif

#endif // not static link
 

#ifndef ANDROID

#define DEFFUNC(name,ret,def_args,call_args) \
typedef ret (*FUNC_##name)def_args; \
extern FUNC_##name name; \
ret IMPL_##name def_args \
{ \
   name = (FUNC_##name)LoadFunc(#name); \
   if (!name) \
   { \
      fprintf(stderr,"Could find function " #name " \n"); \
      exit(1); \
   } \
   return name call_args; \
}\
FUNC_##name name = IMPL_##name;
 
#ifdef NEKO_COMPATIBLE
DEFINE_PRIM(neko_init,5)
#endif

#else


#define DEFFUNC(name,ret,def_args,call_args) \
typedef ret (*FUNC_##name)def_args; \
extern FUNC_##name name; \
ret IMPL_##name def_args \
{ \
   name = (FUNC_##name)LoadFunc(#name); \
   if (!name) \
   { \
      __android_log_print(ANDROID_LOG_ERROR,"CFFILoader", "Could not resolve :" #name "\n"); \
   } \
   return name call_args; \
}\
FUNC_##name name = IMPL_##name;
 

#endif

#endif

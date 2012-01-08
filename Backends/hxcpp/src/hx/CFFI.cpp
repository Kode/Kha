#include <hxcpp.h>
#include <stdio.h>
// Get headers etc.
#include <hx/OS.h>

#define IGNORE_CFFI_API_H

#include <hx/CFFI.h>
#include <map>
#define INT_MIN     (-2147483647 - 1) /* minimum (signed) int value */
#define INT_MAX       2147483647    /* maximum (signed) int value */
#include <string>


// Class for boxing external handles

namespace hx
{

class Abstract_obj : public Object
{
public:
   Abstract_obj(int inType,void *inData)
   {
      mType = inType;
      mHandle = inData;
      mFinalizer = 0;
   }

   virtual int __GetType() const { return mType; }
   virtual hx::ObjectPtr<Class_obj> __GetClass() const { return 0; }
   virtual bool __IsClass(Class inClass ) const { return false; }

   virtual void *__GetHandle() const
   {
      return mHandle;
   }

   void __Mark(HX_MARK_PARAMS)
   {
      if (mFinalizer)
         mFinalizer->Mark();
   }

   void SetFinalizer(finalizer inFinalizer)
   {
      if (!inFinalizer)
      {
         mFinalizer->Detach();
         mFinalizer = 0;
      }
      else
      {
         if (!mFinalizer)
            mFinalizer = new hx::InternalFinalizer(this);
         mFinalizer->mFinalizer = inFinalizer;
      }
   }

   hx::InternalFinalizer *mFinalizer;
   void *mHandle;
   int mType;
};

typedef ObjectPtr<Abstract_obj> Abstract;

} // end namespace hx

vkind k_int32 = (vkind)vtAbstractBase;
vkind k_hash = (vkind)(vtAbstractBase + 1);
static int sgKinds = (int)(vtAbstractBase + 2);
typedef std::map<std::string,int> KindMap;
static KindMap sgKindMap;


int hxcpp_alloc_kind()
{
   return ++sgKinds;
}


void hxcpp_kind_share(int &ioKind,const char *inName)
{
   int &kind = sgKindMap[inName];
   if (kind==0)
      kind = hxcpp_alloc_kind();
   ioKind = kind;
}

#define THROWS throw(Dynamic)
//#define THROWS


extern "C" {


/*
 This bit of Macro magic is used to define extern function pointers
  in ndlls, define stub implementations that link back to the hxcpp dll
  and glue up the implementation in the hxcpp runtime.

 For the static link case, these functions are linked directly.
*/

void hx_error() THROWS
{
   throw Dynamic( HX_CSTRING("ERROR") );
}


void val_throw(hx::Object * arg1) THROWS
{
   if (arg1==0)
      throw Dynamic(null());
   throw Dynamic(arg1);
}


void hx_fail(const char * arg1,const char * arg2,int arg3)
{
   fprintf(stderr,"Terminal error %s, File %s, line %d\n", arg1,arg2,arg3);
   exit(1);
}



// Determine hx::Object * type
int val_type(hx::Object * arg1)
{
   if (arg1==0)
      return valtNull;
   return arg1->__GetType();
}

\
vkind val_kind(hx::Object * arg1) THROWS
{
   if (arg1==0)
      hx::Throw( HX_CSTRING("Value has no 'kind'") );
   int type = arg1->__GetType();
   if (type<valtAbstractBase)
      hx::Throw( HX_CSTRING("Value has no 'kind'") );
   return (vkind)(type);
}


void * val_to_kind(hx::Object * arg1,vkind arg2)
{
   if (arg1==0)
      return 0;
   if ((int)(intptr_t)arg2 == arg1->__GetType())
      return arg1->__GetHandle();
   return 0;
}


// don't check the 'kind' ...
void * val_data(hx::Object * arg1)
{
   if (arg1==0)
      return 0;
   return arg1->__GetHandle();
}


int val_fun_nargs(hx::Object * arg1)
{
   if (arg1==0)
      return faNotFunction;
   return arg1->__ArgCount();
}




// Extract hx::Object * type
bool val_bool(hx::Object * arg1)
{
   if (arg1==0) return false;
   return arg1->__ToInt()!=0;
}


int val_int(hx::Object * arg1)
{
   if (arg1==0) return 0;
   return arg1->__ToInt();
}


double val_float(hx::Object * arg1)
{
   if (arg1==0) return 0.0;
   return arg1->__ToDouble();
}


double val_number(hx::Object * arg1)
{
   if (arg1==0) return 0.0;
   return arg1->__ToDouble();
}



// Create hx::Object * type

hx::Object * alloc_null() { return 0; }
hx::Object * alloc_bool(bool arg1) { return Dynamic(arg1).GetPtr(); }
hx::Object * alloc_int(int arg1) { return Dynamic(arg1).GetPtr(); }
hx::Object * alloc_float(double arg1) { return Dynamic(arg1).GetPtr(); }
hx::Object * alloc_empty_object() { return new hx::Anon_obj(); }


hx::Object * alloc_abstract(vkind arg1,void * arg2)
{
   int type = (int)(intptr_t)arg1;
   return new hx::Abstract_obj(type,arg2);
}

hx::Object * alloc_best_int(int arg1) { return Dynamic(arg1).GetPtr(); }
hx::Object * alloc_int32(int arg1) { return Dynamic(arg1).GetPtr(); }



// String access
int val_strlen(hx::Object * arg1)
{
   if (arg1==0) return 0;
   return arg1->toString().length;
}


const wchar_t * val_wstring(hx::Object * arg1)
{
   if (arg1==0) return L"";
   return arg1->toString().__WCStr();
}


const char * val_string(hx::Object * arg1)
{
   if (arg1==0) return "";
   return arg1->__CStr();
}


hx::Object * alloc_string(const char * arg1)
{
#ifdef HX_UTF8_STRINGS
   return Dynamic( String(arg1,strlen(arg1)).dup() ).GetPtr();
#else
   return Dynamic( String(arg1,strlen(arg1)) ).GetPtr();
#endif
}

wchar_t * val_dup_wstring(value inVal)
{
   hx::Object *obj = (hx::Object *)inVal;
   String  s = obj->toString();
#ifdef HX_UTF8_STRINGS
   return (wchar_t *)s.__WCStr();
#else
   return (char *)s.dup().__s;
#endif
}

char * val_dup_string(value inVal)
{
   hx::Object *obj = (hx::Object *)inVal;
   if (!obj) return 0;

   #ifdef HX_UTF8_STRINGS
   return (char *)obj->toString().dup().__CStr();
   #else
   // Known to create a copy
   return (wchar_t *)obj->toString().__CStr();
   #endif
}

hx::Object *alloc_string_len(const char *inStr,int inLen)
{
#ifdef HX_UTF8_STRINGS
   return Dynamic( String(inStr,inLen).dup() ).GetPtr();
#else
   return Dynamic( String(inStr,inLen) ).GetPtr();
#endif
}

hx::Object *alloc_wstring_len(const wchar_t *inStr,int inLen)
{
   String str(inStr,inLen);
   #ifdef HX_UTF8_STRINGS
   return Dynamic(str).GetPtr();
   #else
   return Dynamic(str.dup()).GetPtr();
   #endif
}

// Array access - generic
int val_array_size(hx::Object * arg1)
{
   if (arg1==0) return 0;
   return arg1->__length();
}


hx::Object * val_array_i(hx::Object * arg1,int arg2)
{
   if (arg1==0) return 0;
   return arg1->__GetItem(arg2).GetPtr();
}

void val_array_set_i(hx::Object * arg1,int arg2,hx::Object *inVal)
{
   if (arg1==0) return;
   arg1->__SetItem(arg2, Dynamic(inVal) );
}

void val_array_set_size(hx::Object * arg1,int inLen)
{
   if (arg1==0) return;
   arg1->__SetSize(inLen);
}

void val_array_push(hx::Object * arg1,hx::Object *inValue)
{
   hx::ArrayBase *base = dynamic_cast<hx::ArrayBase *>(arg1);
   if (base==0) return;
   base->__push(inValue);
}


hx::Object * alloc_array(int arg1)
{
   Array<Dynamic> array(arg1,arg1);
   return array.GetPtr();
}



// Array access - fast if possible - may return null
// Resizing the array may invalidate the pointer
bool * val_array_bool(hx::Object * arg1)
{
   Array_obj<bool> *a = dynamic_cast< Array_obj<bool> * >(arg1);
   if (a==0)
      return 0;
   return (bool *)a->GetBase();
}


int * val_array_int(hx::Object * arg1)
{
   Array_obj<int> *a = dynamic_cast< Array_obj<int> * >(arg1);
   if (a==0)
      return 0;
   return (int *)a->GetBase();
}


double * val_array_double(hx::Object * arg1)
{
   Array_obj<double> *a = dynamic_cast< Array_obj<double> * >(arg1);
   if (a==0)
      return 0;
   return (double *)a->GetBase();
}

value * val_array_value(hx::Object * arg1)
{
   return 0;
}




typedef Array_obj<unsigned char> *ByteArray;

// Byte arrays
// The byte array may be a string or a Array<bytes> depending on implementation
buffer val_to_buffer(hx::Object * arg1)
{
   ByteArray b = dynamic_cast< ByteArray >(arg1);
   return (buffer)b;
}



buffer alloc_buffer(const char *inStr)
{
   int len = inStr ? strlen(inStr) : 0;
   ByteArray b = new Array_obj<unsigned char>(len,len);
   if (len)
      memcpy(b->GetBase(),inStr,len);
   return (buffer)b;
}


buffer alloc_buffer_len(int inLen)
{
   ByteArray b = new Array_obj<unsigned char>(inLen,inLen);
   return (buffer)b;
}


value buffer_val(buffer b)
{
   return (value)b;
}


value buffer_to_string(buffer inBuffer)
{
   ByteArray b = (ByteArray) inBuffer;
   String str(b->GetBase(),b->length);
        Dynamic d(str);
   return (value)d.GetPtr();
}


void buffer_append(buffer inBuffer,const char *inStr)
{
   ByteArray b = (ByteArray)inBuffer;
   int olen = b->length;
   int len = strlen(inStr);
   b->__SetSize(olen+len);
   memcpy(b->GetBase()+olen,inStr,len);

}


int buffer_size(buffer inBuffer)
{
   ByteArray b = (ByteArray)inBuffer;
   return b->length;
}


void buffer_set_size(buffer inBuffer,int inLen)
{
   ByteArray b = (ByteArray)inBuffer;
   b->__SetSize(inLen);
}


void buffer_append_sub(buffer inBuffer,const char *inStr,int inLen)
{
   ByteArray b = (ByteArray)inBuffer;
   int olen = b->length;
   b->__SetSize(olen+inLen);
   memcpy(b->GetBase()+olen,inStr,inLen);
}


void buffer_append_char(buffer inBuffer,int inChar)
{
   ByteArray b = (ByteArray)inBuffer;
   b->Add(inChar);
}


char * buffer_data(buffer inBuffer)
{
   ByteArray b = (ByteArray)inBuffer;
   return b->GetBase();
}


// Append value to buffer
void val_buffer(buffer inBuffer,value inValue)
{
   ByteArray b = (ByteArray)inBuffer;
   hx::Object *obj = (hx::Object *)inValue;
   if (obj)
   {
       buffer_append(inBuffer, obj->toString().__CStr());
   }
   else
   {
      buffer_append_sub(inBuffer,"null",4);
   }
}






// Call Function 
hx::Object * val_call0(hx::Object * arg1) THROWS
{
   if (!arg1) Dynamic::ThrowBadFunctionError();
   return arg1->__run().GetPtr();
}

hx::Object * val_call0_traceexcept(hx::Object * arg1) THROWS
{
   try
   {
   if (!arg1) Dynamic::ThrowBadFunctionError();
   return arg1->__run().GetPtr();
   }
   catch(Dynamic e)
   {
      String s = e;
      fprintf(stderr,"Fatal Error : %s\n",s.__CStr());
      exit(1);
   }
   return 0;
}


hx::Object * val_call1(hx::Object * arg1,hx::Object * arg2) THROWS
{
   if (!arg1) Dynamic::ThrowBadFunctionError();
   return arg1->__run(arg2).GetPtr();
}


hx::Object * val_call2(hx::Object * arg1,hx::Object * arg2,hx::Object * arg3) THROWS
{
   if (!arg1) Dynamic::ThrowBadFunctionError();
   return arg1->__run(arg2,arg3).GetPtr();
}


hx::Object * val_call3(hx::Object * arg1,hx::Object * arg2,hx::Object * arg3,hx::Object * arg4) THROWS
{
   if (!arg1) Dynamic::ThrowBadFunctionError();
   return arg1->__run(arg2,arg3,arg4).GetPtr();
}


hx::Object * val_callN(hx::Object * arg1,hx::Object * arg2) THROWS
{
   if (!arg1) Dynamic::ThrowBadFunctionError();
   return arg1->__Run( Dynamic(arg2) ).GetPtr();
}


// Call object field
hx::Object * val_ocall0(hx::Object * arg1,int arg2) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__IField(arg2)->__run().GetPtr();
}


hx::Object * val_ocall1(hx::Object * arg1,int arg2,hx::Object * arg3) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__IField(arg2)->__run(arg3).GetPtr();
}


hx::Object * val_ocall2(hx::Object * arg1,int arg2,hx::Object * arg3,hx::Object * arg4) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__IField(arg2)->__run(arg3,arg4).GetPtr();
}


hx::Object * val_ocall3(hx::Object * arg1,int arg2,hx::Object * arg3,hx::Object * arg4,hx::Object * arg5) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__IField(arg2)->__run(arg3,arg4,arg5).GetPtr();
}


hx::Object * val_ocallN(hx::Object * arg1,int arg2,hx::Object * arg3) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__IField(arg2)->__run(Dynamic(arg3)).GetPtr();
}



// Objects access
int val_id(const char * arg1)
{
   return __hxcpp_field_to_id(arg1);
}


void alloc_field(hx::Object * arg1,int arg2,hx::Object * arg3) THROWS
{
   //hx::InternalCollect();
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   arg1->__SetField(__hxcpp_field_from_id(arg2),arg3);
}
void hxcpp_alloc_field(hx::Object * arg1,int arg2,hx::Object * arg3)
{
   return alloc_field(arg1,arg2,arg3);
}


hx::Object * val_field(hx::Object * arg1,int arg2) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__IField(arg2).GetPtr();
}

double val_field_numeric(hx::Object * arg1,int arg2) THROWS
{
   if (!arg1) hx::Throw(HX_INVALID_OBJECT);
   return arg1->__INumField(arg2);
}

value val_field_name(field inField)
{
   return (value)Dynamic(__hxcpp_field_from_id(inField)).mPtr;
}


void val_iter_fields(hx::Object *inObj, __hx_field_iter inFunc ,void *inCookie)
{
   if (inObj)
   {
      Array<String> fields = Array_obj<String>::__new(0,0);

      inObj->__GetFields(fields);

      for(int i=0;i<fields->length;i++)
      {
         inFunc((value)inObj, __hxcpp_field_to_id(fields[i].__CStr()), inCookie);
      }
   }
}


   // Abstract types
vkind alloc_kind()
{
   return (vkind)hxcpp_alloc_kind();
}

void kind_share(vkind *inKind,const char *inName)
{
   int k = (int)(intptr_t)*inKind;
   hxcpp_kind_share(k,inName);
   *inKind = (vkind)k;
}



// Garbage Collection
void * hx_alloc(int arg1)
{
   return hx::NewGCBytes(0,arg1);
}


void * alloc_private(int arg1)
{
   return hx::NewGCPrivate(0,arg1);
}


void  val_gc(hx::Object * arg1,hx::finalizer arg2) THROWS
{
   hx::Abstract_obj *abstract = dynamic_cast<hx::Abstract_obj *>(arg1);
   if (!abstract)
      hx::Throw(HX_CSTRING("Finalizer not on abstract object"));
   abstract->SetFinalizer(arg2);
}

void  val_gc_ptr(void * arg1,hxPtrFinalizer arg2) THROWS
{
   hx::Throw(HX_CSTRING("Finalizer not supported here"));
}

void  val_gc_add_root(hx::Object **inRoot)
{
   hx::GCAddRoot(inRoot);
}


void  val_gc_remove_root(hx::Object **inRoot)
{
   hx::GCRemoveRoot(inRoot);
}

void  gc_set_top_of_stack(int *inTopOfStack,bool inForce)
{
   hx::SetTopOfStack(inTopOfStack,inForce);
}


class Root_obj *sgRootHead = 0;

class Root_obj : public hx::Object
{
public:
   Root_obj()
   {
      mNext = 0;
      mPrev = 0;
      mValue = 0;
   }

   virtual int __GetType() const { return valtRoot; }
   virtual hx::ObjectPtr<Class_obj> __GetClass() const { return 0; }
   virtual bool __IsClass(Class inClass ) const { return false; }
   void __Mark(HX_MARK_PARAMS)
   {
      HX_MARK_OBJECT(mNext);
      HX_MARK_OBJECT(mValue);
   }
   Root_obj *mNext;
   Root_obj *mPrev;
   hx::Object *mValue;
};



value *alloc_root()
{
   if (!sgRootHead)
   {
      val_gc_add_root((hx::Object **)&sgRootHead);
      sgRootHead = new Root_obj;
   }

   Root_obj *root = new Root_obj;
   root->mNext = sgRootHead->mNext;
   if (root->mNext)
      root->mNext->mPrev = root;

   sgRootHead->mNext = root;
   root->mPrev = sgRootHead;

   return (value *)&root->mValue;
}

void free_root(value *inValue)
{
   int diff =(char *)(&sgRootHead->mValue) - (char *)sgRootHead;
   Root_obj *root = (Root_obj *)( (char *)inValue - diff );

   if (root->mPrev)
      root->mPrev->mNext = root->mNext;
   if (root->mNext)
      root->mNext->mPrev = root->mPrev;
}


// Used for finding functions in static libraries
int hx_register_prim( const char * arg1, void* arg2)
{
   __hxcpp_register_prim(arg1,arg2);
   return 0;
}

void gc_enter_blocking()
{
   hx::EnterGCFreeZone();
}

void gc_exit_blocking()
{
   hx::ExitGCFreeZone();
}

void gc_safe_point()
{
   __SAFE_POINT;
}

gcroot create_root(value) { return 0; }
value query_root(gcroot) { return 0; }
void destroy_root(gcroot) { }



EXPORT void * hx_cffi(const char *inName)
{
   #define DEFFUNC(name,r,b,c) if ( !strcmp(inName,#name) ) return (void *)name;

   #include <hx/CFFIAPI.h>

   return 0;
}

}

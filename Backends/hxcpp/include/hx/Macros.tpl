#ifndef HX_MACROS_H
#define HX_MACROS_H


#define HX_DO_RTTI_BASE \
   bool __Is(hx::Object *inObj) const { return dynamic_cast<OBJ_ *>(inObj)!=0; } \


#define HX_DO_RTTI \
   HX_DO_RTTI_BASE \
   static hx::ObjectPtr<Class_obj> __mClass; \
   hx::ObjectPtr<Class_obj > __GetClass() const { return __mClass; } \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; } \
   Dynamic __Field(const ::String &inString); \
   void __GetFields(Array< ::String> &outFields); \
   Dynamic __SetField(const ::String &inString,const Dynamic &inValue); \
   virtual int __GetType() const { return vtClass; } \
   inline operator super *() { return this; } 

#define HX_DO_INTERFACE_RTTI \
   static hx::ObjectPtr<Class_obj> __mClass; \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; } \
	static void __register();

#define HX_DO_ENUM_RTTI_INTERNAL \
   HX_DO_RTTI_BASE  \
   Dynamic __Field(const ::String &inString); \
   static int __FindIndex(::String inName); \
   static int __FindArgCount(::String inName);

#define HX_DO_ENUM_RTTI \
   HX_DO_ENUM_RTTI_INTERNAL \
   static hx::ObjectPtr<Class_obj> __mClass; \
   hx::ObjectPtr<Class_obj > __GetClass() const { return __mClass; } \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; }


#define HX_DECLARE_IMPLEMENT_DYNAMIC  hx::FieldMap *__mDynamicFields; \
    hx::FieldMap *__GetFieldMap() { return __mDynamicFields; } \
    bool __HasField(const String &inString) \
      { return hx::FieldMapHas(__mDynamicFields,inString) || super::__HasField(inString); } 


#define HX_INIT_IMPLEMENT_DYNAMIC __mDynamicFields = hx::FieldMapCreate();

#define HX_IMPLEMENT_HAS_FIELD(class) \
    bool class::__HasField(const String &inString) \
    {  if (hx::NS::FieldMap::NS::

#define HX_MARK_DYNAMIC hx::FieldMapMark(__mDynamicFields HX_MARK_ADD_ARG);

#define HX_CHECK_DYNAMIC_GET_FIELD(inName) \
   { Dynamic d;  if (hx::FieldMapGet(__mDynamicFields,inName,d)) return d; }

#define HX_CHECK_DYNAMIC_GET_INT_FIELD(inID) \
   { Dynamic d;  if (hx::FieldMapGet(__mDynamicFields,inID,d)) return d; }

#define HX_DYNAMIC_SET_FIELD(inName,inValue) hx::FieldMapSet(__mDynamicFields,inName,inValue) 

#define HX_APPEND_DYNAMIC_FIELDS(outFields) hx::FieldMapAppendFields(__mDynamicFields,outFields)

::foreach PARAMS::
#define HX_ARR_LIST::ARG:: ::ARR_LIST::::end::

::foreach PARAMS::
#define HX_DYNAMIC_ARG_LIST::ARG:: ::DYNAMIC_ARG_LIST::::end::

::foreach PARAMS::
#define HX_ARG_LIST::ARG:: ::ARG_LIST::::end::

#define HX_DEFINE_DYNAMIC_FUNC0(class,func,ret) \
Dynamic __##class##func(hx::NS::Object *inObj) \
{ \
      ret reinterpret_cast<class *>(inObj)->func(); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::NS::CreateMemberFunction0(this,__##class##func); \
}


#define HX_DEFINE_DYNAMIC_FUNC(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(hx::NS::Object *inObj, dynamic_arg_list) \
{ \
      ret reinterpret_cast<class *>(inObj)->func(arg_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::NS::CreateMemberFunction##N(this,__##class##func); \
}


#define HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(hx::NS::Object *inObj, const Array<Dynamic> &inArgs) \
{ \
      ret reinterpret_cast<class *>(inObj)->func(array_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::NS::CreateMemberFunctionVar(this,__##class##func,N); \
}


#define DELEGATE_0(ret,func) ret func() { return mDelegate->func(); }
#define CDELEGATE_0(ret,func) ret func() const { return mDelegate->func(); }
#define DELEGATE_1(ret,func,arg1) ret func(arg1 _a1) { return mDelegate->func(_a1); }
#define CDELEGATE_1(ret,func,arg1) ret func(arg1 _a1) const { return mDelegate->func(_a1); }
#define DELEGATE_2(ret,func,arg1,arg2) ret func(arg1 _a1,arg2 _a2) { return mDelegate->func(_a1,_a2); }





#define HX_DECLARE_DYNAMIC_FUNC(func,dynamic_arg_list) \
   Dynamic func##_dyn(dynamic_arg_list);

#define STATIC_HX_DECLARE_DYNAMIC_FUNC(func,dynamic_arg_list) \
   static Dynamic func##_dyn(dynamic_arg_list);


::foreach PARAMS::
::if (ARG>0)::::if (ARG<6)::
#define HX_DEFINE_DYNAMIC_FUNC::ARG::(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC(class,::ARG::,func,ret,HX_ARR_LIST::ARG::,HX_DYNAMIC_ARG_LIST::ARG::,HX_ARG_LIST::ARG::)
::else::
#define HX_DEFINE_DYNAMIC_FUNC::ARG::(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,::ARG::,func,ret,HX_ARR_LIST::ARG::,HX_DYNAMIC_ARG_LIST::ARG::,HX_ARG_LIST::ARG::)
::end::
::end::::end::


#define STATIC_HX_DEFINE_DYNAMIC_FUNC0(class,func,ret) \
Dynamic __##class##func() \
{ \
      ret class::func(); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::NS::CreateStaticFunction0(__##class##func); \
}


#define STATIC_HX_DEFINE_DYNAMIC_FUNC(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(dynamic_arg_list) \
{ \
      ret class::func(arg_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::NS::CreateStaticFunction##N(__##class##func); \
}


#define STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(const Array<Dynamic> &inArgs) \
{ \
      ret class::func(array_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::NS::CreateStaticFunctionVar(__##class##func,N); \
}



::foreach PARAMS::
::if (ARG>0)::::if (ARG<6)::
#define STATIC_HX_DEFINE_DYNAMIC_FUNC::ARG::(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC(class,::ARG::,func,ret,HX_ARR_LIST::ARG::,HX_DYNAMIC_ARG_LIST::ARG::,HX_ARG_LIST::ARG::)
::else::
#define STATIC_HX_DEFINE_DYNAMIC_FUNC::ARG::(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,::ARG::,func,ret,HX_ARR_LIST::ARG::,HX_DYNAMIC_ARG_LIST::ARG::,HX_ARG_LIST::ARG::)
::end::
::end::::end::

#define HX_DEFINE_CREATE_ENUM(enum_obj) \
static Dynamic Create##enum_obj(::String inName,hx::DynamicArray inArgs) \
{ \
   int idx =  enum_obj::__FindIndex(inName); \
   if (idx<0) throw HX_INVALID_CONSTRUCTOR; \
   int count =  enum_obj::__FindArgCount(inName); \
   int args = inArgs.GetPtr() ? inArgs.__length() : 0; \
   if (args!=count)  throw HX_INVALID_ARG_COUNT; \
   return hx::CreateEnum<enum_obj >(inName,idx,inArgs); \
}


#define HX_DECLARE_CLASS0(klass) \
	class klass##_obj; \
	typedef hx::ObjectPtr<klass##_obj> klass;
#define HX_DECLARE_CLASS1(ns1,klass) namespace ns1 { HX_DECLARE_CLASS0(klass) }
#define HX_DECLARE_CLASS2(ns2,ns1,klass) namespace ns2 { HX_DECLARE_CLASS1(ns1,klass) }
#define HX_DECLARE_CLASS3(ns3,ns2,ns1,klass) namespace ns3 { HX_DECLARE_CLASS2(ns2,ns1,klass) }
#define HX_DECLARE_CLASS4(ns4,ns3,ns2,ns1,klass) namespace ns4 { HX_DECLARE_CLASS3(ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS5(ns5,ns4,ns3,ns2,ns1,klass) namespace ns5 { HX_DECLARE_CLASS4(ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS6(ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns6 { HX_DECLARE_CLASS5(ns5,ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS7(ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns7 { HX_DECLARE_CLASS6(ns6,ns5,ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS8(ns8,ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns8 { HX_DECLARE_CLASS7(ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS9(ns9,ns8,ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns9 { HX_DECLARE_CLASS8(ns8,ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) }




#define HX_DYNAMIC_CALL(ret,func,array_args,dyn_arg_list,arg_list) \
   Dynamic __Run(const Array<Dynamic> &inArgs) { ret func( array_args ); return null();} \
   Dynamic __run(dyn_arg_list) { ret func( arg_list ); return null();}

::foreach PARAMS::
#define HX_DYNAMIC_CALL::ARG::(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST::ARG::,HX_DYNAMIC_ARG_LIST::ARG::,HX_ARG_LIST::ARG::)::end::

#define HX_BEGIN_DEFAULT_FUNC(name,t0) \
	namespace { \
   struct name : public hx::Object { int __GetType() const { return vtFunction; } \
   hx::ObjectPtr<t0> __this; \
   name(hx::ObjectPtr<t0> __0 = null()) : __this(__0) {} \
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(__this); }


#define HX_END_DEFAULT_FUNC \
}

#define HX_BEGIN_LOCAL_FUNC_S0(SUPER,name) \
   struct name : public SUPER { \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); } \
   name() {}

::foreach LOCALS::
#define HX_BEGIN_LOCAL_FUNC_S::ARG::(SUPER,name,::TYPE_ARGS::) \
   struct name : public SUPER { \
   ::TYPE_DECL::; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); ::MARKS:: } \
   name(::CONSTRUCT_ARGS::) : ::CONSTRUCT_VARS:: {}::end::


#define HX_END_LOCAL_FUNC0(ret) HX_DYNAMIC_CALL0(ret,run) };
::foreach LOCALS::
#define HX_END_LOCAL_FUNC::ARG::(ret) HX_DYNAMIC_CALL::ARG::(ret,run) };::end::

// For compatibility until next version of haxe is released
#define HX_BEGIN_LOCAL_FUNC0(name) \
      HX_BEGIN_LOCAL_FUNC_S0(hx::LocalFunc,name)
::foreach LOCALS::
#define HX_BEGIN_LOCAL_FUNC::ARG::(name,::TYPE_ARGS::) \
      HX_BEGIN_LOCAL_FUNC_S::ARG::(hx::LocalFunc,name,::TYPE_ARGS::)::end::


#define HX_DECLARE_DYNAMIC_FUNCTIONS \
::foreach PARAMS:: ::if (ARG<6):: inline Dynamic operator()(::DYNAMIC_ARG_LIST::) { CheckFPtr(); return mPtr->__run(::ARG_LIST::); } \
::else:: Dynamic operator()(::DYNAMIC_ARG_LIST::); \
::end:: ::end::



namespace hx {
extern void SetTopOfStack(int *inTopOfStack,bool);
}
#define HX_TOP_OF_STACK \
		int t0 = 99; \
		hx::SetTopOfStack(&t0,false);

#ifdef ANDROID
// Java Main....
#include <jni.h>
#include <hx/Thread.h>
#include <android/log.h>

#ifdef __GNUC__
 #define GCC_EXTRA __attribute__ ((visibility("default")))
#else
 #define GCC_EXTRA
#endif

#define HX_BEGIN_MAIN \
extern "C" GCC_EXTRA JNIEXPORT void JNICALL Java_org_haxe_HXCPP_main(JNIEnv * env) { \
	HX_TOP_OF_STACK \
        try { \
	hx::Boot(); \
	__boot_all();


#define HX_END_MAIN \
        } catch (Dynamic e) { \
	  __hx_dump_stack(); \
          __android_log_print(ANDROID_LOG_ERROR, "Exception", "%s", e->toString().__CStr()); \
        }\
}

#elif defined(HX_WIN_MAIN)


#define HX_BEGIN_MAIN \
extern "C" int __stdcall MessageBoxA(void *,const char *,const char *,int); \
\
int __stdcall WinMain( void * hInstance, void * hPrevInstance, const char *lpCmdLine, int nCmdShow) \
{ \
	HX_TOP_OF_STACK \
	hx::Boot(); \
	try{ \
		__boot_all();

#define HX_END_MAIN \
	} \
	catch (Dynamic e){ \
		__hx_dump_stack(); \
		MessageBoxA(0,  e->toString().__CStr(), "Error", 0); \
	} \
	return 0; \
}


#else
// Console Main ...

#define HX_BEGIN_MAIN \
\
int main(int argc,char **argv){ \
	HX_TOP_OF_STACK \
	hx::Boot(); \
	try{ \
		__boot_all();

#define HX_END_MAIN \
	} \
	catch (Dynamic e){ \
		__hx_dump_stack(); \
		printf("Error : %s\n",e->toString().__CStr()); \
	} \
	return 0; \
}

#endif


// Run as library
#define HX_BEGIN_LIB_MAIN \
extern "C" {\
\
void __hxcpp_lib_main() \
{ \
	HX_TOP_OF_STACK \
	hx::Boot(); \
	__boot_all();

#define HX_END_LIB_MAIN \
} }



#endif


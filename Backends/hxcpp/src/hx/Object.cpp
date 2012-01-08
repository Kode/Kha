#include <hxcpp.h>

#include <stdio.h>
#include <hxMath.h>
//#include <hxMacros.h>
#include <cpp/CppInt32__.h>
#include <map>


#ifdef _WIN32

#include <windows.h>
#include <time.h>
// Stoopid windows ...
#ifdef RegisterClass
#undef RegisterClass
#endif
#ifdef abs
#undef abs
#endif

#else

#include <sys/time.h>
#include <wchar.h>
typedef  uint64_t  __int64;

#endif


// --- hxObject -----------------------------------------

namespace hx
{

String sNone[] = { String(null()) };

Dynamic Object::__IField(int inFieldID)
{
   return __Field( __hxcpp_field_from_id(inFieldID) );
}

double Object::__INumField(int inFieldID)
{
	return __IField(inFieldID);
}

hx::FieldMap *Object::__GetFieldMap() { return 0; }


int Object::__Compare(const Object *inRHS) const
{
   return (int)(inRHS-this);
}


Dynamic Object::__Field(const String &inString) { return null(); }
bool Object::__HasField(const String &inString)
{
   return false;
}
Dynamic Object::__Run(const Array<Dynamic> &inArgs) { return 0; }
Dynamic Object::__GetItem(int inIndex) const { return null(); }
Dynamic Object::__SetItem(int inIndex,Dynamic) { return null();  }
DynamicArray Object::__EnumParams() { return DynamicArray(); }
String Object::__Tag() const { return HX_CSTRING("<not enum>"); }
int Object::__Index() const { return -1; }

void Object::__SetThis(Dynamic inThis) { }

bool Object::__Is(Dynamic inClass ) const { return __Is(inClass.GetPtr()); }

static Class Object__mClass;

bool AlwaysCast(Object *inPtr) { return inPtr!=0; }

void Object::__boot()
{
   Static(Object__mClass) = hx::RegisterClass(HX_CSTRING("Dynamic"),AlwaysCast,sNone,sNone,0,0, 0 );
}

Class &Object::__SGetClass() { return Object__mClass; }

Class Object::__GetClass() const { return Object__mClass; }

hx::FieldRef Object::__FieldRef(const String &inString) { return hx::FieldRef(this,inString); }

String Object::__ToString() const { return HX_CSTRING("Object"); }

const char * Object::__CStr() const { return __ToString().__CStr(); }


Dynamic Object::__SetField(const String &inField,const Dynamic &inValue)
{
	throw Dynamic( HX_CSTRING("Invalid field:") + inField );
	return null();
}

Dynamic Object::__run()
{
   return __Run(Array_obj<Dynamic>::__new());
}

Dynamic Object::__run(D a)
{
   return __Run( Array_obj<Dynamic>::__new(0,1) << a );
}

Dynamic Object::__run(D a,D b)
{
   return __Run( Array_obj<Dynamic>::__new(0,2) << a << b );
}

Dynamic Object::__run(D a,D b,D c)
{
   return __Run( Array_obj<Dynamic>::__new(0,3) << a << b << c);
}
Dynamic Object::__run(D a,D b,D c,D d)
{
   return __Run( Array_obj<Dynamic>::__new(0,4) << a << b << c << d);
}
Dynamic Object::__run(D a,D b,D c,D d,D e)
{
   return __Run( Array_obj<Dynamic>::__new(0,5) << a << b << c << d << e);
}

void Object::__GetFields(Array<String> &outFields)
{
}


String Object::toString() { return __ToString(); }


} // end namespace hx





#include <hxcpp.h>


// -------- Enums ---------------------------------

namespace hx
{

Dynamic EnumBase_obj::__Create(DynamicArray inArgs) { return new hx::EnumBase_obj; }
Dynamic EnumBase_obj::__CreateEmpty() { return new hx::EnumBase_obj; }


int EnumBase_obj::__FindIndex(String inName)
{
   if (inName==HX_CSTRING("__")) return 1;
   return -1;
}
int EnumBase_obj::__FindArgCount(String inName)
{
   if (inName==HX_CSTRING("__")) return 0;
   return -1;
}
Dynamic EnumBase_obj::__Field(const String &inString) { return null(); }

static Class hxEnumBase_obj__mClass;
Class &EnumBase_obj::__SGetClass() { return hxEnumBase_obj__mClass; }

//void hxEnumBase_obj::__GetFields(Array<String> &outFields) { }

void EnumBase_obj::__boot()
{
   Static(hxEnumBase_obj__mClass) = hx::RegisterClass(HX_CSTRING("__EnumBase") ,TCanCast<EnumBase_obj>,
                       sNone,sNone,
                       &__CreateEmpty, &__Create, 0 );
}

void EnumBase_obj::__Mark(HX_MARK_PARAMS)
{
   HX_MARK_MEMBER(tag);
   HX_MARK_MEMBER(mArgs);
}

String EnumBase_obj::toString() {
   if (mArgs==null() || mArgs->length==0)
      return tag;
   return tag + HX_CSTRING("(") + mArgs->join(HX_CSTRING(",")) + HX_CSTRING(")");
}

}


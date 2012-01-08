#include <hxcpp.h>
#include "FieldMap.h"

namespace hx
{

Anon_obj::Anon_obj()
{
   mFields = hx::FieldMapCreate();
}

void Anon_obj::__Mark(HX_MARK_PARAMS)
{
   // We will get mFields=0 here if we collect in the constructor before mFields is assigned
   if (mFields)
   {
      hx::MarkAlloc(mFields HX_MARK_ADD_ARG);
      hx::FieldMapMark(mFields HX_MARK_ADD_ARG);
   }
}



Dynamic Anon_obj::__Field(const String &inString)
{
   Dynamic *v = mFields->Find(inString);
   if (!v)
      return null();
   return *v;
}

bool Anon_obj::__HasField(const String &inString)
{
   return mFields->Find(inString);
}


bool Anon_obj::__Remove(String inKey)
{
   return mFields->Erase(inKey);
}


Dynamic Anon_obj::__SetField(const String &inString,const Dynamic &inValue)
{
   mFields->Insert(inString,inValue);
   return inValue;
}

Anon_obj *Anon_obj::Add(const String &inName,const Dynamic &inValue,bool inSetThisPointer)
{
   mFields->Insert(inName,inValue);
   if (inSetThisPointer && inValue.GetPtr())
      inValue.GetPtr()->__SetThis(this);
   return this;
}


struct Stringer
{
   Stringer(String &inString) : result(inString), first(true) { }
   void Visit(void *, const String &inStr, Dynamic &inDyn)
   {

      if (first)
      {
         result += inStr + HX_CSTRING(" => ") + (String)(inDyn);
         first = false;
      }
      else
         result += HX_CSTRING(", ") + inStr + HX_CSTRING(" => ") + (String)(inDyn);
   }

   bool first;
   String &result;
};

String Anon_obj::toString()
{
   String result = HX_CSTRING("{ ");
   Stringer stringer(result);
   mFields->Iterate(stringer);
   return result + HX_CSTRING(" }");
}

void Anon_obj::__GetFields(Array<String> &outFields)
{
   KeyGetter getter(outFields);
   mFields->Iterate(getter);
}



String Anon_obj::__ToString() const { return HX_CSTRING("Anon"); }


Dynamic Anon_obj::__Create(DynamicArray inArgs) { return Anon(new Anon_obj); }

Class Anon_obj::__mClass;


void Anon_obj::__boot()
{
   Static(__mClass) = hx::RegisterClass(HX_CSTRING("__Anon"),TCanCast<Anon_obj>,sNone,sNone,0,0,0,0);
}



Anon SourceInfo(String inFile, int inLine, String inClass, String inMethod)
{
   Anon result = Anon_obj::Create();
   result->Add(HX_CSTRING("fileName"),inFile);
   result->Add(HX_CSTRING("lineNumber"),inLine);
   result->Add(HX_CSTRING("className"),inClass);
   result->Add(HX_CSTRING("methodName"),inMethod);
   return result;
}



}

bool __hxcpp_anon_remove(Dynamic inObj,String inKey)
{
   hx::FieldMap *map = inObj->__GetFieldMap();
   if (map)
      return map->Erase(inKey);
   return false;
}



#ifndef HX_ANON_H
#define HX_ANON_H

namespace hx
{

// --- hx::Anon_obj ----------------------------------------------
//
// The hx::Anon_obj contains an arbitrary string map of fields.

class FieldMap;

FieldMap *FieldMapCreate();

bool FieldMapGet(hx::FieldMap *inMap, const ::String &inName, ::Dynamic &outValue);
bool FieldMapHas(hx::FieldMap *inMap, const ::String &inName);
bool FieldMapGet(hx::FieldMap *inMap, int inID, ::Dynamic &outValue);
void FieldMapSet(hx::FieldMap *inMap, const ::String &inName, const ::Dynamic &inValue);
void FieldMapAppendFields(hx::FieldMap *inMap,::Array< ::String> &outFields);
void FieldMapMark(hx::FieldMap *inMap HX_MARK_ADD_PARAMS);


class Anon_obj : public hx::Object
{
   typedef hx::Anon_obj OBJ_;
   typedef hx::ObjectPtr<hx::Anon_obj> Anon;
   typedef hx::Object super;

   hx::FieldMap *mFields;

public:
   Anon_obj();

   static Anon Create() { return Anon(new hx::Anon_obj); }
   static Anon Create(const Dynamic &inSrc) { return Anon(new hx::Anon_obj); }

   static Dynamic __CreateEmpty() { return Anon(new hx::Anon_obj); }
   static Dynamic __Create(DynamicArray inArgs);
   static void __boot();
   Dynamic __Field(const String &inString);
   bool __HasField(const String &inString);
   Dynamic __SetField(const String &inString,const Dynamic &inValue);
   virtual void __GetFields(Array<String> &outFields);
	hx::FieldMap *__GetFieldMap() { return mFields; }


   static void Destroy(hx::Object * inObj);

   virtual int __GetType() const { return vtObject; }

   hx::Anon_obj *Add(const String &inName,const Dynamic &inValue,bool inSetThisPointer=true);
	void __Mark(HX_MARK_PARAMS);

   String __ToString() const;
   String toString();

   static hx::ObjectPtr<Class_obj> __mClass; \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; }
   bool __Is(hx::Object *inObj) const { return dynamic_cast<OBJ_ *>(inObj)!=0; }
   hx::ObjectPtr<Class_obj > __GetClass() const { return __mClass; }

   bool __Remove(String inKey);
};


typedef hx::ObjectPtr<hx::Anon_obj> Anon;

Anon SourceInfo(String inFile, int inLine, String inClass, String inMethod);


} // end namespace hx

bool __hxcpp_anon_remove(Dynamic inObj,::String inKey);

#endif

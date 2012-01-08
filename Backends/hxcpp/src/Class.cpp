#include <hxcpp.h>
#include <map>

#ifdef ANDROID
#include <android/log.h>
#endif


namespace hx
{

typedef std::map<String,Class> ClassMap;
static ClassMap *sClassMap = 0;

Class RegisterClass(const String &inClassName, CanCastFunc inCanCast,
                    String inStatics[], String inMembers[],
                    ConstructEmptyFunc inConstructEmpty, ConstructArgsFunc inConstructArgs,
                    Class *inSuperClass, ConstructEnumFunc inConstructEnum,
                    MarkFunc inMarkFunc)
{
   if (sClassMap==0)
      sClassMap = new ClassMap;

   Class_obj *obj = new Class_obj(inClassName, inStatics, inMembers,
                                  inConstructEmpty, inConstructArgs, inSuperClass,
                                  inConstructEnum, inCanCast, inMarkFunc);
   Class c(obj);
   (*sClassMap)[inClassName] = c;
   return c;
}



}

using namespace hx;

// -------- Class ---------------------------------------


Class_obj::Class_obj(const String &inClassName,String inStatics[], String inMembers[],
             ConstructEmptyFunc inConstructEmpty, ConstructArgsFunc inConstructArgs,
             Class *inSuperClass,ConstructEnumFunc inConstructEnum,
             CanCastFunc inCanCast, MarkFunc inFunc)
{
   mName = inClassName;
   mSuper = inSuperClass;
   mConstructEmpty = inConstructEmpty;
   mConstructArgs = inConstructArgs;
   mConstructEnum = inConstructEnum;
   mMarkFunc = inFunc;
   if (inStatics)
   {
      mStatics = Array_obj<String>::__new(0,0);
      for(String *s = inStatics; s->length; s++)
         mStatics->Add( *s );
   }
   if (inMembers)
   {
      mMembers = Array_obj<String>::__new(0,0);
      for(String *m = inMembers; m->length; m++)
         mMembers->Add( *m );
   }
   CanCast = inCanCast;
}

Class Class_obj::GetSuper()
{
   if (!mSuper)
      return null();
	if (mSuper==&hx::Object::__SGetClass())
		return null();
   return *mSuper;
}

void Class_obj::__Mark(HX_MARK_PARAMS)
{
   HX_MARK_MEMBER(mName);
   HX_MARK_MEMBER(mStatics);
   HX_MARK_MEMBER(mMembers);
}

Class Class_obj__mClass;

Class  Class_obj::__GetClass() const { return Class_obj__mClass; }
Class &Class_obj::__SGetClass() { return Class_obj__mClass; }

void Class_obj::__boot()
{
Static(Class_obj__mClass) = hx::RegisterClass(HX_CSTRING("Class"),TCanCast<Class_obj>,sNone,sNone, 0,0 , 0 );
}


void Class_obj::MarkStatics(HX_MARK_PARAMS)
{
   if (mMarkFunc)
   {
       mMarkFunc(HX_MARK_ARG);
   }
}

Class Class_obj::Resolve(String inName)
{
   ClassMap::const_iterator i = sClassMap->find(inName);
   if (i==sClassMap->end())
      return null();
   return i->second;
}


String Class_obj::__ToString() const { return mName; }


Array<String> Class_obj::GetInstanceFields()
{
   Array<String> result = mSuper ? (*mSuper)->GetInstanceFields() : Array<String>(0,0);
   if (mMembers.mPtr)
      for(int m=0;m<mMembers->size();m++)
      {
         const String &mem = mMembers[m];
         if (result->Find(mem)==-1)
            result.Add(mem);
      }
   return result;
}

Array<String> Class_obj::GetClassFields()
{
   Array<String> result = mSuper ? (*mSuper)->GetClassFields() : Array<String>(0,0);
   if (mStatics.mPtr)
   {
      for(int s=0;s<mStatics->size();s++)
      {
         const String &mem = mStatics[s];
         if (result->Find(mem)==-1)
            result.Add(mem);
      }
   }
   return result;
}

bool Class_obj::__HasField(const String &inString)
{
   if (mStatics.mPtr)
      for(int s=0;s<mStatics->size();s++)
         if (mStatics[s]==inString)
            return true;
   if (mSuper)
      return (*mSuper)->__HasField(inString);
   return false;
}

Dynamic Class_obj::__Field(const String &inString)
{
   // Not the most efficient way of doing this!
   if (!mConstructEmpty)
      return null();
   Dynamic instance = mConstructEmpty();
   return instance->__Field(inString);
}

Dynamic Class_obj::__SetField(const String &inString,const Dynamic &inValue)
{
   // Not the most efficient way of doing this!
   if (!mConstructEmpty)
      return null();
   Dynamic instance = mConstructEmpty();
   return instance->__SetField(inString,inValue);
}

bool Class_obj::__IsEnum()
{
   return mConstructEnum || this==GetVoidClass().GetPtr() || this==GetBoolClass().GetPtr();
}


namespace hx
{
void MarkClassStatics(HX_MARK_PARAMS)
{
   #ifdef HXCPP_DEBUG
   MarkPushClass("MarkClassStatics",__inCtx);
   #endif
   ClassMap::iterator end = sClassMap->end();
   for(ClassMap::iterator i = sClassMap->begin(); i!=end; ++i)
   {
      HX_MARK_MEMBER(i->first);

      // all strings should be constants anyhow - HX_MARK_MEMBER(i->first);
      HX_MARK_OBJECT(i->second.mPtr);

      #ifdef HXCPP_DEBUG
      hx::MarkPushClass(i->first.__s,__inCtx);
      hx::MarkSetMember("statics",__inCtx);
      #endif
   
      i->second->MarkStatics(HX_MARK_ARG);

      #ifdef HXCPP_DEBUG
      hx::MarkPopClass(__inCtx);
      #endif
   }
   #ifdef HXCPP_DEBUG
   MarkPopClass(__inCtx);
   #endif
}
}



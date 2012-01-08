#ifndef HX_ENUM_H
#define HX_ENUM_H



// Enum (ie enum object class def)  is the same as Class.
typedef Class Enum;


namespace hx
{

// --- hx::EnumBase_obj ----------------------------------------------------------
//
// Base class for Enums.
// Specializations of this class don't actually add more data, just extra constructors
//  and type information.

class  EnumBase_obj : public hx::Object
{
   typedef hx::Object super;
   typedef EnumBase_obj OBJ_;

   protected:
      String       tag;
      DynamicArray mArgs;
   public:
      int          index;

   public:
      HX_DO_ENUM_RTTI_INTERNAL;
      static hx::ObjectPtr<Class_obj> &__SGetClass();


      String toString();

      EnumBase_obj() : index(-1) { }
      EnumBase_obj(const null &inNull) : index(-1) { }
      static Dynamic __CreateEmpty();
      static Dynamic __Create(DynamicArray inArgs);
      static void __boot();

      void __Mark(HX_MARK_PARAMS);

      static hx::ObjectPtr<EnumBase_obj> Resolve(String inName);
      Dynamic __Param(int inID) { return mArgs[inID]; }
      inline int GetIndex() { return index; }

      DynamicArray __EnumParams() { return mArgs; }
      String __Tag() const { return tag; }
      int __Index() const { return index; }

      int __GetType() const { return vtEnum; }

      int __Compare(const hx::Object *inRHS) const
      {
         if (inRHS->__GetType()!=vtEnum) return -1;
         const EnumBase_obj *rhs = dynamic_cast<const EnumBase_obj *>(inRHS);
         if (tag!=rhs->tag || GetEnumName()!=rhs->GetEnumName()) return -1;
         if (mArgs==null() && rhs->mArgs==null())
            return 0;
         if (mArgs==null() || rhs->mArgs==null())
            return -1;

         int n = mArgs->__length();
         if (rhs->mArgs->__length()!=n)
            return -1;
         for(int i=0;i<n;i++)
            if ( mArgs[i] != rhs->mArgs[i] )
               return -1;
         return 0;
      }

      void Set( const String &inName,int inIndex,DynamicArray inArgs)
      {
         tag = inName;
         index = inIndex;
         mArgs = inArgs;
      }
      virtual String GetEnumName( ) const { return HX_CSTRING("Enum"); }
};


typedef hx::ObjectPtr<EnumBase_obj> EnumBase;


// --- CreateEnum -------------------------------------------------------------
//
// Template function to return a strongly-typed version fo the Enum.
// Most of the common stuff is in "Set".

template<typename ENUM>
hx::ObjectPtr<ENUM> CreateEnum(const String &inName,int inIndex, DynamicArray inArgs=DynamicArray())
{
   ENUM *result = new ENUM;
   result->Set(inName,inIndex,inArgs);
   return result;
}
} // end namespace hx

inline void __hxcpp_enum_force(hx::EnumBase inEnum,String inForceName, int inIndex)
{
   hx::DynamicArray empty;
   inEnum->Set(inForceName, inIndex, empty);
}



#endif

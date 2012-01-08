#ifndef HX_FIELD_REF_H
#define HX_FIELD_REF_H

namespace hx
{

// --- FieldRef ----------------------------------------------------------
//
//  This is used to provide syntaxe for setting fields by name.  This is because
//   the field can't be returned by reference, because it may not exist as a dynamic.
//
//  eg, consider class 'A' with variable 'x':
//  class A { int x; }
//
//  And you have a Dynamic pointing to it:
//  Dynamic d = new A;  Then you access x by name:
//  d->__Field("x") = 1;
//
//  __Field can't return a Dynamic & because x is a int, not Dynamic. So I use this class.
//  Note that this may change if I fix the generator to create __SetField("x",1) directly.


#define HX_FIELD_REF_MEM_OP(op,ret) \
inline ret operator op (const FieldRef &inA) \
  { return this->operator Dynamic() op inA.operator Dynamic(); } \
inline ret operator op (const IndexRef &inA); \
template<typename T> inline ret operator op (const T& inA) \
   { return this->operator Dynamic() op inA; }

#define HX_FIELD_REF_IMPL_MEM_OP(op,ret) \
inline ret hx::FieldRef::operator op (const IndexRef &inA) \
    { return this->operator Dynamic() op inA.operator Dynamic(); } \

class FieldRef
{
public:
   explicit FieldRef(hx::Object *inObj,const String &inName) : mObject(inObj), mName(inName)
   {
   }

   Dynamic operator=(const Dynamic &inRHS)
   {
      return mObject->__SetField(mName,inRHS);
   }
   inline operator Dynamic() const { return mObject ? mObject->__Field(mName) : null(); }
   inline operator double() const { return mObject->__Field(mName); }
   inline operator int() const { return mObject->__Field(mName); }


   // post-increment
   inline double operator++(int)
   {
      double d = mObject->__Field(mName)->__ToDouble();
      mObject->__SetField(mName,d+1);
      return d;
   }
   // pre-increment
   inline double operator++()
   {
      double d = mObject->__Field(mName)->__ToDouble() + 1;
      mObject->__SetField(mName,d);
      return d;
   }
   // post-decrement
   inline double operator--(int)
   {
      double d = mObject->__Field(mName)->__ToDouble();
      mObject->__SetField(mName,d-1);
      return d;
   }
   // pre-decrement
   inline double operator--()
   {
      double d = mObject->__Field(mName)->__ToDouble() - 1;
      mObject->__SetField(mName,d);
      return d;
   }
   bool operator !() { return ! mObject->__Field(mName)->__ToInt(); }
   int operator ~() { return ~ mObject->__Field(mName)->__ToInt(); }

   inline bool operator==(const null &) const { return !mObject; }
   inline bool operator!=(const null &) const { return mObject; }

   double operator -() { return - mObject->__Field(mName)->__ToDouble(); }

	bool HasPointer() const { return mObject; }


   HX_FIELD_REF_MEM_OP(==,bool)
   HX_FIELD_REF_MEM_OP(!=,bool)
   HX_FIELD_REF_MEM_OP(<,bool)
   HX_FIELD_REF_MEM_OP(<=,bool)
   HX_FIELD_REF_MEM_OP(>,bool)
   HX_FIELD_REF_MEM_OP(>=,bool)

   HX_FIELD_REF_MEM_OP(+,Dynamic)
   HX_FIELD_REF_MEM_OP(*,double)
   HX_FIELD_REF_MEM_OP(/,double)
   HX_FIELD_REF_MEM_OP(-,double)
   HX_FIELD_REF_MEM_OP(%,double)



   String  mName;
   hx::Object *mObject;
};

// We can define this one now...
template<typename T>
inline FieldRef ObjectPtr<T>::FieldRef(const String &inString)
{
   return hx::FieldRef(mPtr,inString);
}

#define HX_FIELD_REF_OP(op,ret) \
template<typename T> inline ret operator op (T &inT, const FieldRef &inA) \
   { return inT op ( inA.operator Dynamic()); }

HX_FIELD_REF_OP(==,bool)
HX_FIELD_REF_OP(!=,bool)
HX_FIELD_REF_OP(<,bool)
HX_FIELD_REF_OP(<=,bool)
HX_FIELD_REF_OP(>,bool)
HX_FIELD_REF_OP(>=,bool)

HX_FIELD_REF_OP(+,Dynamic)
HX_FIELD_REF_OP(*,double)
HX_FIELD_REF_OP(/,double)
HX_FIELD_REF_OP(-,double)
HX_FIELD_REF_OP(%,double)



// --- IndexRef --------------------------------------------------------------
//
// Like FieldRef, but for integer array access
//

#define HX_INDEX_REF_MEM_OP(op,ret) \
inline ret operator op (const IndexRef &inA) \
    { return this->operator Dynamic() op inA.operator Dynamic(); } \
inline ret operator op (const FieldRef &inA) \
    { return this->operator Dynamic() op inA.operator Dynamic(); } \
template<typename T> inline ret operator op (const T& inA) \
   { return this->operator Dynamic() op inA; }


class IndexRef
{
public:
   explicit IndexRef(hx::Object *inObj,int inIndex) : mObject(inObj), mIndex(inIndex)
   {
   }

   Dynamic operator=(const Dynamic &inRHS)
   {
      return mObject->__SetItem(mIndex,inRHS);
   }
   inline operator Dynamic() const { return mObject->__GetItem(mIndex); }
   inline operator double() const { return mObject->__GetItem(mIndex); }
   inline operator int() const { return mObject->__GetItem(mIndex); }

   // post-increment
   inline double operator++(int)
   {
      double d = mObject->__GetItem(mIndex)->__ToDouble();
      mObject->__SetItem(mIndex,d+1);
      return d;
   }
   // pre-increment
   inline double operator++()
   {
      double d = mObject->__GetItem(mIndex)->__ToDouble() + 1;
      mObject->__SetItem(mIndex,d);
      return d;
   }
   // post-decrement
   inline double operator--(int)
   {
      double d = mObject->__GetItem(mIndex)->__ToDouble();
      mObject->__SetItem(mIndex,d-1);
      return d;
   }
   // pre-decrement
   inline double operator--()
   {
      double d = mObject->__GetItem(mIndex)->__ToDouble() - 1;
      mObject->__SetItem(mIndex,d);
      return d;
   }
   bool operator !() { return ! mObject->__GetItem(mIndex)->__ToInt(); }
   int operator ~() { return ~ mObject->__GetItem(mIndex)->__ToInt(); }
   double operator -() { return - mObject->__GetItem(mIndex)->__ToDouble(); }

   inline bool operator==(const null &) const { return !mObject; }
   inline bool operator!=(const null &) const { return mObject; }

   HX_INDEX_REF_MEM_OP(==,bool)
   HX_INDEX_REF_MEM_OP(!=,bool)
   HX_INDEX_REF_MEM_OP(<,bool)
   HX_INDEX_REF_MEM_OP(<=,bool)
   HX_INDEX_REF_MEM_OP(>,bool)
   HX_INDEX_REF_MEM_OP(>=,bool)

   HX_INDEX_REF_MEM_OP(+,Dynamic)
   HX_INDEX_REF_MEM_OP(*,double)
   HX_INDEX_REF_MEM_OP(/,double)
   HX_INDEX_REF_MEM_OP(-,double)
   HX_INDEX_REF_MEM_OP(%,double)

	bool HasPointer() const { return mObject; }

   int mIndex;
   hx::Object *mObject;
};

// We can define this one now...
template<typename T>
inline IndexRef ObjectPtr<T>::IndexRef(int inIndex)
{
   return hx::IndexRef(mPtr,inIndex);
}

#define HX_INDEX_REF_OP(op,ret) \
template<typename T> inline ret operator op (T &inT, const IndexRef &inA) \
   { return inT op ( inA. operator Dynamic()); }

HX_INDEX_REF_OP(==,bool)
HX_INDEX_REF_OP(!=,bool)
HX_INDEX_REF_OP(<,bool)
HX_INDEX_REF_OP(<=,bool)
HX_INDEX_REF_OP(>,bool)
HX_INDEX_REF_OP(>=,bool)

HX_INDEX_REF_OP(+,Dynamic)
HX_INDEX_REF_OP(*,double)
HX_INDEX_REF_OP(/,double)
HX_INDEX_REF_OP(-,double)
HX_INDEX_REF_OP(%,double)


// Implement once IndexRef has been defined.
HX_FIELD_REF_IMPL_MEM_OP(==,bool)
HX_FIELD_REF_IMPL_MEM_OP(!=,bool)
HX_FIELD_REF_IMPL_MEM_OP(<,bool)
HX_FIELD_REF_IMPL_MEM_OP(<=,bool)
HX_FIELD_REF_IMPL_MEM_OP(>,bool)
HX_FIELD_REF_IMPL_MEM_OP(>=,bool)

HX_FIELD_REF_IMPL_MEM_OP(+,Dynamic)
HX_FIELD_REF_IMPL_MEM_OP(*,double)
HX_FIELD_REF_IMPL_MEM_OP(/,double)
HX_FIELD_REF_IMPL_MEM_OP(-,double)
HX_FIELD_REF_IMPL_MEM_OP(%,double)

// Disambiguate Dynamic operators...

#define HX_INDEX_REF_OP_DYNAMIC(op,ret) \
inline ret operator op (const Dynamic &inT, const IndexRef &inA) \
   { return inT op ( inA.operator Dynamic()); }

HX_INDEX_REF_OP_DYNAMIC(==,bool)
HX_INDEX_REF_OP_DYNAMIC(!=,bool)
HX_INDEX_REF_OP_DYNAMIC(+,Dynamic)
HX_INDEX_REF_OP_DYNAMIC(*,double)



template<typename _OBJ>
class __TArrayImplRef
{
public:
   _OBJ &mObject;
   int mIndex;

   explicit __TArrayImplRef(_OBJ &inObj,int inIndex) : mObject(inObj), mIndex(inIndex) { }

   template<typename _DATA>
   inline void operator=(_DATA inRHS)
   {
      mObject->__set(mIndex,inRHS);
   }
};

template<typename _OBJ>
__TArrayImplRef<_OBJ> __ArrayImplRef(_OBJ &inObj, int inIndex)
{
   return __TArrayImplRef<_OBJ>(inObj,inIndex);
}



} // end namespace hx


#endif

#ifndef HX_ARRAY_H
#define HX_ARRAY_H

#include <cpp/FastIterator.h>

// --- hx::Boxed ------------------------------------------------------
//
// Provides an "Object" of given type.  For types that are not actually objects,
//  Dynamic is used.

namespace hx
{
template<typename T> struct Boxed { typedef T type; };
template<> struct Boxed<int> { typedef Dynamic type; };
template<> struct Boxed<double> { typedef Dynamic type; };
template<> struct Boxed<bool> { typedef Dynamic type; };
template<> struct Boxed<String> { typedef Dynamic type; };
}


namespace hx
{



// --- ArrayIterator -------------------------------------------
//
// An object that conforms to the standard iterator interface for arrays
template<typename T>
class ArrayIterator : public cpp::FastIterator_obj<T>
{
public:
   ArrayIterator(Array<T> inArray) : mArray(inArray), mIdx(0) { }

   // Fast versions ...
   bool hasNext()  { return mIdx < mArray->length; }
   T next() { return mArray->__get(mIdx++); }


   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER_NAME(mArray,"mArray"); }

   int      mIdx;
   Array<T> mArray;
};

}

namespace hx
{

// --- hx::ArrayBase ----------------------------------------------------
//
// Base class that treats array contents as a slab of bytes.
// The derived "Array_obj" adds strong typing to the "[]" operator

class ArrayBase : public hx::Object
{
public:
   ArrayBase(int inSize,int inReserve,int inElementSize,bool inAtomic);

   static void __boot();

   typedef hx::Object super;

   Dynamic __SetField(const String &inString,const Dynamic &inValue) { return null(); }

   static Class __mClass;
   static Class &__SGetClass() { return __mClass; }
   Class __GetClass() const { return __mClass; }
   String toString();
   String __ToString() const;

   int __GetType() const { return vtArray; }

   inline size_t size() const { return length; }
   inline int __length() const { return (int)length; }
   virtual String ItemString(int inI)  = 0;

   const char * __CStr() const { return mBase; }
   inline const char *GetBase() const { return mBase; }
   inline char *GetBase() { return mBase; }

   virtual int GetElementSize() const = 0;

   virtual void __SetSize(int inLen);

   // Dynamic interface
   Dynamic __Field(const String &inString);
   virtual Dynamic __concat(const Dynamic &a0) = 0;
   virtual Dynamic __copy() = 0;
   virtual Dynamic __insert(const Dynamic &a0,const Dynamic &a1) = 0;
   virtual Dynamic __iterator() = 0;
   virtual Dynamic __join(const Dynamic &a0) = 0;
   virtual Dynamic __pop() = 0;
   virtual Dynamic __push(const Dynamic &a0) = 0;
   virtual Dynamic __remove(const Dynamic &a0) = 0;
   virtual Dynamic __reverse() = 0;
   virtual Dynamic __shift() = 0;
   virtual Dynamic __slice(const Dynamic &a0,const Dynamic &a1) = 0;
   virtual Dynamic __splice(const Dynamic &a0,const Dynamic &a1) =0;
   virtual Dynamic __sort(const Dynamic &a0) = 0;
   virtual Dynamic __toString() = 0;
   virtual Dynamic __unshift(const Dynamic &a0) = 0;


   Dynamic concat_dyn();
   Dynamic copy_dyn();
   Dynamic insert_dyn();
   Dynamic iterator_dyn();
   Dynamic join_dyn();
   Dynamic pop_dyn();
   Dynamic push_dyn();
   Dynamic remove_dyn();
   Dynamic reverse_dyn();
   Dynamic shift_dyn();
   Dynamic slice_dyn();
   Dynamic splice_dyn();
   Dynamic sort_dyn();
   Dynamic toString_dyn();
   Dynamic unshift_dyn();

   void EnsureSize(int inLen) const;

   void RemoveElement(int inIndex);


   void Insert(int inPos);

   void Splice(hx::ArrayBase *outResult,int inPos,int inLen);

   void Slice(hx::ArrayBase *outResult,int inPos,int inEnd);

   void Concat(hx::ArrayBase *outResult,const char *inEnd, int inLen);


   void reserve(int inN);


   String join(String inSeparator);


   virtual bool AllocAtomic() const { return false; }

   virtual bool IsByteArray() const = 0;


   mutable int length;
protected:
   mutable int mAlloc;
   mutable char  *mBase;
};

} // end namespace ArrayBase

// --- Array_obj ------------------------------------------------------------------
//
// The Array_obj specialises the ArrayBase, adding typing where required


namespace hx
{
// This is to determine is we need to include our slab of bytes in garbage collection
template<typename T>
inline bool TypeContainsPointers(T *) { return true; }
template<> inline bool TypeContainsPointers(bool *) { return false; }
template<> inline bool TypeContainsPointers(int *) { return false; }
template<> inline bool TypeContainsPointers(double *) { return false; }
template<> inline bool TypeContainsPointers(unsigned char *) { return false; }

template<typename TYPE> inline bool ContainsPointers()
{
   return TypeContainsPointers( (TYPE *)0 );
}


// For returning "null" when out of bounds ...
template<typename TYPE>
inline TYPE *NewNull() { Dynamic d; return (TYPE *)hx::NewGCBytes(&d,sizeof(d)); }

template<> inline int *NewNull<int>() { int i=0; return (int *)hx::NewGCPrivate(&i,sizeof(i)); }
template<> inline bool *NewNull<bool>() { bool b=0; return (bool *)hx::NewGCPrivate(&b,sizeof(b)); }
template<> inline double *NewNull<double>() { double d=0; return (double *)hx::NewGCPrivate(&d,sizeof(d)); }
template<> inline unsigned char *NewNull<unsigned char>() { unsigned char u=0; return (unsigned char *)hx::NewGCPrivate(&u,sizeof(u)); }

}

// sort...
#include <algorithm>


template<typename T>
struct ArrayTraits { enum { IsByteArray = 0, IsDynamic = 0 }; };
template<>
struct ArrayTraits<unsigned char> { enum { IsByteArray = 1, IsDynamic = 0 }; };
template<>
struct ArrayTraits<Dynamic> { enum { IsByteArray = 0, IsDynamic = 1 }; };

template<typename ELEM_>
class Array_obj : public hx::ArrayBase
{
   typedef ELEM_ Elem;
   typedef hx::ObjectPtr< Array_obj<ELEM_> > ObjPtr;
   typedef typename hx::Boxed<ELEM_>::type NullType;


public:
   Array_obj(int inSize,int inReserve) :
        hx::ArrayBase(inSize,inReserve,sizeof(ELEM_),!hx::ContainsPointers<ELEM_>()) { }


   // Defined later so we can use "Array"
   static Array<ELEM_> __new(int inSize=0,int inReserve=0);

   virtual bool AllocAtomic() const { return !hx::ContainsPointers<ELEM_>(); }


   virtual Dynamic __GetItem(int inIndex) const { return __get(inIndex); }
   virtual Dynamic __SetItem(int inIndex,Dynamic inValue)
           { Item(inIndex) = inValue; return inValue; }

   inline ELEM_ *Pointer() { return (ELEM_ *)mBase; }

   inline ELEM_ &Item(int inIndex)
   {
      if (inIndex>=(int)length) EnsureSize(inIndex+1);
      else if (inIndex<0) { return * hx::NewNull<ELEM_>(); }
      return * (ELEM_ *)(mBase + inIndex*sizeof(ELEM_));
   }
   inline ELEM_ __get(int inIndex) const
   {
      if (inIndex>=(int)length || inIndex<0) return null();
      return * (ELEM_ *)(mBase + inIndex*sizeof(ELEM_));
   }

   // Does not check for size valid - use with care
   inline ELEM_ &__unsafe_get(int inIndex) { return * (ELEM_ *)(mBase + inIndex*sizeof(ELEM_)); }
   inline void __unsafe_set(int inIndex, const ELEM_ &inValue)
   {
      * (ELEM_ *)(mBase + inIndex*sizeof(ELEM_)) = inValue;
   }


   void __Mark(HX_MARK_PARAMS)
   {
      if (hx::ContainsPointers<ELEM_>())
      {
         ELEM_ *ptr = (ELEM_ *)mBase;
         for(int i=0;i<length;i++)
            HX_MARK_MEMBER(ptr[i]);
      }
      HX_MARK_ARRAY(mBase);
   }

   int GetElementSize() const { return sizeof(ELEM_); }

   String ItemString(int inI)
   {
      String result(__get(inI));
      if (result==null()) return HX_CSTRING("null");
      return result;
   }

   Array_obj<ELEM_> *Add(const ELEM_ &inItem) { push(inItem); return this; }


   // Haxe API
   inline int push( const ELEM_ &inVal )
   {
      int l = length;
      EnsureSize((int)l+1);
      * (ELEM_ *)(mBase + l*sizeof(ELEM_)) = inVal;
      return length;
   }
   inline NullType pop( )
   {
      if (!length) return null();
      ELEM_ result = __get((int)length-1);
      __SetSize((int)length-1);
      return result;
   }


   int Find(ELEM_ inValue)
   {
      ELEM_ *e = (ELEM_ *)mBase;
      for(int i=0;i<length;i++)
         if (e[i]==inValue)
            return i;
      return -1;
   }


   bool remove(ELEM_ inValue)
   {
      ELEM_ *e = (ELEM_ *)mBase;
      for(int i=0;i<length;i++)
      {
         if (e[i]==inValue)
         {
            RemoveElement((int)i);
            return true;
         }
      }
      return false;
   }

   NullType shift()
   {
      if (length==0) return null();
      ELEM_ result = __get(0);
      RemoveElement(0);
      return result;
   }


   Array<ELEM_> concat( Array<ELEM_> inTail );
   Array<ELEM_> copy( );
   Array<ELEM_> slice(int inPos, Dynamic end = null());
   Array<ELEM_> splice(int inPos, int len);

   void insert(int inPos, ELEM_ inValue)
   {
		if (inPos<0)
		{
			inPos+=length;
			if (inPos<0) inPos = 0;
		}
		else if (inPos>length)
			inPos = length;
		hx::ArrayBase::Insert(inPos);
      Item(inPos) = inValue;
   }

   void unshift(ELEM_ inValue)
   {
      insert(0,inValue);
   }

   void reverse()
   {
      int half = length/2;
      ELEM_ *e = (ELEM_ *)mBase;
      for(int i=0;i<half;i++)
      {
         ELEM_ tmp = e[length-i-1];
         e[length-i-1] = e[i];
         e[i] = tmp;
      }
   }


   struct Sorter
   {
      Sorter(Dynamic inFunc) : mFunc(inFunc) { }

      bool operator()(const ELEM_ &inA, const ELEM_ &inB)
      {
         return mFunc( Dynamic(inA), Dynamic(inB))->__ToInt() < 0;
      }

      Dynamic mFunc;
   };

   void sort(Dynamic inSorter)
   {
      ELEM_ *e = (ELEM_ *)mBase;
      std::sort(e, e+length, Sorter(inSorter) );
   }

   Dynamic iterator() { return new hx::ArrayIterator<ELEM_>(this); }

   virtual bool IsByteArray() const { return ArrayTraits<ELEM_>::IsByteArray; }

   // Dynamic interface
   virtual Dynamic __concat(const Dynamic &a0) { return concat(a0); }
   virtual Dynamic __copy() { return copy(); }
   virtual Dynamic __insert(const Dynamic &a0,const Dynamic &a1) { insert(a0,a1); return null(); }
   virtual Dynamic __iterator() { return iterator(); }
   virtual Dynamic __join(const Dynamic &a0) { return join(a0); }
   virtual Dynamic __pop() { return pop(); }
   virtual Dynamic __push(const Dynamic &a0) { return push(a0);}
   virtual Dynamic __remove(const Dynamic &a0) { return remove(a0); }
   virtual Dynamic __reverse() { reverse(); return null(); }
   virtual Dynamic __shift() { return shift(); }
   virtual Dynamic __slice(const Dynamic &a0,const Dynamic &a1) { return slice(a0,a1); }
   virtual Dynamic __splice(const Dynamic &a0,const Dynamic &a1) { return splice(a0,a1); }
   virtual Dynamic __sort(const Dynamic &a0) { sort(a0); return null(); }
   virtual Dynamic __toString() { return toString(); }
   virtual Dynamic __unshift(const Dynamic &a0) { unshift(a0); return null(); }
};



// --- Array ---------------------------------------------------------------
//
// The array class adds object syntax to the Array_obj pointer

template<typename ELEM_>
class Array : public hx::ObjectPtr< Array_obj<ELEM_> >
{
   typedef hx::ObjectPtr< Array_obj<ELEM_> > super;
   typedef Array_obj<ELEM_> OBJ_;

public:
   typedef Array_obj<ELEM_> *Ptr;
   using super::mPtr;
   using super::GetPtr;

   Array() { }
   Array(int inSize,int inReserve) : super( OBJ_::__new(inSize,inReserve) ) { }
   Array(const null &inNull) : super(0) { }
   Array(Ptr inPtr) : super(inPtr) { }

   #ifdef HXCPP_DEBUG
   inline OBJ_ *CheckGetPtr() const
   {
      if (!mPtr) hx::CriticalError(HX_CSTRING("Null Array Reference"));
      return mPtr;
   }
   #else
   inline OBJ_ *CheckGetPtr() const { return mPtr; }
   #endif

   // Construct from our type ...
   Array ( const hx::ObjectPtr< OBJ_  > &inArray )
        :  hx::ObjectPtr< OBJ_ >(inArray) { }

   Array(const Array<ELEM_> &inArray) : super(inArray.GetPtr()) { }

   // Build dynamic array from foreign array
   template<typename SOURCE_>
   Array( const Array<SOURCE_> &inRHS ) : super(0)
   {
      Array_obj<SOURCE_> *ptr = inRHS.GetPtr(); 
      if (ptr)
      {
         OBJ_ *arr = dynamic_cast<OBJ_ *>(ptr);
         if (!arr)
         {
            // Non-identical type (syntactically, should be creating from Array<Dynamic>)
            // Copy elements one-by-one
            // Not quite right, but is the best we can do...
            int n = ptr->__length();
            *this = Array_obj<ELEM_>::__new(n);
            for(int i=0;i<n;i++)
               mPtr->__unsafe_set(i,ptr->__GetItem(i));
         }
         else
            mPtr = arr;
      }
   }

   Array( const Dynamic &inRHS ) : super(0)
   {
      hx::Object *ptr = inRHS.GetPtr(); 
      if (ptr)
      {
         OBJ_ *arr = dynamic_cast<OBJ_ *>(ptr);
         if (!arr)
         {
            // Non-identical type.
            // Copy elements one-by-one
            // Not quite right, but is the best we can do...
            int n = ptr->__length();
            *this = Array_obj<ELEM_>::__new(n);
            for(int i=0;i<n;i++)
               mPtr->__unsafe_set(i,ptr->__GetItem(i));
         }
         else
            mPtr = arr;
      }
   }


   // operator= exact match...
   Array &operator=( Array<ELEM_> inRHS )
   {
      mPtr = inRHS.GetPtr();
      return *this;
   }

   // Foreign array
   template<typename OTHER>
   Array &operator=( const Array<OTHER> &inRHS )
   {
      *this = Array(inRHS);
      return *this;
   }

   Array &operator=( const Dynamic &inRHS )
   {
      *this = Array(inRHS);
      return *this;
   }

   Array &operator=( const null &inNull )
   {
      mPtr = 0;
      return *this;
   }



   inline ELEM_ &operator[](int inIdx) { return CheckGetPtr()->Item(inIdx); }
   inline ELEM_ operator[](int inIdx) const { return CheckGetPtr()->__get(inIdx); }
   //inline ELEM_ __get(int inIdx) const { return CheckGetPtr()->__get(inIdx); }
   inline int __length() const { return CheckGetPtr()->__length(); }
   inline Array<ELEM_> &Add(const ELEM_ &inElem) { CheckGetPtr()->Add(inElem); return *this; }
   inline Array<ELEM_> & operator<<(const ELEM_ &inElem) { CheckGetPtr()->Add(inElem); return *this; }
};


// Now that the "Array" object is defined, we can implement this function ....

template<typename ELEM_>
Array<ELEM_> Array_obj<ELEM_>::__new(int inSize,int inReserve)
 { return  Array<ELEM_>(new Array_obj(inSize,inReserve)); }


template<>
inline bool Dynamic::IsClass<Array<Dynamic> >()
   { return mPtr && mPtr->__GetClass()== hx::ArrayBase::__mClass; }


template<typename ELEM_>
Array<ELEM_> Array_obj<ELEM_>::concat( Array<ELEM_> inTail )
{
   Array_obj *result = new Array_obj(inTail->__length()+(int)length,0);
   hx::ArrayBase::Concat(result,inTail->GetBase(),inTail->__length());
   return result;
}

template<typename ELEM_>
Array<ELEM_> Array_obj<ELEM_>::copy( )
{
   Array_obj *result = new Array_obj((int)length,0);
   memcpy(result->GetBase(),GetBase(),length*sizeof(ELEM_));
   return result;
}

// Copies the range of the array starting at pos up to, but not including, end.
// Both pos and end can be negative to count from the end: -1 is the last item in the array.
template<typename ELEM_>
Array<ELEM_> Array_obj<ELEM_>::slice(int inPos, Dynamic end)
{
   int e = end==null() ? length : end->__ToInt();
   Array_obj *result = new Array_obj(0,0);
   hx::ArrayBase::Slice(result,inPos,(int)e);
   return result;
}

template<typename ELEM_>
Array<ELEM_> Array_obj<ELEM_>::splice(int inPos, int len)
{
   Array_obj * result = new Array_obj(len,0);
   hx::ArrayBase::Splice(result,inPos,len);
   return result;
}






#endif

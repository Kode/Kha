#ifndef INCLUDED_cpp_FastIterator
#define INCLUDED_cpp_FastIterator

namespace cpp
{

class IteratorBase : public hx::Object
{
public:
   Dynamic __Field(const String &inString);
   virtual bool hasNext() = 0;
   virtual Dynamic _dynamicNext() = 0;

   Dynamic hasNext_dyn( );
   Dynamic next_dyn( );
   Dynamic _dynamicNext_dyn( );
};


template<typename T>
class FastIterator_obj : public IteratorBase
{
public:
   virtual bool hasNext() = 0;
   virtual T next() = 0;

   virtual Dynamic _dynamicNext() { return next(); }
};



template<typename T>
class DynamicIterator : public FastIterator_obj<T>
{
public:
   Dynamic mNext;
   Dynamic mHasNext;

   DynamicIterator(Dynamic inValue)
   {
      mNext = inValue->__Field(HX_CSTRING("next"));
      mHasNext = inValue->__Field(HX_CSTRING("hasNext"));
   }

   bool hasNext() { return mHasNext(); }
   T next() { return mNext(); }

   void __Mark(HX_MARK_PARAMS)
   {
      HX_MARK_MEMBER_NAME(mNext,"mNext");
      HX_MARK_MEMBER_NAME(mHasNext,"mHasNext");
   }

};


template<typename T>
FastIterator_obj<T> *CreateFastIterator(Dynamic inValue)
{
   FastIterator_obj<T> *result = dynamic_cast< FastIterator_obj<T> *>(inValue.GetPtr());
   if (result) return result;
   return new DynamicIterator<T>(inValue);
}

}

#endif

#include <hxcpp.h>

using namespace hx;


// -------- ArrayBase -------------------------------------

namespace hx
{

ArrayBase::ArrayBase(int inSize,int inReserve,int inElementSize,bool inAtomic)
{
   length = inSize;
   mAlloc = inSize < inReserve ? inReserve : inSize;
   if (mAlloc)
   {
      mBase = (char *)( (!inAtomic) ?
        hx::NewGCBytes(0, mAlloc * inElementSize ) : hx::NewGCPrivate(0,mAlloc*inElementSize));
   }
   else
      mBase = 0;
}


void ArrayBase::EnsureSize(int inSize) const
{
   int s = inSize;
   if (s>length)
   {
      if (s>mAlloc)
      {
         int obytes = mAlloc * GetElementSize();
         mAlloc = s*3/2 + 10;
         int bytes = mAlloc * GetElementSize();
         if (mBase)
         {
            mBase = (char *)hx::GCRealloc(mBase, bytes );
         }
         else if (AllocAtomic())
         {
            mBase = (char *)hx::NewGCPrivate(0,bytes);
         }
         else
         {
            mBase = (char *)hx::NewGCBytes(0,bytes);
         }
      }
      length = s;
   }
}




String ArrayBase::__ToString() const { return HX_CSTRING("Array"); }
String ArrayBase::toString()
{
   // Byte-array (not bool!)
   if (IsByteArray())
   {
      return String( (const char *) mBase, length);
   }

   return HX_CSTRING("[") + join(HX_CSTRING(", ")) + HX_CSTRING("]");
}

void ArrayBase::__SetSize(int inSize)
{
   if (inSize<length)
   {
      int s = GetElementSize();
      memset(mBase + inSize*s, 0, (length-inSize)*s);
      length = inSize;
   }
   else if (inSize>length)
   {
      EnsureSize(inSize);
      length = inSize;
   }
}


void ArrayBase::Insert(int inPos)
{
   if (inPos>=length)
      __SetSize(length+1);
   else
   {
      __SetSize(length+1);
      int s = GetElementSize();
      memmove(mBase + inPos*s + s, mBase+inPos*s, (length-inPos-1)*s );
   }
}

void ArrayBase::Splice(ArrayBase *outResult,int inPos,int inLen)
{
   if (inPos>=length)
   {
      outResult->__SetSize(0);
      return;
   }
   else if (inPos<0)
   {
      inPos += length;
      if (inPos<0)
         inPos =0;
   }
   if (inLen<0)
      return;
   if (inPos+inLen>length)
      inLen = length - inPos;

   outResult->__SetSize(inLen);
   int s = GetElementSize();
   memcpy(outResult->mBase, mBase+inPos*s, s*inLen);
   memmove(mBase+inPos*s, mBase + (inPos+inLen)*s, (length-(inPos+inLen))*s);
   __SetSize(length-inLen);
}

void ArrayBase::Slice(ArrayBase *outResult,int inPos,int inEnd)
{
   if (inPos<0)
   {
      inPos += length;
      if (inPos<0)
         inPos =0;
   }
   if (inEnd<0)
      inEnd += length;
   if (inEnd>length)
      inEnd = length;
   int n = inEnd - inPos;
   if (n<=0)
      outResult->__SetSize(0);
   else
   {
      outResult->__SetSize(n);
      int s = GetElementSize();
      memcpy(outResult->mBase, mBase+inPos*s, n*s);
   }
}

void ArrayBase::RemoveElement(int inPos)
{
   if (inPos<length)
   {
      int s = GetElementSize();
      memmove(mBase + inPos*s, mBase+inPos*s + s, (length-inPos-1)*s );
      __SetSize(length-1);
   }

}

void ArrayBase::Concat(ArrayBase *outResult,const char *inSecond,int inLen)
{
   char *ptr =  outResult->GetBase();
   int n = length * GetElementSize();
   memcpy(ptr,mBase,n);
   ptr += n;
   memcpy(ptr,inSecond,inLen*GetElementSize());

}


String ArrayBase::join(String inSeparator)
{
   int len = 0;
   for(int i=0;i<length;i++)
   {
      len += ItemString(i).length;
   }
   if (length) len += (length-1) * inSeparator.length;

   HX_CHAR *buf = hx::NewString(len);

   int pos = 0;
   bool separated = inSeparator.length>0;
   for(int i=0;i<length;i++)
   {
      String s = ItemString(i);
      memcpy(buf+pos,s.__s,s.length*sizeof(HX_CHAR));
      pos += s.length;
      if (separated && (i+1<length) )
      {
         memcpy(buf+pos,inSeparator.__s,inSeparator.length*sizeof(HX_CHAR));
         pos += inSeparator.length;
      }
   }
   buf[len] = '\0';

   return String(buf,len);
}

#define DEFINE_ARRAY_FUNC(func,array_list,dynamic_arg_list,arg_list,ARG_C) \
struct ArrayBase_##func : public hx::Object \
{ \
   bool __IsFunction() const { return true; } \
   ArrayBase *mThis; \
   ArrayBase_##func(ArrayBase *inThis) : mThis(inThis) { } \
   String toString() const{ return HX_CSTRING(#func) ; } \
   String __ToString() const{ return HX_CSTRING(#func) ; } \
   int __GetType() const { return vtFunction; } \
   void *__GetHandle() const { return mThis; } \
   int __ArgCount() const { return ARG_C; } \
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } \
   Dynamic __Run(const Array<Dynamic> &inArgs) \
   { \
      return mThis->__##func(array_list); return Dynamic(); \
   } \
   Dynamic __run(dynamic_arg_list) \
   { \
      return mThis->__##func(arg_list); return Dynamic(); \
   } \
}; \
Dynamic ArrayBase::func##_dyn()  { return new ArrayBase_##func(this);  }


#define DEFINE_ARRAY_FUNC0(func) DEFINE_ARRAY_FUNC(func,HX_ARR_LIST0,HX_DYNAMIC_ARG_LIST0,HX_ARG_LIST0,0)
#define DEFINE_ARRAY_FUNC1(func) DEFINE_ARRAY_FUNC(func,HX_ARR_LIST1,HX_DYNAMIC_ARG_LIST1,HX_ARG_LIST1,1)
#define DEFINE_ARRAY_FUNC2(func) DEFINE_ARRAY_FUNC(func,HX_ARR_LIST2,HX_DYNAMIC_ARG_LIST2,HX_ARG_LIST2,2)


DEFINE_ARRAY_FUNC1(concat);
DEFINE_ARRAY_FUNC2(insert);
DEFINE_ARRAY_FUNC0(iterator);
DEFINE_ARRAY_FUNC1(join);
DEFINE_ARRAY_FUNC0(pop);
DEFINE_ARRAY_FUNC0(copy);
DEFINE_ARRAY_FUNC1(push);
DEFINE_ARRAY_FUNC1(remove);
DEFINE_ARRAY_FUNC0(reverse);
DEFINE_ARRAY_FUNC0(shift);
DEFINE_ARRAY_FUNC2(slice);
DEFINE_ARRAY_FUNC2(splice);
DEFINE_ARRAY_FUNC1(sort);
DEFINE_ARRAY_FUNC0(toString);
DEFINE_ARRAY_FUNC1(unshift);

Dynamic ArrayBase::__Field(const String &inString)
{
   if (inString==HX_CSTRING("length")) return Dynamic((int)size());
   if (inString==HX_CSTRING("concat")) return concat_dyn();
   if (inString==HX_CSTRING("insert")) return insert_dyn();
   if (inString==HX_CSTRING("copy")) return copy_dyn();
   if (inString==HX_CSTRING("iterator")) return iterator_dyn();
   if (inString==HX_CSTRING("join")) return join_dyn();
   if (inString==HX_CSTRING("pop")) return pop_dyn();
   if (inString==HX_CSTRING("push")) return push_dyn();
   if (inString==HX_CSTRING("remove")) return remove_dyn();
   if (inString==HX_CSTRING("reverse")) return reverse_dyn();
   if (inString==HX_CSTRING("shift")) return shift_dyn();
   if (inString==HX_CSTRING("splice")) return splice_dyn();
   if (inString==HX_CSTRING("slice")) return slice_dyn();
   if (inString==HX_CSTRING("sort")) return sort_dyn();
   if (inString==HX_CSTRING("toString")) return toString_dyn();
   if (inString==HX_CSTRING("unshift")) return unshift_dyn();
   return null();
}


static String sArrayFields[] = {
   HX_CSTRING("length"),
   HX_CSTRING("concat"),
   HX_CSTRING("insert"),
   HX_CSTRING("iterator"),
   HX_CSTRING("join"),
   HX_CSTRING("copy"),
   HX_CSTRING("pop"),
   HX_CSTRING("push"),
   HX_CSTRING("remove"),
   HX_CSTRING("reverse"),
   HX_CSTRING("shift"),
   HX_CSTRING("slice"),
   HX_CSTRING("splice"),
   HX_CSTRING("sort"),
   HX_CSTRING("toString"),
   HX_CSTRING("unshift"),
   String(null())
};



// TODO;
Class ArrayBase::__mClass;

Dynamic ArrayCreateEmpty() { return new Array<Dynamic>(0,0); }
Dynamic ArrayCreateArgs(DynamicArray inArgs)
{
   return inArgs->__copy();
}

void ArrayBase::__boot()
{
   Static(__mClass) = hx::RegisterClass(HX_CSTRING("Array"),TCanCast<ArrayBase>,sNone,sArrayFields,
                                    ArrayCreateEmpty,ArrayCreateArgs,0,0);
}




// -------- ArrayIterator -------------------------------------

} // End namespace hx


namespace cpp
{
HX_DEFINE_DYNAMIC_FUNC0(IteratorBase,hasNext,return)
HX_DEFINE_DYNAMIC_FUNC0(IteratorBase,_dynamicNext,return)

Dynamic IteratorBase::next_dyn()
{
   return hx::CreateMemberFunction0(this,__IteratorBase_dynamicNext);
}

Dynamic IteratorBase::__Field(const String &inString)
{
   if (inString==HX_CSTRING("hasNext")) return hasNext_dyn();
   if (inString==HX_CSTRING("next")) return _dynamicNext_dyn();
   return null();
}
}




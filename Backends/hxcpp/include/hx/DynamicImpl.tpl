
::foreach PARAMS:: ::if (ARG>=6)::
Dynamic Dynamic::NS::operator()(::DYNAMIC_ARG_LIST::)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::NS::__new(0,::ARG::)::DYNAMIC_ADDS::);
}
::else::

namespace hx {

struct CMemberFunction::ARG:: : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction::ARG:: mFunction;


   CMemberFunction::ARG::(hx::Object *inObj, MemberFunction::ARG:: inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction::ARG:: *other = dynamic_cast<const CMemberFunction::ARG:: *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return ::ARG::; } 
   ::String __ToString() const{ return HX_CSTRING("#function::ARG::"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      ::if (ARG>0)::
      return mFunction(mThis.GetPtr(), ::ARR_LIST::);
      ::else::
      return mFunction(mThis.GetPtr());
      ::end::
   } 
   Dynamic __run(::DYNAMIC_ARG_LIST::) 
   { 
      ::if (ARG>0)::
      return mFunction(mThis.GetPtr(), ::ARG_LIST::);
      ::else::
      return mFunction(mThis.GetPtr());
      ::end::
   } 
}; 



struct CStaticFunction::ARG:: : public hx::Object 
{ 
   StaticFunction::ARG:: mFunction;

   CStaticFunction::ARG::(StaticFunction::ARG:: inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction::ARG:: *other = dynamic_cast<const CStaticFunction::ARG:: *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return ::ARG::; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction::ARG::"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(::ARR_LIST::);
   } 
   Dynamic __run(::DYNAMIC_ARG_LIST::) 
   { 
      return mFunction(::ARG_LIST::);
   } 
}; 


Dynamic CreateMemberFunction::ARG::(hx::Object *inObj, MemberFunction::ARG:: inFunc)
   { return new CMemberFunction::ARG::(inObj,inFunc); }

Dynamic CreateStaticFunction::ARG::(StaticFunction::ARG:: inFunc)
   { return new CStaticFunction::ARG::(inFunc); }

}

::end::
::end::

namespace hx
{


struct CMemberFunctionVar : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunctionVar mFunction;
   int N;


   CMemberFunctionVar(hx::Object *inObj, MemberFunctionVar inFunction,int inN)
   {
      mThis = inObj;
      mFunction = inFunction;
      N = inN;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunctionVar *other = dynamic_cast<const CMemberFunctionVar *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }


   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return N; } 
   ::String __ToString() const{ return HX_CSTRING("#vfunction"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(mThis.GetPtr(), inArgs);
   } 
}; 



struct CStaticFunctionVar : public hx::Object 
{ 
   StaticFunctionVar mFunction;
   int N;

   CStaticFunctionVar( StaticFunctionVar inFunction,int inN)
   {
      mFunction = inFunction;
      N = inN;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunctionVar *other = dynamic_cast<const CStaticFunctionVar *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }


   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return N; } 
   ::String __ToString() const{ return HX_CSTRING("#vsfunction"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs);
   } 
}; 


Dynamic CreateMemberFunctionVar(hx::Object *inObj, MemberFunctionVar inFunc,int inN)
   { return new CMemberFunctionVar(inObj,inFunc,inN); }

Dynamic CreateStaticFunctionVar(StaticFunctionVar inFunc,int inN)
   { return new CStaticFunctionVar(inFunc,inN); }

}



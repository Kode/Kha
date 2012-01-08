// DO NOT EDIT
// This file is generated from the .tpl file

 

namespace hx {

struct CMemberFunction0 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction0 mFunction;


   CMemberFunction0(hx::Object *inObj, MemberFunction0 inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction0 *other = dynamic_cast<const CMemberFunction0 *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 0; } 
   ::String __ToString() const{ return HX_CSTRING("#function0"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr());
      
   } 
   Dynamic __run() 
   { 
      
      return mFunction(mThis.GetPtr());
      
   } 
}; 



struct CStaticFunction0 : public hx::Object 
{ 
   StaticFunction0 mFunction;

   CStaticFunction0(StaticFunction0 inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction0 *other = dynamic_cast<const CStaticFunction0 *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 0; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction0"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction();
   } 
   Dynamic __run() 
   { 
      return mFunction();
   } 
}; 


Dynamic CreateMemberFunction0(hx::Object *inObj, MemberFunction0 inFunc)
   { return new CMemberFunction0(inObj,inFunc); }

Dynamic CreateStaticFunction0(StaticFunction0 inFunc)
   { return new CStaticFunction0(inFunc); }

}


 

namespace hx {

struct CMemberFunction1 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction1 mFunction;


   CMemberFunction1(hx::Object *inObj, MemberFunction1 inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction1 *other = dynamic_cast<const CMemberFunction1 *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 1; } 
   ::String __ToString() const{ return HX_CSTRING("#function1"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0]);
      
   } 
   Dynamic __run(const Dynamic &inArg0) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0);
      
   } 
}; 



struct CStaticFunction1 : public hx::Object 
{ 
   StaticFunction1 mFunction;

   CStaticFunction1(StaticFunction1 inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction1 *other = dynamic_cast<const CStaticFunction1 *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 1; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction1"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs[0]);
   } 
   Dynamic __run(const Dynamic &inArg0) 
   { 
      return mFunction(inArg0);
   } 
}; 


Dynamic CreateMemberFunction1(hx::Object *inObj, MemberFunction1 inFunc)
   { return new CMemberFunction1(inObj,inFunc); }

Dynamic CreateStaticFunction1(StaticFunction1 inFunc)
   { return new CStaticFunction1(inFunc); }

}


 

namespace hx {

struct CMemberFunction2 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction2 mFunction;


   CMemberFunction2(hx::Object *inObj, MemberFunction2 inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction2 *other = dynamic_cast<const CMemberFunction2 *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 2; } 
   ::String __ToString() const{ return HX_CSTRING("#function2"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1);
      
   } 
}; 



struct CStaticFunction2 : public hx::Object 
{ 
   StaticFunction2 mFunction;

   CStaticFunction2(StaticFunction2 inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction2 *other = dynamic_cast<const CStaticFunction2 *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 2; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction2"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs[0],inArgs[1]);
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1) 
   { 
      return mFunction(inArg0,inArg1);
   } 
}; 


Dynamic CreateMemberFunction2(hx::Object *inObj, MemberFunction2 inFunc)
   { return new CMemberFunction2(inObj,inFunc); }

Dynamic CreateStaticFunction2(StaticFunction2 inFunc)
   { return new CStaticFunction2(inFunc); }

}


 

namespace hx {

struct CMemberFunction3 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction3 mFunction;


   CMemberFunction3(hx::Object *inObj, MemberFunction3 inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction3 *other = dynamic_cast<const CMemberFunction3 *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 3; } 
   ::String __ToString() const{ return HX_CSTRING("#function3"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1],inArgs[2]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1,inArg2);
      
   } 
}; 



struct CStaticFunction3 : public hx::Object 
{ 
   StaticFunction3 mFunction;

   CStaticFunction3(StaticFunction3 inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction3 *other = dynamic_cast<const CStaticFunction3 *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 3; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction3"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs[0],inArgs[1],inArgs[2]);
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2) 
   { 
      return mFunction(inArg0,inArg1,inArg2);
   } 
}; 


Dynamic CreateMemberFunction3(hx::Object *inObj, MemberFunction3 inFunc)
   { return new CMemberFunction3(inObj,inFunc); }

Dynamic CreateStaticFunction3(StaticFunction3 inFunc)
   { return new CStaticFunction3(inFunc); }

}


 

namespace hx {

struct CMemberFunction4 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction4 mFunction;


   CMemberFunction4(hx::Object *inObj, MemberFunction4 inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction4 *other = dynamic_cast<const CMemberFunction4 *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 4; } 
   ::String __ToString() const{ return HX_CSTRING("#function4"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1],inArgs[2],inArgs[3]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1,inArg2,inArg3);
      
   } 
}; 



struct CStaticFunction4 : public hx::Object 
{ 
   StaticFunction4 mFunction;

   CStaticFunction4(StaticFunction4 inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction4 *other = dynamic_cast<const CStaticFunction4 *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 4; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction4"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs[0],inArgs[1],inArgs[2],inArgs[3]);
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3) 
   { 
      return mFunction(inArg0,inArg1,inArg2,inArg3);
   } 
}; 


Dynamic CreateMemberFunction4(hx::Object *inObj, MemberFunction4 inFunc)
   { return new CMemberFunction4(inObj,inFunc); }

Dynamic CreateStaticFunction4(StaticFunction4 inFunc)
   { return new CStaticFunction4(inFunc); }

}


 

namespace hx {

struct CMemberFunction5 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction5 mFunction;


   CMemberFunction5(hx::Object *inObj, MemberFunction5 inFunction)
   {
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction5 *other = dynamic_cast<const CMemberFunction5 *>(inRHS);
      if (!other)
         return -1;
      return (mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 5; } 
   ::String __ToString() const{ return HX_CSTRING("#function5"); } 
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(mThis); } 
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1,inArg2,inArg3,inArg4);
      
   } 
}; 



struct CStaticFunction5 : public hx::Object 
{ 
   StaticFunction5 mFunction;

   CStaticFunction5(StaticFunction5 inFunction)
   {
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction5 *other = dynamic_cast<const CStaticFunction5 *>(inRHS);
      if (!other)
         return -1;
      return mFunction==other->mFunction ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 5; } 
   ::String __ToString() const{ return HX_CSTRING("#sfunction5"); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4]);
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4) 
   { 
      return mFunction(inArg0,inArg1,inArg2,inArg3,inArg4);
   } 
}; 


Dynamic CreateMemberFunction5(hx::Object *inObj, MemberFunction5 inFunc)
   { return new CMemberFunction5(inObj,inFunc); }

Dynamic CreateStaticFunction5(StaticFunction5 inFunc)
   { return new CStaticFunction5(inFunc); }

}


 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,6)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,7)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,8)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,9)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,10)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,11)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,12)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,13)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,14)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,15)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13)->Add(inArg14));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,16)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13)->Add(inArg14)->Add(inArg15));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,17)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13)->Add(inArg14)->Add(inArg15)->Add(inArg16));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,18)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13)->Add(inArg14)->Add(inArg15)->Add(inArg16)->Add(inArg17));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17,const Dynamic &inArg18)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,19)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13)->Add(inArg14)->Add(inArg15)->Add(inArg16)->Add(inArg17)->Add(inArg18));
}

 
Dynamic Dynamic::operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17,const Dynamic &inArg18,const Dynamic &inArg19)
{
   CheckFPtr();
   return mPtr->__Run(Array_obj<Dynamic>::__new(0,20)->Add(inArg0)->Add(inArg1)->Add(inArg2)->Add(inArg3)->Add(inArg4)->Add(inArg5)->Add(inArg6)->Add(inArg7)->Add(inArg8)->Add(inArg9)->Add(inArg10)->Add(inArg11)->Add(inArg12)->Add(inArg13)->Add(inArg14)->Add(inArg15)->Add(inArg16)->Add(inArg17)->Add(inArg18)->Add(inArg19));
}



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



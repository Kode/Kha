// DO NOT EDIT
// This file is generated from the .tpl file
#ifndef HX_MACROS_H
#define HX_MACROS_H


#define HX_DO_RTTI_BASE \
   bool __Is(hx::Object *inObj) const { return dynamic_cast<OBJ_ *>(inObj)!=0; } \


#define HX_DO_RTTI \
   HX_DO_RTTI_BASE \
   static hx::ObjectPtr<Class_obj> __mClass; \
   hx::ObjectPtr<Class_obj > __GetClass() const { return __mClass; } \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; } \
   Dynamic __Field(const ::String &inString); \
   void __GetFields(Array< ::String> &outFields); \
   Dynamic __SetField(const ::String &inString,const Dynamic &inValue); \
   virtual int __GetType() const { return vtClass; } \
   inline operator super *() { return this; } 

#define HX_DO_INTERFACE_RTTI \
   static hx::ObjectPtr<Class_obj> __mClass; \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; } \
	static void __register();

#define HX_DO_ENUM_RTTI_INTERNAL \
   HX_DO_RTTI_BASE  \
   Dynamic __Field(const ::String &inString); \
   static int __FindIndex(::String inName); \
   static int __FindArgCount(::String inName);

#define HX_DO_ENUM_RTTI \
   HX_DO_ENUM_RTTI_INTERNAL \
   static hx::ObjectPtr<Class_obj> __mClass; \
   hx::ObjectPtr<Class_obj > __GetClass() const { return __mClass; } \
   static hx::ObjectPtr<Class_obj> &__SGetClass() { return __mClass; }


#define HX_DECLARE_IMPLEMENT_DYNAMIC  hx::FieldMap *__mDynamicFields; \
    hx::FieldMap *__GetFieldMap() { return __mDynamicFields; } \
    bool __HasField(const String &inString) \
      { return hx::FieldMapHas(__mDynamicFields,inString) || super::__HasField(inString); } 


#define HX_INIT_IMPLEMENT_DYNAMIC __mDynamicFields = hx::FieldMapCreate();

#define HX_IMPLEMENT_HAS_FIELD(class) \
    bool class::__HasField(const String &inString) \
    {  if (hx::FieldMap::

#define HX_MARK_DYNAMIC hx::FieldMapMark(__mDynamicFields HX_MARK_ADD_ARG);

#define HX_CHECK_DYNAMIC_GET_FIELD(inName) \
   { Dynamic d;  if (hx::FieldMapGet(__mDynamicFields,inName,d)) return d; }

#define HX_CHECK_DYNAMIC_GET_INT_FIELD(inID) \
   { Dynamic d;  if (hx::FieldMapGet(__mDynamicFields,inID,d)) return d; }

#define HX_DYNAMIC_SET_FIELD(inName,inValue) hx::FieldMapSet(__mDynamicFields,inName,inValue) 

#define HX_APPEND_DYNAMIC_FIELDS(outFields) hx::FieldMapAppendFields(__mDynamicFields,outFields)


#define HX_ARR_LIST0 
#define HX_ARR_LIST1 inArgs[0]
#define HX_ARR_LIST2 inArgs[0],inArgs[1]
#define HX_ARR_LIST3 inArgs[0],inArgs[1],inArgs[2]
#define HX_ARR_LIST4 inArgs[0],inArgs[1],inArgs[2],inArgs[3]
#define HX_ARR_LIST5 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4]
#define HX_ARR_LIST6 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5]
#define HX_ARR_LIST7 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6]
#define HX_ARR_LIST8 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7]
#define HX_ARR_LIST9 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8]
#define HX_ARR_LIST10 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9]
#define HX_ARR_LIST11 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10]
#define HX_ARR_LIST12 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11]
#define HX_ARR_LIST13 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12]
#define HX_ARR_LIST14 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13]
#define HX_ARR_LIST15 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13],inArgs[14]
#define HX_ARR_LIST16 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13],inArgs[14],inArgs[15]
#define HX_ARR_LIST17 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13],inArgs[14],inArgs[15],inArgs[16]
#define HX_ARR_LIST18 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13],inArgs[14],inArgs[15],inArgs[16],inArgs[17]
#define HX_ARR_LIST19 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13],inArgs[14],inArgs[15],inArgs[16],inArgs[17],inArgs[18]
#define HX_ARR_LIST20 inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9],inArgs[10],inArgs[11],inArgs[12],inArgs[13],inArgs[14],inArgs[15],inArgs[16],inArgs[17],inArgs[18],inArgs[19]


#define HX_DYNAMIC_ARG_LIST0 
#define HX_DYNAMIC_ARG_LIST1 const Dynamic &inArg0
#define HX_DYNAMIC_ARG_LIST2 const Dynamic &inArg0,const Dynamic &inArg1
#define HX_DYNAMIC_ARG_LIST3 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2
#define HX_DYNAMIC_ARG_LIST4 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3
#define HX_DYNAMIC_ARG_LIST5 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4
#define HX_DYNAMIC_ARG_LIST6 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5
#define HX_DYNAMIC_ARG_LIST7 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6
#define HX_DYNAMIC_ARG_LIST8 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7
#define HX_DYNAMIC_ARG_LIST9 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8
#define HX_DYNAMIC_ARG_LIST10 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9
#define HX_DYNAMIC_ARG_LIST11 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10
#define HX_DYNAMIC_ARG_LIST12 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11
#define HX_DYNAMIC_ARG_LIST13 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12
#define HX_DYNAMIC_ARG_LIST14 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13
#define HX_DYNAMIC_ARG_LIST15 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14
#define HX_DYNAMIC_ARG_LIST16 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15
#define HX_DYNAMIC_ARG_LIST17 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16
#define HX_DYNAMIC_ARG_LIST18 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17
#define HX_DYNAMIC_ARG_LIST19 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17,const Dynamic &inArg18
#define HX_DYNAMIC_ARG_LIST20 const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17,const Dynamic &inArg18,const Dynamic &inArg19


#define HX_ARG_LIST0 
#define HX_ARG_LIST1 inArg0
#define HX_ARG_LIST2 inArg0,inArg1
#define HX_ARG_LIST3 inArg0,inArg1,inArg2
#define HX_ARG_LIST4 inArg0,inArg1,inArg2,inArg3
#define HX_ARG_LIST5 inArg0,inArg1,inArg2,inArg3,inArg4
#define HX_ARG_LIST6 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5
#define HX_ARG_LIST7 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6
#define HX_ARG_LIST8 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7
#define HX_ARG_LIST9 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8
#define HX_ARG_LIST10 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9
#define HX_ARG_LIST11 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10
#define HX_ARG_LIST12 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11
#define HX_ARG_LIST13 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12
#define HX_ARG_LIST14 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13
#define HX_ARG_LIST15 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13,inArg14
#define HX_ARG_LIST16 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13,inArg14,inArg15
#define HX_ARG_LIST17 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13,inArg14,inArg15,inArg16
#define HX_ARG_LIST18 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13,inArg14,inArg15,inArg16,inArg17
#define HX_ARG_LIST19 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13,inArg14,inArg15,inArg16,inArg17,inArg18
#define HX_ARG_LIST20 inArg0,inArg1,inArg2,inArg3,inArg4,inArg5,inArg6,inArg7,inArg8,inArg9,inArg10,inArg11,inArg12,inArg13,inArg14,inArg15,inArg16,inArg17,inArg18,inArg19

#define HX_DEFINE_DYNAMIC_FUNC0(class,func,ret) \
Dynamic __##class##func(hx::Object *inObj) \
{ \
      ret reinterpret_cast<class *>(inObj)->func(); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::CreateMemberFunction0(this,__##class##func); \
}


#define HX_DEFINE_DYNAMIC_FUNC(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(hx::Object *inObj, dynamic_arg_list) \
{ \
      ret reinterpret_cast<class *>(inObj)->func(arg_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::CreateMemberFunction##N(this,__##class##func); \
}


#define HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(hx::Object *inObj, const Array<Dynamic> &inArgs) \
{ \
      ret reinterpret_cast<class *>(inObj)->func(array_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::CreateMemberFunctionVar(this,__##class##func,N); \
}


#define DELEGATE_0(ret,func) ret func() { return mDelegate->func(); }
#define CDELEGATE_0(ret,func) ret func() const { return mDelegate->func(); }
#define DELEGATE_1(ret,func,arg1) ret func(arg1 _a1) { return mDelegate->func(_a1); }
#define CDELEGATE_1(ret,func,arg1) ret func(arg1 _a1) const { return mDelegate->func(_a1); }
#define DELEGATE_2(ret,func,arg1,arg2) ret func(arg1 _a1,arg2 _a2) { return mDelegate->func(_a1,_a2); }





#define HX_DECLARE_DYNAMIC_FUNC(func,dynamic_arg_list) \
   Dynamic func##_dyn(dynamic_arg_list);

#define STATIC_HX_DECLARE_DYNAMIC_FUNC(func,dynamic_arg_list) \
   static Dynamic func##_dyn(dynamic_arg_list);





#define HX_DEFINE_DYNAMIC_FUNC1(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC(class,1,func,ret,HX_ARR_LIST1,HX_DYNAMIC_ARG_LIST1,HX_ARG_LIST1)



#define HX_DEFINE_DYNAMIC_FUNC2(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC(class,2,func,ret,HX_ARR_LIST2,HX_DYNAMIC_ARG_LIST2,HX_ARG_LIST2)



#define HX_DEFINE_DYNAMIC_FUNC3(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC(class,3,func,ret,HX_ARR_LIST3,HX_DYNAMIC_ARG_LIST3,HX_ARG_LIST3)



#define HX_DEFINE_DYNAMIC_FUNC4(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC(class,4,func,ret,HX_ARR_LIST4,HX_DYNAMIC_ARG_LIST4,HX_ARG_LIST4)



#define HX_DEFINE_DYNAMIC_FUNC5(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC(class,5,func,ret,HX_ARR_LIST5,HX_DYNAMIC_ARG_LIST5,HX_ARG_LIST5)



#define HX_DEFINE_DYNAMIC_FUNC6(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,6,func,ret,HX_ARR_LIST6,HX_DYNAMIC_ARG_LIST6,HX_ARG_LIST6)



#define HX_DEFINE_DYNAMIC_FUNC7(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,7,func,ret,HX_ARR_LIST7,HX_DYNAMIC_ARG_LIST7,HX_ARG_LIST7)



#define HX_DEFINE_DYNAMIC_FUNC8(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,8,func,ret,HX_ARR_LIST8,HX_DYNAMIC_ARG_LIST8,HX_ARG_LIST8)



#define HX_DEFINE_DYNAMIC_FUNC9(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,9,func,ret,HX_ARR_LIST9,HX_DYNAMIC_ARG_LIST9,HX_ARG_LIST9)



#define HX_DEFINE_DYNAMIC_FUNC10(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,10,func,ret,HX_ARR_LIST10,HX_DYNAMIC_ARG_LIST10,HX_ARG_LIST10)



#define HX_DEFINE_DYNAMIC_FUNC11(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,11,func,ret,HX_ARR_LIST11,HX_DYNAMIC_ARG_LIST11,HX_ARG_LIST11)



#define HX_DEFINE_DYNAMIC_FUNC12(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,12,func,ret,HX_ARR_LIST12,HX_DYNAMIC_ARG_LIST12,HX_ARG_LIST12)



#define HX_DEFINE_DYNAMIC_FUNC13(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,13,func,ret,HX_ARR_LIST13,HX_DYNAMIC_ARG_LIST13,HX_ARG_LIST13)



#define HX_DEFINE_DYNAMIC_FUNC14(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,14,func,ret,HX_ARR_LIST14,HX_DYNAMIC_ARG_LIST14,HX_ARG_LIST14)



#define HX_DEFINE_DYNAMIC_FUNC15(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,15,func,ret,HX_ARR_LIST15,HX_DYNAMIC_ARG_LIST15,HX_ARG_LIST15)



#define HX_DEFINE_DYNAMIC_FUNC16(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,16,func,ret,HX_ARR_LIST16,HX_DYNAMIC_ARG_LIST16,HX_ARG_LIST16)



#define HX_DEFINE_DYNAMIC_FUNC17(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,17,func,ret,HX_ARR_LIST17,HX_DYNAMIC_ARG_LIST17,HX_ARG_LIST17)



#define HX_DEFINE_DYNAMIC_FUNC18(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,18,func,ret,HX_ARR_LIST18,HX_DYNAMIC_ARG_LIST18,HX_ARG_LIST18)



#define HX_DEFINE_DYNAMIC_FUNC19(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,19,func,ret,HX_ARR_LIST19,HX_DYNAMIC_ARG_LIST19,HX_ARG_LIST19)



#define HX_DEFINE_DYNAMIC_FUNC20(class,func,ret) \
          HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,20,func,ret,HX_ARR_LIST20,HX_DYNAMIC_ARG_LIST20,HX_ARG_LIST20)




#define STATIC_HX_DEFINE_DYNAMIC_FUNC0(class,func,ret) \
Dynamic __##class##func() \
{ \
      ret class::func(); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::CreateStaticFunction0(__##class##func); \
}


#define STATIC_HX_DEFINE_DYNAMIC_FUNC(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(dynamic_arg_list) \
{ \
      ret class::func(arg_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::CreateStaticFunction##N(__##class##func); \
}


#define STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,N,func,ret,array_list,dynamic_arg_list,arg_list) \
Dynamic __##class##func(const Array<Dynamic> &inArgs) \
{ \
      ret class::func(array_list); return Dynamic(); \
}; \
Dynamic class::func##_dyn() \
{\
   return hx::CreateStaticFunctionVar(__##class##func,N); \
}






#define STATIC_HX_DEFINE_DYNAMIC_FUNC1(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC(class,1,func,ret,HX_ARR_LIST1,HX_DYNAMIC_ARG_LIST1,HX_ARG_LIST1)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC2(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC(class,2,func,ret,HX_ARR_LIST2,HX_DYNAMIC_ARG_LIST2,HX_ARG_LIST2)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC3(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC(class,3,func,ret,HX_ARR_LIST3,HX_DYNAMIC_ARG_LIST3,HX_ARG_LIST3)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC4(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC(class,4,func,ret,HX_ARR_LIST4,HX_DYNAMIC_ARG_LIST4,HX_ARG_LIST4)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC5(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC(class,5,func,ret,HX_ARR_LIST5,HX_DYNAMIC_ARG_LIST5,HX_ARG_LIST5)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC6(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,6,func,ret,HX_ARR_LIST6,HX_DYNAMIC_ARG_LIST6,HX_ARG_LIST6)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC7(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,7,func,ret,HX_ARR_LIST7,HX_DYNAMIC_ARG_LIST7,HX_ARG_LIST7)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC8(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,8,func,ret,HX_ARR_LIST8,HX_DYNAMIC_ARG_LIST8,HX_ARG_LIST8)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC9(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,9,func,ret,HX_ARR_LIST9,HX_DYNAMIC_ARG_LIST9,HX_ARG_LIST9)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC10(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,10,func,ret,HX_ARR_LIST10,HX_DYNAMIC_ARG_LIST10,HX_ARG_LIST10)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC11(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,11,func,ret,HX_ARR_LIST11,HX_DYNAMIC_ARG_LIST11,HX_ARG_LIST11)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC12(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,12,func,ret,HX_ARR_LIST12,HX_DYNAMIC_ARG_LIST12,HX_ARG_LIST12)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC13(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,13,func,ret,HX_ARR_LIST13,HX_DYNAMIC_ARG_LIST13,HX_ARG_LIST13)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC14(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,14,func,ret,HX_ARR_LIST14,HX_DYNAMIC_ARG_LIST14,HX_ARG_LIST14)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC15(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,15,func,ret,HX_ARR_LIST15,HX_DYNAMIC_ARG_LIST15,HX_ARG_LIST15)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC16(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,16,func,ret,HX_ARR_LIST16,HX_DYNAMIC_ARG_LIST16,HX_ARG_LIST16)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC17(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,17,func,ret,HX_ARR_LIST17,HX_DYNAMIC_ARG_LIST17,HX_ARG_LIST17)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC18(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,18,func,ret,HX_ARR_LIST18,HX_DYNAMIC_ARG_LIST18,HX_ARG_LIST18)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC19(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,19,func,ret,HX_ARR_LIST19,HX_DYNAMIC_ARG_LIST19,HX_ARG_LIST19)



#define STATIC_HX_DEFINE_DYNAMIC_FUNC20(class,func,ret) \
          STATIC_HX_DEFINE_DYNAMIC_FUNC_EXTRA(class,20,func,ret,HX_ARR_LIST20,HX_DYNAMIC_ARG_LIST20,HX_ARG_LIST20)



#define HX_DEFINE_CREATE_ENUM(enum_obj) \
static Dynamic Create##enum_obj(::String inName,hx::DynamicArray inArgs) \
{ \
   int idx =  enum_obj::__FindIndex(inName); \
   if (idx<0) throw HX_INVALID_CONSTRUCTOR; \
   int count =  enum_obj::__FindArgCount(inName); \
   int args = inArgs.GetPtr() ? inArgs.__length() : 0; \
   if (args!=count)  throw HX_INVALID_ARG_COUNT; \
   return hx::CreateEnum<enum_obj >(inName,idx,inArgs); \
}


#define HX_DECLARE_CLASS0(klass) \
	class klass##_obj; \
	typedef hx::ObjectPtr<klass##_obj> klass;
#define HX_DECLARE_CLASS1(ns1,klass) namespace ns1 { HX_DECLARE_CLASS0(klass) }
#define HX_DECLARE_CLASS2(ns2,ns1,klass) namespace ns2 { HX_DECLARE_CLASS1(ns1,klass) }
#define HX_DECLARE_CLASS3(ns3,ns2,ns1,klass) namespace ns3 { HX_DECLARE_CLASS2(ns2,ns1,klass) }
#define HX_DECLARE_CLASS4(ns4,ns3,ns2,ns1,klass) namespace ns4 { HX_DECLARE_CLASS3(ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS5(ns5,ns4,ns3,ns2,ns1,klass) namespace ns5 { HX_DECLARE_CLASS4(ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS6(ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns6 { HX_DECLARE_CLASS5(ns5,ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS7(ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns7 { HX_DECLARE_CLASS6(ns6,ns5,ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS8(ns8,ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns8 { HX_DECLARE_CLASS7(ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) }
#define HX_DECLARE_CLASS9(ns9,ns8,ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) namespace ns9 { HX_DECLARE_CLASS8(ns8,ns7,ns6,ns5,ns4,ns3,ns2,ns1,klass) }




#define HX_DYNAMIC_CALL(ret,func,array_args,dyn_arg_list,arg_list) \
   Dynamic __Run(const Array<Dynamic> &inArgs) { ret func( array_args ); return null();} \
   Dynamic __run(dyn_arg_list) { ret func( arg_list ); return null();}


#define HX_DYNAMIC_CALL0(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST0,HX_DYNAMIC_ARG_LIST0,HX_ARG_LIST0)
#define HX_DYNAMIC_CALL1(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST1,HX_DYNAMIC_ARG_LIST1,HX_ARG_LIST1)
#define HX_DYNAMIC_CALL2(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST2,HX_DYNAMIC_ARG_LIST2,HX_ARG_LIST2)
#define HX_DYNAMIC_CALL3(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST3,HX_DYNAMIC_ARG_LIST3,HX_ARG_LIST3)
#define HX_DYNAMIC_CALL4(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST4,HX_DYNAMIC_ARG_LIST4,HX_ARG_LIST4)
#define HX_DYNAMIC_CALL5(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST5,HX_DYNAMIC_ARG_LIST5,HX_ARG_LIST5)
#define HX_DYNAMIC_CALL6(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST6,HX_DYNAMIC_ARG_LIST6,HX_ARG_LIST6)
#define HX_DYNAMIC_CALL7(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST7,HX_DYNAMIC_ARG_LIST7,HX_ARG_LIST7)
#define HX_DYNAMIC_CALL8(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST8,HX_DYNAMIC_ARG_LIST8,HX_ARG_LIST8)
#define HX_DYNAMIC_CALL9(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST9,HX_DYNAMIC_ARG_LIST9,HX_ARG_LIST9)
#define HX_DYNAMIC_CALL10(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST10,HX_DYNAMIC_ARG_LIST10,HX_ARG_LIST10)
#define HX_DYNAMIC_CALL11(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST11,HX_DYNAMIC_ARG_LIST11,HX_ARG_LIST11)
#define HX_DYNAMIC_CALL12(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST12,HX_DYNAMIC_ARG_LIST12,HX_ARG_LIST12)
#define HX_DYNAMIC_CALL13(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST13,HX_DYNAMIC_ARG_LIST13,HX_ARG_LIST13)
#define HX_DYNAMIC_CALL14(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST14,HX_DYNAMIC_ARG_LIST14,HX_ARG_LIST14)
#define HX_DYNAMIC_CALL15(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST15,HX_DYNAMIC_ARG_LIST15,HX_ARG_LIST15)
#define HX_DYNAMIC_CALL16(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST16,HX_DYNAMIC_ARG_LIST16,HX_ARG_LIST16)
#define HX_DYNAMIC_CALL17(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST17,HX_DYNAMIC_ARG_LIST17,HX_ARG_LIST17)
#define HX_DYNAMIC_CALL18(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST18,HX_DYNAMIC_ARG_LIST18,HX_ARG_LIST18)
#define HX_DYNAMIC_CALL19(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST19,HX_DYNAMIC_ARG_LIST19,HX_ARG_LIST19)
#define HX_DYNAMIC_CALL20(ret,func) HX_DYNAMIC_CALL(ret,func,HX_ARR_LIST20,HX_DYNAMIC_ARG_LIST20,HX_ARG_LIST20)

#define HX_BEGIN_DEFAULT_FUNC(name,t0) \
	namespace { \
   struct name : public hx::Object { int __GetType() const { return vtFunction; } \
   hx::ObjectPtr<t0> __this; \
   name(hx::ObjectPtr<t0> __0 = null()) : __this(__0) {} \
   void __Mark(HX_MARK_PARAMS) { HX_MARK_MEMBER(__this); }


#define HX_END_DEFAULT_FUNC \
}

#define HX_BEGIN_LOCAL_FUNC_S0(SUPER,name) \
   struct name : public SUPER { \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); } \
   name() {}


#define HX_BEGIN_LOCAL_FUNC_S1(SUPER,name,t0,v0) \
   struct name : public SUPER { \
   t0 v0; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); } \
   name(t0 __0) : v0(__0) {}
#define HX_BEGIN_LOCAL_FUNC_S2(SUPER,name,t0,v0,t1,v1) \
   struct name : public SUPER { \
   t0 v0;t1 v1; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); } \
   name(t0 __0,t1 __1) : v0(__0),v1(__1) {}
#define HX_BEGIN_LOCAL_FUNC_S3(SUPER,name,t0,v0,t1,v1,t2,v2) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); } \
   name(t0 __0,t1 __1,t2 __2) : v0(__0),v1(__1),v2(__2) {}
#define HX_BEGIN_LOCAL_FUNC_S4(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3) : v0(__0),v1(__1),v2(__2),v3(__3) {}
#define HX_BEGIN_LOCAL_FUNC_S5(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4) {}
#define HX_BEGIN_LOCAL_FUNC_S6(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5) {}
#define HX_BEGIN_LOCAL_FUNC_S7(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6) {}
#define HX_BEGIN_LOCAL_FUNC_S8(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7) {}
#define HX_BEGIN_LOCAL_FUNC_S9(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7;t8 v8; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); HX_MARK_MEMBER(v8); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7,t8 __8) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7),v8(__8) {}
#define HX_BEGIN_LOCAL_FUNC_S10(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7;t8 v8;t9 v9; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); HX_MARK_MEMBER(v8); HX_MARK_MEMBER(v9); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7,t8 __8,t9 __9) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7),v8(__8),v9(__9) {}
#define HX_BEGIN_LOCAL_FUNC_S11(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7;t8 v8;t9 v9;t10 v10; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); HX_MARK_MEMBER(v8); HX_MARK_MEMBER(v9); HX_MARK_MEMBER(v10); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7,t8 __8,t9 __9,t10 __10) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7),v8(__8),v9(__9),v10(__10) {}
#define HX_BEGIN_LOCAL_FUNC_S12(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7;t8 v8;t9 v9;t10 v10;t11 v11; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); HX_MARK_MEMBER(v8); HX_MARK_MEMBER(v9); HX_MARK_MEMBER(v10); HX_MARK_MEMBER(v11); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7,t8 __8,t9 __9,t10 __10,t11 __11) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7),v8(__8),v9(__9),v10(__10),v11(__11) {}
#define HX_BEGIN_LOCAL_FUNC_S13(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11,t12,v12) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7;t8 v8;t9 v9;t10 v10;t11 v11;t12 v12; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); HX_MARK_MEMBER(v8); HX_MARK_MEMBER(v9); HX_MARK_MEMBER(v10); HX_MARK_MEMBER(v11); HX_MARK_MEMBER(v12); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7,t8 __8,t9 __9,t10 __10,t11 __11,t12 __12) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7),v8(__8),v9(__9),v10(__10),v11(__11),v12(__12) {}
#define HX_BEGIN_LOCAL_FUNC_S14(SUPER,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11,t12,v12,t13,v13) \
   struct name : public SUPER { \
   t0 v0;t1 v1;t2 v2;t3 v3;t4 v4;t5 v5;t6 v6;t7 v7;t8 v8;t9 v9;t10 v10;t11 v11;t12 v12;t13 v13; \
   void __Mark(HX_MARK_PARAMS) { DoMarkThis(HX_MARK_ARG); HX_MARK_MEMBER(v0); HX_MARK_MEMBER(v1); HX_MARK_MEMBER(v2); HX_MARK_MEMBER(v3); HX_MARK_MEMBER(v4); HX_MARK_MEMBER(v5); HX_MARK_MEMBER(v6); HX_MARK_MEMBER(v7); HX_MARK_MEMBER(v8); HX_MARK_MEMBER(v9); HX_MARK_MEMBER(v10); HX_MARK_MEMBER(v11); HX_MARK_MEMBER(v12); HX_MARK_MEMBER(v13); } \
   name(t0 __0,t1 __1,t2 __2,t3 __3,t4 __4,t5 __5,t6 __6,t7 __7,t8 __8,t9 __9,t10 __10,t11 __11,t12 __12,t13 __13) : v0(__0),v1(__1),v2(__2),v3(__3),v4(__4),v5(__5),v6(__6),v7(__7),v8(__8),v9(__9),v10(__10),v11(__11),v12(__12),v13(__13) {}


#define HX_END_LOCAL_FUNC0(ret) HX_DYNAMIC_CALL0(ret,run) };

#define HX_END_LOCAL_FUNC1(ret) HX_DYNAMIC_CALL1(ret,run) };
#define HX_END_LOCAL_FUNC2(ret) HX_DYNAMIC_CALL2(ret,run) };
#define HX_END_LOCAL_FUNC3(ret) HX_DYNAMIC_CALL3(ret,run) };
#define HX_END_LOCAL_FUNC4(ret) HX_DYNAMIC_CALL4(ret,run) };
#define HX_END_LOCAL_FUNC5(ret) HX_DYNAMIC_CALL5(ret,run) };
#define HX_END_LOCAL_FUNC6(ret) HX_DYNAMIC_CALL6(ret,run) };
#define HX_END_LOCAL_FUNC7(ret) HX_DYNAMIC_CALL7(ret,run) };
#define HX_END_LOCAL_FUNC8(ret) HX_DYNAMIC_CALL8(ret,run) };
#define HX_END_LOCAL_FUNC9(ret) HX_DYNAMIC_CALL9(ret,run) };
#define HX_END_LOCAL_FUNC10(ret) HX_DYNAMIC_CALL10(ret,run) };
#define HX_END_LOCAL_FUNC11(ret) HX_DYNAMIC_CALL11(ret,run) };
#define HX_END_LOCAL_FUNC12(ret) HX_DYNAMIC_CALL12(ret,run) };
#define HX_END_LOCAL_FUNC13(ret) HX_DYNAMIC_CALL13(ret,run) };
#define HX_END_LOCAL_FUNC14(ret) HX_DYNAMIC_CALL14(ret,run) };

// For compatibility until next version of haxe is released
#define HX_BEGIN_LOCAL_FUNC0(name) \
      HX_BEGIN_LOCAL_FUNC_S0(hx::LocalFunc,name)

#define HX_BEGIN_LOCAL_FUNC1(name,t0,v0) \
      HX_BEGIN_LOCAL_FUNC_S1(hx::LocalFunc,name,t0,v0)
#define HX_BEGIN_LOCAL_FUNC2(name,t0,v0,t1,v1) \
      HX_BEGIN_LOCAL_FUNC_S2(hx::LocalFunc,name,t0,v0,t1,v1)
#define HX_BEGIN_LOCAL_FUNC3(name,t0,v0,t1,v1,t2,v2) \
      HX_BEGIN_LOCAL_FUNC_S3(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2)
#define HX_BEGIN_LOCAL_FUNC4(name,t0,v0,t1,v1,t2,v2,t3,v3) \
      HX_BEGIN_LOCAL_FUNC_S4(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3)
#define HX_BEGIN_LOCAL_FUNC5(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4) \
      HX_BEGIN_LOCAL_FUNC_S5(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4)
#define HX_BEGIN_LOCAL_FUNC6(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5) \
      HX_BEGIN_LOCAL_FUNC_S6(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5)
#define HX_BEGIN_LOCAL_FUNC7(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6) \
      HX_BEGIN_LOCAL_FUNC_S7(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6)
#define HX_BEGIN_LOCAL_FUNC8(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7) \
      HX_BEGIN_LOCAL_FUNC_S8(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7)
#define HX_BEGIN_LOCAL_FUNC9(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8) \
      HX_BEGIN_LOCAL_FUNC_S9(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8)
#define HX_BEGIN_LOCAL_FUNC10(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9) \
      HX_BEGIN_LOCAL_FUNC_S10(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9)
#define HX_BEGIN_LOCAL_FUNC11(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10) \
      HX_BEGIN_LOCAL_FUNC_S11(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10)
#define HX_BEGIN_LOCAL_FUNC12(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11) \
      HX_BEGIN_LOCAL_FUNC_S12(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11)
#define HX_BEGIN_LOCAL_FUNC13(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11,t12,v12) \
      HX_BEGIN_LOCAL_FUNC_S13(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11,t12,v12)
#define HX_BEGIN_LOCAL_FUNC14(name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11,t12,v12,t13,v13) \
      HX_BEGIN_LOCAL_FUNC_S14(hx::LocalFunc,name,t0,v0,t1,v1,t2,v2,t3,v3,t4,v4,t5,v5,t6,v6,t7,v7,t8,v8,t9,v9,t10,v10,t11,v11,t12,v12,t13,v13)


#define HX_DECLARE_DYNAMIC_FUNCTIONS \
  inline Dynamic operator()() { CheckFPtr(); return mPtr->__run(); } \
   inline Dynamic operator()(const Dynamic &inArg0) { CheckFPtr(); return mPtr->__run(inArg0); } \
   inline Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1) { CheckFPtr(); return mPtr->__run(inArg0,inArg1); } \
   inline Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2) { CheckFPtr(); return mPtr->__run(inArg0,inArg1,inArg2); } \
   inline Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3) { CheckFPtr(); return mPtr->__run(inArg0,inArg1,inArg2,inArg3); } \
   inline Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4) { CheckFPtr(); return mPtr->__run(inArg0,inArg1,inArg2,inArg3,inArg4); } \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17,const Dynamic &inArg18); \
   Dynamic operator()(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9,const Dynamic &inArg10,const Dynamic &inArg11,const Dynamic &inArg12,const Dynamic &inArg13,const Dynamic &inArg14,const Dynamic &inArg15,const Dynamic &inArg16,const Dynamic &inArg17,const Dynamic &inArg18,const Dynamic &inArg19); \
 



namespace hx {
extern void SetTopOfStack(int *inTopOfStack,bool);
}
#define HX_TOP_OF_STACK \
		int t0 = 99; \
		hx::SetTopOfStack(&t0,false);

#ifdef ANDROID
// Java Main....
#include <jni.h>
#include <hx/Thread.h>
#include <android/log.h>

#ifdef __GNUC__
 #define GCC_EXTRA __attribute__ ((visibility("default")))
#else
 #define GCC_EXTRA
#endif

#define HX_BEGIN_MAIN \
extern "C" GCC_EXTRA JNIEXPORT void JNICALL Java_org_haxe_HXCPP_main(JNIEnv * env) { \
	HX_TOP_OF_STACK \
        try { \
	hx::Boot(); \
	__boot_all();


#define HX_END_MAIN \
        } catch (Dynamic e) { \
	  __hx_dump_stack(); \
          __android_log_print(ANDROID_LOG_ERROR, "Exception", "%s", e->toString().__CStr()); \
        }\
}

#elif defined(HX_WIN_MAIN)


#define HX_BEGIN_MAIN \
extern "C" int __stdcall MessageBoxA(void *,const char *,const char *,int); \
\
int __stdcall WinMain( void * hInstance, void * hPrevInstance, const char *lpCmdLine, int nCmdShow) \
{ \
	HX_TOP_OF_STACK \
	hx::Boot(); \
	try{ \
		__boot_all();

#define HX_END_MAIN \
	} \
	catch (Dynamic e){ \
		__hx_dump_stack(); \
		MessageBoxA(0,  e->toString().__CStr(), "Error", 0); \
	} \
	return 0; \
}


#else
// Console Main ...

#define HX_BEGIN_MAIN \
\
int main(int argc,char **argv){ \
	HX_TOP_OF_STACK \
	hx::Boot(); \
	try{ \
		__boot_all();

#define HX_END_MAIN \
	} \
	catch (Dynamic e){ \
		__hx_dump_stack(); \
		printf("Error : %s\n",e->toString().__CStr()); \
	} \
	return 0; \
}

#endif


// Run as library
#define HX_BEGIN_LIB_MAIN \
extern "C" {\
\
void __hxcpp_lib_main() \
{ \
	HX_TOP_OF_STACK \
	hx::Boot(); \
	__boot_all();

#define HX_END_LIB_MAIN \
} }



#endif


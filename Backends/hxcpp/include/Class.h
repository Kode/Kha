#ifndef HX_CLASS_H
#define HX_CLASS_H


namespace hx
{
// --- hxClassOf --------------------------------------------------------------
//
// Gets the class definition that relates to a specific type.
// Most classes have their own class data, by the standard types (non-classes)
//  use the template traits to get the class


template<typename T> 
inline Class &ClassOf() { typedef typename T::Obj Obj; return Obj::__SGetClass(); }

template<> 
inline Class &ClassOf<int>() { return GetIntClass(); }

template<> 
inline Class &ClassOf<double>() { return GetFloatClass(); }

template<> 
inline Class &ClassOf<bool>() { return GetBoolClass(); }

template<> 
inline Class &ClassOf<null>() { return GetVoidClass(); }

template<> 
inline Class &ClassOf<String>() { return GetStringClass(); }

} // end namespace hx


// --- Class_obj --------------------------------------------------------------------
//
// The Class_obj provides the type information required by the Reflect and type APIs.

namespace hx
{
typedef Dynamic (*ConstructEmptyFunc)();
typedef Dynamic (*ConstructArgsFunc)(DynamicArray inArgs);
typedef Dynamic (*ConstructEnumFunc)(String inName,DynamicArray inArgs);
typedef void (*MarkFunc)(HX_MARK_PARAMS);
typedef bool (*CanCastFunc)(hx::Object *inPtr);
}

inline bool operator!=(hx::ConstructEnumFunc inFunc,const null &inNull) { return inFunc!=0; }

class Class_obj : public hx::Object
{
public:
   Class_obj() : mSuper(0) { };
   Class_obj(const String &inClassName, String inStatics[], String inMembers[],
             hx::ConstructEmptyFunc inConstructEmpty, hx::ConstructArgsFunc inConstructArgs,
             Class *inSuperClass, hx::ConstructEnumFunc inConstructEnum,
             hx::CanCastFunc inCanCast, hx::MarkFunc inMarkFunc);

   String __ToString() const;

   void __Mark(HX_MARK_PARAMS);

   void MarkStatics(HX_MARK_PARAMS);


   // the "Class class"
   Class              __GetClass() const;
   static Class      & __SGetClass();
	static void       __boot();

   Dynamic __Field(const String &inString);

   Dynamic __SetField(const String &inString,const Dynamic &inValue);

   bool __HasField(const String &inString);


   int __GetType() const { return vtObject; }

   bool __IsEnum();

	hx::CanCastFunc     CanCast;


   Array<String>      GetInstanceFields();
   Array<String>      GetClassFields();
   Class              GetSuper();
   static Class       Resolve(String inName);

   Class              *mSuper;
   String             mName;
	hx::ConstructArgsFunc  mConstructArgs;
	hx::ConstructEmptyFunc mConstructEmpty;
	hx::ConstructEnumFunc  mConstructEnum;
	hx::MarkFunc           mMarkFunc;
   Array<String>      mStatics;
   Array<String>      mMembers;
};

typedef hx::ObjectPtr<Class_obj> Class;

void __hxcpp_boot_std_classes();


// --- All classes should be registered with this function via the "__boot" method

namespace hx
{
Class RegisterClass(const String &inClassName, CanCastFunc inCanCast,
                    String inStatics[], String inMembers[],
                    ConstructEmptyFunc inConstructEmpty, ConstructArgsFunc inConstructArgs,
                    Class *inSuperClass, ConstructEnumFunc inConst=0, MarkFunc inMarkFunc=0);

template<typename T>
inline bool TCanCast(hx::Object *inPtr)
{
	return inPtr && ( dynamic_cast<T *>(inPtr->__GetRealObject()) || inPtr->__ToInterface(typeid(T)) );
}

}


#endif

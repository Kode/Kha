#ifndef HX_DYNAMIC_H
#define HX_DYNAMIC_H

// --- Dynamic ---------------------------------------------------------------
//
// The Dynamic class views all classes through the hx::Object interface, and
//  provides generic access to its pointer.
// It uses dynamic_cast to provide strongly-typed access to the real class.



class Dynamic : public hx::ObjectPtr<hx::Object>
{
   typedef  hx::ObjectPtr<hx::Object> super;

public:

   Dynamic() {};
   Dynamic(int inVal);
   Dynamic(const cpp::CppInt32__ &inVal);
   Dynamic(bool inVal);
   Dynamic(double inVal);
   Dynamic(hx::Object *inObj) : super(inObj) { }
   Dynamic(const String &inString);
   Dynamic(const null &inNull) : super(0) { }
   Dynamic(const Dynamic &inRHS) : super(inRHS.mPtr) { }
   explicit Dynamic(const HX_CHAR *inStr);

    void Set(bool inVal);
    void Set(int inVal);
    void Set(double inVal);

   inline operator double () const { return mPtr ? mPtr->__ToDouble() : 0.0; }
   inline operator int () const { return mPtr ? mPtr->__ToInt() : 0; }
   inline operator unsigned char () const { return mPtr ? mPtr->__ToInt() : 0; }
   inline operator bool() const { return mPtr && mPtr->__ToInt(); }
   inline bool operator !() const { return !mPtr || !mPtr->__ToInt(); }

   hx::IndexRef operator[](int inIndex);
   inline Dynamic __get(int inIndex) const { return mPtr->__GetItem(inIndex); }

   template<typename SOURCE_>
   Dynamic(const hx::ObjectPtr<SOURCE_> &inObjectPtr) :
          hx::ObjectPtr<hx::Object>(inObjectPtr.mPtr) { }

   Dynamic Default(const Dynamic &inDef) { return mPtr ? *this : inDef; }

   template<typename RETURN_>
   RETURN_ Cast() const { return RETURN_(*this); }

   template<typename CLASS_>
   bool IsClass() { return CLASS_(mPtr).mPtr; }

	static void __boot();

	inline bool IsNumeric() const
	{
		if (!mPtr) return false;
		int t = mPtr->__GetType();
		return t==vtInt || t==vtFloat;
	}


   int Compare(const Dynamic &inRHS) const
   {
      if (mPtr==inRHS.mPtr) return 0;
      if (mPtr==0) return -1;
      if (inRHS.mPtr==0) return -1;
      return mPtr->__Compare(inRHS.mPtr);
   }

   bool operator==(const null &inRHS) const { return mPtr==0; }
   bool operator!=(const null &inRHS) const { return mPtr!=0; }

   bool operator != (const Dynamic &inRHS) const { return (Compare(inRHS) != 0); }
   bool operator != (const String &inRHS)  const { return !mPtr || ((String)(*this) != inRHS); }
   bool operator != (double inRHS)  const { return !mPtr || ((double)(*this) != inRHS); }
   bool operator != (int inRHS)  const { return !mPtr || ((double)(*this) != (double)inRHS); }
   bool operator != (bool inRHS)  const { return !mPtr || ((double)(*this) != (double)inRHS); }

   bool operator == (const Dynamic &inRHS) const
   {
      if (mPtr==inRHS.mPtr) return true;
      if (!mPtr || !inRHS.mPtr) return false;
      return mPtr->__Compare(inRHS.mPtr)==0;
   }

   #define DYNAMIC_COMPARE_OP( op ) \
      bool operator op (const String &inRHS)  const { return mPtr && ((String)(*this) op inRHS); } \
      bool operator op (double inRHS)  const { return mPtr && ((double)(*this) op inRHS); } \
      bool operator op (int inRHS)  const { return mPtr && ((double)(*this) op (double)inRHS); } \
      bool operator op (bool inRHS)  const { return mPtr && ((double)(*this) op (double)inRHS); } \

   #define DYNAMIC_COMPARE_OP_ALL( op ) \
      bool operator op (const Dynamic &inRHS) const { return mPtr && (Compare(inRHS) op 0); } \
      DYNAMIC_COMPARE_OP(op)


   DYNAMIC_COMPARE_OP( == )
   DYNAMIC_COMPARE_OP_ALL( < )
   DYNAMIC_COMPARE_OP_ALL( <= )
   DYNAMIC_COMPARE_OP_ALL( >= )
   DYNAMIC_COMPARE_OP_ALL( >  )

   template<typename T_>
   bool operator==(const hx::ObjectPtr<T_> &inRHS) const
   {
      if (mPtr==inRHS.mPtr) return true;
      if (!mPtr || !inRHS.mPtr) return false;
      return mPtr->__GetRealObject() == inRHS.mPtr->__GetRealObject();
   }

   template<typename T_>
   bool operator!=(const hx::ObjectPtr<T_> &inRHS) const
   {
      if (mPtr==inRHS.mPtr) return false;
      if (!mPtr || !inRHS.mPtr) return true;
      return mPtr->__GetRealObject() != inRHS.mPtr->__GetRealObject();
   }


   // Operator + is different, since it must consider strings too...
    Dynamic operator+(const Dynamic &inRHS) const;
   inline String operator+(const String &s) const;
    Dynamic operator+(const int &i) const;
    Dynamic operator+(const double &d) const;

   double operator%(const Dynamic &inRHS) const;
   double operator-() const { return mPtr ? - mPtr->__ToDouble() : 0.0; }
   double operator++() { double val = mPtr->__ToDouble() + 1; *this = val; return val; }
   double operator++(int) {double val = mPtr->__ToDouble(); *this = val+1; return val; }
   double operator--() { double val = mPtr->__ToDouble() - 1; *this = val; return val; }
   double operator--(int) {double val = mPtr->__ToDouble(); *this = val-1; return val; }


   #define DYNAMIC_ARITH( op ) \
      double operator op (const Dynamic &inRHS) const { return (double)(*this) op (double)inRHS; } \
      double operator op (const double &inRHS) const { return (double)(*this) op (double)inRHS; } \
      double operator op (const int &inRHS) const { return (double)(*this) op (double)inRHS; }

   DYNAMIC_ARITH( - )
   DYNAMIC_ARITH( * )
   DYNAMIC_ARITH( / )

   static void ThrowBadFunctionError();
   inline void CheckFPtr() { if (!mPtr) ThrowBadFunctionError(); }


   HX_DECLARE_DYNAMIC_FUNCTIONS;


   typedef const Dynamic &D;
};



namespace hx
{
typedef Dynamic (*MemberFunction0)(hx::Object *inObj);
typedef Dynamic (*MemberFunction1)(hx::Object *inObj,const Dynamic &inArg0);
typedef Dynamic (*MemberFunction2)(hx::Object *inObj,const Dynamic &inArg0,const Dynamic &inArg1);
typedef Dynamic (*MemberFunction3)(hx::Object *inObj,const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2);
typedef Dynamic (*MemberFunction4)(hx::Object *inObj,const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3);
typedef Dynamic (*MemberFunction5)(hx::Object *inObj,const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4);
typedef Dynamic (*MemberFunctionVar)(hx::Object *inObj,const Array<Dynamic> &inArgs);

typedef Dynamic (*StaticFunction0)();
typedef Dynamic (*StaticFunction1)(const Dynamic &inArg0);
typedef Dynamic (*StaticFunction2)(const Dynamic &inArg0,const Dynamic &inArg1);
typedef Dynamic (*StaticFunction3)(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2);
typedef Dynamic (*StaticFunction4)(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3);
typedef Dynamic (*StaticFunction5)(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4);
typedef Dynamic (*StaticFunctionVar)(const Array<Dynamic> &inArgs);


Dynamic CreateMemberFunction0(hx::Object *, MemberFunction0);
Dynamic CreateMemberFunction1(hx::Object *, MemberFunction1);
Dynamic CreateMemberFunction2(hx::Object *, MemberFunction2);
Dynamic CreateMemberFunction3(hx::Object *, MemberFunction3);
Dynamic CreateMemberFunction4(hx::Object *, MemberFunction4);
Dynamic CreateMemberFunction5(hx::Object *, MemberFunction5);
Dynamic CreateMemberFunctionVar(hx::Object *, MemberFunctionVar,int inN);

Dynamic CreateStaticFunction0(StaticFunction0);
Dynamic CreateStaticFunction1(StaticFunction1);
Dynamic CreateStaticFunction2(StaticFunction2);
Dynamic CreateStaticFunction3(StaticFunction3);
Dynamic CreateStaticFunction4(StaticFunction4);
Dynamic CreateStaticFunction5(StaticFunction5);
Dynamic CreateStaticFunctionVar(StaticFunctionVar,int inN);


}







template<>
inline int Dynamic::Cast<int>() const { return mPtr ? mPtr->__ToInt() : 0; }
template<>
inline bool Dynamic::Cast<bool>() const { return mPtr ? mPtr->__ToInt() : 0; }
template<>
inline double Dynamic::Cast<double>() const { return mPtr ? mPtr->__ToDouble() : 0; }
template<>
inline String Dynamic::Cast<String>() const { return mPtr ? mPtr->toString() : String(null()); }



//
// Gets the class definition that relates to a specific type.
// Most classes have their own class data, by the standard types (non-classes)
//  use the template traits to get the class

namespace hx
{
Class &GetIntClass();
Class &GetFloatClass();
Class &GetBoolClass();
Class &GetVoidClass();
Class &GetStringClass();
}

template<>
inline bool Dynamic::IsClass<int>() { return mPtr && mPtr->__GetClass()==hx::GetIntClass(); }
template<>
inline bool Dynamic::IsClass<double>() { return mPtr && mPtr->__GetClass()==hx::GetFloatClass(); }
template<>
inline bool Dynamic::IsClass<bool>() { return mPtr && mPtr->__GetClass()==hx::GetBoolClass(); }
template<>
inline bool Dynamic::IsClass<null>() { return !mPtr; }
template<>
inline bool Dynamic::IsClass<String>() { return mPtr && mPtr->__GetClass()==hx::GetStringClass(); }

inline String Dynamic::operator+(const String &s) const { return Cast<String>() + s; }


inline bool operator != (double inLHS,const Dynamic &inRHS) \
   { return !inRHS.GetPtr() || (inLHS != (double)inRHS); } \
inline bool operator != (int inLHS,const Dynamic &inRHS) \
   { return !inRHS.GetPtr() || (inLHS != (double)inRHS); } \
inline bool operator != (bool inLHS,const Dynamic &inRHS) \
   { return !inRHS.GetPtr() || ((double)inLHS != (double)inRHS); }


#define COMPARE_DYNAMIC_OP( op ) \
   inline bool operator op (double inLHS,const Dynamic &inRHS) \
      { return inRHS.IsNumeric() && (inLHS op (double)inRHS); } \
   inline bool operator op (int inLHS,const Dynamic &inRHS) \
      { return inRHS.IsNumeric() && (inLHS op (double)inRHS); }

inline bool operator == (bool inLHS,const Dynamic &inRHS) \
 { return inRHS.mPtr  && inRHS.mPtr->__GetType()==vtBool && (inLHS == (bool)inRHS); }

inline bool operator < (bool inLHS,const Dynamic &inRHS) { return false; }
inline bool operator <= (bool inLHS,const Dynamic &inRHS) { return false; }
inline bool operator >= (bool inLHS,const Dynamic &inRHS) { return false; }
inline bool operator > (bool inLHS,const Dynamic &inRHS) { return false; }

COMPARE_DYNAMIC_OP( == )
COMPARE_DYNAMIC_OP( < )
COMPARE_DYNAMIC_OP( <= )
COMPARE_DYNAMIC_OP( >= )
COMPARE_DYNAMIC_OP( >  )


#define ARITH_DYNAMIC( op ) \
   inline double operator op (const double &inLHS,const Dynamic &inRHS) { return inLHS op (double)inRHS;} \
   inline double operator op (const int &inLHS,const Dynamic &inRHS) { return inLHS op (double)inRHS; } \

ARITH_DYNAMIC( - )
ARITH_DYNAMIC( + )
ARITH_DYNAMIC( / )
ARITH_DYNAMIC( * )

double operator%(const int &inLHS,const Dynamic &inRHS);
double operator%(const double &inLHS,const Dynamic &inRHS);


#endif

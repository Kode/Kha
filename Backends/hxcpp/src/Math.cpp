#include <hxcpp.h>
#include <limits>
#include <hxMath.h>


#include <stdlib.h>
#include <time.h>
#ifndef HX_WINDOWS
#include <unistd.h>
#include <sys/time.h>
#else
#include <process.h>
#endif


// -------- Math ---------------------------------------

using namespace hx;


bool Math_obj::isNaN(double inX)
  { return inX!=inX; }
bool Math_obj::isFinite(double inX)
  { return !isNaN(inX) && inX!=NEGATIVE_INFINITY && inX!=POSITIVE_INFINITY; }

double Math_obj::NaN = std::numeric_limits<double>::quiet_NaN();
double Math_obj::NEGATIVE_INFINITY = -std::numeric_limits<double>::infinity();
double Math_obj::PI = 3.1415926535897932385;
double Math_obj::POSITIVE_INFINITY = std::numeric_limits<double>::infinity();

#ifdef min
#undef min
#endif

#ifdef max
#undef max
#endif

STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,floor,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,ceil,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,round,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC0(Math_obj,random,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,sqrt,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,cos,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,sin,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,tan,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC2(Math_obj,atan2,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,abs,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC2(Math_obj,pow,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,log,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC2(Math_obj,min,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC2(Math_obj,max,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,atan,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,asin,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,acos,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,exp,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,isNaN,return);
STATIC_HX_DEFINE_DYNAMIC_FUNC1(Math_obj,isFinite,return);

Dynamic Math_obj::__Field(const String &inString)
{
   if (inString==HX_CSTRING("floor")) return floor_dyn();
   if (inString==HX_CSTRING("ceil")) return ceil_dyn();
   if (inString==HX_CSTRING("round")) return round_dyn();
   if (inString==HX_CSTRING("random")) return random_dyn();
   if (inString==HX_CSTRING("sqrt")) return sqrt_dyn();
   if (inString==HX_CSTRING("cos")) return cos_dyn();
   if (inString==HX_CSTRING("sin")) return sin_dyn();
   if (inString==HX_CSTRING("tan")) return tan_dyn();
   if (inString==HX_CSTRING("atan2")) return atan2_dyn();
   if (inString==HX_CSTRING("abs")) return abs_dyn();
   if (inString==HX_CSTRING("pow")) return pow_dyn();
   if (inString==HX_CSTRING("log")) return log_dyn();
   if (inString==HX_CSTRING("min")) return min_dyn();
   if (inString==HX_CSTRING("max")) return max_dyn();
   if (inString==HX_CSTRING("atan")) return max_dyn();
   if (inString==HX_CSTRING("acos")) return max_dyn();
   if (inString==HX_CSTRING("asin")) return max_dyn();
   if (inString==HX_CSTRING("exp")) return max_dyn();
   if (inString==HX_CSTRING("isNaN")) return isNaN_dyn();
   if (inString==HX_CSTRING("isFinite")) return isFinite_dyn();
   return null();
}

void Math_obj::__GetFields(Array<String> &outFields) { }

static String sMathFields[] = {
   HX_CSTRING("floor"),
   HX_CSTRING("ceil"),
   HX_CSTRING("round"),
   HX_CSTRING("random"),
   HX_CSTRING("sqrt"),
   HX_CSTRING("cos"),
   HX_CSTRING("sin"),
   HX_CSTRING("tan"),
   HX_CSTRING("atan2"),
   HX_CSTRING("abs"),
   HX_CSTRING("pow"),
   HX_CSTRING("atan"),
   HX_CSTRING("acos"),
   HX_CSTRING("asin"),
   HX_CSTRING("exp"),
   HX_CSTRING("isFinite"),
   String(null()) };


Dynamic Math_obj::__SetField(const String &inString,const Dynamic &inValue) { return null(); }

Dynamic Math_obj::__CreateEmpty() { return new Math_obj; }

Class Math_obj::__mClass;

/*
Class &Math_obj::__SGetClass() { return __mClass; }
Class Math_obj::__GetClass() const { return __mClass; }
bool Math_obj::__Is(hxObject *inObj) const { return dynamic_cast<OBJ_ *>(inObj)!=0; } \
*/


void Math_obj::__boot()
{
   Static(Math_obj::__mClass) = hx::RegisterClass(HX_CSTRING("Math"),TCanCast<Math_obj>,sMathFields,sNone, &__CreateEmpty,0 , 0 );

	unsigned int t;
#ifdef HX_WINDOWS
	t = clock();
	int pid = _getpid();
#else
	int pid = getpid();
	struct timeval tv;
	gettimeofday(&tv,NULL);
	t = tv.tv_sec * 1000000 + tv.tv_usec;
#endif	

  srand(t ^ (pid | (pid << 16)));
  rand();
}

namespace hx
{

double DoubleMod(double inLHS,double inRHS)
{
   if (inRHS==0) return 0;
   double divs = inLHS/inRHS;
   double lots = divs<0 ? ::floor(-divs) : ::floor(divs);
   return inLHS - lots*inRHS;
}

}



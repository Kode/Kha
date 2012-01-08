#ifndef HX_MATH
#define HX_MATH

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <math.h>
#include <stdlib.h>

class Math_obj : public hx::Object
{
public:
   typedef hx::Object super;
   typedef Math_obj OBJ_;
   HX_DO_RTTI;
   void __construct();
   static Dynamic __CreateEmpty();
   static void __boot();


   inline static int floor(double inX) { return __int__(::floor(inX)); }
   inline static int ceil(double inX) { return __int__(::ceil(inX)); }
   inline static int round(double inX) { return floor(inX+0.5); }
   inline static double random() { return (double)rand()/RAND_MAX; }
   inline static double sqrt(double inX) { return ::sqrt(inX); }
   inline static double cos(double inX) { return ::cos(inX); }
   inline static double sin(double inX) { return ::sin(inX); }
   inline static double tan(double inX) { return ::tan(inX); }
   inline static double atan2(double inY,double inX) { return ::atan2(inY,inX); }
   inline static double abs(double inX) { return ::fabs(inX); }
   inline static double pow(double inA,double inB) { return ::pow(inA,inB); }
   inline static double log(double inA) { return ::log(inA); }
   inline static double max(double inA,double inB) { return inA>inB ? inA:inB; }
   inline static double min(double inA,double inB) { return inA<inB ? inA:inB; }

   inline static double atan(double inA) { return ::atan(inA); }
   inline static double asin(double inA) { return ::asin(inA); }
   inline static double acos(double inA) { return ::acos(inA); }
   inline static double exp(double inA) { return ::exp(inA); }


   static bool isNaN(double inX);
   static bool isFinite(double inX);


   static Dynamic floor_dyn();
   static Dynamic ceil_dyn();
   static Dynamic round_dyn();
   static Dynamic random_dyn();
   static Dynamic sqrt_dyn();
   static Dynamic cos_dyn();
   static Dynamic sin_dyn();
   static Dynamic tan_dyn();
   static Dynamic atan2_dyn();
   static Dynamic abs_dyn();
   static Dynamic pow_dyn();
   static Dynamic log_dyn();
   static Dynamic min_dyn();
   static Dynamic max_dyn();
   static Dynamic atan_dyn();
   static Dynamic asin_dyn();
   static Dynamic acos_dyn();
   static Dynamic exp_dyn();
   static Dynamic isNaN_dyn();
   static Dynamic isFinite_dyn();

   static double NaN;
   static double PI;
   static double NEGATIVE_INFINITY;
   static double POSITIVE_INFINITY;
};

typedef hx::ObjectPtr<Math_obj> Math;


#endif

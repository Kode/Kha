#ifndef HX_FUNCTIONS_H
#define HX_FUNCTIONS_H
#include <hxcpp.h>

namespace hx
{
   struct LocalFunc : public hx::Object
   {
      int __GetType() const { return vtFunction; }
      inline void DoMarkThis(HX_MARK_PARAMS) { }
   };

   struct LocalThisFunc : public LocalFunc
   {
      Dynamic __this;
		void __SetThis(Dynamic inThis) { __this = inThis; }
      inline void DoMarkThis(HX_MARK_PARAMS) { HX_MARK_MEMBER(__this); }
   };

}

#endif

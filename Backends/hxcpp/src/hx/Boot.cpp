#include <hxcpp.h>
#include <hxMath.h>

namespace hx
{

void Boot()
{
   //__hxcpp_enable(false);

	#ifdef GPH
	 setvbuf( stdout , 0 , _IONBF , 0 );
	 setvbuf( stderr , 0 , _IONBF , 0 );
	#endif


   Object::__boot();
	Dynamic::__boot();
	Class_obj::__boot();
	String::__boot();
	Anon_obj::__boot();
	ArrayBase::__boot();
	EnumBase_obj::__boot();
   Math_obj::__boot();
}

}



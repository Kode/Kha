/*
 Use the "hxRunLibrary" code to run the static version of the code
*/
#include <hxcpp.h>
#define INT_MIN     (-2147483647 - 1) /* minimum (signed) int value */
#define INT_MAX       2147483647    /* maximum (signed) int value */
#include <string>


extern "C"
{
void __hxcpp_lib_main();
int std_register_prims();
int regexp_register_prims();
int zlib_register_prims();


#ifdef HX_UTF8_STRINGS
std::string sgResultBuffer;
#else
std::wstring sgResultBuffer;
#endif

const HX_CHAR *hxRunLibrary()
{
   //std_register_prims();
   //regexp_register_prims();
   //zlib_register_prims();
    
   try { 
      __hxcpp_lib_main();
      return 0;
   }
   catch ( Dynamic d ) {
      sgResultBuffer = d->toString().__s;
      return sgResultBuffer.c_str();
   }
}



}

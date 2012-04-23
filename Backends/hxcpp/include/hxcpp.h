#ifndef HXCPP_H
#define HXCPP_H

// Standard headers ....

// Windows hack
#define NOMINMAX


#ifdef _MSC_VER
#include <typeinfo.h>
#else
#include <typeinfo>
#include <stdint.h>
using std::type_info;
typedef  int64_t  __int64;
#endif



#include <string.h>

#define HX_UTF8_STRINGS

#include <wchar.h>

#ifdef HX_LINUX
#include <unistd.h>
#include <cstdio>
#endif




// Some compilers are over-enthusiastic about what they #define ...
#ifdef NULL
#undef NULL
#endif

#ifdef assert
#undef assert
#endif


#ifdef HXCPP_SET_PROP
#define HXCPP_EXTRA_FIELD_DECL ,bool inCallProp
#define HXCPP_EXTRA_FIELD_CALL ,inCallProp
#define HXCPP_EXTRA_FIELD_TRUE ,true
#else
#define HXCPP_EXTRA_FIELD_DECL
#define HXCPP_EXTRA_FIELD_CALL
#define HXCPP_EXTRA_FIELD_TRUE
#endif



typedef char HX_CHAR;

#define HX_STRINGI(s,len) ::String( ("\xff\xff\xff\xff" s) + 4 ,len)

#define HX_STRI(s) HX_STRINGI(s,sizeof(s)/sizeof(HX_CHAR)-1)

#define HX_CSTRING(x) HX_STRI(x)

#define HX_CSTRING2(wide,len,utf8) HX_STRI(utf8)

#define HX_FIELD_EQ(name,field) !memcmp(name.__s, field, sizeof(field)/sizeof(char))





#ifdef HXCPP_DEBUG

struct __AutoStack
{
   __AutoStack(const char *inName);
   ~__AutoStack();
};
void __hx_set_source_pos(const char *inFile, int inLine);

#define HX_SOURCE_PUSH(name) __AutoStack __autostack(name);
#define HX_SOURCE_POS(a,b) __hx_set_source_pos(a,b);


#else

#define HX_SOURCE_PUSH(x)
#define HX_SOURCE_POS(FILE,LINE)

#endif

void __hx_dump_stack();









#ifdef BIG_ENDIAN
#undef BIG_ENDIAN

  #ifndef HX_LITTLE_ENDIAN
  #define HX_LITTLE_ENDIAN 0
  #endif
#endif

#ifdef __BIG_ENDIAN__
  #ifndef HX_LITTLE_ENDIAN
  #define HX_LITTLE_ENDIAN 0
  #endif
#endif

#ifdef LITTLE_ENDIAN
#undef LITTLE_ENDIAN

  #ifndef HX_LITTLE_ENDIAN
  #define HX_LITTLE_ENDIAN 1
  #endif
#endif

#ifdef __LITTLE_ENDIAN__
  #ifndef HX_LITTLE_ENDIAN
  #define HX_LITTLE_ENDIAN 1
  #endif
#endif

#ifndef HX_LITTLE_ENDIAN
#define HX_LITTLE_ENDIAN 1
#endif


#pragma warning(disable:4251)
#pragma warning(disable:4800)

#if defined(_MSC_VER) && _MSC_VER < 1201
#error MSVC 7.1 does not support template specialization and is not supported by HXCPP
#endif


// HXCPP includes...

// Basic mapping from haxe -> c++

typedef int Int;
typedef bool Bool;

#ifdef HXCPP_FLOAT32
typedef float Float;
#else
typedef double Float;
#endif

// --- Forward decalarations --------------------------------------------

namespace haxe { namespace io { typedef unsigned char Unsigned_char__; } }
namespace cpp { class CppInt32__; }
namespace hx { class Object; }
namespace hx { class FieldMap; }
namespace hx { class FieldRef; }
namespace hx { class IndexRef; }
namespace hx { template<typename O> class ObjectPtr; }
template<typename ELEM_> class Array_obj;
template<typename ELEM_> class Array;
class Class_obj;
typedef hx::ObjectPtr<Class_obj> Class;
class Dynamic;
class String;

// Use an external routine to throw to avoid sjlj overhead on iphone.
namespace hx { extern Dynamic Throw(Dynamic inDynamic); }
namespace hx { extern void CriticalError(const String &inError); }
namespace hx { extern String sNone[]; }
void __hxcpp_check_overflow(int inVal);

namespace hx { class MarkContext; }



// The order of these includes has been chosen to minimize forward declarations.
// You should not include the individual files, just this one.
#include <hx/Macros.h>
#include <hx/ErrorCodes.h>
#include <hx/GC.h>
#include "null.h"
#include <hx/Object.h>
#include <cpp/CppInt32__.h>
#include "hxString.h"
#include "Dynamic.h"
// This needs to "see" other declarations ...
#include <hx/GCTemplates.h>
#include <hx/FieldRef.h>
#include <hx/Anon.h>
#include "Array.h"
#include "Class.h"
#include "Enum.h"
#include <hx/Interface.h>
#include <hx/StdLibs.h>
#include <hx/Operators.h>
#include <hx/Functions.h>

#include <hx/Boot.h>

#include <hx/Undefine.h>

#endif

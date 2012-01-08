#ifndef HX_STDLIBS_H
#define HX_STDLIBS_H

// --- Resource -------------------------------------------------------------

namespace hx
{
struct Resource
{
   String        mName;
   int           mDataLength;
   unsigned char *mData;

   bool operator<(const Resource &inRHS) const { return mName < inRHS.mName; }
};

Resource *GetResources();

void RegisterResources(hx::Resource *inResources);
} // end namespace hx

Array<String>        __hxcpp_resource_names();
String               __hxcpp_resource_string(String inName);
Array<unsigned char> __hxcpp_resource_bytes(String inName);




// System access
Array<String>  __get_args();
double         __time_stamp();
void           __hxcpp_print(Dynamic &inV);
void           __hxcpp_println(Dynamic &inV);
void           __trace(Dynamic inPtr, Dynamic inData);


// --- Casting/Converting ---------------------------------------------------------
bool  __instanceof(const Dynamic &inValue, const Dynamic &inType);
int   __int__(double x);
bool  __hxcpp_same_closure(Dynamic &inF1,Dynamic &inF2);
Dynamic __hxcpp_parse_int(const String &inString);
double __hxcpp_parse_float(const String &inString);
Dynamic __hxcpp_create_var_args(Dynamic &inArrayFunc);

// --- CFFI helpers ------------------------------------------------------------------

// Used for accessing object fields by integer ID, rather than string ID.
// Used mainly for neko ndll interaction.
int           __hxcpp_field_to_id( const char *inField );
const String &__hxcpp_field_from_id( int f );
int           __hxcpp_register_prim(const HX_CHAR *inName,void *inFunc);

// Get function pointer from dll file
Dynamic __loadprim(String inLib, String inPrim,int inArgCount);
// Loading functions via name (dummy return value)



// --- haxe.io.BytesData ----------------------------------------------------------------

void __hxcpp_bytes_of_string(Array<unsigned char> &outBytes,const String &inString);
void __hxcpp_string_of_bytes(Array<unsigned char> &inBytes,String &outString,int pos,int len);
// UTF8 processing
String __hxcpp_char_array_to_utf8_string(Array<int> &inChars,int inFirst=0, int inLen=-1);
Array<int> __hxcpp_utf8_string_to_char_array(String &inString);
String __hxcpp_char_bytes_to_utf8_string(String &inBytes);
String __hxcpp_utf8_string_to_char_bytes(String &inUTF8);


// --- IntHash ----------------------------------------------------------------------

hx::Object   *__int_hash_create();
void          __int_hash_set(Dynamic inHash,int inKey,const Dynamic &value);
Dynamic       __int_hash_get(Dynamic inHash,int inKey);
bool          __int_hash_exists(Dynamic inHash,int inKey);
bool          __int_hash_remove(Dynamic inHash,int inKey);
Dynamic       __int_hash_keys(Dynamic inHash);
Dynamic       __int_hash_values(Dynamic inHash);


// --- Date --------------------------------------------------------------------------

double __hxcpp_new_date(int inYear,int inMonth,int inDay,int inHour, int inMin, int inSeconds);
int    __hxcpp_get_hours(double inSeconds);
int    __hxcpp_get_minutes(double inSeconds);
int    __hxcpp_get_seconds(double inSeconds);
int    __hxcpp_get_year(double inSeconds);
int    __hxcpp_get_month(double inSeconds);
int    __hxcpp_get_date(double inSeconds);
int    __hxcpp_get_day(double inSeconds);
String __hxcpp_to_string(double inSeconds);
double __hxcpp_date_now();

// --- vm/threading --------------------------------------------------------------------

Dynamic __hxcpp_thread_create(Dynamic inFunc);
Dynamic __hxcpp_thread_current();
void    __hxcpp_thread_send(Dynamic inThread, Dynamic inMessage);
Dynamic __hxcpp_thread_read_message(bool inBlocked);

Dynamic __hxcpp_mutex_create();
void    __hxcpp_mutex_acquire(Dynamic);
bool    __hxcpp_mutex_try(Dynamic);
void    __hxcpp_mutex_release(Dynamic);


Dynamic __hxcpp_lock_create();
bool    __hxcpp_lock_wait(Dynamic inlock,double inTime);
void    __hxcpp_lock_release(Dynamic inlock);

Dynamic __hxcpp_deque_create();
void    __hxcpp_deque_add(Dynamic q,Dynamic inVal);
void    __hxcpp_deque_push(Dynamic q,Dynamic inVal);
Dynamic __hxcpp_deque_pop(Dynamic q,bool block);

Dynamic __hxcpp_tls_get(int inID);
void    __hxcpp_tls_set(int inID,Dynamic inVal);

int __hxcpp_obj_id(Dynamic inObj);


// --- Memory --------------------------------------------------------------------------

extern unsigned char *__hxcpp_memory;

inline void __hxcpp_memory_clear( ) { __hxcpp_memory = 0; }
inline void __hxcpp_memory_select( Array<unsigned char> &inBuffer )
   { __hxcpp_memory= (unsigned char *)inBuffer->GetBase(); }

inline int __hxcpp_memory_get_byte(int addr) { return __hxcpp_memory[addr]; }
inline double __hxcpp_memory_get_double(int addr) { return *(double *)(__hxcpp_memory+addr); }
inline double __hxcpp_memory_get_float(int addr) { return *(float *)(__hxcpp_memory+addr); }
inline int __hxcpp_memory_get_i32(int addr) { return *(int *)(__hxcpp_memory+addr); }
inline int __hxcpp_memory_get_ui16(int addr) { return *(unsigned short *)(__hxcpp_memory+addr); }

inline void __hxcpp_memory_set_byte(int addr,int v) { __hxcpp_memory[addr] = v; }
inline void __hxcpp_memory_set_double(int addr,double v) { *(double *)(__hxcpp_memory+addr) = v; }
inline void __hxcpp_memory_set_float(int addr,double v) { *(float *)(__hxcpp_memory+addr) = v; }
inline void __hxcpp_memory_set_i16(int addr,int v) { *(short *)(__hxcpp_memory+addr) = v; }
inline void __hxcpp_memory_set_i32(int addr,int v) { *(int *)(__hxcpp_memory+addr) = v; }



#endif

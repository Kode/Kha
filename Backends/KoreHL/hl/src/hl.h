/*
 * Copyright (C)2005-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
#ifndef HL_H
#define HL_H

/**
	Detailed documentation can be found here:
	https://github.com/HaxeFoundation/hashlink/wiki/
**/

#define HL_VERSION	0x010C00

#if defined(_WIN32)
#	define HL_WIN
#	ifndef _DURANGO
#		define HL_WIN_DESKTOP
#	endif
#endif

#if defined(__APPLE__) || defined(__MACH__) || defined(macintosh)
#include <TargetConditionals.h>
#if TARGET_OS_IOS
#define HL_IOS
#elif TARGET_OS_TV
#define HL_TVOS
#elif TARGET_OS_MAC
#define HL_MAC
#endif
#endif

#ifdef __ANDROID__
#	define HL_ANDROID
#endif

#if defined(linux) || defined(__linux__)
#	define HL_LINUX
#	define _GNU_SOURCE
#endif

#if defined(HL_IOS) || defined(HL_ANDROID) || defined(HL_TVOS)
#	define HL_MOBILE
#endif

#ifdef __ORBIS__
#	define HL_PS
#endif

#ifdef __NX__
#	define HL_NX
#endif

#ifdef _DURANGO
#	define HL_XBO
#endif

#if defined(HL_PS) || defined(HL_NX) || defined(HL_XBO)
#	define HL_CONSOLE
#endif

#if (defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__)) && !defined(HL_CONSOLE)
#	define HL_BSD
#endif

#if defined(_64BITS) || defined(__x86_64__) || defined(_M_X64) || defined(__LP64__)
#	define HL_64
#endif

#if defined(__GNUC__)
#	define HL_GCC
#endif

#if defined(__MINGW32__)
#	define HL_MINGW
#endif

#if defined(__CYGWIN__)
#	define HL_CYGWIN
#endif

#if defined(__llvm__)
#	define HL_LLVM
#endif

#if defined(__clang__)
#	define HL_CLANG
#endif

#if defined(_MSC_VER) && !defined(HL_LLVM)
#	define HL_VCC
#	pragma warning(disable:4996) // remove deprecated C API usage warnings
#	pragma warning(disable:4055) // void* - to - function cast
#	pragma warning(disable:4152) // void* - to - function cast
#	pragma warning(disable:4201) // anonymous struct
#	pragma warning(disable:4127) // while( true )
#	pragma warning(disable:4710) // inline disabled
#	pragma warning(disable:4711) // inline activated
#	pragma warning(disable:4255) // windows include
#	pragma warning(disable:4820) // windows include
#	pragma warning(disable:4668) // windows include
#	pragma warning(disable:4738) // return float bad performances
#endif

#if defined(HL_VCC) || defined(HL_MINGW) || defined(HL_CYGWIN)
#	define HL_WIN_CALL
#endif

#ifdef _DEBUG
#	define HL_DEBUG
#endif

#ifndef HL_CONSOLE
#	define HL_TRACK_ENABLE
#endif

#ifndef HL_NO_THREADS
#	define HL_THREADS
#	ifdef HL_VCC
#		define HL_THREAD_VAR __declspec( thread )
#		define HL_THREAD_STATIC_VAR HL_THREAD_VAR static
#	else
#		define HL_THREAD_VAR __thread
#		define HL_THREAD_STATIC_VAR static HL_THREAD_VAR
#	endif
#else
#	define HL_THREAD_VAR
#	define HL_THREAD_STATIC_VAR static
#endif

#include <stddef.h>
#ifndef HL_VCC
#	include <stdint.h>
#endif

#if defined(HL_VCC) || defined(HL_MINGW)
#	define EXPORT __declspec( dllexport )
#	define IMPORT __declspec( dllimport )
#else
#	define EXPORT
#	define IMPORT extern
#endif

#ifdef HL_64
#	define HL_WSIZE 8
#	define IS_64	1
#	ifdef HL_VCC
#		define _PTR_FMT	L"%IX"
#	else
#		define _PTR_FMT	u"%lX"
#	endif
#else
#	define HL_WSIZE 4
#	define IS_64	0
#	ifdef HL_VCC
#		define _PTR_FMT	L"%IX"
#	else
#		define _PTR_FMT	u"%X"
#	endif
#endif

#ifdef __cplusplus
#	define C_FUNCTION_BEGIN extern "C" {
#	define C_FUNCTION_END	};
#else
#	define C_FUNCTION_BEGIN
#	define C_FUNCTION_END
#	ifndef true
#		define true 1
#		define false 0
		typedef unsigned char bool;
#	endif
#endif

typedef intptr_t int_val;
typedef long long int64;
typedef unsigned long long uint64;

#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#if defined(LIBHL_EXPORTS)
#define HL_API extern EXPORT
#elif defined(LIBHL_STATIC)
#define HL_API extern
#else
#define	HL_API IMPORT
#endif

// -------------- UNICODE -----------------------------------

#if defined(HL_WIN) && !defined(HL_LLVM)
#if defined(HL_WIN_DESKTOP) && !defined(HL_MINGW)
#	include <Windows.h>
#elif defined(HL_WIN_DESKTOP) && defined(HL_MINGW)
#	include<windows.h>
#else
#	include <xdk.h>
#endif
#	include <wchar.h>
typedef wchar_t	uchar;
#	define USTR(str)	L##str
#	define HL_NATIVE_UCHAR_FUN
#	define usprintf		swprintf
#	define uprintf		wprintf
#	define ustrlen		wcslen
#	define ustrdup		_wcsdup
HL_API int uvszprintf( uchar *out, int out_size, const uchar *fmt, va_list arglist );
#	define utod(s,end)	wcstod(s,end)
#	define utoi(s,end)	wcstol(s,end,10)
#	define ucmp(a,b)	wcscmp(a,b)
#	define utostr(out,size,str) wcstombs(out,str,size)
#elif defined(HL_MAC)
typedef uint16_t uchar;
#	undef USTR
#	define USTR(str)	u##str
#else
#	include <stdarg.h>
#if defined(HL_IOS) || defined(HL_TVOS) || defined(HL_MAC)
#include <stddef.h>
#include <stdint.h>
typedef uint16_t char16_t;
typedef uint32_t char32_t;
#else
#	include <uchar.h>
#endif
typedef char16_t uchar;
#	undef USTR
#	define USTR(str)	u##str
#endif

#ifndef HL_NATIVE_UCHAR_FUN
C_FUNCTION_BEGIN
HL_API int ustrlen( const uchar *str );
HL_API uchar *ustrdup( const uchar *str );
HL_API double utod( const uchar *str, uchar **end );
HL_API int utoi( const uchar *str, uchar **end );
HL_API int ucmp( const uchar *a, const uchar *b );
HL_API int utostr( char *out, int out_size, const uchar *str );
HL_API int usprintf( uchar *out, int out_size, const uchar *fmt, ... );
HL_API int uvszprintf( uchar *out, int out_size, const uchar *fmt, va_list arglist );
HL_API void uprintf( const uchar *fmt, const uchar *str );
C_FUNCTION_END
#endif

#if defined(HL_VCC)
#	define hl_debug_break()	if( IsDebuggerPresent() ) __debugbreak()
#elif defined(HL_PS) && defined(_DEBUG)
#	define hl_debug_break()	__debugbreak()
#elif defined(HL_NX)
C_FUNCTION_BEGIN
HL_API void hl_debug_break( void );
C_FUNCTION_END
#elif defined(HL_LINUX) && defined(__i386__)
#	ifdef HL_64
#	define hl_debug_break() \
		if( hl_detect_debugger() ) \
			__asm__("0: int3;" \
			    ".pushsection embed-breakpoints;" \
			    ".quad 0b;" \
			    ".popsection")
#	else
#	define hl_debug_break() \
		if( hl_detect_debugger() ) \
			__asm__("0: int3;" \
			    ".pushsection embed-breakpoints;" \
			    ".long 0b;" \
			    ".popsection")
#	endif
#elif defined(HL_MAC)
#include <signal.h>
#	define hl_debug_break() \
		if( hl_detect_debugger() ) \
			raise(SIGTRAP);//__builtin_trap();
#else
#	define hl_debug_break()
#endif

#ifdef HL_VCC
#	define HL_NO_RETURN(f) __declspec(noreturn) f
#	define HL_UNREACHABLE
#else
#	define HL_NO_RETURN(f) f __attribute__((noreturn))
#	define HL_UNREACHABLE __builtin_unreachable()
#endif

// ---- TYPES -------------------------------------------

typedef enum {
	HVOID	= 0,
	HUI8	= 1,
	HUI16	= 2,
	HI32	= 3,
	HI64	= 4,
	HF32	= 5,
	HF64	= 6,
	HBOOL	= 7,
	HBYTES	= 8,
	HDYN	= 9,
	HFUN	= 10,
	HOBJ	= 11,
	HARRAY	= 12,
	HTYPE	= 13,
	HREF	= 14,
	HVIRTUAL= 15,
	HDYNOBJ = 16,
	HABSTRACT=17,
	HENUM	= 18,
	HNULL	= 19,
	HMETHOD = 20,
	HSTRUCT	= 21,
	// ---------
	HLAST	= 22,
	_H_FORCE_INT = 0x7FFFFFFF
} hl_type_kind;

typedef struct hl_type hl_type;
typedef struct hl_runtime_obj hl_runtime_obj;
typedef struct hl_alloc_block hl_alloc_block;
typedef struct { hl_alloc_block *cur; } hl_alloc;
typedef struct _hl_field_lookup hl_field_lookup;

typedef struct {
	hl_alloc alloc;
	void **functions_ptrs;
	hl_type **functions_types;
} hl_module_context;

typedef struct {
	hl_type **args;
	hl_type *ret;
	int nargs;
	// storage for closure
	hl_type *parent;
	struct {
		hl_type_kind kind;
		void *p;
	} closure_type;
	struct {
		hl_type **args;
		hl_type *ret;
		int nargs;
		hl_type *parent;
	} closure;
} hl_type_fun;

typedef struct {
	const uchar *name;
	hl_type *t;
	int hashed_name;
} hl_obj_field;

typedef struct {
	const uchar *name;
	int findex;
	int pindex;
	int hashed_name;
} hl_obj_proto;

typedef struct {
	int nfields;
	int nproto;
	int nbindings;
	const uchar *name;
	hl_type *super;
	hl_obj_field *fields;
	hl_obj_proto *proto;
	int *bindings;
	void **global_value;
	hl_module_context *m;
	hl_runtime_obj *rt;
} hl_type_obj;

typedef struct {
	hl_obj_field *fields;
	int nfields;
	// runtime
	int dataSize;
	int *indexes;
	hl_field_lookup *lookup;
} hl_type_virtual;

typedef struct {
	const uchar *name;
	int nparams;
	hl_type **params;
	int size;
	bool hasptr;
	int *offsets;
} hl_enum_construct;

typedef struct {
	const uchar *name;
	int nconstructs;
	hl_enum_construct *constructs;
	void **global_value;
} hl_type_enum;

struct hl_type {
	hl_type_kind kind;
	union {
		const uchar *abs_name;
		hl_type_fun *fun;
		hl_type_obj *obj;
		hl_type_enum *tenum;
		hl_type_virtual *virt;
		hl_type	*tparam;
	};
	void **vobj_proto;
	unsigned int *mark_bits;
};

C_FUNCTION_BEGIN

HL_API int hl_type_size( hl_type *t );
#define hl_pad_size(size,t)	((t)->kind == HVOID ? 0 : ((-(size)) & (hl_type_size(t) - 1)))
HL_API int hl_pad_struct( int size, hl_type *t );

HL_API hl_runtime_obj *hl_get_obj_rt( hl_type *ot );
HL_API hl_runtime_obj *hl_get_obj_proto( hl_type *ot );
HL_API void hl_flush_proto( hl_type *ot );
HL_API void hl_init_enum( hl_type *et, hl_module_context *m );

/* -------------------- VALUES ------------------------------ */

typedef unsigned char vbyte;

typedef struct {
	hl_type *t;
#	ifndef HL_64
	int __pad; // force align on 16 bytes for double
#	endif
	union {
		bool b;
		unsigned char ui8;
		unsigned short ui16;
		int i;
		float f;
		double d;
		vbyte *bytes;
		void *ptr;
		int64 i64;
	} v;
} vdynamic;

typedef struct {
	hl_type *t;
	/* fields data */
} vobj;

typedef struct _vvirtual vvirtual;
struct _vvirtual {
	hl_type *t;
	vdynamic *value;
	vvirtual *next;
};

#define hl_vfields(v) ((void**)(((vvirtual*)(v))+1))

typedef struct {
	hl_type *t;
	hl_type *at;
	int size;
	int __pad; // force align on 16 bytes for double
} varray;

typedef struct _vclosure {
	hl_type *t;
	void *fun;
	int hasValue;
#	ifdef HL_64
	int stackCount;
#	endif
	void *value;
} vclosure;

typedef struct {
	vclosure cl;
	vclosure *wrappedFun;
} vclosure_wrapper;

struct _hl_field_lookup {
	hl_type *t;
	int hashed_name;
	int field_index; // negative or zero : index in methods
};

typedef struct {
	void *ptr;
	hl_type *closure;
	int fid;
} hl_runtime_binding;

struct hl_runtime_obj {
	hl_type *t;
	// absolute
	int nfields;
	int nproto;
	int size;
	int nmethods;
	int nbindings;
	bool hasPtr;
	void **methods;
	int *fields_indexes;
	hl_runtime_binding *bindings;
	hl_runtime_obj *parent;
	const uchar *(*toStringFun)( vdynamic *obj );
	int (*compareFun)( vdynamic *a, vdynamic *b );
	vdynamic *(*castFun)( vdynamic *obj, hl_type *t );
	vdynamic *(*getFieldFun)( vdynamic *obj, int hfield );
	// relative
	int nlookup;
	hl_field_lookup *lookup;
};

typedef struct {
	hl_type *t;
	hl_field_lookup *lookup;
	char *raw_data;
	void **values;
	int nfields;
	int raw_size;
	int nvalues;
	vvirtual *virtuals;
} vdynobj;

typedef struct _venum {
	hl_type *t;
	int index;
} venum;

HL_API hl_type hlt_void;
HL_API hl_type hlt_i32;
HL_API hl_type hlt_i64;
HL_API hl_type hlt_f64;
HL_API hl_type hlt_f32;
HL_API hl_type hlt_dyn;
HL_API hl_type hlt_array;
HL_API hl_type hlt_bytes;
HL_API hl_type hlt_dynobj;
HL_API hl_type hlt_bool;
HL_API hl_type hlt_abstract;

HL_API double hl_nan( void );
HL_API bool hl_is_dynamic( hl_type *t );
#define hl_is_ptr(t)	((t)->kind >= HBYTES)
HL_API bool hl_same_type( hl_type *a, hl_type *b );
HL_API bool hl_safe_cast( hl_type *t, hl_type *to );

#define hl_aptr(a,t)	((t*)(((varray*)(a))+1))

HL_API varray *hl_alloc_array( hl_type *t, int size );
HL_API vdynamic *hl_alloc_dynamic( hl_type *t );
HL_API vdynamic *hl_alloc_dynbool( bool b );
HL_API vdynamic *hl_alloc_obj( hl_type *t );
HL_API venum *hl_alloc_enum( hl_type *t, int index );
HL_API vvirtual *hl_alloc_virtual( hl_type *t );
HL_API vdynobj *hl_alloc_dynobj( void );
HL_API vbyte *hl_alloc_bytes( int size );
HL_API vbyte *hl_copy_bytes( const vbyte *byte, int size );
HL_API int hl_utf8_length( const vbyte *s, int pos );
HL_API int hl_from_utf8( uchar *out, int outLen, const char *str );
HL_API char *hl_to_utf8( const uchar *bytes );
HL_API uchar *hl_to_utf16( const char *str );
HL_API vdynamic *hl_virtual_make_value( vvirtual *v );
HL_API hl_obj_field *hl_obj_field_fetch( hl_type *t, int fid );

HL_API int hl_hash( vbyte *name );
HL_API int hl_hash_utf8( const char *str ); // no cache
HL_API int hl_hash_gen( const uchar *name, bool cache_name );
HL_API vbyte *hl_field_name( int hash );

#define hl_error(msg, ...) hl_throw(hl_alloc_strbytes(USTR(msg), ## __VA_ARGS__))

HL_API vdynamic *hl_alloc_strbytes( const uchar *msg, ... );
HL_API void hl_assert( void );
HL_API HL_NO_RETURN( void hl_throw( vdynamic *v ) );
HL_API HL_NO_RETURN( void hl_rethrow( vdynamic *v ) );
HL_API HL_NO_RETURN( void hl_null_access( void ) );
HL_API void hl_setup_longjump( void *j );
HL_API void hl_setup_exception( void *resolve_symbol, void *capture_stack );
HL_API void hl_dump_stack( void );
HL_API varray *hl_exception_stack( void );
HL_API bool hl_detect_debugger( void );

HL_API vvirtual *hl_to_virtual( hl_type *vt, vdynamic *obj );
HL_API void hl_init_virtual( hl_type *vt, hl_module_context *ctx );
HL_API hl_field_lookup *hl_lookup_find( hl_field_lookup *l, int size, int hash );
HL_API hl_field_lookup *hl_lookup_insert( hl_field_lookup *l, int size, int hash, hl_type *t, int index );

HL_API int hl_dyn_geti( vdynamic *d, int hfield, hl_type *t );
HL_API void *hl_dyn_getp( vdynamic *d, int hfield, hl_type *t );
HL_API float hl_dyn_getf( vdynamic *d, int hfield );
HL_API double hl_dyn_getd( vdynamic *d, int hfield );

HL_API int hl_dyn_casti( void *data, hl_type *t, hl_type *to );
HL_API void *hl_dyn_castp( void *data, hl_type *t, hl_type *to );
HL_API float hl_dyn_castf( void *data, hl_type *t );
HL_API double hl_dyn_castd( void *data, hl_type *t );

#define hl_invalid_comparison 0xAABBCCDD
HL_API int hl_dyn_compare( vdynamic *a, vdynamic *b );
HL_API vdynamic *hl_make_dyn( void *data, hl_type *t );
HL_API void hl_write_dyn( void *data, hl_type *t, vdynamic *v, bool is_tmp );

HL_API void hl_dyn_seti( vdynamic *d, int hfield, hl_type *t, int value );
HL_API void hl_dyn_setp( vdynamic *d, int hfield, hl_type *t, void *ptr );
HL_API void hl_dyn_setf( vdynamic *d, int hfield, float f );
HL_API void hl_dyn_setd( vdynamic *d, int hfield, double v );

typedef enum {
	OpAdd,
	OpSub,
	OpMul,
	OpMod,
	OpDiv,
	OpShl,
	OpShr,
	OpUShr,
	OpAnd,
	OpOr,
	OpXor,
	OpLast
} DynOp;
HL_API vdynamic *hl_dyn_op( int op, vdynamic *a, vdynamic *b );

HL_API vclosure *hl_alloc_closure_void( hl_type *t, void *fvalue );
HL_API vclosure *hl_alloc_closure_ptr( hl_type *fullt, void *fvalue, void *ptr );
HL_API vclosure *hl_make_fun_wrapper( vclosure *c, hl_type *to );
HL_API void *hl_wrapper_call( void *value, void **args, vdynamic *ret );
HL_API void *hl_dyn_call_obj( vdynamic *obj, hl_type *ft, int hfield, void **args, vdynamic *ret );
HL_API vdynamic *hl_dyn_call( vclosure *c, vdynamic **args, int nargs );
HL_API vdynamic *hl_dyn_call_safe( vclosure *c, vdynamic **args, int nargs, bool *isException );

/*
	These macros should be only used when the closure `cl` has been type checked beforehand
	so you are sure it's of the used typed. Otherwise use hl_dyn_call
*/
#define hl_call0(ret,cl) \
	(cl->hasValue ? ((ret(*)(vdynamic*))cl->fun)(cl->value) : ((ret(*)())cl->fun)()) 
#define hl_call1(ret,cl,t,v) \
	(cl->hasValue ? ((ret(*)(vdynamic*,t))cl->fun)(cl->value,v) : ((ret(*)(t))cl->fun)(v))
#define hl_call2(ret,cl,t1,v1,t2,v2) \
	(cl->hasValue ? ((ret(*)(vdynamic*,t1,t2))cl->fun)(cl->value,v1,v2) : ((ret(*)(t1,t2))cl->fun)(v1,v2))
#define hl_call3(ret,cl,t1,v1,t2,v2,t3,v3) \
	(cl->hasValue ? ((ret(*)(vdynamic*,t1,t2,t3))cl->fun)(cl->value,v1,v2,v3) : ((ret(*)(t1,t2,t3))cl->fun)(v1,v2,v3))
#define hl_call4(ret,cl,t1,v1,t2,v2,t3,v3,t4,v4) \
	(cl->hasValue ? ((ret(*)(vdynamic*,t1,t2,t3,t4))cl->fun)(cl->value,v1,v2,v3,v4) : ((ret(*)(t1,t2,t3,t4))cl->fun)(v1,v2,v3,v4))

// ----------------------- THREADS --------------------------------------------------

struct _hl_thread;
struct _hl_mutex;
struct _hl_tls;
typedef struct _hl_thread hl_thread;
typedef struct _hl_mutex hl_mutex;
typedef struct _hl_tls hl_tls;

HL_API hl_thread *hl_thread_start( void *callback, void *param, bool withGC );
HL_API hl_thread *hl_thread_current( void );
HL_API void hl_thread_yield(void);
HL_API void hl_register_thread( void *stack_top );
HL_API void hl_unregister_thread( void );

HL_API hl_mutex *hl_mutex_alloc( bool gc_thread );
HL_API void hl_mutex_acquire( hl_mutex *l );
HL_API bool hl_mutex_try_acquire( hl_mutex *l );
HL_API void hl_mutex_release( hl_mutex *l );
HL_API void hl_mutex_free( hl_mutex *l );

HL_API hl_tls *hl_tls_alloc( bool gc_value );
HL_API void hl_tls_set( hl_tls *l, void *value );
HL_API void *hl_tls_get( hl_tls *l );
HL_API void hl_tls_free( hl_tls *l );

// ----------------------- ALLOC --------------------------------------------------

#define MEM_HAS_PTR(kind)	(!((kind)&2))
#define MEM_KIND_DYNAMIC	0
#define MEM_KIND_RAW		1
#define MEM_KIND_NOPTR		2
#define MEM_KIND_FINALIZER	3
#define MEM_ALIGN_DOUBLE	128
#define MEM_ZERO			256

HL_API void *hl_gc_alloc_gen( hl_type *t, int size, int flags );
HL_API void hl_add_root( void *ptr );
HL_API void hl_remove_root( void *ptr );
HL_API void hl_gc_major( void );
HL_API bool hl_is_gc_ptr( void *ptr );

HL_API void hl_blocking( bool b );
HL_API bool hl_is_blocking( void );

typedef void (*hl_types_dump)( void (*)( void *, int) );
HL_API void hl_gc_set_dump_types( hl_types_dump tdump );

#define hl_gc_alloc_noptr(size)		hl_gc_alloc_gen(&hlt_bytes,size,MEM_KIND_NOPTR)
#define hl_gc_alloc(t,size)			hl_gc_alloc_gen(t,size,MEM_KIND_DYNAMIC)
#define hl_gc_alloc_raw(size)		hl_gc_alloc_gen(&hlt_abstract,size,MEM_KIND_RAW)
#define hl_gc_alloc_finalizer(size) hl_gc_alloc_gen(&hlt_abstract,size,MEM_KIND_FINALIZER)

HL_API void hl_alloc_init( hl_alloc *a );
HL_API void *hl_malloc( hl_alloc *a, int size );
HL_API void *hl_zalloc( hl_alloc *a, int size );
HL_API void hl_free( hl_alloc *a );

HL_API void hl_global_init( void );
HL_API void hl_global_free( void );

HL_API void *hl_alloc_executable_memory( int size );
HL_API void hl_free_executable_memory( void *ptr, int size );

// ----------------------- BUFFER --------------------------------------------------

typedef struct hl_buffer hl_buffer;

HL_API hl_buffer *hl_alloc_buffer( void );
HL_API void hl_buffer_val( hl_buffer *b, vdynamic *v );
HL_API void hl_buffer_char( hl_buffer *b, uchar c );
HL_API void hl_buffer_str( hl_buffer *b, const uchar *str );
HL_API void hl_buffer_cstr( hl_buffer *b, const char *str );
HL_API void hl_buffer_str_sub( hl_buffer *b, const uchar *str, int len );
HL_API int hl_buffer_length( hl_buffer *b );
HL_API uchar *hl_buffer_content( hl_buffer *b, int *len );
HL_API uchar *hl_to_string( vdynamic *v );
HL_API const uchar *hl_type_str( hl_type *t );
HL_API void hl_throw_buffer( hl_buffer *b );

// ----------------------- FFI ------------------------------------------------------

// match GNU C++ mangling
#define TYPE_STR	"vcsilfdbBDPOATR??X?N"

#undef  _VOID
#define _NO_ARG
#define _VOID						"v"
#define	_I8							"c"
#define _I16						"s"
#define _I32						"i"
#define _I64						"l"
#define _F32						"f"
#define _F64						"d"
#define _BOOL						"b"
#define _BYTES						"B"
#define _DYN						"D"
#define _FUN(t, args)				"P" args "_" t
#define _OBJ(fields)				"O" fields "_"
#define _ARR						"A"
#define _TYPE						"T"
#define _REF(t)						"R" t
#define _ABSTRACT(name)				"X" #name "_"
#undef _NULL
#define _NULL(t)					"N" t

#undef _STRING
#define _STRING						_OBJ(_BYTES _I32)

typedef struct {
	hl_type *t;
	uchar *bytes;
	int length;
} vstring;

#define DEFINE_PRIM(t,name,args)						DEFINE_PRIM_WITH_NAME(t,name,args,name)
#define _DEFINE_PRIM_WITH_NAME(t,name,args,realName)	C_FUNCTION_BEGIN EXPORT void *hlp_##realName( const char **sign ) { *sign = _FUN(t,args); return (void*)(&HL_NAME(name)); } C_FUNCTION_END

#if !defined(HL_NAME)
#	define HL_NAME(p)					p
#	ifdef LIBHL_EXPORTS
#		define HL_PRIM				EXPORT
#		undef DEFINE_PRIM
#		define DEFINE_PRIM(t,name,args)						_DEFINE_PRIM_WITH_NAME(t,hl_##name,args,name)
#		define DEFINE_PRIM_WITH_NAME						_DEFINE_PRIM_WITH_NAME
#	else
#		define HL_PRIM
#		define DEFINE_PRIM_WITH_NAME(t,name,args,realName)
#	endif
#elif defined(LIBHL_STATIC)
#	ifdef __cplusplus
#		define	HL_PRIM				extern "C"
#	else
#		define	HL_PRIM
#	endif
#define DEFINE_PRIM_WITH_NAME(t,name,args,realName)
#else
#	ifdef __cplusplus
#		define	HL_PRIM				extern "C" EXPORT
#	else
#		define	HL_PRIM				EXPORT
#	endif
#	define DEFINE_PRIM_WITH_NAME	_DEFINE_PRIM_WITH_NAME
#endif

#if defined(HL_GCC) && !defined(HL_CONSOLE)
#	ifdef HL_CLANG
#		define HL_NO_OPT	__attribute__ ((optnone))
#	else
#		define HL_NO_OPT	__attribute__((optimize("-O0")))
#	endif
#else
#	define HL_NO_OPT
#endif

// -------------- EXTRA ------------------------------------

#define hl_fatal(msg)			hl_fatal_error(msg,__FILE__,__LINE__)
#define hl_fatal1(msg,p0)		hl_fatal_fmt(__FILE__,__LINE__,msg,p0)
#define hl_fatal2(msg,p0,p1)	hl_fatal_fmt(__FILE__,__LINE__,msg,p0,p1)
#define hl_fatal3(msg,p0,p1,p2)	hl_fatal_fmt(__FILE__,__LINE__,msg,p0,p1,p2)
#define hl_fatal4(msg,p0,p1,p2,p3)	hl_fatal_fmt(__FILE__,__LINE__,msg,p0,p1,p2,p3)
HL_API void *hl_fatal_error( const char *msg, const char *file, int line );
HL_API void hl_fatal_fmt( const char *file, int line, const char *fmt, ...);
HL_API void hl_sys_init(void **args, int nargs, void *hlfile);
HL_API void hl_setup_callbacks(void *sc, void *gw);
HL_API void hl_setup_callbacks2(void *sc, void *gw, int flags);
HL_API void hl_setup_reload_check( void *freload, void *param );

#include <setjmp.h>
typedef struct _hl_trap_ctx hl_trap_ctx;
struct _hl_trap_ctx {
	jmp_buf buf;
	hl_trap_ctx *prev;
	vdynamic *tcheck;
};
#define hl_trap(ctx,r,label) { hl_thread_info *__tinf = hl_get_thread(); ctx.tcheck = NULL; ctx.prev = __tinf->trap_current; __tinf->trap_current = &ctx; if( setjmp(ctx.buf) ) { r = __tinf->exc_value; goto label; } }
#define hl_endtrap(ctx)	hl_get_thread()->trap_current = ctx.prev

#define HL_EXC_MAX_STACK	0x100
#define HL_EXC_RETHROW		1
#define HL_EXC_CATCH_ALL	2
#define HL_EXC_IS_THROW		4
#define HL_THREAD_INVISIBLE	16
#define HL_THREAD_PROFILER_PAUSED 32
#define HL_TREAD_TRACK_SHIFT 16

#define HL_TRACK_ALLOC		1
#define HL_TRACK_CAST		2
#define HL_TRACK_DYNFIELD	4
#define HL_TRACK_DYNCALL	8
#define HL_TRACK_MASK		(HL_TRACK_ALLOC | HL_TRACK_CAST | HL_TRACK_DYNFIELD | HL_TRACK_DYNCALL)

#define HL_MAX_EXTRA_STACK 64

typedef struct {
	int thread_id;
	// gc vars
	volatile int gc_blocking;
	void *stack_top;
	void *stack_cur;
	// exception handling
	hl_trap_ctx *trap_current;
	hl_trap_ctx *trap_uncaught;
	vclosure *exc_handler;
	vdynamic *exc_value;
	int flags;
	int exc_stack_count;
	// extra
	jmp_buf gc_regs;
	void *exc_stack_trace[HL_EXC_MAX_STACK];
	void *extra_stack_data[HL_MAX_EXTRA_STACK];
	int extra_stack_size;
} hl_thread_info;

HL_API hl_thread_info *hl_get_thread();

#ifdef HL_TRACK_ENABLE

typedef struct {
	int flags;
	void (*on_alloc)(hl_type *,int,int,void*);
	void (*on_cast)(hl_type *, hl_type*);
	void (*on_dynfield)( vdynamic *, int );
	void (*on_dyncall)( vdynamic *, int );
} hl_track_info;

#define hl_is_tracking(flag) ((hl_track.flags&(flag)) && (hl_get_thread()->flags & (flag<<HL_TREAD_TRACK_SHIFT)))
#define hl_track_call(flag,call) if( hl_is_tracking(flag) ) hl_track.call

HL_API hl_track_info hl_track;

#else 

#define hl_is_tracking(_) false
#define hl_track_call(a,b)

#endif

C_FUNCTION_END

#endif

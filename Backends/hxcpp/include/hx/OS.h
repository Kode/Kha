#ifndef HX_OS_H
#define HX_OS_H

// OS FLAGS
#if defined(_WIN32)
#	define NEKO_WINDOWS
#endif

#if defined(__APPLE__) || defined(__MACH__) || defined(macintosh)
#	define NEKO_MAC
#endif

#if defined(linux) || defined(__linux__)
#	define NEKO_LINUX
#endif

#if defined(__FreeBSD_kernel__)
#	define NEKO_GNUKBSD
#endif

#if defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__)
#	define NEKO_BSD
#endif

// COMPILER/PROCESSOR FLAGS
#if defined(__GNUC__)
#	define NEKO_GCC
#endif

#if defined(_MSC_VER)
#	define NEKO_VCC
#endif

#if defined(__MINGW32__)
#	define NEKO_MINGW
#endif

#if defined(__i386__) || defined(_WIN32)
#	define NEKO_X86
#endif

#if defined(__ppc__)
#	define NEKO_PPC
#endif

#if defined(_64BITS)
#	define NEKO_64BITS
#endif

#if defined(NEKO_LINUX) || defined(NEKO_MAC) || defined(NEKO_BSD) || defined(NEKO_GNUKBSD)
#	define NEKO_POSIX
#endif

#if defined(NEKO_GCC)
#	define NEKO_THREADED
#	define NEKO_DIRECT_THREADED
#endif

#include <stddef.h>
#ifndef NEKO_VCC
#	include <stdint.h>
#endif





#undef EXPORT
#undef IMPORT
#if defined(NEKO_VCC) || defined(NEKO_MINGW)
#	define INLINE __inline
#	define EXPORT __declspec( dllexport )
#	define IMPORT __declspec( dllimport )
#elif defined (HX_LINUX)
#	define INLINE inline
#	define EXPORT __attribute__ ((visibility("default")))
#	define IMPORT
#else
#	define INLINE inline
#	define EXPORT __attribute__ ((visibility("default")))
#	define IMPORT
#endif

#ifdef NEKO_POSIX
#	include <errno.h>
#	define POSIX_LABEL(name)	name:
#	define HANDLE_EINTR(label)	if( errno == EINTR ) goto label
#	define HANDLE_FINTR(f,label) if( ferror(f) && errno == EINTR ) goto label
#else
#	define POSIX_LABEL(name)
#	define HANDLE_EINTR(label)
#	define HANDLE_FINTR(f,label)
#endif


#endif

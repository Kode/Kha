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
#ifndef HLC_H
#define HLC_H

#include <math.h>
#include <hl.h>

#ifdef HL_64
#	define PAD_64_VAL	,0
#else
#	define PAD_64_VAL
#endif

#ifdef HLC_BOOT

// undefine some commonly used names that can clash with class/var name
#undef CONST
#undef stdin
#undef stdout
#undef stderr
#undef DELETE
#undef NO_ERROR
#undef EOF
#undef STRICT
#undef TRUE
#undef FALSE
#undef CW_USEDEFAULT
#undef HIDDEN
#undef RESIZABLE
#undef __SIGN

// disable some warnings triggered by HLC code generator

#ifdef HL_VCC
#	pragma warning(disable:4100) // unreferenced param
#	pragma warning(disable:4101) // unreferenced local var
#	pragma warning(disable:4102) // unreferenced label
#	pragma warning(disable:4204) // nonstandard extension
#	pragma warning(disable:4221) // nonstandard extension
#	pragma warning(disable:4244) // possible loss of data
#	pragma warning(disable:4700) // uninitialized local variable used
#	pragma warning(disable:4701) // potentially uninitialized local variable
#	pragma warning(disable:4702) // unreachable code
#	pragma warning(disable:4703) // potentially uninitialized local
#	pragma warning(disable:4715) // control paths must return a value
#	pragma warning(disable:4716) // must return a value (ends with throw)
#	pragma warning(disable:4723) // potential divide by 0
#else
#	pragma GCC diagnostic ignored "-Wunused-variable"
#	pragma GCC diagnostic ignored "-Wunused-function"
#	pragma GCC diagnostic ignored "-Wcomment" // comment in comment
#	ifdef HL_CLANG
#	pragma GCC diagnostic ignored "-Wreturn-type"
#	pragma GCC diagnostic ignored "-Wsometimes-uninitialized"
#	else
#	pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#	pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#	endif
#endif

#endif

extern void *hlc_static_call(void *fun, hl_type *t, void **args, vdynamic *out);
extern void *hlc_get_wrapper(hl_type *t);
extern void hl_entry_point();

#define HL__ENUM_CONSTRUCT__	hl_type *t; int index;
#define HL__ENUM_INDEX__(v)		((venum*)(v))->index

#endif

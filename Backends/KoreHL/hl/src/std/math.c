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
#include <hl.h>
#include <math.h>

#ifndef NAN
    static const unsigned long __nan[2] = {0xffffffff, 0x7fffffff};
    #define NAN (*(const float *) __nan)
#endif

HL_PRIM double hl_nan() {
	return NAN;
}

HL_PRIM double hl_math_abs( double a ) {
	return fabs(a);
}

HL_PRIM bool hl_math_isnan( double a ) {
#ifdef HL_WIN
	return isnan(a);
#else
	return a != a; //does not work on some platforms
#endif
}

typedef union {
	double d;
	struct {
		unsigned int l;
		unsigned int h;
	} i;
} qw;

HL_PRIM bool hl_math_isfinite( double a ) {
	qw q;
	unsigned int h, l;
	if( a != a )
		return false;
	q.d = a;
	h = q.i.h;
	l = q.i.l;
	l = l | (h & 0xFFFFF);
	h = h & 0x7FF00000;
	return h != 0x7FF00000 || l;
}

HL_PRIM double hl_math_fceil( double d ) {
	return ceil(d);
}

HL_PRIM double hl_math_fround( double d ) {
	return floor(d + 0.5);
}

HL_PRIM double hl_math_ffloor( double d ) {
	return floor(d);
}

HL_PRIM int hl_math_round( double d ) {
	return (int)hl_math_fround(d);
}

HL_PRIM int hl_math_ceil( double d ) {
	return (int)hl_math_fceil(d);
}

HL_PRIM int hl_math_floor( double d ) {
	return (int)hl_math_ffloor(d);
}

HL_PRIM double hl_math_cos( double a ) {
	return cos(a);
}

HL_PRIM double hl_math_sin( double a ) {
	return sin(a);
}

HL_PRIM double hl_math_tan( double a ) {
	return tan(a);
}

HL_PRIM double hl_math_acos( double a ) {
	return acos(a);
}

HL_PRIM double hl_math_asin( double a ) {
	return asin(a);
}

HL_PRIM double hl_math_atan( double a ) {
	return atan(a);
}

HL_PRIM double hl_math_atan2( double a, double b ) {
	return atan2(a,b);
}

HL_PRIM double hl_math_pow( double a, double b ) {
	return pow(a,b);
}

HL_PRIM double hl_math_log( double a ) {
	return log(a);
}

HL_PRIM double hl_math_exp( double a ) {
	return exp(a);
}

HL_PRIM double hl_math_sqrt( double a ) {
	return sqrt(a);
}

DEFINE_PRIM(_F64, nan, _NO_ARG);
DEFINE_PRIM(_F64, math_abs, _F64);
DEFINE_PRIM(_BOOL, math_isnan, _F64);
DEFINE_PRIM(_BOOL, math_isfinite, _F64);
DEFINE_PRIM(_F64, math_fceil, _F64);
DEFINE_PRIM(_F64, math_fround, _F64);
DEFINE_PRIM(_F64, math_ffloor, _F64);
DEFINE_PRIM(_I32, math_round, _F64);
DEFINE_PRIM(_I32, math_ceil, _F64);
DEFINE_PRIM(_I32, math_floor, _F64);
DEFINE_PRIM(_F64, math_cos, _F64);
DEFINE_PRIM(_F64, math_sin, _F64);
DEFINE_PRIM(_F64, math_tan, _F64);
DEFINE_PRIM(_F64, math_acos, _F64);
DEFINE_PRIM(_F64, math_asin, _F64);
DEFINE_PRIM(_F64, math_atan, _F64);
DEFINE_PRIM(_F64, math_atan2, _F64 _F64);
DEFINE_PRIM(_F64, math_pow, _F64 _F64);
DEFINE_PRIM(_F64, math_log, _F64);
DEFINE_PRIM(_F64, math_exp, _F64);
DEFINE_PRIM(_F64, math_sqrt, _F64);

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

#ifndef OP_BEGIN
#	define		OP_BEGIN	typedef enum {
#	define		OP_END		} hl_op;
#endif

#ifndef OP
#	define OP(o,_) o,
#endif

OP_BEGIN
	OP(OMov,2)
	OP(OInt,2)
	OP(OFloat,2)
	OP(OBool,2)
	OP(OBytes,2)
	OP(OString,2)
	OP(ONull,1)

	OP(OAdd,3)
	OP(OSub,3)
	OP(OMul,3)
	OP(OSDiv,3)
	OP(OUDiv,3)
	OP(OSMod,3)
	OP(OUMod,3)
	OP(OShl,3)
	OP(OSShr,3)
	OP(OUShr,3)
	OP(OAnd,3)
	OP(OOr,3)
	OP(OXor,3)

	OP(ONeg,2)
	OP(ONot,2)
	OP(OIncr,1)
	OP(ODecr,1)

	OP(OCall0,2)
	OP(OCall1,3)
	OP(OCall2,4)
	OP(OCall3,5)
	OP(OCall4,6)
	OP(OCallN,-1)
	OP(OCallMethod,-1)
	OP(OCallThis,-1)
	OP(OCallClosure,-1)

	OP(OStaticClosure,2)
	OP(OInstanceClosure,3)
	OP(OVirtualClosure,3)

	OP(OGetGlobal, 2)
	OP(OSetGlobal,2)
	OP(OField,3)
	OP(OSetField,3)
	OP(OGetThis,2)
	OP(OSetThis,2)
	OP(ODynGet,3)
	OP(ODynSet,3)

	OP(OJTrue,2)
	OP(OJFalse,2)
	OP(OJNull,2)
	OP(OJNotNull,2)
	OP(OJSLt,3)
	OP(OJSGte,3)
	OP(OJSGt,3)
	OP(OJSLte,3)
	OP(OJULt,3)
	OP(OJUGte,3)
	OP(OJNotLt,3)
	OP(OJNotGte,3)
	OP(OJEq,3)
	OP(OJNotEq,3)
	OP(OJAlways,1)

	OP(OToDyn,2)
	OP(OToSFloat,2)
	OP(OToUFloat,2)
	OP(OToInt,2)
	OP(OSafeCast,2)
	OP(OUnsafeCast,2)
	OP(OToVirtual,2)

	OP(OLabel,0)
	OP(ORet,1)
	OP(OThrow,1)
	OP(ORethrow,1)
	OP(OSwitch,-1)
	OP(ONullCheck,1)
	OP(OTrap,2)
	OP(OEndTrap,1)

	OP(OGetI8,3)
	OP(OGetI16,3)
	OP(OGetMem,3)
	OP(OGetArray,3)
	OP(OSetI8,3)
	OP(OSetI16,3)
	OP(OSetMem,3)
	OP(OSetArray,3)

	OP(ONew,1)
	OP(OArraySize,2)
	OP(OType,2)
	OP(OGetType,2)
	OP(OGetTID,2)

	OP(ORef,2)
	OP(OUnref,2)
	OP(OSetref,2)

	OP(OMakeEnum,-1)
	OP(OEnumAlloc,2)
	OP(OEnumIndex,2)
	OP(OEnumField,4)
	OP(OSetEnumField,3)

	OP(OAssert,0)
	OP(ORefData,2)
	OP(ORefOffset,3)
	OP(ONop,0)
	// --
	OP(OLast,0)
OP_END

#undef OP_BEGIN
#undef OP_END
#undef OP

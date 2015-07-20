/*
 * Copyright (C)2014-2015 Haxe Foundation
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
package js.node;

import haxe.extern.EitherType;

/**
	This module is used for writing unit tests for your applications
**/
@:jsRequire("assert")
extern class Assert {
	/**
		Throws an exception that displays the values for `actual` and `expected` separated by the provided `operator`.
	**/
	static function fail<T>(actual:T, expected:T, message:String, operator:String):Void;

	/**
		Tests if value is truthy
	**/
	@:selfCall
	static function assert(value:Bool, ?message:String):Void;

	/**
		Tests if value is truthy
	**/
	static function ok(value:Bool, ?message:String):Void;

	/**
		Tests shallow, coercive equality with the equal comparison operator (==).
	**/
	static function equal<T>(actual:T, expected:T, ?message:String):Void;

	/**
		Tests shallow, coercive non-equality with the not equal comparison operator (!=).
	**/
	static function notEqual<T>(actual:T, expected:T, ?message:String):Void;

	/**
		Tests for deep equality.
	**/
	static function deepEqual<T>(actual:T, expected:T, ?message:String):Void;

	/**
		Tests for any deep inequality.
	**/
	static function notDeepEqual<T>(actual:T, expected:T, ?message:String):Void;

	/**
		Tests strict equality, as determined by the JavaScript strict equality operator (===)
	**/
	static function strictEqual<T>(actual:T, expected:T, ?message:String):Void;

	/**
		Tests strict non-equality, as determined by the strict not equal operator (!==)
	**/
	static function notStrictEqual<T>(actual:T, expected:T, ?message:String):Void;

	/**
		Expects block to throw an error.
		`error` can be a class, javascript RegExp or a validation function.
	**/
	@:overload(function(block:Void->Void, ?message:String):Void {})
	static function throws(block:Void->Void, error:ThrowsExpectedError, ?message:String):Void;

	/**
		Expects block not to throw an error, see `throws` for details.
	**/
	static function doesNotThrow(block:Void->Void, ?message:String):Void;

	/**
		Tests if `value` is not a false value, throws that value if it is a true value.

		A 'false' value in JavaScript is false, null, undefined and 0.

		Useful when testing the first argument, error in callbacks.
	**/
	static function ifError(value:Dynamic):Void;
}

/**
	a class, RegExp or function.
**/
private typedef ThrowsExpectedError = EitherType<Class<Dynamic>, EitherType<js.RegExp, Dynamic->Bool>>;

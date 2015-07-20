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

import js.node.smalloc.*;

/**
	Buffers are backed by a simple allocator that only handles the assignation of external raw memory.
	Smalloc exposes that functionality.
**/
@:jsRequire("smalloc")
extern class Smalloc {
	/**
		Returns `receiver` with allocated external array data.
		If no `receiver` is passed then a new Object will be created and returned.

		This can be used to create your own `Buffer`-like classes.
		No other properties are set, so the user will need to keep track of
		other necessary information (e.g. length of the allocation).
	**/
	@:overload(function<T>(length:Int, receiver:T, ?type:Types):T {})
	static function alloc<T>(length:Int, ?type:Types):T;

	/**
		Copy memory from one external array allocation to another.

		`copyOnto` automatically detects the length of the allocation internally,
		so no need to set any additional properties for this to work.
	**/
	static function copyOnto(source:Dynamic, sourceStart:Int, dest:Dynamic, destStart:Int, copyLength:Int):Void;

	/**
		Free memory that has been allocated to an object via `alloc`.
	**/
	static function dispose(obj:Dynamic):Void;

	/**
		Returns true if the `obj` has externally allocated memory.
	**/
	static function hasExternalData(obj:Dynamic):Bool;

	/**
		Size of maximum allocation.
		This is also applicable to `Buffer` creation.
	**/
	static var kMaxLength(default,null):Int;
}

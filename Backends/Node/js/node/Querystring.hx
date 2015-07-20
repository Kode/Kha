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

import haxe.DynamicAccess;

/**
	This module provides utilities for dealing with query strings.
**/
@:jsRequire("querystring")
extern class Querystring {
	/**
		Serialize an object to a query string.
		Optionally override the default separator ('&') and assignment ('=') characters.
	**/
	static function stringify(obj:{}, ?sep:String, ?eq:String):String;

	/**
		Deserialize a query string to an object.
		Optionally override the default separator ('&') and assignment ('=') characters.

		Options object may contain `maxKeys` property (equal to 1000 by default), it'll be used to limit processed keys.
		Set it to 0 to remove key count limitation.
	**/
	@:overload(function(str:String, ?options:{maxKeys:Int}):DynamicAccess<String> {})
	@:overload(function(str:String, sep:String, ?options:{maxKeys:Int}):DynamicAccess<String> {})
	static function parse(str:String, ?sep:String, ?eq:String):DynamicAccess<String>;

	/**
		The escape function used by `Querystring.stringify`, provided so that it could be overridden if necessary.
	**/
	static dynamic function escape(obj:Dynamic):String;

	/**
		The unescape function used by `Querystring.parse`, provided so that it could be overridden if necessary.
	**/
	static dynamic function unescape(str:String):Dynamic;
}

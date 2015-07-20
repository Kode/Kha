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
import js.node.stream.Readable;
import js.node.stream.Writable;

@:jsRequire("util")
extern class Util {
	/**
		Returns a formatted string using the first argument as a printf-like format.

		The first argument is a string that contains zero or more placeholders.
		Each placeholder is replaced with the converted value from its corresponding argument.
		Supported placeholders are:
			%s - String.
			%d - Number (both integer and float).
			%j - JSON.
			% - single percent sign ('%'). This does not consume an argument.
		If the placeholder does not have a corresponding argument, the placeholder is not replaced.

		If there are more arguments than placeholders, the extra arguments are converted to strings with `inspect`
		and these strings are concatenated, delimited by a space.

		If the first argument is not a format string then `format` returns a string that is the concatenation of
		all its arguments separated by spaces. Each argument is converted to a string with `inspect`.
	**/
	@:overload(function(args:haxe.extern.Rest<Dynamic>):String {})
	static function format(format:String, args:haxe.extern.Rest<Dynamic>):String;

	/**
		A synchronous output function.
		Will block the process and output string immediately to stderr.
	**/
	static function debug(string:String):Void;

	/**
		Same as `debug` except this will output all arguments immediately to stderr.
	**/
	static function error(args:haxe.extern.Rest<Dynamic>):Void;

	/**
		A synchronous output function.
		Will block the process and output all arguments to stdout with newlines after each argument.
	**/
	static function puts(args:haxe.extern.Rest<Dynamic>):Void;

	/**
		A synchronous output function.
		Will block the process, cast each argument to a string then output to stdout.
		Does not place newlines after each argument.
	**/
	static function print(args:haxe.extern.Rest<Dynamic>):Void;

	/**
		Output with timestamp on stdout.
	**/
	static function log(string:String):Void;

	/**
		Return a string representation of `object`, which is useful for debugging.
		An optional `options` object may be passed that alters certain aspects of the formatted string.

		Objects also may define their own `inspect(depth:Int)` function which `inspect` will invoke and
		use the result of when inspecting the object.
	**/
	static function inspect(object:Dynamic, ?options:InspectOptions):String;

	/**
		a map assigning each style a color from `inspect_colors`.
		Highlighted styles and their default values are:
			number (yellow)
			boolean (yellow)
			string (green)
			date (magenta)
			regexp (red)
			null (bold)
			undefined (grey)
			special - only function at this time (cyan)
			name (intentionally no styling)
	**/
	static var inspect_styles(get,set):DynamicAccess<String>;
	private static inline function get_inspect_styles():DynamicAccess<String> return untyped inspect.styles;
	private static inline function set_inspect_styles(value:DynamicAccess<String>):DynamicAccess<String> return untyped inspect.styles = value;

	/**
		Predefined color codes are: white, grey, black, blue, cyan, green, magenta, red and yellow.
		There are also bold, italic, underline and inverse codes.
	**/
	static var inspect_colors(get,set):DynamicAccess<Array<Int>>; // TODO: these Arrays are supposed to have only 2 values, add Pair<Int> abstract?
	private static inline function get_inspect_colors():DynamicAccess<Array<Int>> return untyped inspect.colors;
	private static inline function set_inspect_colors(value:DynamicAccess<Array<Int>>):DynamicAccess<Array<Int>> return untyped inspect.colors = value;

	/**
		Returns true if the given "object" is an Array. false otherwise.
	**/
	static function isArray(object:Dynamic):Bool;

	/**
		Returns true if the given "object" is a RegExp. false otherwise.
	**/
	static function isRegExp(object:Dynamic):Bool;

	/**
		Returns true if the given "object" is a Date. false otherwise.
	**/
	static function isDate(object:Dynamic):Bool;

	/**
		Returns true if the given "object" is an Error. false otherwise.
	**/
	static function isError(object:Dynamic):Bool;

	/**
		Deprecated: Use `readableStream.pipe(writableStream)`

		Read the data from `readableStream` and send it to the `writableStream`.
		When `writableStream.write(data)` returns false `readableStream` will be paused until
		the drain event occurs on the `writableStream`.

		`callback` is called when `writableStream` is closed or when an error occurs.
	**/
	@:deprecated("Use `readableStream.pipe(writableStream)` instead")
	static function pump(readableStream:IReadable, writableStream:IWritable, ?callback:js.Error->Void):Void;

	/**
		Inherit the prototype methods from one constructor into another.
		The prototype of constructor will be set to a new object created from superConstructor.

		As an additional convenience, superConstructor will be accessible through the constructor.`super_` property.
	**/
	static function inherits(constructor:Class<Dynamic>, superConstructor:Class<Dynamic>):Bool; // TODO: do we need this? isn't it basically the same haxe does for class inheritance?
}

/**
	Options object used by `Util.inspect`.
**/
typedef InspectOptions = {
	/**
		if true then the object's non-enumerable properties will be shown too.
		Defaults to false.
	**/
	@:optional var showHidden:Bool;

	/**
		Tells `Util.inspect` how many times to recurse while formatting the object.
		This is useful for inspecting large complicated objects.
		Defaults to 2. To make it recurse indefinitely pass `null`.
	**/
	@:optional var depth:Null<Int>;

	/**
		if true, then the output will be styled with ANSI color codes.
		Defaults to false.
		Colors are customizable globally via `Util.inspect_styles` and `Util.inspect_colors` objects.
	**/
	@:optional var colors:Bool;

	/**
		if false, then custom `inspect` functions defined on the objects being inspected won't be called.
		Defaults to true.
	**/
	@:optional var customInspect:Bool;
}

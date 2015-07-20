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
package js.node.buffer;

/**
	The Buffer class is a global type for dealing with binary data directly. It can be constructed in a variety of ways.

	It supports array access syntax to get and set the octet at index. The values refer to individual bytes,
	so the legal range is between 0x00 and 0xFF hex or 0 and 255.
**/
@:jsRequire("buffer", "Buffer")
extern class Buffer implements ArrayAccess<Int> {

	/**
		How many bytes will be returned when `buffer.inspect()` is called.
		This can be overridden by user modules.
		Default: 50
	**/
    public static var INSPECT_MAX_BYTES(get,set):Int;
    private inline static function get_INSPECT_MAX_BYTES():Int {
        return js.Lib.require("buffer").INSPECT_MAX_BYTES;
    }
    private inline static function set_INSPECT_MAX_BYTES(value:Int):Int {
        return js.Lib.require("buffer").INSPECT_MAX_BYTES = value;
    }

	/**
		Returns `true` if the encoding is a valid encoding argument, or `false` otherwise.
	**/
	static function isEncoding(encoding:String):Bool;

	/**
		Tests if `obj` is a `Buffer`.
	**/
	static function isBuffer(obj:Dynamic):Bool;

	/**
		Gives the actual byte length of a string.

		`encoding` defaults to 'utf8'.

		This is not the same as `String.length` since that
		returns the number of characters in a string.
	**/
	static function byteLength(string:String, ?encoding:String):Int;

	/**
		Returns a buffer which is the result of concatenating all the buffers in the `list` together.

		If the `list` has no items, or if the `totalLength` is 0, then it returns a zero-length buffer.
		If the `list` has exactly one item, then the first item of the `list` is returned.
		If the `list` has more than one item, then a new `Buffer` is created.

		If `totalLength` is not provided, it is read from the buffers in the `list`.
		However, this adds an additional loop to the function, so it is faster to provide the length explicitly.
	**/
	static function concat(list:Array<Buffer>, ?totalLength:Int):Buffer;

	/**
		The same as `buf1.compare(buf2)`. Useful for sorting an Array of Buffers.
	**/
	@:native("compare")
	static function compareBuffers(buf1:Buffer, buf2:Buffer):Int;

	/**
		Allocates a new buffer.
	**/
	@:overload(function(string:String, ?encoding:String):Void {})
	@:overload(function(buffer:Buffer):Void {})
	@:overload(function(array:Array<Int>):Void {})
	function new(size:Int):Void;

	/**
		The size of the buffer in bytes.

		Note that this is not necessarily the size of the contents.
		`length` refers to the amount of memory allocated for the buffer object.
		It does not change when the contents of the buffer are changed.
	**/
	var length(default,null):Int;

	/**
		Returns a JSON-representation of the `Buffer` instance.
	**/
	function toJSON():Dynamic;

	/**
		Writes `string` to the buffer at `offset` using the given `encoding`.

		`offset` defaults to 0, encoding defaults to 'utf8'. `length` is the number of bytes to write.

		Returns number of octets written. If buffer did not contain enough space to fit the entire `string`,
		it will write a partial amount of the `string`. `length` defaults to `buffer.length - offset`.

		The method will not write partial characters.
	**/
	@:overload(function(string:String, offset:Int, length:Int, ?encoding:String):Int {})
	@:overload(function(string:String, offset:Int, ?encoding:String):Int {})
	function write(string:String, ?encoding:String):Int;

	/**
		Decodes and returns a string from buffer data encoded with `encoding` (defaults to 'utf8')
		beginning at `start` (defaults to 0) and ending at `end` (defaults to `buffer.length`).
	**/
	@:overload(function(encoding:String, ?start:Int, ?end:Int):String {})
	function toString():String;

	/**
		Does copy between buffers.
		The source and target regions can be overlapped.
		`targetStart` and `sourceStart` default to 0. `sourceEnd` defaults to `buffer.length`.
	**/
	function copy(targetBuffer:Buffer, ?targetStart:Int, ?sourceStart:Int, ?sourceEnd:Int):Void;

	/**
		Returns a new buffer which references the same memory as the old,
		but offset and cropped by the `start` (defaults to 0) and `end` (defaults to `buffer.length`) indexes.
		Negative indexes start from the end of the buffer.

		Modifying the new buffer slice will modify memory in the original buffer!
	**/
	function slice(?start:Int, ?end:Int):Buffer;

	/**
		Reads an unsigned 8 bit integer from the buffer at the specified offset.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readUInt8(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads an unsigned 16 bit integer from the buffer at the specified `offset` with little-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readUInt16LE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads an unsigned 16 bit integer from the buffer at the specified `offset` with big-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readUInt16BE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads an unsigned 32 bit integer from the buffer at the specified `offset` with little-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readUInt32LE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads an unsigned 32 bit integer from the buffer at the specified `offset` with big-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readUInt32BE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads a signed 8 bit integer from the buffer at the specified `offset`.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.

		Works as `readUInt8`, except buffer contents are treated as two's complement signed values.
	**/
	function readInt8(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads a signed 16 bit integer from the buffer at the specified `offset` with little-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.

		Works as `readUInt16LE`, except buffer contents are treated as two's complement signed values.
	**/
	function readInt16LE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads a signed 16 bit integer from the buffer at the specified `offset` with big-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.

		Works as `readUInt16BE`, except buffer contents are treated as two's complement signed values.
	**/
	function readInt16BE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads a signed 32 bit integer from the buffer at the specified `offset` with little-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.

		Works as `readUInt32LE`, except buffer contents are treated as two's complement signed values.
	**/
	function readInt32LE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads a signed 32 bit integer from the buffer at the specified `offset` with big-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.

		Works as `readUInt32BE`, except buffer contents are treated as two's complement signed values.
	**/
	function readInt32BE(offset:Int, ?noAssert:Bool):Int;

	/**
		Reads a 32 bit float from the buffer at the specified `offset` with little-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readFloatLE(offset:Int, ?noAssert:Bool):Float;

	/**
		Reads a 32 bit float from the buffer at the specified `offset` with big-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readFloatBE(offset:Int, ?noAssert:Bool):Float;

	/**
		Reads a 64 bit double from the buffer at the specified `offset` with little-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readDoubleLE(offset:Int, ?noAssert:Bool):Float;

	/**
		Reads a 64 bit double from the buffer at the specified `offset` with big-endian format.

		Set `noAssert` to `true` to skip validation of `offset`.
		This means that `offset` may be beyond the end of the buffer. Defaults to `false`.
	**/
	function readDoubleBE(offset:Int, ?noAssert:Bool):Float;

	/**
		Writes `value` to the buffer at the specified `offset`.
		Note, `value` must be a valid unsigned 8 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeUInt8(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with little-endian format.
		Note, `value` must be a valid unsigned 16 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeUInt16LE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with big-endian format.
		Note, `value` must be a valid unsigned 16 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeUInt16BE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with little-endian format.
		Note, `value` must be a valid unsigned 32 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeUInt32LE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with big-endian format.
		Note, `value` must be a valid unsigned 32 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeUInt32BE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset`.
		Note, `value` must be a valid signed 8 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.

		Works as `writeUInt8`, except `value` is written out as a two's complement signed integer into buffer.
	**/
	function writeInt8(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with little-endian format.
		Note, value must be a valid signed 16 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.

		Works as `writeUInt16LE`, except `value` is written out as a two's complement signed integer into buffer.
	**/
	function writeInt16LE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with big-endian format.
		Note, value must be a valid signed 16 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.

		Works as `writeUInt16BE`, except `value` is written out as a two's complement signed integer into buffer.
	**/
	function writeInt16BE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with little-endian format.
		Note, value must be a valid signed 32 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.

		Works as `writeUInt32LE`, except `value` is written out as a two's complement signed integer into buffer.
	**/
	function writeInt32LE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with big-endian format.
		Note, value must be a valid signed 32 bit integer.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.

		Works as `writeUInt32BE`, except `value` is written out as a two's complement signed integer into buffer.
	**/
	function writeInt32BE(value:Int, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with little-endian format.
		Note, behavior is unspecified if `value` is not a 32 bit float.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeFloatLE(value:Float, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with big-endian format.
		Note, behavior is unspecified if `value` is not a 32 bit float.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeFloatBE(value:Float, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with little-endian format.
		Note, `value` must be a valid 64 bit double.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeDoubleLE(value:Float, offset:Int, ?noAssert:Bool):Void;

	/**
		Writes `value` to the buffer at the specified `offset` with big-endian format.
		Note, `value` must be a valid 64 bit double.

		Set `noAssert` to `true` to skip validation of `value` and `offset`.
		This means that `value` may be too large for the specific function
		and `offset` may be beyond the end of the buffer leading to the values
		being silently dropped. This should not be used unless you are certain
		of correctness. Defaults to `false`.
	**/
	function writeDoubleBE(value:Float, offset:Int, ?noAssert:Bool):Void;

	/**
		Fills the buffer with the specified `value`.
		If the `offset` (defaults to 0) and `end` (defaults to `buffer.length`)
		are not given it will fill the entire buffer.
	**/
	@:overload(function(value:String, ?offset:Int, ?end:Int):Void {})
	function fill(value:Int, ?offset:Int, ?end:Int):Void;

	/**
		Returns a boolean of whether `this` and `otherBuffer` have the same bytes.
	**/
	function equals(otherBuffer:Buffer):Bool;

	/**
		Returns a number indicating whether `this` comes before or after or is the same as the `otherBuffer` in sort order.
	**/
	function compare(otherBuffer:Buffer):Int;
}

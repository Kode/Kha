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

import js.Error;
import js.node.Buffer;
import js.node.zlib.*;

typedef ZlibOptions = {
	/**
		default: `Zlib.Z_NO_FLUSH`
	**/
	@:optional var flush:Int;

	/**
		default: 16*1024
	**/
	@:optional var chunkSize:Int;

	@:optional var windowBits:Int;

	/**
		compression only
	**/
	@:optional var level:Int;

	/**
		compression only
	**/
	@:optional var memLevel:Int;

	/**
		compression only
	**/
	@:optional var strategy:Int;

	/**
		deflate/inflate only, empty dictionary by default
	**/
	@:optional var dictionary:Buffer;
}

/**
	This provides bindings to Gzip/Gunzip, Deflate/Inflate, and DeflateRaw/InflateRaw classes.
	Each class takes the same options, and is a readable/writable Stream.
**/
@:jsRequire("zlib")
extern class Zlib {

	/**
		Allowed `flush` values.
	**/
	static var Z_NO_FLUSH(default,null):Int;
	static var Z_PARTIAL_FLUSH(default,null):Int;
	static var Z_SYNC_FLUSH(default,null):Int;
	static var Z_FULL_FLUSH(default,null):Int;
	static var Z_FINISH(default,null):Int;
	static var Z_BLOCK(default,null):Int;
	static var Z_TREES(default,null):Int;

	/**
		Return codes for the compression/decompression functions.
		Negative values are errors, positive values are used for special but normal events.
	**/
	static var Z_OK(default,null):Int;
	static var Z_STREAM_END(default,null):Int;
	static var Z_NEED_DICT(default,null):Int;
	static var Z_ERRNO(default,null):Int;
	static var Z_STREAM_ERROR(default,null):Int;
	static var Z_DATA_ERROR(default,null):Int;
	static var Z_MEM_ERROR(default,null):Int;
	static var Z_BUF_ERROR(default,null):Int;
	static var Z_VERSION_ERROR(default,null):Int;

	/**
		Compression levels.
	**/
	static var Z_NO_COMPRESSION(default,null):Int;
	static var Z_BEST_SPEED(default,null):Int;
	static var Z_BEST_COMPRESSION(default,null):Int;
	static var Z_DEFAULT_COMPRESSION(default,null):Int;

	/**
		Compression strategy.
	**/
	static var Z_FILTERED(default,null):Int;
	static var Z_HUFFMAN_ONLY(default,null):Int;
	static var Z_RLE(default,null):Int;
	static var Z_FIXED(default,null):Int;
	static var Z_DEFAULT_STRATEGY(default,null):Int;

	/**
		Possible values of the data_type field.
	**/
	static var Z_BINARY(default,null):Int;
	static var Z_TEXT(default,null):Int;
	static var Z_ASCII(default,null):Int;
	static var Z_UNKNOWN(default,null):Int;

	/**
		The deflate compression method (the only one supported in this version).
	**/
	static var Z_DEFLATED(default,null):Int;

	/**
		For initializing zalloc, zfree, opaque.
	**/
	static var Z_NULL(default,null):Int;


	/**
		Returns a new `Gzip` object with an `options`.
	**/
	static function createGzip(?options:ZlibOptions):Gzip;

	/**
		Returns a new `Gunzip` object with an `options`.
	**/
	static function createGunzip(?options:ZlibOptions):Gunzip;

	/**
		Returns a new `Deflate` object with an `options`.
	**/
	static function createDeflate(?options:ZlibOptions):Deflate;

	/**
		Returns a new `Inflate` object with an `options`.
	**/
	static function createInflate(?options:ZlibOptions):Inflate;

	/**
		Returns a new `DeflateRaw` object with an `options`.
	**/
	static function createDeflateRaw(?options:ZlibOptions):DeflateRaw;

	/**
		Returns a new `InflateRaw` object with an `options`.
	**/
	static function createInflateRaw(?options:ZlibOptions):InflateRaw;

	/**
		Returns a new `Unzip` object with an `options`.
	**/
	static function createUnzip(?options:ZlibOptions):Unzip;

	/**
		Compress a string with `Deflate`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function deflate(buf:String, callback:Error->Buffer->Void):Void;

	/**
		Compress a string with `DeflateRaw`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function deflateRaw(buf:String, callback:Error->Buffer->Void):Void;

	/**
		Compress a string with `Gzip`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function gzip(buf:String, callback:Error->Buffer->Void):Void;

	/**
		Decompress a raw Buffer with `Gunzip`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function gunzip(buf:String, callback:Error->Buffer->Void):Void;

	/**
		Decompress a raw Buffer with `Inflate`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function inflate(buf:String, callback:Error->Buffer->Void):Void;

	/**
		Decompress a raw Buffer with `InflateRaw`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function inflateRaw(buf:String, callback:Error->Buffer->Void):Void;

	/**
		Decompress a raw Buffer with `Unzip`.
	**/
	@:overload(function(buf:Buffer, callback:Error->Buffer->Void):Void {})
	static function unzip(buf:String, callback:Error->Buffer->Void):Void;
}

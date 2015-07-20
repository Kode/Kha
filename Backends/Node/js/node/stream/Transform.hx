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
package js.node.stream;

import haxe.extern.EitherType;

/**
	Transform streams are `Duplex` streams where the output is in some way computed from the input.
	They implement both the `Readable` and `Writable` interfaces.

	Examples of Transform streams include:

		- zlib streams
		- crypto streams
**/
@:jsRequire("stream", "Transform")
extern class Transform<TSelf:Transform<TSelf>> extends Duplex<TSelf> {
    // --------- API for stream implementors - see node.js API documentation ---------
    private function new(?options:Duplex.DuplexNewOptions);
    @:overload(function(chunk:String, encoding:String, callback:js.Error->EitherType<String,Buffer>->Void):Void {})
    private function _transform(chunk:Buffer, encoding:String, callback:js.Error->EitherType<String,Buffer>->Void):Void;
    private function _flush(callback:js.Error->Void):Void;
}

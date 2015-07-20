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
package js.node.http;

import haxe.DynamicAccess;
import js.node.stream.Readable;
import js.node.net.Socket;

/**
	An `IncomingMessage` object is created by `Server` or `ClientRequest`
	and passed as the first argument to the 'request' and 'response' event respectively.
	It may be used to access response status, headers and data.
**/
@:jsRequire("http", "IncomingMessage")
extern class IncomingMessage extends Readable<IncomingMessage> {
	/**
		In case of server request, the HTTP version sent by the client.
		In the case of client response, the HTTP version of the connected-to server.
		Probably either '1.1' or '1.0'.
	**/
	var httpVersion(default,null):String;

	/**
		HTTP Version first integer
	**/
	var httpVersionMajor(default,null):Int;

	/**
		HTTP Version second integer
	**/
	var httpVersionMinor(default,null):Int;

	/**
		The request/response headers object.
		Read only map of header names and values. Header names are lower-cased
	**/
	var headers(default,null):DynamicAccess<String>;

	/**
		The request/response trailers object.
		Only populated after the 'end' event.
	**/
	var trailers(default,null):DynamicAccess<String>;

	/**
		Calls `setTimeout` on the `socket` object.
	**/
	function setTimeout(msecs:Int, ?callback:Void->Void):Void;

	/**
		Only valid for request obtained from `Server`.

		The request method as a string.
		Read only. Example: 'GET', 'DELETE'.
	**/
	var method(default,null):Method;

	/**
		Only valid for request obtained from `Server`.

		Request URL string. This contains only the URL that is present in the actual HTTP request.
	**/
	var url(default,null):String;

	/**
		Only valid for response obtained from `ClientRequest`.
		The 3-digit HTTP response status code. E.G. 404.
	**/
	var statusCode(default,null):Int;

	/**
		The `Socket` object associated with the connection.
	**/
	var socket(default,null):Socket;

	/**
		Alias for `socket`.
	**/
	var connection(default,null):Socket;
}

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

import js.node.http.IncomingMessage;
import js.node.http.ClientRequest;
import js.node.http.ServerResponse;
import js.node.https.*;
import js.node.Tls.TlsServerOptions;
import js.node.Tls.TlsConnectOptions;

typedef HttpsRequestOptions = {
	>js.node.Http.HttpRequestOptions,
	>TlsConnectOptions, // TODO: clean those options up
}

/**
	HTTPS is the HTTP protocol over TLS/SSL.
	In Node this is implemented as a separate module.
**/
@:jsRequire("https")
extern class Https {

	/**
		Global instance of `Agent` for all HTTPS client requests.
	**/
	static var globalAgent:Agent;

	/**
		Returns a new HTTPS web server object.
		The options is similar to `Tls.createServer`.
		The `requestListener` is a function which is automatically added to the 'request' event.
	**/
	static function createServer(options:TlsServerOptions, ?listener:IncomingMessage->ServerResponse->Void):Server;

	/**
		Makes a request to a secure web server.

		`options` can be an object or a string. If `options` is a string, it is automatically parsed with `Url.parse`.

		All options from `Http.request` are valid.
	**/
	@:overload(function(options:String, ?callback:IncomingMessage->Void):ClientRequest {})
	static function request(options:HttpsRequestOptions, ?callback:IncomingMessage->Void):ClientRequest;

	/**
		Like `Http.get` but for HTTPS.
	**/
	@:overload(function(options:String, ?callback:IncomingMessage->Void):ClientRequest {})
	static function get(options:HttpsRequestOptions, ?callback:IncomingMessage->Void):ClientRequest;
}

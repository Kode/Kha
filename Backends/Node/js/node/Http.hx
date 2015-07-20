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
import js.node.http.*;

/**
	Type of the options object passed to `Http.request`.
**/
typedef HttpRequestOptions = {
	/**
		A domain name or IP address of the server to issue the request to.
		Defaults to 'localhost'.
	**/
	@:optional var host:String;

	/**
		To support `Url.parse` `hostname` is preferred over `host`
	**/
	@:optional var hostname:String;

	/**
		Port of remote server.
		Defaults to 80.
	**/
	@:optional var port:Int;

	/**
		Local interface to bind for network connections.
	**/
	@:optional var localAddress:String;

	/**
		Unix Domain Socket (use one of `host`:`port` or `socketPath`)
	**/
	@:optional var socketPath:String;

	/**
		A string specifying the HTTP request method.
		Defaults to 'GET'.
	**/
	@:optional var method:Method;

	/**
		Request path.
		Defaults to '/'.
		Should include query string if any. E.G. '/index.html?page=12'
	**/
	@:optional var path:String;

	/**
		An object containing request headers.

		There are a few special headers that should be noted:

			Sending a 'Connection: keep-alive' will notify Node that the connection to the server
			should be persisted until the next request.

			Sending a 'Content-length' header will disable the default chunked encoding.

			Sending an 'Expect' header will immediately send the request headers.
			Usually, when sending 'Expect: 100-continue', you should both set a timeout
			and listen for the continue event. See RFC2616 Section 8.2.3 for more information.

			Sending an Authorization header will override using the auth option to compute basic authentication.
	**/
	@:optional var headers:DynamicAccess<String>;

	/**
		Basic authentication i.e. 'user:password' to compute an Authorization header.
	**/
	@:optional var auth:String;

	/**
		Controls Agent behavior.
		When an Agent is used request will default to Connection: keep-alive.

		Possible values:
			null (default): use global `Agent` for this `host` and `port`.
			`Agent` object: explicitly use the passed in `Agent`.
			false: opts out of connection pooling with an `Agent`, defaults request to 'Connection: close'.
	**/
	@:optional var agent:haxe.extern.EitherType<Agent,Bool>;
}

/**
	The HTTP interfaces in Node are designed to support many features of the protocol
	which have been traditionally difficult to use. In particular, large, possibly chunk-encoded, messages.
	The interface is careful to never buffer entire requests or responses--the user is able to stream data.

	HTTP message headers are represented by an object like this:
		{ 'content-length': '123',
		  'content-type': 'text/plain',
		  'connection': 'keep-alive' }
		Keys are lowercased. Values are not modified.

	In order to support the full spectrum of possible HTTP applications, Node's HTTP API is very low-level.
	It deals with stream handling and message parsing only. It parses a message into headers and body but
	it does not parse the actual headers or the body.
**/
@:jsRequire("http")
extern class Http {

	/**
		A collection of all the standard HTTP response status codes, and the short description of each.
		For example, http.STATUS_CODES["404"] == 'Not Found'.
	**/
	static var STATUS_CODES(default,null):DynamicAccess<String>;

	/**
		Global instance of Agent which is used as the default for all http client requests.
	**/
	static var globalAgent:Agent;

	/**
		Returns a new web server object.

		The `requestListener` is a function which is automatically added to the 'request' event.
	**/
	static function createServer(?requestListener:IncomingMessage->ServerResponse->Void):Server;

	/**
		This function is deprecated; please use `request` instead.

		Constructs a new HTTP client.
		`port` and `host` refer to the server to be connected to.
	**/
	@:deprecated("This function is deprecated; please use `request` instead.")
	static function createClient(?port:Int, ?host:String):Client;

	/**
		Node maintains several connections per server to make HTTP requests.
		This function allows one to transparently issue requests.

		`options` can be an object or a string. If `options` is a string, it is automatically parsed with `Url.parse`.

		The optional `callback` parameter will be added as a one time listener for the 'response' event.
	**/
	@:overload(function(options:String, ?callback:IncomingMessage->Void):ClientRequest {})
	static function request(options:HttpRequestOptions, ?callback:IncomingMessage->Void):ClientRequest;

	/**
		Since most requests are GET requests without bodies, Node provides this convenience method.
		The only difference between this method and `request` is that it sets the method to GET
		and calls req.end() automatically.
	**/
	@:overload(function(options:String, ?callback:IncomingMessage->Void):ClientRequest {})
	static function get(options:HttpRequestOptions, ?callback:IncomingMessage->Void):ClientRequest;
}

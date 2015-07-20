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

import js.node.events.EventEmitter.Event;
import js.node.stream.Writable;

/**
	Enumeration of events emitted by the `ServerResponse` objects in addition to its parent class events.
**/
@:enum abstract ServerResponseEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
	/**
		Indicates that the underlying connection was terminated before `end` was called or able to flush.
	**/
	var Close : ServerResponseEvent<Void->Void> = "close";

	/**
		Emitted when the response has been sent. More specifically, this event is emitted when
		the last segment of the response headers and body have been handed off to the operating system
		for transmission over the network. It does not imply that the client has received anything yet.

		After this event, no more events will be emitted on the response object.
	**/
	var Finish : ServerResponseEvent<Void->Void> = "finish";
}

/**
	This object is created internally by a HTTP server--not by the user.
	It is passed as the second parameter to the 'request' event.
**/
@:jsRequire("http", "ServerResponse")
extern class ServerResponse extends Writable<ServerResponse> {

	/**
		Sends a HTTP/1.1 100 Continue message to the client, indicating that the request body should be sent.
		See the 'checkContinue' event on `Server`.
	 */
	function writeContinue():Void;

	/**
		Sends a response header to the request.
		The status code is a 3-digit HTTP status code, like 404.
		The last argument, `headers`, are the response headers.
		Optionally one can give a human-readable `reasonPhrase` as the second argument.

		This method must only be called once on a message and it must be called before `end` is called.

		If you call `write` or `end` before calling this, the implicit/mutable headers
		will be calculated and call this function for you.

		Note: that Content-Length is given in bytes not characters.
	**/
	@:overload(function(statusCode:Int, ?headers:DynamicAccess<String>):Void {})
	function writeHead(statusCode:Int, reasonPhrase:String, ?headers:DynamicAccess<String>):Void;

	/**
		Sets the `Socket`'s timeout value to `msecs`.
		If a `callback` is provided, then it is added as a listener on the 'timeout' event on the response object.

		If no 'timeout' listener is added to the request, the response, or the server,
		then sockets are destroyed when they time out. If you assign a handler on the request,
		the response, or the server's 'timeout' events, then it is your responsibility to handle timed out sockets.
	**/
	function setTimeout(msecs:Int, ?callback:Void->Void):Void;

	/**
		When using implicit headers (not calling `writeHead` explicitly), this property controls the status code
		that will be sent to the client when the headers get flushed.
	**/
	var statusCode:Int;

	/**
		True if headers were sent, false otherwise.
	**/
	var headersSent(default,null):Bool;

	/**
		When true, the Date header will be automatically generated and sent in the response
		if it is not already present in the headers.
		Defaults to true.

		This should only be disabled for testing; HTTP requires the Date header in responses.
	**/
	var sendDate:Bool;

	/**
		Reads out a header that's already been queued but not sent to the client.
		Note that the name is case insensitive.
		This can only be called before headers get implicitly flushed.
	**/
	function getHeader(name:String):String;

	/**
		Sets a single header value for implicit headers.
		If this header already exists in the to-be-sent headers, its value will be replaced.
		Use an array of strings here if you need to send multiple headers with the same name.
	**/
	@:overload(function(name:String, value:Array<String>):Void {})
	function setHeader(name:String, value:String):Void;

	/**
		Removes a header that's queued for implicit sending.
	**/
	function removeHeader(name:String):Void;

	/**
		This method adds HTTP trailing headers (a header but at the end of the message) to the response.

		Trailers will only be emitted if chunked encoding is used for the response;
		if it is not (e.g., if the request was HTTP/1.0), they will be silently discarded.

		Note that HTTP requires the 'Trailer' header to be sent if you intend to emit trailers,
		with a list of the header fields in its value.
	**/
    @:overload(function(headers:Array<Array<String>>):Void {})
    function addTrailers(headers:DynamicAccess<String>):Void;
}

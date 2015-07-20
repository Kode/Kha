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

import js.node.Buffer;
import js.node.events.EventEmitter.Event;
import js.node.net.Socket;
import js.node.stream.Writable;

/**
	Enumeration of events emitted by `ClientRequest`
**/
@:enum abstract ClientRequestEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
	/**
		Emitted when a response is received to this request. This event is emitted only once.
	**/
	var Response : ClientRequestEvent<IncomingMessage->Void> = "response";

	/**
		Emitted after a socket is assigned to this request.
	**/
	var Socket : ClientRequestEvent<Socket->Void> = "socket";

	/**
		Emitted each time a server responds to a request with a CONNECT method.
		If this event isn't being listened for, clients receiving a CONNECT method
		will have their connections closed.
	**/
	var Connect : ClientRequestEvent<IncomingMessage->Socket->Buffer->Void> = "connect";

	/**
		Emitted each time a server responds to a request with an upgrade.
		If this event isn't being listened for, clients receiving an upgrade header
		will have their connections closed.
	**/
	var Upgrade : ClientRequestEvent<IncomingMessage->Socket->Buffer->Void> = "upgrade";

	/**
		Emitted when the server sends a '100 Continue' HTTP response,
		usually because the request contained 'Expect: 100-continue'.
		This is an instruction that the client should send the request body.
	**/
	var Continue : ClientRequestEvent<Void->Void> = "continue";
}

/**
	This object is created internally and returned from `Http.request`.

	It represents an in-progress request whose header has already been queued.
	The header is still mutable using the `setHeader`, `getHeader` and `removeHeader`.
	The actual header will be sent along with the first data chunk or when closing the connection.

	To get the response, add a listener for 'response' to the request object.
	'response' will be emitted from the request object when the response headers have been received.
	The 'response' event is executed with one argument which is an instance of `IncomingMessage`.

	During the 'response' event, one can add listeners to the response object;
	particularly to listen for the 'data' event.

	If no 'response' handler is added, then the response will be entirely discarded.
	However, if you add a 'response' event handler, then you must consume the data from the response object,
	either by calling `read` whenever there is a 'readable' event, or by adding a 'data' handler, or by calling
	the `resume` method. Until the data is consumed, the 'end' event will not fire. Also, until the data is read
	it will consume memory that can eventually lead to a 'process out of memory' error.

	Note: Node does not check whether 'Content-Length' and the length of the body which has been transmitted are equal or not.
**/
@:jsRequire("http", "ClientRequest")
extern class ClientRequest extends Writable<ClientRequest> {

	/**
		Get header value
	**/
	function getHeader(name:String):String;

	/**
		Set header value.

		Headers can only be modified before the request is sent.
	**/
	function setHeader(name:String, value:String):Void;

	/**
		Remove header

		Headers can only be modified before the request is sent.
	**/
	function removeHeader(name:String):String;

	/**
		Flush the request headers.

		For efficiency reasons, node.js normally buffers the request headers until you call `request.end()`
		or write the first chunk of request data. It then tries hard to pack the request headers and data
		into a single TCP packet.

		That's usually what you want (it saves a TCP round-trip) but not when the first data isn't sent
		until possibly much later. `flushHeaders` lets you bypass the optimization and kickstart the request.
	**/
	function flushHeaders():Void;

	/**
		Aborts a request.
	**/
	function abort():Void;

	/**
		Once a socket is assigned to this request and is connected
		`socket.setTimeout` will be called.
	**/
	function setTimeout(timeout:Int, ?callback:Void->Void):Void;

	/**
		Once a socket is assigned to this request and is connected
		`socket.setNoDelay` will be called.
	**/
	function setNoDelay(?noDelay:Bool):Void;

	/**
		Once a socket is assigned to this request and is connected
		`socket.setKeepAlive`() will be called.
	**/
    @:overload(function(?initialDelay:Int):Void {})
    function setSocketKeepAlive(enable:Bool, ?initialDelay:Int):Void;
}

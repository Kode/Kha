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

/**
	Enumeration of events emitted by `http.Server` class in addition to
	its parent `net.Server` class.
**/
@:enum abstract ServerEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
	/**
		Emitted each time there is a request.

		Note that there may be multiple requests per connection (in the case of keep-alive connections).
	**/
	var Request : ServerEvent<IncomingMessage->ServerResponse->Void> = "request";

	/**
		When a new TCP stream is established.
		Usually users will not want to access this event.
		In particular, the socket will not emit readable events because of how the protocol parser attaches to the socket.
		The socket can also be accessed at request.socket.
	**/
	var Connection : ServerEvent<Socket->Void> = "connection";

	/**
		Emitted when the server closes.
	**/
	var Close : ServerEvent<Void->Void> = "close";

	/**
		Emitted each time a request with an http Expect: 100-continue is received.

		If this event isn't listened for, the server will automatically respond with a 100 Continue as appropriate.

		Handling this event involves calling `response.writeContinue` if the client should continue
		to send the request body, or generating an appropriate HTTP response (e.g., 400 Bad Request) if the client
		should not continue to send the request body.

		Note that when this event is emitted and handled, the 'request' event will not be emitted.
	**/
	var CheckContinue : ServerEvent<IncomingMessage->ServerResponse->Void> = "checkContinue";

	/**
		Emitted each time a client requests a http CONNECT method.

		If this event isn't listened for, then clients requesting a CONNECT method will have their connections closed.

		Listener arguments:
			request - arguments for the http request, as it is in the request event
			socket - network socket between the server and client
			head - the first packet of the tunneling stream, this may be empty

		After this event is emitted, the request's socket will not have a 'data' event listener,
		meaning you will need to bind to it in order to handle data sent to the server on that socket.
	**/
	var Connect : ServerEvent<IncomingMessage->Socket->Buffer->Void> = "connect";

	/**
		Emitted each time a client requests a http upgrade.

		If this event isn't listened for, then clients requesting an upgrade will have their connections closed.

		Listener arguments:
			request - arguments for the http request, as it is in the request event
			socket - network socket between the server and client
			head - the first packet of the tunneling stream, this may be empty

		After this event is emitted, the request's socket will not have a data event listener,
		meaning you will need to bind to it in order to handle data sent to the server on that socket.
	**/
	var Upgrade : ServerEvent<IncomingMessage->Socket->Buffer->Void> = "upgrade";

	/**
		If a client connection emits an 'error' event - it will forwarded here.
	**/
	var ClientError : ServerEvent<js.Error->Socket->Void> = "clientError";
}

/**
	HTTP server
**/
@:jsRequire("http", "Server")
extern class Server extends js.node.net.Server {
	/**
		Limits maximum incoming headers count, equal to 1000 by default.
		If set to 0 - no limit will be applied.
	**/
	var maxHeadersCount:Int;

	/**
		Sets the timeout value for sockets, and emits a 'timeout' event on the `Server` object,
		passing the socket as an argument, if a timeout occurs.

		If there is a 'timeout' event listener on the `Server` object,
		then it will be called with the timed-out socket as an argument.

		By default, the Server's timeout value is 2 minutes, and sockets are destroyed automatically if they time out.
		However, if you assign a callback to the Server's 'timeout' event, then you are responsible
		for handling socket timeouts.
	**/
	function setTimeout(msecs:Int, ?callback:js.node.net.Socket->Void):Void;

	/**
		The number of milliseconds of inactivity before a socket is presumed to have timed out.

		Note that the socket timeout logic is set up on connection, so changing this value
		only affects new connections to the server, not any existing connections.

		Set to 0 to disable any kind of automatic timeout behavior on incoming connections.

		Default: 120000 (2 minutes)
	**/
	var timeout:Int;
}

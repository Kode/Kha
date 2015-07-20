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
package js.node.tls;

import js.node.Buffer;
import js.node.Crypto.CredentialOptions;
import js.node.events.EventEmitter.Event;

/**
	Enumeration of events emitted by `Server` in addition to its parent classes.
**/
@:enum abstract ServerEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
	/**
		This event is emitted after a new connection has been successfully handshaked.
	**/
	var SecureConnection : ServerEvent<CleartextStream->Void> = "secureConnection";

	/**
		When a client connection emits an 'error' event before secure connection is established -
		it will be forwarded here.

		Listener arguments:
			exception - error object
			securePair - a secure pair that the error originated from
	**/
	var ClientError : ServerEvent<js.Error->SecurePair->Void> = "clientError";

	/**
		Emitted on creation of TLS session.
		May be used to store sessions in external storage.

		Listener arguments:
			sessionId
			sessionData
	**/
	var NewSession : ServerEvent<Buffer->Buffer->Void> = "newSession";

	/**
		Emitted when client wants to resume previous TLS session.

		Event listener may perform lookup in external storage using given sessionId,
		and invoke callback(null, sessionData) once finished.

		If session can't be resumed (i.e. doesn't exist in storage) one may call callback(null, null).

		Calling callback(err) will terminate incoming connection and destroy socket.

		Listener arguments:
			sessionId
			callback
	**/
	var ResumeSession : ServerEvent<Buffer->(js.Error->?Buffer->Void)->Void>= "resumeSession";
}

/**
	This class is a subclass of `net.Server` and has the same methods on it.
	Instead of accepting just raw TCP connections, this accepts encrypted connections using TLS or SSL.
**/
@:jsRequire("tls", "Server")
extern class Server extends js.node.net.Server {
	/**
		Add secure context that will be used if client request's SNI hostname
		is matching passed hostname (wildcards can be used).
	**/
	function addContext(hostname:String, credentials:CredentialOptions):Void;
}

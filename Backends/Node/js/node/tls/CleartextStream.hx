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

import js.node.events.EventEmitter.Event;
import js.node.net.Socket.NetworkAdress;

@:enum abstract CleartextStreamEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
	/**
		This event is emitted after a new connection has been successfully handshaked.

		The listener will be called no matter if the server's certificate was authorized or not.

		It is up to the user to test `CleartextStream.authorized` to see
		if the server certificate was signed by one of the specified CAs.

		If `CleartextStream.authorized` is false then the error can be found in `CleartextStream.authorizationError`.

		Also if NPN was used - you can check `CleartextStream.npnProtocol` for negotiated protocol.
	**/
	var SecureConnect : CleartextStreamEvent<Void->Void> = "secureConnect";
}

/**
	This is a stream on top of the Encrypted stream that
	makes it possible to read/write an encrypted data as a cleartext data.

	A `ClearTextStream` is the `cleartext` member of a `SecurePair` object.
**/
extern class CleartextStream extends CryptoStream {

	/**
		A boolean that is true if the peer certificate was signed by one of the specified CAs, otherwise false
	**/
	var authorized(default,null):Bool;

	/**
		The reason why the peer's certificate has not been verified.
		This property becomes available only when `authorized` is false.
	**/
	var authorizationError(default,null):String;

	/**
		The string representation of the remote IP address.
		For example, '74.125.127.100' or '2001:4860:a005::68'.
	**/
	var remoteAddress(default,null):String;

	/**
		The numeric representation of the remote port.
		For example, 443.
	**/
	var remotePort(default,null):Int;

	/**
		Negotiated protocol name.
	**/
	var npnProtocol(default,null):String;

	/**
		Returns an object representing the peer's certificate.
		The returned object has some properties corresponding to the field of the certificate.

		If the peer does not provide a certificate, it returns null or an empty object.
	**/
	function getPeerCertificate():Dynamic<Dynamic>; // TODO: do we want a type for this?

	/**
		Returns an object representing the cipher name and the SSL/TLS protocol version of the current connection.
		Example: { name: 'AES256-SHA', version: 'TLSv1/SSLv3' }

		See SSL_CIPHER_get_name() and SSL_CIPHER_get_version() in http://www.openssl.org/docs/ssl/ssl.html#DEALING_WITH_CIPHERS
		for more information.
	**/
	function getCipher():{name:String, version:String};

	/**
		Returns the bound address, the address family name and port
		of the underlying socket as reported by the operating system.
	**/
	function address():NetworkAdress;
}

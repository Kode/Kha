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

import haxe.extern.EitherType;

import js.node.Buffer;
import js.node.crypto.Credentials;
import js.node.crypto.SecureContext;
import js.node.net.Socket;
import js.node.tls.CleartextStream;
import js.node.tls.SecurePair;
import js.node.tls.Server;

// TODO: clean up these options structures keeping in mind that they are used by https as well

/**
	Base structure for options object used in tls methods.
**/
typedef TlsOptions = {
	/**
		passphrase for the private key or pfx.
	**/
	@:optional var passphrase:String;

	/**
		PEM encoded CRLs (Certificate Revocation List)
	**/
	@:optional var crl:EitherType<String,Array<String>>;

	/**
		ciphers to use or exclude.

		To mitigate BEAST attacks it is recommended that you use this option in conjunction with the `honorCipherOrder`
		option described below to prioritize the non-CBC cipher.

		Defaults to AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH.

		Consult the OpenSSL cipher list format documentation for details on the format.
		ECDH (Elliptic Curve Diffie-Hellman) ciphers are not yet supported.
	**/
	@:optional var ciphers:String;

	/**
		Abort the connection if the SSL/TLS handshake does not finish in this many milliseconds.
		The default is 120 seconds.
		A 'clientError' is emitted on the tls.Server object whenever a handshake times out.
	**/
	@:optional var handshakeTimeout:Int;

	/**
		When choosing a cipher, use the server's preferences instead of the client preferences.

		Note that if SSLv2 is used, the server will send its list of preferences to the client,
		and the client chooses the cipher.

		Although, this option is disabled by default, it is recommended that you use this option
		in conjunction with the `ciphers` option to mitigate BEAST attacks.
	**/
	@:optional var honorCipherOrder:Bool;

	/**
		If true the server will request a certificate from clients that connect
		and attempt to verify that certificate.
		Default: false.
	**/
	@:optional var requestCert:Bool;

	/**
		If true the server will reject any connection which is not authorized with the list of supplied CAs.
		This option only has an effect if `requestCert` is true.
		Default: false.
	**/
	@:optional var rejectUnauthorized:Bool;

	/**
		possible NPN protocols. (Protocols should be ordered by their priority).
	**/
	@:optional var NPNProtocols:Array<EitherType<String,Buffer>>;

	/**
		A function that will be called if client supports SNI TLS extension.
		Only one argument will be passed to it: `servername`.
		And SNICallback should return SecureContext instance.
		(You can use `Crypto.createCredentials(...).context` to get proper `SecureContext`).
		If SNICallback wasn't provided - default callback with high-level API will be used.
	**/
	@:optional var SNICallback:String->SecureContext;

	/**
		opaque identifier for session resumption.
		If `requestCert` is true, the default is MD5 hash value generated from command-line.
		Otherwise, the default is not provided.
	**/
	@:optional var sessionIdContext:String;

	/**
		The SSL method to use, e.g. SSLv3_method to force SSL version 3.
		The possible values depend on your installation of OpenSSL and are defined in the constant SSL_METHODS.
		TODO: make an abstract enum for that
	**/
	@:optional var secureProtocol:String;
}

/**
	Structure to use to configure pfx
**/
typedef TlsOptionsPfx = {
	>TlsOptions,

	/**
		private key, certificate and CA certs of the server in PFX or PKCS12 format.
	**/
	var pfx:EitherType<String,Buffer>;
}

/**
	Structure to use to configure PEM
**/
typedef TlsOptionsPem = {
	>TlsOptions,

	/**
		private key of the server in PEM format.
	**/
	var key:EitherType<String,Buffer>;

	/**
		certificate key of the server in PEM format.
	**/
	var cert:EitherType<String,Buffer>;

	/**
		trusted certificates in PEM format.
		If this is omitted several well known "root" CAs will be used, like VeriSign.
		These are used to authorize connections.
	**/
	@:optional var ca:Array<EitherType<String,Buffer>>;
}

typedef TlsServerOptions = EitherType<TlsOptionsPem,TlsOptionsPfx>;


typedef TlsConnectOptions = {
	/**
		Host the client should connect to.
		Defaults to 'localhost'
	**/
	@:optional var host:String;

	/**
		Port the client should connect to
	**/
	@:optional var port:Int;

	/**
		Establish secure connection on a given socket rather than creating a new socket.
		If this option is specified, `host` and `port` are ignored.
	**/
	@:optional var socket:Socket;

	/**
		passphrase for the private key or pfx.
	**/
	@:optional var passphrase:String;

	/**
		If true, the server certificate is verified against the list of supplied CAs.
		An 'error' event is emitted if verification fails. Default: true.
	**/
	@:optional var rejectUnauthorized:Bool;

	/**
		supported NPN protocols.
		Buffers should have following format: 0x05hello0x05world, where first byte is next protocol name's length.
		Passing array of strings should usually be much simpler: ['hello', 'world'].
	**/
	@:optional var NPNProtocols:Array<EitherType<String,Buffer>>;

	/**
		Servername for SNI (Server Name Indication) TLS extension.
	**/
	@:optional var servername:String;

	/**
		The SSL method to use, e.g. SSLv3_method to force SSL version 3.
		The possible values depend on your installation of OpenSSL and are defined in the constant SSL_METHODS.
		TODO: make an abstract enum for that
	**/
	@:optional var secureProtocol:String;
}

/**
	Structure to use to configure pfx
**/
typedef TlsConnectOptionsPfx = {
	>TlsConnectOptions,

	/**
		private key, certificate and CA certs of the client in PFX or PKCS12 format.
	**/
	var pfx:EitherType<String,Buffer>;
}

/**
	Structure to use to configure PEM
**/
typedef TlsConnectOptionsPem = {
	>TlsConnectOptions,

	/**
		private key of the client in PEM format.
	**/
	var key:EitherType<String,Buffer>;

	/**
		certificate key of the client in PEM format.
	**/
	var cert:EitherType<String,Buffer>;

	/**
		trusted certificates in PEM format.
		If this is omitted several well known "root" CAs will be used, like VeriSign.
		These are used to authorize connections.
	**/
	@:optional var ca:Array<EitherType<String,Buffer>>;
}


/**
	The tls module uses OpenSSL to provide Transport Layer Security
	and/or Secure Socket Layer: encrypted stream communication.
**/
@:jsRequire("tls")
extern class Tls {

	/**
		renegotiation limit, default is 3.
	**/
	static var CLIENT_RENEG_LIMIT:Int;

	/**
		renegotiation window in seconds, default is 10 minutes.
	**/
	static var CLIENT_RENEG_WINDOW:Int;

	/**
		Size of slab buffer used by all tls servers and clients. Default: 10 * 1024 * 1024.

		Don't change the defaults unless you know what you are doing.
	**/
	static var SLAB_BUFFER_SIZE :Int;

	/**
		Returns an array with the names of the supported SSL ciphers.
	**/
	static function getCiphers():Array<String>;

	/**
		Creates a new `Server`.
		The `connectionListener` argument is automatically set as a listener for the 'secureConnection' event.
	**/
	static function createServer(options:TlsServerOptions, ?secureConnectionListener:CleartextStream->Void):Server;

	/**
		Creates a new client connection to the given `port` and `host` (old API) or `options.port` and `options.host`.
		If `host` is omitted, it defaults to 'localhost'.
	**/
	@:overload(function(port:Int, ?callback:Void->Void):CleartextStream {})
	@:overload(function(port:Int, options:TlsConnectOptions, ?callback:Void->Void):CleartextStream {})
	@:overload(function(port:Int, host:String, ?callback:Void->Void):CleartextStream {})
	@:overload(function(port:Int, host:String, options:TlsConnectOptions, ?callback:Void->Void):CleartextStream {})
	static function connect(options:TlsConnectOptions, ?callback:Void->Void):CleartextStream;

	/**
		Creates a new secure pair object with two streams, one of which reads/writes encrypted data,
		and one reads/writes cleartext data. Generally the encrypted one is piped to/from an incoming
		encrypted data stream, and the cleartext one is used as a replacement for the initial encrypted stream.

		`credentials`: A credentials object from `Crypto.createCredentials()`

		`isServer`: A boolean indicating whether this tls connection should be opened as a server or a client.

		`requestCert`: A boolean indicating whether a server should request a certificate from a connecting client.
		Only applies to server connections.

		`rejectUnauthorized`: A boolean indicating whether a server should automatically reject clients with invalid certificates.
		 Only applies to servers with `requestCert` enabled.
	**/
	@:overload(function(?credentials:Credentials, ?isServer:Bool, ?requestCert:Bool, ?rejectUnauthorized:Bool):SecurePair {})
	static function createSecurePair(?credentials:Credentials, ?isServer:Bool):SecurePair;
}

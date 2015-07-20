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
import js.Error;
import js.node.Buffer;
import js.node.crypto.*;
import js.node.crypto.DiffieHellman.IDiffieHellman;

/**
	Enumerations of crypto algorighms to be used.
**/
@:enum abstract CryptoAlgorithm(String) from String to String {
	var SHA1 = "sha1";
	var MD5 = "md5";
	var SHA256 = "sha256";
	var SHA512 = "sha512";
}

typedef CredentialOptions = {
	/**
		PFX or PKCS12 encoded private key, certificate and CA certificates
	**/
	pfx:EitherType<String,Buffer>,

	/**
		PEM encoded private key
	**/
	key:String,

	/**
		passphrase for the private key or pfx
	**/
	passphrase:String,

	/**
		PEM encoded certificate
	**/
	cert:String,

	/**
		PEM encoded CA certificates to trust.
		If no `ca` details are given, then node.js will use the default publicly trusted list of CAs as given in
		http://mxr.mozilla.org/mozilla/source/security/nss/lib/ckfw/builtins/certdata.txt.
	**/
	?ca:EitherType<String,Array<String>>,

	/**
		PEM encoded CRLs (Certificate Revocation List)
	**/
	crl:EitherType<String,Array<String>>,

	/**
		ciphers to use or exclude.
		Consult http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT for details on the format.
	**/
	ciphers:String,

}

/**
	Enumeration of supported group names for `Crypto.getDiffieHellman`.
**/
@:enum abstract DiffieHellmanGroupName(String) from String to String {
	var Modp1 = "modp1";
	var Modp2 = "modp2";
	var Modp5 = "modp5";
	var Modp14 = "modp14";
	var Modp15 = "modp15";
	var Modp16 = "modp16";
	var Modp17 = "modp17";
	var Modp18 = "modp18";
}

/**
	The crypto module offers a way of encapsulating secure credentials to be used as part of a secure HTTPS net or http connection.
	It also offers a set of wrappers for OpenSSL's hash, hmac, cipher, decipher, sign and verify methods.
**/
@:jsRequire("crypto")
extern class Crypto {
	/**
		The default encoding to use for functions that can take either strings or buffers.
		The default value is 'buffer', which makes it default to using `Buffer` objects.
		This is here to make the crypto module more easily compatible with legacy programs
		that expected 'binary' to be the default encoding.

		Note that new programs will probably expect buffers, so only use this as a temporary measure.
	**/
	@:deprecated
	static var DEFAULT_ENCODING:String;

	/**
		Returns an array with the names of the supported ciphers.
	**/
	static function getCiphers():Array<String>;

	/**
		Returns an array with the names of the supported hash algorithms.
	**/
	static function getHashes():Array<String>;

	/**
		Creates a credentials object
	**/
	static function createCredentials(?details:CredentialOptions):Credentials;

	/**
		Creates and returns a hash object, a cryptographic hash with the given algorithm which can be used to generate hash digests.
		`algorithm` is dependent on the available algorithms supported by the version of OpenSSL on the platform.
		Examples are 'sha1', 'md5', 'sha256', 'sha512', etc.
		On recent releases, openssl list-message-digest-algorithms will display the available digest algorithms.
	**/
	static function createHash(algorithm:CryptoAlgorithm):Hash;


	/**
		Creates and returns a hmac object, a cryptographic hmac with the given algorithm and key.
		`algorithm` is dependent on the available algorithms supported by OpenSSL - see `createHash` above.
		`key` is the hmac key to be used.
	**/
	@:overload(function(algorithm:CryptoAlgorithm, key:String):Hmac {})
	static function createHmac(algorithm:CryptoAlgorithm, key:Buffer):Hmac;

	/**
		Creates and returns a cipher object, with the given algorithm and password.

		`algorithm` is dependent on OpenSSL, examples are 'aes192', etc.
		On recent releases, openssl list-cipher-algorithms will display the available cipher algorithms.

		`password` is used to derive key and IV, which must be a 'binary' encoded string or a buffer.

		It is a stream that is both readable and writable. The written data is used to compute the hash.
		Once the writable side of the stream is ended, use the `read` method to get the computed hash digest.
		The legacy `update` and `digest` methods are also supported.
	**/
	static function createCipher(algorithm:String, password:EitherType<String,Buffer>):Cipher;

	/**
		Creates and returns a cipher object, with the given algorithm, key and iv.

		`algorithm` is the same as the argument to `createCipher`.

		`key` is the raw key used by the algorithm.

		`iv` is an initialization vector.

		`key` and `iv` must be 'binary' encoded strings or buffers.
	**/
	static function createCipheriv(algorithm:String, key:EitherType<String,Buffer>, iv:EitherType<String,Buffer>):Cipher;

	/**
		Creates and returns a decipher object, with the given algorithm and key.
		This is the mirror of the `createCipher` above.
	**/
	static function createDecipher(algorithm:String, password:EitherType<String,Buffer>):Decipher;

	/**
		Creates and returns a decipher object, with the given algorithm, key and iv.
		This is the mirror of the `createCipheriv` above.
	**/
	static function createDecipheriv(algorithm:String, key:EitherType<String,Buffer>, iv:EitherType<String,Buffer>):Decipher;


	/**
		Creates and returns a signing object, with the given algorithm.
		On recent OpenSSL releases, openssl list-public-key-algorithms will display the available signing algorithms.
		Example: 'RSA-SHA256'.
	**/
	static function createSign(algorithm:String):Sign;

	/**
		Creates and returns a verification object, with the given algorithm.
		This is the mirror of the signing object above.
	**/
	static function createVerify(algorithm:String):Verify;


	/**
		Creates a Diffie-Hellman key exchange object using the supplied `prime` or generated prime of given bit `prime_length`.
		The generator used is 2. `encoding` can be 'binary', 'hex', or 'base64'.

		Creates a Diffie-Hellman key exchange object and generates a prime of the given bit length. The generator used is 2.
	**/
	@:overload(function(prime_length:Int):DiffieHellman {})
	@:overload(function(prime:Buffer):DiffieHellman {})
	static function createDiffieHellman(prime:String, encoding:String):DiffieHellman;

	/**
		Creates a predefined Diffie-Hellman key exchange object.
		The supported groups are: 'modp1', 'modp2', 'modp5' (defined in RFC 2412) and 'modp14', 'modp15', 'modp16', 'modp17', 'modp18' (defined in RFC 3526).
		The returned object mimics the interface of objects created by `createDiffieHellman` above,
		but will not allow to change the keys (with setPublicKey() for example).
		The advantage of using this routine is that the parties don't have to generate nor exchange group modulus beforehand,
		saving both processor and communication time.
	**/
	static function getDiffieHellman(group_name:DiffieHellmanGroupName):IDiffieHellman;


	/**
		Asynchronous PBKDF2 applies pseudorandom function HMAC-SHA1 to derive a key of given length
		from the given password, salt and iterations.
	**/
	static function pbkdf2(password:EitherType<String,Buffer>, salt:EitherType<String,Buffer>, iterations:Int, keylen:Int, callback:Error->String->Void):Void;

	/**
		Synchronous PBKDF2 function. Returns derivedKey or throws error.
	**/
	static function pbkdf2Sync(password:EitherType<String,Buffer>, salt:EitherType<String,Buffer>, iterations:Int, keylen:Int):String;

	/**
		Generates cryptographically strong pseudo-random data.

		If `callback` is specified, the function runs asynchronously, otherwise it will block and synchronously
		return random bytes.

		NOTE: Will throw error or invoke callback with error, if there is not enough accumulated entropy
		to generate cryptographically strong data. In other words, `randomBytes` without callback will not
		block even if all entropy sources are drained.
	**/
	@:overload(function(size:Int, callback:Error->Buffer->Void):Void {})
	static function randomBytes(size:Int):Buffer;

	/**
		Generates non-cryptographically strong pseudo-random data.

		The data returned will be unique if it is sufficiently long, but is not necessarily unpredictable.
		For this reason, the output of this function should never be used where unpredictability is important,
		such as in the generation of encryption keys.

		Usage is otherwise identical to `randomBytes`.
	**/
	@:overload(function(size:Int, callback:Error->Buffer->Void):Void {})
	static function pseudoRandomBytes(size:Int):Buffer;
}

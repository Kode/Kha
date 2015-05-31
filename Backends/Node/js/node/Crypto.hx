package js.node;

import js.node.Buffer;
import js.support.Callback;

/* CRYPTO ..................................... */
  
typedef CryptoCredDetails = {
  var key:String;
  var cert:String;
  var ca:Array<String>;
  /*
    TODO
  */
}

typedef CryptoPeerCert = {
  var subject:String;
  var issuer:String;
  var valid_from:String;
  var valid_to:String;
}

typedef CryptoCreds = Dynamic;

typedef CryptoHmac = {
  function update(data:Dynamic):Void;
  function digest(?enc:String):String;
}
  
typedef CryptoHash = {
  function update(data:Dynamic):Void;
  function digest(?enc:String):String;
  function createHmac(algo:String,key:String):CryptoHmac;
}

typedef CryptoCipher = {
  function update(data:Dynamic,?input_enc:String,?output_enc:String):Dynamic;
  function final(output_enc:String):Void;
  function setAutoPadding(padding:Bool):Void; // default true
}
  
typedef CryptoDecipher = {
  function update(data:Dynamic,?input_enc:String,?output_enc:String):Dynamic;
  function final(?output_enc:String):Dynamic;
  function setAutoPadding(padding:Bool):Void; // default true
}
  
typedef CryptoSigner = {
  function update(data:Dynamic):Void;
  function sign(private_key:String,?output_format:String):Dynamic;
}
  
typedef CryptoVerify = {
  function update(data:Dynamic):Void;
  function verify(cert:String,?sig_format:String):Bool;
}

typedef CryptoDiffieHellman = {
    function generateKeys(?enc:String):String;
    function computeSecret(otherPublicKey:String,?inputEnc:String,?outputEnc:String):String;
    function getPrime(?enc:String):Int;
    function getGenerator(?enc:String):String;
    function getPublicKey(?enc:String):String;
    function getPrivateKey(?enc:String):String;
    function setPublicKey(pubKey:String,?enc:String):Void;
    function setPrivateKey(privKey:String,?enc:String):Void;
}

extern class Crypto
implements npm.Package.Require<"crypto","*"> 
{
  static function createCredentials(details:CryptoCredDetails):CryptoCreds;
  static function createHash(algo:String):CryptoHash; // 'sha1', 'md5', 'sha256', 'sha512'
  static function createCipher(algo:String,password:String):CryptoCipher;
  static function createCipheriv(algo:String,key:String,iv:String):CryptoCipher;
  static function createDecipher(algo:String,key:String):CryptoDecipher;
  static function createDecipheriv(algo:String,key:String,iv:String):CryptoDecipher;
  static function createSign(algo:String):CryptoSigner;
  static function createVerify(algo:String):CryptoVerify;
  @:overload(function(prime_length:Int):CryptoDiffieHellman {})
  static function createDiffieHellman(prime:String,?enc:String):CryptoDiffieHellman;
  static function getDiffieHellman(groupName:String):CryptoDiffieHellman;
  static function pbkdf2(password:String,salt:String,iterations:Int,keylen:Int,cb:Callback<String>):Void;
  static function randomBytes(size:Int,cb:Callback<Buffer>):Void;

}

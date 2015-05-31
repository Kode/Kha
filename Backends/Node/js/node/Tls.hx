package js.node;

import js.node.Crypto;
import js.node.Net;

/* TLS/SSL ................................................ */

/* 
   Emits:
   secureConnection
*/
typedef TlsServer = { > NetServer,
    function addContext(hostName:String,credentials:CryptoCreds):Void;
}

/* Emits: secure */
extern class TlsSecurePair extends js.Node.NodeEventEmitter {
   // ?? todo
}
extern class Tls 
implements npm.Package.Require<"tls","*"> 
{
  static function connect(port:Int,host:String,opts:Dynamic,cb:Void->Void):Void;
  static function createServer(opts:Dynamic,cb:TlsServer->Void):Void;
  static function createSecurePair(creds:CryptoCreds,isServer:Bool,requestCert:Bool,rejectUnauthorized:Bool):TlsSecurePair;
}
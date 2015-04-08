package js.node;

import js.node.events.EventEmitter ;
import js.node.http.*;
import js.node.net.Socket;
import js.node.Url;
import js.node.Crypto;
/* HTTP ............................................*/
  
/* 
   Emits:
   data,end,close
 */
extern class HttpServerReq 
extends EventEmitter
{
  var method:String;
  var url:String;
  var headers:Dynamic;
  var trailers:Dynamic;
  var httpVersion:String;
  var connection:Socket;
  function setEncoding(enc:String):Void;
  function pause():Void;
  function resume():Void;
}

/* Emits:
   data,end,close
*/
extern class HttpClientResp 
extends EventEmitter 
{
  var statusCode:Int;
  var httpVersion:String;
  var headers:Dynamic;
  var client:HttpClient;
  function setEncoding(enc:String):Void;
  function resume():Void;
  function pause():Void;  
}


extern class HttpClient 
extends EventEmitter 
{
  function request(method:String,path:String,?headers:Dynamic):ClientRequest;
  function verifyPeer():Bool;
  function getPeerCertificate():CryptoPeerCert;
}

/* 
 */
typedef HttpReqOpt = {
  var host:String;
  var port:Int;
  var path:String;
  var method:String;
  var headers:Dynamic;
}

extern class Http 
implements npm.Package.Require<"http","*"> 
{
  static function createServer(?listener:HttpServerReq->ServerResponse->Void):Server;
  static function createClient(port:Int,host:String):HttpClient;
  @:overload(function(parsedUrl:UrlObj,res:HttpClientResp->Void):ClientRequest {})
  static function request(options:HttpReqOpt,res:HttpClientResp->Void):ClientRequest;
  @:overload(function(parsedUrl:UrlObj,res:HttpClientResp->Void):Void {})
  static function get(options:HttpReqOpt,res:HttpClientResp->Void):Void;
  static function getAgent(host:String,port:Int):Agent;
}

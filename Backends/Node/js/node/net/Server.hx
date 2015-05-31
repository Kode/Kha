package js.node.net;

import js.node.Net;
  
/* 
   Emits:
   connection,close,error,listening
*/
extern class Server 
extends js.node.events.EventEmitter 
implements npm.Package.RequireNamespace<"net","*">
{

  public static inline var EVENT_REQUEST = "request";
  public static inline var EVENT_CONNECTION = "connection";
  public static inline var EVENT_CLOSE = "close";
  public static inline var EVENT_CHECK_CONTINUE = "checkContinue";
  public static inline var EVENT_CONNECT = "connect";
  public static inline var EVENT_UPGRADE = "upgrade";
  public static inline var EVENT_CLIENT_ERROR = "clientError";

  var maxConnections:Int;
  var connections:Int;

  @:overload(function(path:String,?cb:Void->Void):Void {})
  @:overload(function(fd:Int,?cb:Void->Void):Void {})                        
  function listen(port:Int,?host:String,?cb:Void->Void):Void;
  function close(cb:Void->Void):Void;
  function address():Void;
  function pause(msecs:Int):Void;

}
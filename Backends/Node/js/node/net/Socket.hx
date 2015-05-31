package js.node.net;

import js.node.Net;
/*
  
  Emits:
  connect,data,end,timeout,drain,error,close

  implements a duplex stream interface
*/
extern class Socket 
implements npm.Package.RequireNamespace<"net","*">
extends js.node.events.EventEmitter 
{
  var remoteAddress:String;
  var remotePort:Int;
  var bufferSize:Int;
  var bytesRead:Int;
  var bytesWritten:Int;
                          
  @:overload(function(path:String,?cb:Void->Void):Void {})
  @:overload(function(options:NetConnectionOpt,connectionListener:Void->Void):Void {})
  function connect(port:Int,?host:String,?cb:Void->Void):Void;
  function setEncoding(enc:String):Void;
  function setSecure():Void;
  @:overload(function(data:Dynamic,?enc:String,?fileDesc:Int,?cb:Void->Void):Bool {})
  function write(data:Dynamic,?enc:String,?cb:Void->Void):Bool;
  function end(?data:Dynamic,?enc:String):Void;
  function destroy():Void;
  function pause():Void;
  function resume():Void;
  function setTimeout(timeout:Int,?cb:Void->Void):Void;
  function setNoDelay(?noDelay:Bool):Void;
  function setKeepAlive(enable:Bool,?delay:Int):Void;
  function address():{address:String,port:Int}; 
  function new(?options:Dynamic):Void;

}

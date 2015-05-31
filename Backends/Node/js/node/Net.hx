package js.node;

/* NET ............................................. */
  
/* 
   Emits:
   connection
*/
extern class Net 
extends js.node.events.EventEmitter 
implements npm.Package.Require<"net","*"> 
{
  static function createServer(?options:{allowHalfOpen:Bool},fn:js.node.net.Socket->Void):js.node.net.Server;
  @:overload(function(cs:String):js.node.net.Socket {})
  static function createConnection(port:Int,host:String):js.node.net.Socket;
  @:overload(function(cs:String):js.node.net.Socket {})
  static function connect(port:Int,host:String):js.node.net.Socket;                    
  static function isIP(input:String):Int; // 4 or 6
  static function isIPv4(input:String):Bool;
  static function isIPv6(input:String):Bool;
}


typedef NetConnectionOpt = {
    port:Int,
    ?host:String,
    ?localAddress:String
}


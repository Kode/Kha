package js.node.http;

import js.node.events.EventEmitter;
/* 
   Emits:
   request,connection,checkContinue,connect,clientError,close
 */
extern class Server 
extends EventEmitter 
implements npm.Package.RequireNamespace<"http","*">
{
    public static inline var EVENT_REQUEST = "request";
    public static inline var EVENT_CONNECTION = "connection";
    public static inline var EVENT_CLOSE = "close";
    public static inline var EVENT_CHECK_CONTINUE = "checkContinue";
    public static inline var EVENT_CONNECT = "connect";
    public static inline var EVENT_UPGRADE = "upgrade";
    public static inline var EVENT_CLIENT_ERROR = "clientError";
    
    var timeout: Int;
    var maxHeadersCount: Int;

    @:overload(function(path:String,?callback:Void->Void):Void {})
    function listen(port:Int,?host:String,?backlog:Int,?callback:Void->Void):Void;
    function close(?callback:Void->Void):Void;
    function setTimeout(msecs: Int, callback:Void->Void):Void;
}
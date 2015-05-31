package js.node.http;

import js.node.events.EventEmitter;

/* Emits:
   continue,response
*/
extern class ClientRequest 
extends EventEmitter 
implements npm.Package.RequireNamespace<"http","*">
{
    public static inline var EVENT_RESPONSE = "response";
    public static inline var EVENT_SOCKET = "socket";
    public static inline var EVENT_CONNECT = "connect";
    public static inline var EVENT_UPGRADE = "upgrade";
    public static inline var EVENT_CONTINUE = "continue";

    function write(data:Dynamic,?enc:String):Void;
    function end(?data:Dynamic,?enc:String):Void;
    function abort():Void;
    function setTimeout(timeout: Int, ?callback: Void->Void): Void;
    
}

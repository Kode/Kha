package js.node.http;

import js.node.events.EventEmitter;
import js.node.net.Socket;
import js.node.Http;

extern class Agent 
extends EventEmitter 
implements npm.Package.RequireNamespace<"http","*">
{
  var maxSockets:Int;
  var sockets:Array<Socket>;
  var queue:Array<HttpServerReq>;
}
    
package js.npm.connect.support;

import js.node.http.ClientRequest;
import js.node.http.ServerResponse;

typedef MiddlewareNext = ?Dynamic->Void;

typedef Middleware = TMiddleware<ClientRequest,ServerResponse>;

abstract TMiddleware<Request:ClientRequest,Response:ServerResponse>(Request->Response->MiddlewareNext->Void) {
	@:from static public inline function fromMiddleware( middleware : js.npm.connect.Middleware ){
		return untyped middleware;
	}
	@:from static public inline function fromAsync( method : Request->Response->MiddlewareNext->Void ){
		return untyped method;
	}
	@:from static public inline function fromSync( method : Request->Response->Void ){
		return untyped method;
	}
}
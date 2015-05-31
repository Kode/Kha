package js.npm;

import js.node.Http;
import js.node.http.*;

import js.npm.connect.support.Middleware;

//private typedef MiddlewareFunction = ClientRequest->ServerResponse->Null<(Void->Void)>->Void;

extern class Connect 
implements npm.Package.Require<"connect","*">
{
	public function new() : Void;

	//@:overload( function ( middleware : Middleware ) : Connect {} )
	//@:overload( function ( mount : String , middleware : MiddlewareFunction ) : Connect {} )
	@:overload( function ( mount : String , middleware : TMiddleware<ClientRequest,ServerResponse> ) : Connect {} )
	public function use ( middleware : TMiddleware<ClientRequest,ServerResponse> ) : Connect ;

	@:overload(function( port :Int, ready : Void -> Void ): Server { } )
	public function listen (port :Int, ?address :String) : Server;

	public static function createServer (a1 :Dynamic, ?a2 :Dynamic, ?a3 :Dynamic, ?a4 :Dynamic, ?a5 :Dynamic, ?a6 :Dynamic, ?a7 :Dynamic, ?a8 :Dynamic, ?a9 :Dynamic) : Connect;

}

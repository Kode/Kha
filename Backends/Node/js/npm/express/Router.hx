package js.npm.express;
import js.npm.connect.support.Middleware;
import js.support.Callback;

extern class Router 
implements js.npm.connect.Middleware
implements Dynamic<String->TMiddleware<Request,Response>->Void>
implements npm.Package.RequireNamespace<"express","~4.0">
{

	public function new() : Void;

	@:overload(function( path : String , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	@:overload( function ( path : String , TMiddleware : TMiddleware<Request,Response> ) : Application {} )
	@:overload( function ( errorHandler : Dynamic -> Request -> Response -> Callback0 -> Void  ) : Application {} )
	public function use ( TMiddleware : TMiddleware<Request,Response> ) : Application ;

	@:overload(function(path : RegExp , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	@:overload(function(path : RegExp , f : TMiddleware<Request,Response> ) : Void {} )
	@:overload(function(path : String , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	function get(path : String, f : TMiddleware<Request,Response> ) : Void;
	
	@:overload(function(path : RegExp , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	@:overload(function(path : RegExp , f : TMiddleware<Request,Response> ) : Void {} )
	@:overload(function(path : String , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	function post(path : String, f : TMiddleware<Request,Response> ) : Void;

	@:overload(function(path : RegExp , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	@:overload(function(path : RegExp , f : TMiddleware<Request,Response> ) : Void {} )
	@:overload(function(path : String , f : Array<TMiddleware<Request,Response>> ) : Void {} )
	function all(path : String, f : TMiddleware<Request,Response> ) : Void;

	function param( name : String , callback : Request -> Response -> Callback0 -> Dynamic -> Void ) : Void;

}
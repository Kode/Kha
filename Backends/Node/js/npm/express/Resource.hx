package js.npm.express;

import js.npm.connect.support.Middleware;
import js.npm.Express;
import js.npm.express.Application;
import js.npm.express.Request;
import js.npm.express.Response;
import js.support.Callback;

typedef ResourceMap = {
	/*?doIndex : Request->Response->Void,
	?doCreate : Request->Response->Void,
	?doShow : Request->Response->Void,
	?doEdit : Request->Response->Void,
	?doUpdate : Request->Response->Void,
	?doDestroy : Request->Response->Void,
	?doNew : Request->Response->Void*/
};
// {
// 	@:optional
// 	public function edit ( req : Request , res : Response ) : Void;
//};//Dynamic<Middleware<Request,Response>>;
typedef ResourceOptions = Dynamic;

extern class Resource<T>
implements npm.Package.Require<"express-resource","*">
{
	public static inline function toplevelResource<T>( app : Application , resource : ResourceMap , ?options : ResourceOptions ) : Resource<T> { 	
		return untyped app['resource']( resource , options );
	}
	public static inline function resource<T>( app : Application , path : String , resource : ResourceMap , ?options : ResourceOptions ) : Resource<T> { 	
		return untyped app['resource']( path , resource , options );
	}

	public var base : String;
	public var app : Express;
	public var routes : {};
	public var name : String;
	public var id : String;
	public function load( cb : String -> Callback<T> -> Void ) : Resource<T>;
	public function map( method : String , path : String , fn : Middleware ) : Resource<T>;
	public function add<R>( resource : Resource<R> ) : Resource<T>;

}
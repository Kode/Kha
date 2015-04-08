package js.npm.connect;

@:native('basicAuth')
extern class BasicAuth
implements npm.Package.RequireNamespace<"connect","*"> #if !haxe3,#end
implements js.npm.connect.Middleware {
	@:overload( function( callback : String -> String -> Bool ) : Void {} )
	@:overload( function( callback : String -> String -> Dynamic -> Bool ) : Void {} )
	public function new(username:String,password:String) : Void;
}
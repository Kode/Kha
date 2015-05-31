package js.npm.connect;

extern class CookieParser 
implements npm.Package.Require<"cookie-parser","~1.1.0"> #if !haxe3,#end
implements js.npm.connect.Middleware
{
	public function new(?secret:String) : Void;
	public inline static function cookies( req : js.node.http.ClientRequest ) : Dynamic {
		return untyped req.cookies;
	}
}
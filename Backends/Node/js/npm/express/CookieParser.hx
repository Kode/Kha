package js.npm.express;

typedef CookieParserOptions = {
	?decode : String -> Dynamic
}

@:native('cookieParser')
extern class CookieParser 
implements npm.Package.Require<"cookie-parser","~1.3.3"> #if !haxe3,#end
implements js.npm.connect.Middleware
{
	public function new(?secret:String , ?options: CookieParserOptions ) : Void;
	public inline static function cookies( req : js.node.http.ClientRequest ) : Dynamic {
		return untyped req.cookies;
	}
	// TODO : static methods https://github.com/expressjs/cookie-parser
}
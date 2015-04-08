package js.npm.connect;

typedef BodyParserOptions = {
	?uploadDir : String
};

extern class BodyParser
implements npm.Package.Require<"body-parser","~1.3.0"> #if !haxe3,#end
implements js.npm.connect.Middleware {

	public inline static function body( req : js.node.http.ClientRequest ) : Dynamic {
		return untyped req.body;
	}

	public function new(?options:BodyParserOptions) : Void;
}
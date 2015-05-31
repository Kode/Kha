package js.npm.connect;

typedef StaticOptions = {
	?maxAge : Int,
	?hidden : Bool,
	?redirect : Bool
}

extern class Static 
implements npm.Package.Require<"serve-static","~1.2.1"> #if !haxe3,#end
implements js.npm.connect.Middleware
{
	public function new( path : String , ?opts : StaticOptions ) : Void;
}
package js.npm.connect;

typedef CompressOptions = {
	?threshold : Dynamic,
	?filter : Dynamic
}

extern class Compress 
implements npm.Package.Require<"compress","~1.0.3"> #if !haxe3,#end
implements js.npm.connect.Middleware
{
	public function new() : Void;
}
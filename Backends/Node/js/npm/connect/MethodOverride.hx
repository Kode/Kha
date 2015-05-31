package js.npm.connect;

extern class MethodOverride 
implements npm.Package.Require<"method-override","~2.0.1"> #if !haxe3,#end
implements js.npm.connect.Middleware
{

	public function new( ?key : String ) : Void;

}
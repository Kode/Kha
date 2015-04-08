package js.node.zlib;

extern class Zlib 
implements npm.Package.RequireNamespace<"zlib","*">
{
	function flush(cb:Dynamic):Void;
    function reset():Void;
}
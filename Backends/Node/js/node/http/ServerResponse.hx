package js.node.http;

/* 
 */
extern class ServerResponse
extends js.node.stream.Writable 
implements npm.Package.RequireNamespace<"http","*">
{
    public static inline var EVENT_CLOSE  = "close";
	public static inline var EVENT_FINISH = "finish";

	var statusCode:Int;
	function writeContinue():Void;
	@:overload(function(statusCode:Int,?reasonPhrase:String,?headers:Dynamic):Void {})
	function writeHead(statusCode:Int,headers:Dynamic):Void;
	function setHeader(name:String,value:Dynamic):Void;
	function getHeader(name:String):Dynamic;
	function removeHeader(name:String):Void;
	function addTrailers(headers:Dynamic):Void;
}
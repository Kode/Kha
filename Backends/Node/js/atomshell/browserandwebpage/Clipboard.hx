package js.atomshell.browserandwebpage;

/**
 * @author AS3Boyan
 * MIT

 */
extern class Clipboard implements npm.Package.Require<"clipboard","*">
{
	static function readText(?type:String):String;
	static function writeText(text:String, ?type:String):Void;
	static function clear():Void;
	/* Note: This API is experimental and could be removed in future. */
	static function has(format:String, ?type:String):Bool;
	static function read(format:String, ?type:String):String;
}
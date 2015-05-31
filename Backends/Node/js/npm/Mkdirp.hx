package js.npm;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
extern class Mkdirp implements npm.Package.Require<"mkdirp","*">
{	
	@:overload(function (dir:String, cb:Dynamic->String->Void):Void { } )
	static function mkdirp(dir:String, mode:Int, cb:Dynamic->String->Void):Void;
	static function mkdirpSync(dir:String, ?mode:Int):String;
}
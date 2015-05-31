package js.npm;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
extern class Remove implements npm.Package.Require<"remove","*">
{
	static function removeAsync(path:String, options:Dynamic, cb:String->Void):Void;
}
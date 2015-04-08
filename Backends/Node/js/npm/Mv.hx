package js.npm;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
extern class Mv implements npm.Package.Require<"mv","*">
{	
	static function move(src:String, dest:String, cb:String->Void):Void;
}
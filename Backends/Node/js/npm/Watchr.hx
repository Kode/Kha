package js.npm;
import js.node.fs.Stats;

/**
 * ...
 * @author AS3Boyan
 */
 
typedef WatchrListeners =
{
	?log:String->Void,
	?error:Dynamic->Void,
	?watching:Dynamic->Dynamic->Bool->Void,
	?change:String->String->Stats->Stats->Void
}

typedef WatchrConfig =
{
	?path:String,
	?paths:Array<String>,
	?listener:Dynamic,
	?listeners:Dynamic,
	?next:Dynamic,
	?stat:Dynamic,
	?interval:Int,
	?persistent:Bool,
	?catchupDelay:Int,
	?preferredMethods:Array<String>,
	?followLinks:Bool,
	?ignorePaths:Bool,
	?ignoreHiddenFiles:Bool,
	?ignoreCommonPatterns:Bool,
	?ignoreCustomPatterns:Dynamic
}

extern class Watchr implements npm.Package.Require<"watchr","*">
{
	static function watch(config:WatchrConfig):Dynamic;
}
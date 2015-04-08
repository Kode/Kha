package js.npm;

/**
 * @author AS3Boyan
 * MIT

 */

extern class PathWatcherInstance
{
	var handleWatcher:{path:String};
	function close():Void;
}

extern class Pathwatcher implements npm.Package.Require<"pathwatcher","*">
{
	static function watch(filename:String, listener:String->String->Void):PathWatcherInstance;
	static function closeAllWatchers():Void;
	static function getWatchedPaths():Array<String>;
}
	
@:enum
abstract PathwatcherEvent(String) to String
{
	var RENAME = "rename";
	var DELETE = "delete";
	var CHANGE = "change";
}
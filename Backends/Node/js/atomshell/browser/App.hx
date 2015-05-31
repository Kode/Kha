package js.atomshell.browser;

/**
* @author AS3Boyan 
 */
extern class AppCommandLine
{
	function appendSwitch(switchArg:String, ?value:String):Void;
	function appendArgument(value:String):Void;
}

extern class AppDock
{
	/* Mac only */
	function bounce(?type:String):Void;
	/* Mac only */
	function cancelBounce(id:Int):Void;
	/* Mac only */
	function setBadge(text:String):Void;
	/* Mac only */
	function getBadge():String;
	/* Mac only */
	function hide():Void;
	/* Mac only */
	function show():Void;
}

extern class App implements atomshell.Package.Require<"app","*">
{
	static var commandLine:AppCommandLine;
	static var dock:AppDock;
	
	static function on(eventType:String, cb:Dynamic):Void;
	static function terminate():Void;
	static function getVersion():String;
	static function getName():String;
	static function quit():Void;
}

@:enum
abstract AppEvent(String) to String
{
	var WINDOW_ALL_CLOSED = "window-all-closed";
	var READY = "ready";
	var WILL_FINISH_LAUNCHING = "will-finish-launching";
	var WILL_QUIT = "will-quit";
	var OPEN_FILE = "open-file";
	var ACTIVATE_WITH_NO_OPEN_WINDOWS = "activate-with-no-open-windows";
}
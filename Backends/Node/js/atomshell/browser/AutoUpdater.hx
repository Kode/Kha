package js.atomshell.browser;
import js.node.events.EventEmitter;

/**
 * @author AS3Boyan
 * MIT
 */
/* Mac only */
extern class AutoUpdater implements atomshell.Package.Require<"auto-updater","*"> extends EventEmitter
{
	static function setFeedUrl(url:String):Void;
	static function checkForUpdates():Void;
}

@:enum
abstract AutoUpdaterEvent(String) to String
{
	var CHECKING_FOR_UPDATE = "checking-for-update";
	var UPDATE_AVAILABLE = "update-available";
	var UPDATE_NOT_AVAILABLE = "update-not-available";
	var UPDATE_DOWNLOADED = "update-downloaded";
}
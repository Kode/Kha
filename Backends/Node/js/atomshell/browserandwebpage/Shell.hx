package js.atomshell.browserandwebpage;

/**
 * @author AS3Boyan
 * MIT

 */
extern class Shell implements npm.Package.Require<"shell","*">
{
	static function showItemInFolder(fullPath:String):Void;
	static function openItem(fullPath:String):Void;
	static function openExternal(url:String):Void;
	static function moveItemToTrash(fullPath:String):Void;
	static function beep():Void;
}
package js.atomshell.webpage;

/**
 * @author AS3Boyan
 * MIT

 */
extern class WebView implements npm.Package.Require<"web-view","*">
{
	static function setZoomFactor(factor:Float):Void;
	static function getZoomFactor():Float;
	static function setZoomLevel(level:Float):Void;
	static function getZoomLevel():Float;
}
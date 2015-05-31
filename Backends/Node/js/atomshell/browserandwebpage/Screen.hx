package js.atomshell.browserandwebpage;

/**
 * @author AS3Boyan
 * MIT

 */
typedef ScreenPos = 
{
	?x:Int,
	?y:Int
}

typedef ScreenDisplaySize = 
{
	?width:Int,
	?height:Int
}

typedef ScreenDisplayRect = 
{
	?x:Int,
	?y:Int,
	?width:Int,
	?height:Int
}

typedef ScreenDisplay = 
{
	?bounds: ScreenDisplayRect,
	?workArea: ScreenDisplayRect,
	?size: ScreenDisplaySize,
	?workAreaSize: ScreenDisplaySize,
	?scaleFactor: Float
}

extern class Screen implements npm.Package.Require<"screen","*">
{
	static function getCursorScreenPoint():ScreenPos;
	static function getPrimaryDisplay():ScreenDisplay;
}
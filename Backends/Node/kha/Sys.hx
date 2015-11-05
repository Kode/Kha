package kha;

import js.Browser;
import js.html.CanvasElement;
import js.Node;

class Sys {
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	private static var theMouse: Mouse = null;
	private static var width: Int;
	private static var height: Int;
	
	public static function init(width: Int, height: Int): Void {
		Sys.width = width;
		Sys.height = height;
	}
	
	public static function _updateSize(width: Int, height: Int): Void {
		Sys.width = width;
		Sys.height = height;
	}
	
	public static function _updateScreenRotation(value: Int): Void {
		screenRotation = ScreenRotation.createByIndex(value);
	}
	
	public static function getTime(): Float {
		var time = Node.process.hrtime();
		return cast(time[0], Float) + cast(time[1], Float) / 1000000000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		if (theMouse == null) theMouse = new kha.js.Mouse();
		return theMouse;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	public static function get_pixelWidth(): Int {
		return width;
	}
	
	public static function get_pixelHeight(): Int {
		return height;
	}
	
	public static function vsynced(): Bool {
		return false;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static function systemId(): String {
		return "nodejs";
	}
	
	public static function requestShutdown(): Void {
		Node.process.exit(0);
	}

	public static function canSwitchFullscreen() : Bool{
		return false;
	}

	public static function isFullscreen() : Bool{
		return false;
	}

	public static function requestFullscreen(): Void {
		
	}

	public static function exitFullscreen(): Void {
		
  	}

	public function notifyOfFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public function removeFromFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}
}

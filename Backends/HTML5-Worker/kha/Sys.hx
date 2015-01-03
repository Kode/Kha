package kha;

import js.Browser;
import js.html.CanvasElement;

class Sys {
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	private static var theMouse: Mouse;
	private static var width: Int;
	private static var height: Int;
	
	public static function init(width: Int, height: Int): Void {
		Sys.width = width;
		Sys.height = height;
		theMouse = new kha.js.Mouse();
	}
	
	public static function getTime(): Float {
		return untyped __js__("Date.now()") / 1000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
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
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
}

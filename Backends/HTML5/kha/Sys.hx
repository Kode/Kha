package kha;

import js.Browser;

class Sys {
	public static var needs3d: Bool = false;
	public static var gl: Dynamic;
	public static var audio: Dynamic;
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	//public static var graphics(default, null): Graphics;
	private static var theMouse: Mouse;
	private static var canvas: Dynamic;
	
	public static function init(webgl: Bool): Void {
		canvas = Browser.document.getElementById("khanvas");
		//graphics = null;// new kha.js.graphics.Graphics(webgl);
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
		return canvas.width;
	}
	
	public static function get_pixelHeight(): Int {
		return canvas.height;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
}

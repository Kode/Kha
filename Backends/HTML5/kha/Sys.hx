package kha;

import js.Browser;
import js.html.CanvasElement;

class Sys {
	public static var gl: Dynamic;
	public static var audio: Dynamic;
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	//public static var graphics(default, null): Graphics;
	private static var theMouse: Mouse;
	public static var khanvas: CanvasElement;
	private static var performance: Dynamic;
	
	public static function initPerformanceTimer(): Void {
		if (Browser.window.performance != null) {
			performance = Browser.window.performance;
		}
		else {
			performance = untyped __js__("Date.now");
		}
	}
	
	public static function init(canvas: CanvasElement): Void {
		khanvas = canvas;
		theMouse = new kha.js.Mouse();
	}
	
	public static function getTime(): Float {
		return performance.now() / 1000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		return theMouse;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	public static function get_pixelWidth(): Int {
		return khanvas.width;
	}
	
	public static function get_pixelHeight(): Int {
		return khanvas.height;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static function systemId(): String {
		return "HTML5";
	}
}

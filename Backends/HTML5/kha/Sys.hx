package kha;

import js.Browser;
import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var gl: Dynamic;
	public static var audio: Dynamic;
	private static var theMouse: Mouse;
	private static var w: Int;
	private static var h: Int;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(webgl: Bool): Void {
		graphics = new kha.js.graphics.Graphics(webgl);
		theMouse = new kha.js.Mouse();
		var canvas: Dynamic = Browser.document.getElementById("khanvas");
		w = canvas.width;
		h = canvas.height;
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
		return w;
	}
	
	public static function get_pixelHeight(): Int {
		return h;
	}
}

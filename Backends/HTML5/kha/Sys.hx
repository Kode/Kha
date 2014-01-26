package kha;

import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var gl: Dynamic;
	public static var audio: Dynamic;
	private static var theMouse: Mouse;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(webgl: Bool): Void {
		graphics = new kha.js.graphics.Graphics(webgl);
		theMouse = new kha.js.Mouse();
	}
	
	public static function getTime(): Float {
		return untyped __js__("Date.now()") / 1000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		return theMouse;
	}
}

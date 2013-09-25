package kha;

import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var gl: Dynamic;
	public static var audio: Dynamic;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(webgl: Bool): Void {
		graphics = new kha.js.graphics.Graphics(webgl);
	}
	
	public static function getFrequency(): Float {
		return 1000;
	}
	
	public static function getTimestamp(): Int {
		return untyped __js__("Date.now()");
	}
}
package kha;

import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var gl: Dynamic;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(): Void {
		graphics = new kha.js.graphics.Graphics();
	}
	
	public static function getFrequency(): Float {
		return 1000;
	}
	
	public static function getTimestamp(): Int {
		var date: Dynamic = untyped __js__("new Date()");
		return date.getMilliseconds();
	}
}
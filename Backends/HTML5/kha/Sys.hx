package kha;

import kha.graphics.Graphics;

class Sys {
	public static var gl: Dynamic;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(): Void {
		graphics = new kha.js.graphics.Graphics();
	}
}
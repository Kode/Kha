package kha;

import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(): Void {
		graphics = new kha.cpp.graphics.Graphics();
	}
}
package kha;

import flash.display3D.Context3D;
import flash.Lib;
import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var graphics: Graphics;
	private static var theMouse: Mouse;
	
	public static function init(context: Context3D): Void {
		graphics = new kha.flash.graphics.Graphics(context);
		theMouse = new kha.flash.Mouse();
	}
	
	public static function getTime(): Float {
		return Lib.getTimer() / 1000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		return theMouse;
	}
}

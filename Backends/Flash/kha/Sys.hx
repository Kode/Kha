package kha;

import flash.display3D.Context3D;
import flash.Lib;
import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var graphics: Graphics;
	
	public static function init(context: Context3D): Void {
		graphics = new kha.flash.graphics.Graphics(context);
	}
	
	public static function getFrequency(): Float {
		return 1000;
	}

	public static function getTimestamp(): Float {
		return Lib.getTimer();
	}
}
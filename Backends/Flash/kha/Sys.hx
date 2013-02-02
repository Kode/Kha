package kha;

import flash.Lib;
import haxe.Int32;
import haxe.Int64;
import kha.graphics.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	public static var graphics: Graphics;
	
	public static function getFrequency(): Float {
		return 1000;
	}

	public static function getTimestamp(): Int {
		return Lib.getTimer();
	}
}
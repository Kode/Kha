package kha;

import flash.display3D.Context3D;
import flash.Lib;
import kha.graphics4.Graphics;

class Sys {
	public static var needs3d: Bool = false;
	private static var theMouse: Mouse;
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init(): Void {
		theMouse = new kha.flash.Mouse();
	}
	
	public static function getTime(): Float {
		return Lib.getTimer() / 1000;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		return theMouse;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	public static function get_pixelWidth(): Int {
		return Lib.current.stage.stageWidth;
	}
	
	public static function get_pixelHeight(): Int {
		return Lib.current.stage.stageHeight;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static function systemId(): String {
		return "Flash";
	}
	
	public static function requestShutdown(): Void {
		Game.the.onPause();
		Game.the.onBackground();
		Game.the.onShutdown();
		flash.Lib.fscommand("quit");
	}
}

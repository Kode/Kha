package kha;

import kha.psm.graphics4.Graphics;
import system.diagnostics.Stopwatch;

class Sys {
	private static var watch: Stopwatch;
	
	public static var mouse(default, null): kha.Mouse;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init(): Void {
		mouse = new Mouse();
		watch = new Stopwatch();
		watch.Start();
	}
	
	@:functionCode('
		return watch.ElapsedMilliseconds / 1000.0;
	')
	public static function getTime(): Float {
		return 0;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	//@:functionCode('
	//	return kha.psm.Painter.graphics.Screen.Width;
	//')
	public static function get_pixelWidth(): Int {
		return 960;
	}
	
	//@:functionCode('
	//	return kha.psm.Painter.graphics.Screen.Height;
	//')
	public static function get_pixelHeight(): Int {
		return 544;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}

	public static function canSwitchFullscreen() : Bool{
		return false;
	}

	public static function isFullscreen() : Bool{
		return false;
	}

	public static function requestFullscreen(): Void {
		
	}

	public static function exitFullscreen(): Void {
		
  	}

	public function notifyOfFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public function removeFromFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}
}

package kha;

import kha.psm.Graphics;
//import system.diagnostics.Stopwatch;

class Sys {
	//private static var watch: Stopwatch;
	
	public static var graphics: Graphics;
	
	public static var mouse(default, null): kha.Mouse;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init(): Void {
		mouse = new Mouse();
		graphics = new Graphics();
		//watch = new Stopwatch();
		//watch.Start();
	}
	
	//@:functionCode('
	//	return (int) watch.ElapsedMilliseconds;
	//')
	public static function getTime(): Float {
		return 0;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	@:functionCode('
		return kha.psm.Painter.graphics.Screen.Width;
	')
	public static function get_pixelWidth(): Int {
		return 0;
	}
	
	@:functionCode('
		return kha.psm.Painter.graphics.Screen.Height;
	')
	public static function get_pixelHeight(): Int {
		return 0;
	}
}

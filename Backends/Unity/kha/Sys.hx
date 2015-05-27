package kha;

//import system.diagnostics.Stopwatch;

class Sys {
	//private static var watch: Stopwatch;
	
	//public static var graphics: Graphics;
	
	public static var mouse(default, null): kha.Mouse;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init(): Void {
		//mouse = new Mouse();
		//graphics = new Graphics();
		//watch = new Stopwatch();
		//watch.Start();
	}
	
	//@:functionCode('
	//	return watch.ElapsedMilliseconds / 1000.0;
	//')
	public static function getTime(): Float {
		return 0;
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	public static function get_pixelWidth(): Int {
		return unityEngine.Screen.width;
	}
	
	public static function get_pixelHeight(): Int {
		return unityEngine.Screen.height;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
}

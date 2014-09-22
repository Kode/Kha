package kha;
import kha.java.Graphics;

class Sys {
	
	public static var mouse(default, null): Mouse;
	
	public static var graphics(default, null): Graphics;
	
	private static var startTime : Float;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init(): Void {
		mouse = new Mouse();
		graphics = new Graphics();
		startTime = getTimestamp();
	}
	
	public static function getFrequency(): Int {
		return 1000;
	}
	
	@:functionCode('
		return System.currentTimeMillis();
	')
	public static function getTimestamp(): Float {
		return 0;
	}
	
	public static function getTime(): Float {
		return (getTimestamp() - startTime) / getFrequency();
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static var pixelWidth: Int = 640;
	
	public static var pixelHeight: Int = 480;
}

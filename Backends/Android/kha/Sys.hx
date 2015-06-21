package kha;

class Sys {
	public static var pixelWidth(get, null): Int;
	
	private static function get_pixelWidth(): Int {
		return 640;
	}
	
	public static var pixelHeight(get, null): Int;
	
	private static function get_pixelHeight(): Int {
		return 480;
	}
	
	public static var screenRotation: ScreenRotation;
	
	private static function get_screenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}
	
	public static function getTime(): Float {
		return 0;
	}
	
	public static var mouse(get, null): Mouse;
	
	public static function get_mouse(): Mouse {
		return null;
	}
	
	public static function vsynced(): Bool {
		return true;
	}
	
	public static function refreshRate(): Int {
		return 60;
	}
	
	public static function systemId(): String {
		return "Android";
	}
}

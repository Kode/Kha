package kha;

class Sys {
	private static var w: Int = 640;
	private static var h: Int = 480;
	private static var m: Mouse;
	
	public static function init(width: Int, height: Int): Void {
		w = width;
		h = height;
		m = new Mouse();
	}
	
	public static var pixelWidth(get, null): Int;
	
	private static function get_pixelWidth(): Int {
		return w;
	}
	
	public static var pixelHeight(get, null): Int;
	
	private static function get_pixelHeight(): Int {
		return h;
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
		return m;
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

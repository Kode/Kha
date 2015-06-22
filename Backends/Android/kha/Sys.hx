package kha;

class Sys {
	public static var w: Int = 640;
	public static var h: Int = 480;
	private static var m: Mouse;
	private static var startTime: Float;
	
	public static function init(width: Int, height: Int): Void {
		w = width;
		h = height;
		m = new Mouse();
	}
	
	public static function initTime(): Void {
		startTime = getTimestamp();
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

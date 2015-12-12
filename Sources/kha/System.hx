package kha;

@:allow(kha.SystemImpl)
class System {
	private static var renderListeners: Array<Framebuffer -> Void> = new Array();
	private static var foregroundListeners: Array<Void -> Void> = new Array();
	private static var resumeListeners: Array<Void -> Void> = new Array();
	private static var pauseListeners: Array<Void -> Void> = new Array();
	private static var backgroundListeners: Array<Void -> Void> = new Array();
	private static var shutdownListeners: Array<Void -> Void> = new Array();
	
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void): Void {
		SystemImpl.init(title, width, height, callback);
	}
	
	public static function notifyOnRender(listener: Framebuffer -> Void): Void {
		renderListeners.push(listener);
	}
	
	public static function notifyOnApplicationState(foregroundListener: Void -> Void, resumeListener: Void -> Void,
	pauseListener: Void -> Void, backgroundListener: Void-> Void, shutdownListener: Void -> Void): Void {
		foregroundListeners.push(foregroundListener);
		resumeListeners.push(resumeListener);
		pauseListeners.push(pauseListener);
		backgroundListeners.push(backgroundListener);
		shutdownListeners.push(shutdownListener);
	}
	
	private static function render(framebuffer: Framebuffer): Void {
		for (listener in renderListeners) {
			listener(framebuffer);
		}
	}
	
	private static function foreground(): Void {
		for (listener in foregroundListeners) {
			listener();
		}
	}
	
	private static function resume(): Void {
		for (listener in resumeListeners) {
			listener();
		}
	}
	
	private static function pause(): Void {
		for (listener in pauseListeners) {
			listener();
		}
	}
	
	private static function background(): Void {
		for (listener in backgroundListeners) {
			listener();
		}
	}
	
	private static function shutdown(): Void {
		for (listener in shutdownListeners) {
			listener();
		}
	}
	
	public static var time(get, null): Float;
	
	private static function get_time(): Float {
		return SystemImpl.getTime();
	}
	
	public static var pixelWidth(get, null): Int;
	public static var pixelHeight(get, null): Int;
	
	private static function get_pixelWidth(): Int {
		return SystemImpl.getPixelWidth();
	}
	
	private static function get_pixelHeight(): Int {
		return SystemImpl.getPixelHeight();
	}
	
	public static var screenRotation(get, null): ScreenRotation;
	
	private static function get_screenRotation(): ScreenRotation {
		return SystemImpl.getScreenRotation();
	}
	
	public static var vsync(get, null): Bool;
	
	private static function get_vsync(): Bool {
		return SystemImpl.getVsync();
	}
	
	public static var refreshRate(get, null): Int;
	
	private static function get_refreshRate(): Int {
		return SystemImpl.getRefreshRate();
	}
	
	public static var systemId(get, null): String;
	
	private static function get_systemId(): String {
		return SystemImpl.getSystemId();
	}
	
	public static function requestShutdown(): Void {
		SystemImpl.requestShutdown();
	}
	
	public static function changeResolution(width: Int, height: Int): Void {
		SystemImpl.changeResolution(width, height);
	}
	
	public static function loadUrl(url: String): Void {
		
	}
}

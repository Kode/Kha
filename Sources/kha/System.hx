package kha;

import kha.WindowOptions;

typedef SystemOptions = {
	?title: String,
	?width: Int,
	?height: Int,
	?samplesPerPixel: Int
}

@:allow(kha.SystemImpl)
class System {
	private static var renderListeners: Array<Array<Framebuffer -> Void>> = new Array();
	private static var foregroundListeners: Array<Void -> Void> = new Array();
	private static var resumeListeners: Array<Void -> Void> = new Array();
	private static var pauseListeners: Array<Void -> Void> = new Array();
	private static var backgroundListeners: Array<Void -> Void> = new Array();
	private static var shutdownListeners: Array<Void -> Void> = new Array();

	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		if (options.title == null) options.title = "Kha";
		if (options.width == null) options.width = 800;
		if (options.height == null) options.height = 600;
		if (options.samplesPerPixel == null) options.samplesPerPixel = 1;
		SystemImpl.init(options, callback);
	}

	public static function initEx( title : String, options : Array<WindowOptions>, windowCallback : Int -> Void, callback : Void -> Void ) {
		SystemImpl.initEx(title, options, windowCallback, callback);
	}

	public static function notifyOnRender(listener: Framebuffer -> Void, id: Int = 0): Void {
		while (id >= renderListeners.length) {
			renderListeners.push(new Array());
		}

		renderListeners[id].push(listener);
	}

	public static function notifyOnApplicationState(foregroundListener: Void -> Void, resumeListener: Void -> Void,	pauseListener: Void -> Void, backgroundListener: Void-> Void, shutdownListener: Void -> Void): Void {
		foregroundListeners.push(foregroundListener);
		resumeListeners.push(resumeListener);
		pauseListeners.push(pauseListener);
		backgroundListeners.push(backgroundListener);
		shutdownListeners.push(shutdownListener);
	}

	private static function render(id: Int, framebuffer: Framebuffer): Void {
		if (renderListeners.length == 0) {
			return;
		}

		for (listener in renderListeners[id]) {
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

	public static function windowWidth(windowId: Int = 0): Int {
		return SystemImpl.windowWidth(windowId);
	}

	public static function windowHeight(windowId: Int = 0): Int {
		return SystemImpl.windowHeight(windowId);
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

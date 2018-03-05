package kha;

import kha.WindowMode;
import kha.WindowOptions;

typedef SystemOptions = {
	?title: String,
	?width: Int,
	?height: Int,
	?samplesPerPixel: Int,
	?vSync: Bool,
	?windowMode: WindowMode,
	?resizable: Bool,
	?maximizable: Bool,
	?minimizable: Bool
}

@:allow(kha.SystemImpl)
class System {
	private static var renderListeners: Array<Array<Framebuffer -> Void>> = new Array();
	private static var foregroundListeners: Array<Void -> Void> = new Array();
	private static var resumeListeners: Array<Void -> Void> = new Array();
	private static var pauseListeners: Array<Void -> Void> = new Array();
	private static var backgroundListeners: Array<Void -> Void> = new Array();
	private static var shutdownListeners: Array<Void -> Void> = new Array();
	private static var dropFilesListeners: Array<String -> Void> = new Array();
	static var cutListener: Void->String = null;
	static var copyListener: Void->String = null;
	static var pasteListener: String->Void = null;
	private static var theTitle: String;

	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		if (options.title == null) options.title = "Kha";
		if (options.width == null) options.width = 800;
		if (options.height == null) options.height = 600;
		if (options.samplesPerPixel == null) options.samplesPerPixel = 1;
		if (options.vSync == null) options.vSync = true;
		if (options.windowMode == null) options.windowMode = WindowMode.Window;
		if (options.resizable == null) options.resizable = false;
		if (options.maximizable == null) options.maximizable = false;
		if (options.minimizable == null) options.minimizable = true;
		theTitle = options.title;
		SystemImpl.init(options, callback);
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void) {
		theTitle = title;
		SystemImpl.initEx(title, options, windowCallback, callback);
	}

	public static var title(get, null): String;

	private static function get_title(): String {
		return theTitle;
	}

	public static function notifyOnRender(listener: Framebuffer -> Void, id: Int = 0): Void {
		while (id >= renderListeners.length) {
			renderListeners.push(new Array());
		}
		renderListeners[id].push(listener);
	}

	public static function removeRenderListener(listener: Framebuffer -> Void, id: Int = 0): Void {
		renderListeners[id].remove(listener);
	}

	public static function notifyOnApplicationState(foregroundListener: Void -> Void, resumeListener: Void -> Void,	pauseListener: Void -> Void, backgroundListener: Void-> Void, shutdownListener: Void -> Void): Void {
		if (foregroundListener != null) foregroundListeners.push(foregroundListener);
		if (resumeListener != null) resumeListeners.push(resumeListener);
		if (pauseListener != null) pauseListeners.push(pauseListener);
		if (backgroundListener != null) backgroundListeners.push(backgroundListener);
		if (shutdownListener != null) shutdownListeners.push(shutdownListener);
	}

	public static function notifyOnDropFiles(dropFilesListener: String -> Void): Void {
		dropFilesListeners.push(dropFilesListener);
	}

	public static function notifyOnCutCopyPaste(cutListener: Void->String, copyListener: Void->String, pasteListener: String->Void): Void {
		System.cutListener = cutListener;
		System.copyListener = copyListener;
		System.pasteListener = pasteListener;
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

	private static function dropFiles(filePath: String): Void {
		for (listener in dropFilesListeners) {
			listener(filePath);
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
	
	public static function screenDpi(): Int {
		return SystemImpl.screenDpi();
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
		SystemImpl.loadUrl(url);
	}

	public static function canSwitchFullscreen(): Bool {
		return SystemImpl.canSwitchFullscreen();
	}

	public static function isFullscreen(): Bool {
		return SystemImpl.isFullscreen();
	}

	public static function requestFullscreen(): Void {
		SystemImpl.requestFullscreen();
	}

	public static function exitFullscreen(): Void {
		SystemImpl.exitFullscreen();
	}

	public static function notifyOnFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		SystemImpl.notifyOfFullscreenChange(func, error);
	}

	public static function removeFullscreenListener(func: Void -> Void, error: Void -> Void): Void {
		SystemImpl.removeFromFullscreenChange(func, error);
	}
}

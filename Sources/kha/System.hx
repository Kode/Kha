package kha;

import kha.WindowOptions;

@:structInit
class SystemOptions {
	@:optional public var title: String = "Kha";
	@:optional public var width: Int = -1;
	@:optional public var height: Int = -1;
	@:optional public var window: WindowOptions = null;
	@:optional public var framebuffer: FramebufferOptions = null;

	/**
	 * Used to provide parameters for System.start
	 * @param title The application title is the default window title (unless the window parameter provides a title of its own)
	 * and is used for various other purposes - for example for save data locations
	 * @param width Just a shortcut which overwrites window.width if set
	 * @param height Just a shortcut which overwrites window.height if set
	 * @param window Optionally provide window options
	 * @param framebuffer Optionally provide framebuffer options
	 */
	public function new(title: String = "Kha", ?width: Int = -1, ?height: Int = -1, window: WindowOptions = null, framebuffer: FramebufferOptions = null) {
		this.title = title;
		this.window = window == null ? {} : window;

		if (width > 0) {
			this.window.width = width;
			this.width = width;
		}
		else {
			this.width = this.window.width;
		}

		if (height > 0) {
			this.window.height = height;
			this.height = height;
		}
		else {
			this.height = this.window.height;
		}

		if (this.window.title == null) {
			this.window.title = title;
		}

		this.framebuffer = framebuffer == null ? {} : framebuffer;
	}
}

typedef OldSystemOptions = {
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
	static var renderListeners: Array<Array<Framebuffer>->Void> = [];
	static var foregroundListeners: Array<Void->Void> = [];
	static var resumeListeners: Array<Void->Void> = [];
	static var pauseListeners: Array<Void->Void> = [];
	static var backgroundListeners: Array<Void->Void> = [];
	static var shutdownListeners: Array<Void->Void> = [];
	static var dropFilesListeners: Array<String->Void> = [];
	static var cutListener: Void->String = null;
	static var copyListener: Void->String = null;
	static var pasteListener: String->Void = null;
	static var loginListener: Void->Void = null;
	static var logoutListener: Void->Void = null;
	static var theTitle: String;

	@:deprecated("Use System.start instead")
	public static function init(options: OldSystemOptions, callback: Void->Void): Void {
		var features: kha.WindowFeatures = None;
		if (options.resizable)
			features |= WindowFeatures.FeatureResizable;
		if (options.maximizable)
			features |= WindowFeatures.FeatureMaximizable;
		if (options.minimizable)
			features |= WindowFeatures.FeatureMinimizable;

		var newOptions: SystemOptions = {
			title: options.title,
			width: options.width,
			height: options.height,
			window: {
				mode: options.windowMode,
				windowFeatures: features
			},
			framebuffer: {
				samplesPerPixel: options.samplesPerPixel,
				verticalSync: options.vSync
			}
		};
		start(newOptions, function(_) {
			callback();
		});
	}

	public static function start(options: SystemOptions, callback: Window->Void): Void {
		theTitle = options.title;
		SystemImpl.init(options, callback);
	}

	public static var title(get, never): String;

	static function get_title(): String {
		return theTitle;
	}

	@:deprecated("Use System.notifyOnFrames instead")
	public static function notifyOnRender(listener: Framebuffer->Void, id: Int = 0): Void {
		renderListeners.push(function(framebuffers: Array<Framebuffer>) {
			if (id < framebuffers.length) {
				listener(framebuffers[id]);
			}
		});
	}

	/**
	 * The provided listener is called when new framebuffers are ready for rendering into.
	 * Each framebuffer corresponds to the kha.Window of the same index, single-window
	 * applications always receive an array of only one framebuffer.
	 * @param listener
	 * The callback to add
	 */
	public static function notifyOnFrames(listener: Array<Framebuffer>->Void): Void {
		renderListeners.push(listener);
	}

	/**
	 * Removes a previously set frames listener.
	 * @param listener
	 * The callback to remove
	 */
	public static function removeFramesListener(listener: Array<Framebuffer>->Void): Void {
		renderListeners.remove(listener);
	}

	public static function notifyOnApplicationState(foregroundListener: Void->Void, resumeListener: Void->Void, pauseListener: Void->Void,
			backgroundListener: Void->Void, shutdownListener: Void->Void): Void {
		if (foregroundListener != null)
			foregroundListeners.push(foregroundListener);
		if (resumeListener != null)
			resumeListeners.push(resumeListener);
		if (pauseListener != null)
			pauseListeners.push(pauseListener);
		if (backgroundListener != null)
			backgroundListeners.push(backgroundListener);
		if (shutdownListener != null)
			shutdownListeners.push(shutdownListener);
	}

	public static function removeApplicationStateListeners(foregroundListener: Void->Void, resumeListener: Void->Void, pauseListener: Void->Void,
			backgroundListener: Void->Void, shutdownListener: Void->Void): Void {
		if (foregroundListener != null)
			foregroundListeners.remove(foregroundListener);
		if (resumeListener != null)
			resumeListeners.remove(resumeListener);
		if (pauseListener != null)
			pauseListeners.remove(pauseListener);
		if (backgroundListener != null)
			backgroundListeners.remove(backgroundListener);
		if (shutdownListener != null)
			shutdownListeners.remove(shutdownListener);
	}

	public static function notifyOnDropFiles(dropFilesListener: String->Void): Void {
		dropFilesListeners.push(dropFilesListener);
	}

	public static function removeDropListener(listener: String->Void): Void {
		dropFilesListeners.remove(listener);
	}

	public static function notifyOnCutCopyPaste(cutListener: Void->String, copyListener: Void->String, pasteListener: String->Void): Void {
		System.cutListener = cutListener;
		System.copyListener = copyListener;
		System.pasteListener = pasteListener;
	}

	/*public static function copyToClipboard(text: String) {
		SystemImpl.copyToClipboard(text);
	}*/
	public static function notifyOnLoginLogout(loginListener: Void->Void, logoutListener: Void->Void) {
		System.loginListener = loginListener;
		System.logoutListener = logoutListener;
	}

	public static function login(): Void {
		SystemImpl.login();
	}

	public static function waitingForLogin(): Bool {
		return SystemImpl.waitingForLogin();
	}

	public static function allowUserChange(): Void {
		SystemImpl.allowUserChange();
	}

	public static function disallowUserChange(): Void {
		SystemImpl.disallowUserChange();
	}

	static function render(framebuffers: Array<Framebuffer>): Void {
		for (listener in renderListeners) {
			listener(framebuffers);
		}
	}

	static function foreground(): Void {
		for (listener in foregroundListeners) {
			listener();
		}
	}

	static function resume(): Void {
		for (listener in resumeListeners) {
			listener();
		}
	}

	static function pause(): Void {
		for (listener in pauseListeners) {
			listener();
		}
	}

	static function background(): Void {
		for (listener in backgroundListeners) {
			listener();
		}
	}

	static function shutdown(): Void {
		for (listener in shutdownListeners) {
			listener();
		}
	}

	static function dropFiles(filePath: String): Void {
		for (listener in dropFilesListeners) {
			listener(filePath);
		}
	}

	public static var time(get, null): Float;

	static function get_time(): Float {
		return SystemImpl.getTime();
	}

	public static function windowWidth(window: Int = 0): Int {
		return Window.get(window).width;
	}

	public static function windowHeight(window: Int = 0): Int {
		return Window.all[window].height;
	}

	public static var screenRotation(get, null): ScreenRotation;

	static function get_screenRotation(): ScreenRotation {
		return RotationNone;
	}

	public static var systemId(get, null): String;

	static function get_systemId(): String {
		return SystemImpl.getSystemId();
	}

	/**
	 * Pulses the vibration hardware on the device for time in milliseconds, if such hardware exists.
	 */
	public static function vibrate(ms: Int): Void {
		return SystemImpl.vibrate(ms);
	}

	/**
	 * The IS0 639 system current language identifier.
	 */
	public static var language(get, never): String;

	static function get_language(): String {
		return SystemImpl.getLanguage();
	}

	/**
	 * Schedules the application to stop as soon as possible. This is not possible on all targets.
	 * @return Returns true if the application can be stopped
	 */
	public static function stop(): Bool {
		return SystemImpl.requestShutdown();
	}

	public static function loadUrl(url: String): Void {
		SystemImpl.loadUrl(url);
	}

	@:deprecated("This only returns a default value")
	public static function canSwitchFullscreen(): Bool {
		return true;
	}

	@:deprecated("Use the kha.Window API instead")
	public static function isFullscreen(): Bool {
		return Window.get(0).mode == WindowMode.Fullscreen || Window.get(0).mode == WindowMode.ExclusiveFullscreen;
	}

	@:deprecated("Use the kha.Window API instead")
	public static function requestFullscreen(): Void {
		Window.get(0).mode = WindowMode.Fullscreen;
	}

	@:deprecated("Use the kha.Window API instead")
	public static function exitFullscreen(): Void {
		Window.get(0).mode = WindowMode.Windowed;
	}

	@:deprecated("This does nothing")
	public static function notifyOnFullscreenChange(func: Void->Void, error: Void->Void): Void {}

	@:deprecated("This does nothing")
	public static function removeFullscreenListener(func: Void->Void, error: Void->Void): Void {}

	@:deprecated("This does nothing. On Windows you can use Window.resize instead after setting the mode to ExclusiveFullscreen")
	public static function changeResolution(width: Int, height: Int): Void {}

	@:deprecated("Use System.stop instead")
	public static function requestShutdown(): Void {
		stop();
	}

	@:deprecated("Use the kha.Window API instead")
	public static var vsync(get, null): Bool;

	static function get_vsync(): Bool {
		return Window.get(0).vSynced;
	}

	@:deprecated("Use the kha.Display API instead")
	public static var refreshRate(get, null): Int;

	static function get_refreshRate(): Int {
		return Display.primary.frequency;
	}

	@:deprecated("Use the kha.Display API instead")
	public static function screenDpi(): Int {
		return Display.primary.pixelsPerInch;
	}

	public static function safeZone(): Float {
		return SystemImpl.safeZone();
	}

	public static function automaticSafeZone(): Bool {
		return SystemImpl.automaticSafeZone();
	}

	public static function setSafeZone(value: Float): Void {
		SystemImpl.setSafeZone(value);
	}

	public static function unlockAchievement(id: Int): Void {
		SystemImpl.unlockAchievement(id);
	}
}

package kha;

import js.Browser;
import js.html.CanvasElement;
import js.Node;
import kha.System.SystemOptions;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.js.EmptyGraphics1;
import kha.js.EmptyGraphics2;
import kha.js.EmptyGraphics4;
import kha.netsync.Session;

class SystemImpl {
	static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;

	static inline var networkSendRate = 0.05;

	public static function init(options: SystemOptions, callback: Window->Void): Void {
		Window.get(0).width = options.width;
		Window.get(0).height = options.height;
		init2();
		callback(null);
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int->Void, callback: Window->Void) {
		trace('initEx is not supported on the node target, running init() with first window options');

		init({title: title, width: options[0].width, height: options[0].height}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}

	public static function changeResolution(width: Int, height: Int): Void {}

	public static function _updateSize(width: Int, height: Int): Void {
		Window.get(0).width = width;
		Window.get(0).height = height;
	}

	public static function _updateScreenRotation(value: Int): Void {
		screenRotation = cast value;
	}

	public static function getTime(): Float {
		var time = Node.process.hrtime();
		return cast(time[0], Float) + cast(time[1], Float) / 1000000000;
	}

	public static function screenDpi(): Int {
		return 96;
	}

	public static function getScreenRotation(): ScreenRotation {
		return screenRotation;
	}

	public static function getVsync(): Bool {
		return false;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "nodejs";
	}

	public static function vibrate(ms: Int): Void {}

	public static function getLanguage(): String {
		return "en";
	}

	public static function requestShutdown(): Bool {
		Node.process.exit(0);
		return true;
	}

	static var frame: Framebuffer = null;
	static var keyboard: Keyboard;
	static var mouse: kha.input.Mouse;
	static var gamepad: Gamepad;

	public static var mouseX: Int;
	public static var mouseY: Int;

	static var lastTime: Float = 0;

	static function init2() {
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();

		Scheduler.init();

		Shaders.init();
		final width = Window.get(0).width;
		final height = Window.get(0).height;
		frame = new Framebuffer(0, new EmptyGraphics1(width, height), new EmptyGraphics2(width, height), new EmptyGraphics4(width, height));
		Scheduler.start();

		lastTime = Scheduler.time();
		run();
		synch();
	}

	static function run() {
		Scheduler.executeFrame();
		var time = Scheduler.time();

		// Was scheduler reset?
		if (time < lastTime - 10) {
			lastTime = time;
		}

		if (time >= lastTime + 10) {
			lastTime = time;
			Node.console.log(lastTime + " seconds.");
		}
		Node.setTimeout(run, 1);
	}

	static function synch() {
		if (Session.the() != null) {
			Session.the().update();
		}
		Node.setTimeout(synch, Std.int(networkSendRate * 1000));
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0)
			return null;
		return keyboard;
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0)
			return null;
		return mouse;
	}

	public static function lockMouse(): Void {}

	public static function unlockMouse(): Void {}

	public static function canLockMouse(): Bool {
		return false;
	}

	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void->Void, error: Void->Void): Void {}

	public static function removeFromMouseLockChange(func: Void->Void, error: Void->Void): Void {}

	public static function canSwitchFullscreen(): Bool {
		return false;
	}

	public static function isFullscreen(): Bool {
		return false;
	}

	public static function requestFullscreen(): Void {}

	public static function exitFullscreen(): Void {}

	public static function notifyOfFullscreenChange(func: Void->Void, error: Void->Void): Void {}

	public static function removeFromFullscreenChange(func: Void->Void, error: Void->Void): Void {}

	public static function setKeepScreenOn(on: Bool): Void {}

	public static function loadUrl(url: String): Void {}

	public static function getGamepadId(index: Int): String {
		return "unknown";
	}

	public static function getGamepadVendor(index: Int): String {
		return "unknown";
	}

	public static function setGamepadRumble(index: Int, leftAmount: Float, rightAmount: Float): Void {}

	public static function getPen(num: Int): kha.input.Pen {
		return null;
	}

	public static function safeZone(): Float {
		return 1.0;
	}

	public static function login(): Void {}

	public static function automaticSafeZone(): Bool {
		return true;
	}

	public static function setSafeZone(value: Float): Void {}

	public static function unlockAchievement(id: Int): Void {}

	public static function waitingForLogin(): Bool {
		return false;
	}

	public static function disallowUserChange(): Void {}

	public static function allowUserChange(): Void {}
}

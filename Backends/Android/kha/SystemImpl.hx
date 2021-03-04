package kha;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import tech.kode.kha.KhaActivity;
import kha.android.Graphics;
import kha.android.Keyboard;
import kha.graphics4.Graphics2;
import android.view.KeyEvent;
import android.os.Vibrator;
// import android.os.VibrationEffect;
import android.os.BuildVERSION;
import kha.input.Mouse;
import kha.input.KeyCode;
import kha.input.Surface;
import kha.System;

class SystemImpl {
	public static var w: Int = 640;
	public static var h: Int = 480;
	static var startTime: Float;

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getFrequency(): Int {
		return 1000;
	}

	@:functionCode('
		return java.lang.System.currentTimeMillis();
	')
	public static function getTimestamp(): Float {
		return 0;
	}

	public static function getTime(): Float {
		return (getTimestamp() - startTime) / getFrequency();
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "Android";
	}

	public static function vibrate(ms: Int): Void {
		var instance = KhaActivity.the();
		var v: Vibrator = cast instance.getSystemService(Context.VIBRATOR_SERVICE);
		if (BuildVERSION.SDK_INT >= 26) { // Build.VERSION_CODES.O
			untyped __java__("v.vibrate(
					android.os.VibrationEffect.createOneShot(ms,
						android.os.VibrationEffect.DEFAULT_AMPLITUDE));
			");
		}
		else {
			// deprecated in API 26
			v.vibrate(ms);
		}
	}

	public static function getLanguage(): String {
		final lang = java.util.Locale.getDefault().getLanguage();
		return lang.substr(0, 2).toLowerCase();
	}

	public static function requestShutdown(): Bool {
		shutdown();
		untyped __java__("java.lang.System.exit(0)");
		return true;
	}

	public static function changeResolution(width: Int, height: Int): Void {}

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

	static var framebuffer: Framebuffer;
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	static var keyboard: Keyboard;
	static var shift = false;
	static var mouse: Mouse;
	static var surface: Surface;

	public static function init(options: SystemOptions, done: Window->Void) {
		w = options.width;
		h = options.height;
		KhaActivity.the();
		keyboard = new Keyboard();
		mouse = new Mouse();
		// gamepad = new Gamepad();
		surface = new Surface();

		new Window();
		LoaderImpl.init(KhaActivity.the().getApplicationContext());
		Scheduler.init();

		Shaders.init();
		var graphics = new Graphics();
		framebuffer = new Framebuffer(0, null, null, graphics);
		var g1 = new kha.graphics2.Graphics1(framebuffer);
		var g2 = new Graphics2(framebuffer);
		framebuffer.init(g1, g2, graphics);

		// if (kha.audio2.Audio._init()) {
		// kha.audio2.Audio1._init();
		// }

		Scheduler.start();

		done(Window.get(0));
	}

	public static function getKeyboard(num: Int = 0): Keyboard {
		if (num == 0)
			return keyboard;
		else
			return null;
	}

	public static function getMouse(num: Int = 0): Mouse {
		if (num == 0)
			return mouse;
		else
			return null;
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

	@:access(Main.main)
	public static function preinit(width: Int, height: Int): Void {
		w = width;
		h = height;
		startTime = getTimestamp();
		Main.main();
	}

	public static function setWidthHeight(width: Int, height: Int): Void {
		w = width;
		h = height;
	}

	public static function step(): Void {
		Scheduler.executeFrame();
		System.render([framebuffer]);
	}

	static function setMousePosition(x: Int, y: Int) {
		mouseX = x;
		mouseY = y;
	}

	public static function touch(index: Int, x: Int, y: Int, action: Int): Void {
		switch (action) {
			case 0: // DOWN
				if (index == 0) {
					setMousePosition(x, y);
					mouse.sendDownEvent(0, 0, x, y);
				}
				surface.sendTouchStartEvent(index, x, y);
			case 1: // MOVE
				if (index == 0) {
					var movementX = x - mouseX;
					var movementY = y - mouseY;
					setMousePosition(x, y);
					mouse.sendMoveEvent(0, x, y, movementX, movementY);
				}
				surface.sendMoveEvent(index, x, y);
			case 2: // UP
				if (index == 0) {
					setMousePosition(x, y);
					mouse.sendUpEvent(0, 0, x, y);
				}
				surface.sendTouchEndEvent(index, x, y);
		}
	}

	public static function keyDown(code: Int): Void {
		switch (code) {
			case 0x00000120:
				shift = true;
				keyboard.sendDownEvent(KeyCode.Shift);
			case 0x00000103:
				keyboard.sendDownEvent(KeyCode.Backspace);
			case 0x00000104:
				keyboard.sendDownEvent(KeyCode.Return);
			case 0x00000004:
				keyboard.sendDownEvent(KeyCode.Back);
			default:
		}
	}

	public static function keyUp(code: Int): Void {
		switch (code) {
			case 0x00000120:
				shift = false;
				keyboard.sendUpEvent(KeyCode.Shift);
			case 0x00000103:
				keyboard.sendUpEvent(KeyCode.Backspace);
			case 0x00000104:
				keyboard.sendUpEvent(KeyCode.Return);
			case 0x00000004:
				keyboard.sendUpEvent(KeyCode.Back);
			default:
		}
	}

	public static function keyPress(char: String): Void {
		keyboard.sendPressEvent(char);
	}

	public static var showKeyboard: Bool;

	public static function keyboardShown(): Bool {
		return showKeyboard;
	}

	public static function foreground(): Void {
		System.foreground();
	}

	public static function resume(): Void {
		System.resume();
	}

	public static function pause(): Void {
		System.pause();
	}

	public static function background(): Void {
		System.background();
	}

	public static function shutdown(): Void {
		System.shutdown();
	}

	public static function setKeepScreenOn(on: Bool): Void {}

	public static function loadUrl(url: String): Void {
		var i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
		KhaActivity.the().startActivity(i);
	}

	public static function getGamepadId(index: Int): String {
		return "unknown";
	}

	public static function getGamepadVendor(index: Int): String {
		return "unknown";
	}

	public static function setGamepadRumble(index: Int, leftAmount: Float, rightAmount: Float) {}

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

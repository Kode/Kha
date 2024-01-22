package kha;

import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.input.Pen;
import kha.input.Surface;
import kha.System;
import haxe.ds.Vector;

class SystemImpl {
	static var start: Float;
	static var framebuffer: Framebuffer;
	static var keyboard: Keyboard;
	static var mouse: Mouse;
	static var pen: Pen;
	static var maxGamepads: Int = 8;
	static var gamepads: Array<Gamepad>;
	static var mouseLockListeners: Array<Void->Void> = [];

	static function renderCallback(): Void {
		Scheduler.executeFrame();
		System.render([framebuffer]);
	}

	static function dropFilesCallback(filePath: String): Void {
		System.dropFiles(filePath);
	}

	static function copyCallback(): String {
		if (System.copyListener != null) {
			return System.copyListener();
		}
		else {
			return null;
		}
	}

	static function cutCallback(): String {
		if (System.cutListener != null) {
			return System.cutListener();
		}
		else {
			return null;
		}
	}

	static function pasteCallback(data: String): Void {
		if (System.pasteListener != null) {
			System.pasteListener(data);
		}
	}

	static function foregroundCallback(): Void {
		System.foreground();
	}

	static function resumeCallback(): Void {
		System.resume();
	}

	static function pauseCallback(): Void {
		System.pause();
	}

	static function backgroundCallback(): Void {
		System.background();
	}

	static function shutdownCallback(): Void {
		System.shutdown();
	}

	static function keyboardDownCallback(code: Int): Void {
		keyboard.sendDownEvent(cast code);
	}

	static function keyboardUpCallback(code: Int): Void {
		keyboard.sendUpEvent(cast code);
	}

	static function keyboardPressCallback(charCode: Int): Void {
		keyboard.sendPressEvent(String.fromCharCode(charCode));
	}

	static function mouseDownCallback(button: Int, x: Int, y: Int): Void {
		mouse.sendDownEvent(0, button, x, y);
	}

	static function mouseUpCallback(button: Int, x: Int, y: Int): Void {
		mouse.sendUpEvent(0, button, x, y);
	}

	static function mouseMoveCallback(x: Int, y: Int, mx: Int, my: Int): Void {
		mouse.sendMoveEvent(0, x, y, mx, my);
	}

	static function mouseWheelCallback(delta: Int): Void {
		mouse.sendWheelEvent(0, delta);
	}

	static function penDownCallback(x: Int, y: Int, pressure: Float): Void {
		pen.sendDownEvent(0, x, y, pressure);
	}

	static function penUpCallback(x: Int, y: Int, pressure: Float): Void {
		pen.sendUpEvent(0, x, y, pressure);
	}

	static function penMoveCallback(x: Int, y: Int, pressure: Float): Void {
		pen.sendMoveEvent(0, x, y, pressure);
	}

	static function gamepadAxisCallback(gamepad: Int, axis: Int, value: Float): Void {
		gamepads[gamepad].sendAxisEvent(axis, value);
	}

	static function gamepadButtonCallback(gamepad: Int, button: Int, value: Float): Void {
		gamepads[gamepad].sendButtonEvent(button, value);
	}

	static function audioCallback(samples: Int): Void {
		kha.audio2.Audio._callCallback(samples);
		var buffer = @:privateAccess kha.audio2.Audio.buffer;
		Krom.writeAudioBuffer(buffer.data.buffer, samples);
	}

	public static function init(options: SystemOptions, callback: Window->Void): Void {
		Krom.init(options.title, options.width, options.height, options.framebuffer.samplesPerPixel, options.framebuffer.verticalSync,
			cast options.window.mode, options.window.windowFeatures, Krom.KROM_API);

		start = Krom.getTime();

		haxe.Log.trace = function(v: Dynamic, ?infos: haxe.PosInfos) {
			var message = haxe.Log.formatOutput(v, infos);
			Krom.log(message);
		};

		new Window(0);
		Scheduler.init();
		Shaders.init();

		var g4 = new kha.krom.Graphics();
		framebuffer = new Framebuffer(0, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.graphics4.Graphics2(framebuffer), g4);
		Krom.setCallback(renderCallback);
		Krom.setDropFilesCallback(dropFilesCallback);
		Krom.setCutCopyPasteCallback(cutCallback, copyCallback, pasteCallback);
		Krom.setApplicationStateCallback(foregroundCallback, resumeCallback, pauseCallback, backgroundCallback, shutdownCallback);

		keyboard = new Keyboard();
		mouse = new MouseImpl();
		pen = new Pen();
		gamepads = new Array<Gamepad>();
		for (i in 0...maxGamepads) {
			gamepads[i] = new Gamepad(i);
		}

		Krom.setKeyboardDownCallback(keyboardDownCallback);
		Krom.setKeyboardUpCallback(keyboardUpCallback);
		Krom.setKeyboardPressCallback(keyboardPressCallback);
		Krom.setMouseDownCallback(mouseDownCallback);
		Krom.setMouseUpCallback(mouseUpCallback);
		Krom.setMouseMoveCallback(mouseMoveCallback);
		Krom.setMouseWheelCallback(mouseWheelCallback);
		Krom.setPenDownCallback(penDownCallback);
		Krom.setPenUpCallback(penUpCallback);
		Krom.setPenMoveCallback(penMoveCallback);
		Krom.setGamepadAxisCallback(gamepadAxisCallback);
		Krom.setGamepadButtonCallback(gamepadButtonCallback);

		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		Krom.setAudioCallback(audioCallback);

		Scheduler.start();

		callback(Window.get(0));
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int->Void, callback: Void->Void): Void {}

	static function translateWindowMode(value: Null<WindowMode>): Int {
		if (value == null) {
			return 0;
		}

		return switch (value) {
			case Windowed: 0;
			case Fullscreen: 1;
			case ExclusiveFullscreen: 2;
		}
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getTime(): Float {
		return Krom.getTime() - start;
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return Krom.systemId();
	}

	public static function vibrate(ms: Int): Void {
		// TODO: Implement
	}

	public static function getLanguage(): String {
		return "en"; // TODO: Implement
	}

	public static function requestShutdown(): Bool {
		Krom.requestShutdown();
		return true;
	}

	public static function getMouse(num: Int): Mouse {
		return mouse;
	}

	public static function getPen(num: Int): Pen {
		return pen;
	}

	public static function getKeyboard(num: Int): Keyboard {
		return keyboard;
	}

	public static function lockMouse(): Void {
		if (!isMouseLocked()) {
			Krom.lockMouse();
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function unlockMouse(): Void {
		if (isMouseLocked()) {
			Krom.unlockMouse();
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function canLockMouse(): Bool {
		return Krom.canLockMouse();
	}

	public static function isMouseLocked(): Bool {
		return Krom.isMouseLocked();
	}

	public static function notifyOfMouseLockChange(func: Void->Void, error: Void->Void): Void {
		if (canLockMouse() && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func: Void->Void, error: Void->Void): Void {
		if (canLockMouse() && func != null) {
			mouseLockListeners.remove(func);
		}
	}

	public static function hideSystemCursor(): Void {
		Krom.showMouse(false);
	}

	public static function showSystemCursor(): Void {
		Krom.showMouse(true);
	}

	static function unload(): Void {}

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

	public static function changeResolution(width: Int, height: Int): Void {}

	public static function setKeepScreenOn(on: Bool): Void {}

	public static function loadUrl(url: String): Void {}

	public static function getGamepadId(index: Int): String {
		return "unknown";
	}

	public static function getGamepadVendor(index: Int): String {
		return "unknown";
	}

	public static function setGamepadRumble(index: Int, leftAmount: Float, rightAmount: Float): Void {}

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

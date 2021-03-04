package kha;

import kha.graphics4.Graphics2;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.KeyCode;
import system.diagnostics.Stopwatch;
import kha.System;

class SystemImpl {
	static var watch: Stopwatch;

	// public static var graphics: Graphics;

	public static function init2(): Void {
		// graphics = new Graphics();
		watch = new Stopwatch();
		watch.Start();
	}

	@:functionCode('
		return watch.ElapsedMilliseconds / 1000.0;
	')
	public static function getTime(): Float {
		return 0;
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function windowWidth(windowId: Int = 0): Int {
		return unityEngine.Screen.width;
	}

	public static function windowHeight(windowId: Int = 0): Int {
		return unityEngine.Screen.height;
	}

	public static function screenDpi(): Int {
		return 96;
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

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

	public static function requestShutdown(): Bool {
		// unityEngine.Application.Quit();
		return true;
	}

	public static function getSystemId(): String {
		return "unity";
	}

	public static function vibrate(ms: Int): Void {
		// TODO: Implement
	}

	public static function getLanguage(): String {
		return "en"; // TODO: Implement
	}

	static var frame: Framebuffer;

	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	static var keyboard: Keyboard;
	static var mouse: kha.input.Mouse;
	static var gamepad1: Gamepad;
	static var gamepad2: Gamepad;
	static var gamepad3: Gamepad;
	static var gamepad4: Gamepad;

	public static function init(options: SystemOptions, callback: Window->Void) {
		init2();
		Scheduler.init();
		new Window(0);
		Window.get(0).title = options.title;
		// TODO: update shaders in %kha%\Backends\Unity\kha\graphics4
		Shaders.init();

		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad1 = new Gamepad(0);
		gamepad2 = new Gamepad(1);
		gamepad3 = new Gamepad(2);
		gamepad4 = new Gamepad(3);

		var g4 = new kha.unity.Graphics(null);
		frame = new Framebuffer(0, null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new Graphics2(frame), g4);
		Scheduler.start();
		callback(Window.get(0));
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int->Void, callback: Window->Void) {
		trace('System.initEx is not supported on unity, falling back to init() with first window options');
		init({title: title, width: options[0].width, height: options[0].height}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num == 0)
			return keyboard;
		else
			return null;
	}

	public static function getMouse(num: Int): kha.input.Mouse {
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

	public static function leftDown(): Void {
		Keyboard.get().sendDownEvent(KeyCode.Left);
	}

	public static function rightDown(): Void {
		Keyboard.get().sendDownEvent(KeyCode.Right);
	}

	public static function upDown(): Void {
		Keyboard.get().sendDownEvent(KeyCode.Up);
	}

	public static function downDown(): Void {
		Keyboard.get().sendDownEvent(KeyCode.Down);
	}

	public static function leftUp(): Void {
		Keyboard.get().sendUpEvent(KeyCode.Left);
	}

	public static function rightUp(): Void {
		Keyboard.get().sendUpEvent(KeyCode.Right);
	}

	public static function upUp(): Void {
		Keyboard.get().sendUpEvent(KeyCode.Up);
	}

	public static function downUp(): Void {
		Keyboard.get().sendUpEvent(KeyCode.Down);
	}

	public static function mouseDown(button: Int, x: Int, y: Int): Void {
		kha.input.Mouse.get().sendDownEvent(0, button, x, y);
	}

	public static function mouseUp(button: Int, x: Int, y: Int): Void {
		kha.input.Mouse.get().sendUpEvent(0, button, x, y);
	}

	public static function gamepad1Axis(axis: Int, value: Float): Void {
		gamepad1.sendAxisEvent(axis, value);
	}

	public static function gamepad1Button(button: Int, value: Float): Void {
		gamepad1.sendButtonEvent(button, value);
	}

	public static function gamepad2Axis(axis: Int, value: Float): Void {
		gamepad2.sendAxisEvent(axis, value);
	}

	public static function gamepad2Button(button: Int, value: Float): Void {
		gamepad2.sendButtonEvent(button, value);
	}

	public static function gamepad3Axis(axis: Int, value: Float): Void {
		gamepad3.sendAxisEvent(axis, value);
	}

	public static function gamepad3Button(button: Int, value: Float): Void {
		gamepad3.sendButtonEvent(button, value);
	}

	public static function gamepad4Axis(axis: Int, value: Float): Void {
		gamepad4.sendAxisEvent(axis, value);
	}

	public static function gamepad4Button(button: Int, value: Float): Void {
		gamepad4.sendButtonEvent(button, value);
	}

	public static function update(): Void {
		Scheduler.executeFrame();
		System.render([frame]);
	}

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

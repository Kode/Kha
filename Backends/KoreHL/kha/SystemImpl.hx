package kha;

import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.input.Pen;
import kha.input.Surface;
import kha.System;

class SystemImpl {
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var pen: kha.input.Pen;
	private static var gamepad1: Gamepad;
	private static var gamepad2: Gamepad;
	private static var gamepad3: Gamepad;
	private static var gamepad4: Gamepad;
	private static var surface: Surface;
	private static var mouseLockListeners: Array<Void->Void>;

	public static function init(options: SystemOptions, callback: Window -> Void): Void {
		haxe.Log.trace = function(v: Dynamic, ?infos: haxe.PosInfos) {
			var message = infos != null ? infos.className + ":" + infos.lineNumber + ": " + v : Std.string(v);
			kore_log(StringHelper.convert(message));
		};
		init_kore(StringHelper.convert(options.title), options.width, options.height, options.framebuffer.samplesPerPixel, options.framebuffer.verticalSync, cast options.window.mode, options.window.windowFeatures);

		new Window(0);
		Scheduler.init();
		Shaders.init();

		var g4 = new kha.korehl.graphics4.Graphics();
		framebuffer = new Framebuffer(0, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.korehl.graphics4.Graphics2(framebuffer), g4);
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		kore_init_audio(kha.audio2.Audio._callCallback, kha.audio2.Audio._readSample, kha.audio2.Audio.samplesPerSecond);
		keyboard = new kha.input.Keyboard();
		mouse = new kha.input.MouseImpl();
		pen = new kha.input.Pen();
		gamepad1 = new kha.input.Gamepad(0);
		gamepad2 = new kha.input.Gamepad(1);
		gamepad3 = new kha.input.Gamepad(2);
		gamepad4 = new kha.input.Gamepad(3);
		surface = new kha.input.Surface();
		mouseLockListeners = new Array();
		kore_register_keyboard(keyDown, keyUp, keyPress);
		kore_register_mouse(mouseDown, mouseUp, mouseMove, mouseWheel);
		kore_register_pen(penDown, penUp, penMove);
		kore_register_gamepad(0, gamepad1Axis, gamepad1Button);
		kore_register_gamepad(1, gamepad2Axis, gamepad2Button);
		kore_register_gamepad(2, gamepad3Axis, gamepad3Button);
		kore_register_gamepad(3, gamepad4Axis, gamepad4Button);
		kore_register_surface(touchStart, touchEnd, touchMove);
		kore_register_sensor(kha.input.Sensor._accelerometerChanged, kha.input.Sensor._gyroscopeChanged);
		kore_register_callbacks(foreground, resume, pause, background, shutdown);
		kore_register_dropfiles(dropFiles);
		kore_register_copycutpaste(copy, cut, paste);

		Scheduler.start();
		callback(Window.get(0));

		run_kore();
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void): Void {

	}

	@:keep
	public static function frame(): Void {
		Scheduler.executeFrame();
		System.render([framebuffer]);
	}

	public static function getTime(): Float {
		return kore_get_time();
	}

	public static function windowWidth(windowId: Int): Int {
		return kore_get_window_width(windowId);
	}

	public static function windowHeight(windowId: Int): Int {
		return kore_get_window_height(windowId);
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getSystemId(): String {
		// return kore_get_system_id();
		return 'HL';
	}

	public static function vibrate(ms:Int): Void {
		//TODO: Implement
	}

	public static function getLanguage(): String {
		return "en"; //TODO: Implement
	}

	public static function requestShutdown(): Bool {
		kore_request_shutdown();
		return true;
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}

	public static function getPen(num: Int): Pen {
		if (num != 0) return null;
		return pen;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
		return keyboard;
	}

	public static function lockMouse(windowId: Int = 0): Void {
		if (!isMouseLocked()) {
			kore_mouse_lock(windowId);
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function unlockMouse(windowId: Int = 0): Void {
		if (isMouseLocked()) {
			kore_mouse_unlock(windowId);
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function canLockMouse(windowId: Int = 0): Bool {
		return kore_can_lock_mouse(windowId);
	}

	public static function isMouseLocked(windowId: Int = 0): Bool {
		return kore_is_mouse_locked(windowId);
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void{
		if (canLockMouse(0) && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		if (canLockMouse(0) && func != null) {
			mouseLockListeners.remove(func);
		}
	}

	public static function hideSystemCursor(): Void {
		kore_show_mouse(false);
	}

	public static function showSystemCursor(): Void {
		kore_show_mouse(true);
	}

	public static function keyDown(code: KeyCode): Void {
		keyboard.sendDownEvent(code);
	}

	public static function keyUp(code: KeyCode): Void {
		keyboard.sendUpEvent(code);
	}

	public static function keyPress(char: Int): Void {
		keyboard.sendPressEvent(String.fromCharCode(char));
	}

	public static function mouseDown(windowId: Int, button: Int, x: Int, y: Int): Void {
		mouse.sendDownEvent(windowId, button, x, y);
	}

	public static function mouseUp(windowId: Int, button: Int, x: Int, y: Int): Void {
		mouse.sendUpEvent(windowId, button, x, y);
	}

	public static function mouseMove(windowId: Int, x: Int, y: Int, movementX: Int, movementY: Int): Void {
		mouse.sendMoveEvent(windowId, x, y, movementX, movementY);
	}

	public static function mouseWheel(windowId: Int, delta: Int): Void {
		mouse.sendWheelEvent(windowId, delta);
	}

	public static function mouseLeave(windowId: Int): Void {
		mouse.sendLeaveEvent(windowId);
	}

	public static function penDown(windowId: Int, x: Int, y: Int, pressure: Float): Void {
		pen.sendDownEvent(windowId, x, y, pressure);
	}

	public static function penUp(windowId: Int, x: Int, y: Int, pressure: Float): Void {
		pen.sendUpEvent(windowId, x, y, pressure);
	}

	public static function penMove(windowId: Int, x: Int, y: Int, pressure: Float): Void {
		pen.sendMoveEvent(windowId, x, y, pressure);
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

	public static function touchStart(index: Int, x: Int, y: Int): Void {
		surface.sendTouchStartEvent(index, x, y);
	}

	public static function touchEnd(index: Int, x: Int, y: Int): Void {
		surface.sendTouchEndEvent(index, x, y);
	}

	public static function touchMove(index: Int, x: Int, y: Int): Void {
		surface.sendMoveEvent(index, x, y);
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

	public static function dropFiles(filePath: String): Void {
		System.dropFiles(filePath);
	}

	public static function copy(): String {
		if (System.copyListener != null) {
			return System.copyListener();
		}
		else {
			return null;
		}
	}

	public static function cut(): String {
		if (System.cutListener != null) {
			return System.cutListener();
		}
		else {
			return null;
		}
	}

	public static function paste(data: String): Void {
		if (System.pasteListener != null) {
			System.pasteListener(data);
		}
	}

	private static var fullscreenListeners: Array<Void->Void> = new Array();
	private static var previousWidth: Int = 0;
	private static var previousHeight: Int = 0;

	public static function canSwitchFullscreen(): Bool {
		return true;
	}

	public static function isFullscreen(): Bool {
		return kore_system_is_fullscreen();
	}

	public static function requestFullscreen(): Void {
		if(!isFullscreen()){
			previousWidth = kore_get_window_width(0);
			previousHeight = kore_get_window_height(0);
			kore_system_request_fullscreen();
			for (listener in fullscreenListeners) {
				listener();
			}
		}
	}

	public static function exitFullscreen(): Void {
		if (isFullscreen()) {
			if (previousWidth == 0 || previousHeight == 0){
				previousWidth = kore_get_window_width(0);
				previousHeight = kore_get_window_height(0);
			}
			kore_system_exit_fullscreen(previousWidth, previousHeight);
			for (listener in fullscreenListeners) {
				listener();
			}
		}
	}

	public static function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		if (canSwitchFullscreen() && func != null) {
			fullscreenListeners.push(func);
		}
	}

	public static function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		if (canSwitchFullscreen() && func != null) {
			fullscreenListeners.remove(func);
		}
	}

	public static function changeResolution(width: Int, height: Int): Void {
		kore_system_change_resolution(width, height);
	}

	public static function setKeepScreenOn(on: Bool): Void {
		kore_system_set_keepscreenon(on);
	}

	public static function loadUrl(url: String): Void {
		kore_system_load_url(StringHelper.convert(url));
	}

	public static function getGamepadId(index: Int): String {
		return "";//kore_get_gamepad_id(index);
	}

	public static function safeZone(): Float {
		return 1.0;
	}

	@:hlNative("std", "init_kore") static function init_kore(title: hl.Bytes, width: Int, height: Int, samplesPerPixel: Int, vSync: Bool, windowMode: Int, windowFeatures: Int): Void { }
	@:hlNative("std", "run_kore") static function run_kore(): Void { }
	@:hlNative("std", "kore_init_audio") static function kore_init_audio(callCallback: Int->Void, readSample: Void->FastFloat, outSamplesPerSecond: hl.Ref<Int>): Void { }
	@:hlNative("std", "kore_log") static function kore_log(v: hl.Bytes): Void { }
	@:hlNative("std", "kore_get_time") static function kore_get_time(): Float { return 0; }
	@:hlNative("std", "kore_get_window_width") static function kore_get_window_width(window: Int): Int { return 0; }
	@:hlNative("std", "kore_get_window_height") static function kore_get_window_height(window: Int): Int { return 0; }
	@:hlNative("std", "kore_get_system_id") static function kore_get_system_id(): hl.Bytes { return null; }
	@:hlNative("std", "kore_request_shutdown") static function kore_request_shutdown(): Void { }
	@:hlNative("std", "kore_mouse_lock") static function kore_mouse_lock(windowId: Int): Void { }
	@:hlNative("std", "kore_mouse_unlock") static function kore_mouse_unlock(windowId: Int): Void { }
	@:hlNative("std", "kore_can_lock_mouse") static function kore_can_lock_mouse(windowId: Int): Bool { return false; }
	@:hlNative("std", "kore_is_mouse_locked") static function kore_is_mouse_locked(windowId: Int): Bool { return false; }
	@:hlNative("std", "kore_show_mouse") static function kore_show_mouse(show: Bool): Void { }
	@:hlNative("std", "kore_system_is_fullscreen") static function kore_system_is_fullscreen(): Bool { return false; }
	@:hlNative("std", "kore_system_request_fullscreen") static function kore_system_request_fullscreen(): Void { }
	@:hlNative("std", "kore_system_exit_fullscreen") static function kore_system_exit_fullscreen(previousWidth: Int, previousHeight: Int): Void { }
	@:hlNative("std", "kore_register_keyboard") static function kore_register_keyboard(keyDown: KeyCode->Void, keyUp: KeyCode->Void, keyPress: Int->Void): Void { }
	@:hlNative("std", "kore_register_mouse") static function kore_register_mouse(mouseDown: Int->Int->Int->Int->Void, mouseUp: Int->Int->Int->Int->Void, mouseMove: Int->Int->Int->Int->Int->Void, mouseWheel: Int->Int->Void): Void { }
	@:hlNative("std", "kore_register_pen") static function kore_register_pen(penDown: Int->Int->Int->Float->Void, penUp: Int->Int->Int->Float->Void, penMove: Int->Int->Int->Float->Void): Void { }
	@:hlNative("std", "kore_register_gamepad") static function kore_register_gamepad(index: Int, gamepadAxis: Int->Float->Void, gamepadButton: Int->Float->Void): Void { }
	@:hlNative("std", "kore_register_surface") static function kore_register_surface(touchStart: Int->Int->Int->Void, touchEnd: Int->Int->Int->Void, touchMove: Int->Int->Int->Void): Void { }
	@:hlNative("std", "kore_register_sensor") static function kore_register_sensor(accelerometerChanged: Float->Float->Float->Void, gyroscopeChanged: Float->Float->Float->Void): Void { }
	@:hlNative("std", "kore_register_callbacks") static function kore_register_callbacks(foreground: Void->Void, resume: Void->Void, pause: Void->Void, background: Void->Void, shutdown: Void->Void): Void { }
	@:hlNative("std", "kore_register_dropfiles") static function kore_register_dropfiles(dropFiles: String->Void): Void { }
	@:hlNative("std", "kore_register_copycutpaste") static function kore_register_copycutpaste(copy: Void->String, cut: Void->String, paste: String->Void): Void { }
	@:hlNative("std", "kore_system_change_resolution") static function kore_system_change_resolution(width: Int, height: Int): Void { }
	@:hlNative("std", "kore_system_set_keepscreenon") static function kore_system_set_keepscreenon(on: Bool): Void { }
	@:hlNative("std", "kore_system_load_url") static function kore_system_load_url(url: hl.Bytes): Void { }
	@:hlNative("std", "kore_get_gamepad_id") static function kore_get_gamepad_id(index: Int): hl.Bytes { return null; }
}

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
	static var framebuffer: Framebuffer;
	static var keyboard: Keyboard;
	static var mouse: kha.input.Mouse;
	static var pen: kha.input.Pen;
	static var gamepads: Array<Gamepad>;
	static var surface: Surface;
	static var mouseLockListeners: Array<Void->Void>;

	public static function init(options: SystemOptions, callback: Window->Void): Void {
		haxe.Log.trace = function(v: Dynamic, ?infos: haxe.PosInfos) {
			var message = infos != null ? infos.className + ":" + infos.lineNumber + ": " + v : Std.string(v);
			kinc_log(StringHelper.convert(message));
		};
		init_kore(StringHelper.convert(options.title), options.width, options.height, options.framebuffer.samplesPerPixel, options.framebuffer.verticalSync,
			cast options.window.mode, options.window.windowFeatures);

		new Window(0);
		Scheduler.init();
		Shaders.init();

		var g4 = new kha.korehl.graphics4.Graphics();
		framebuffer = new Framebuffer(0, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.korehl.graphics4.Graphics2(framebuffer), g4);
		final samplesRef: hl.Ref<Int> = kha.audio2.Audio.samplesPerSecond;
		kinc_init_audio(kha.audio2.Audio._callCallback, kha.audio2.Audio._readSample, samplesRef);
		kha.audio2.Audio.samplesPerSecond = samplesRef.get();
		kha.audio1.Audio._init();
		kha.audio2.Audio._init();
		keyboard = new kha.input.Keyboard();
		mouse = new kha.input.MouseImpl();
		pen = new kha.input.Pen();
		gamepads = new Array<Gamepad>();
		for (i in 0...8) {
			gamepads[i] = new kha.input.Gamepad(i);
			gamepads[i].connected = kinc_gamepad_connected(i);
		}
		surface = new kha.input.Surface();
		mouseLockListeners = new Array();
		kinc_register_keyboard(keyDown, keyUp, keyPress);
		kinc_register_mouse(mouseDown, mouseUp, mouseMove, mouseWheel);
		kinc_register_pen(penDown, penUp, penMove);
		kinc_register_gamepad(gamepadAxis, gamepadButton);
		kinc_register_surface(touchStart, touchEnd, touchMove);
		kinc_register_sensor(kha.input.Sensor._accelerometerChanged, kha.input.Sensor._gyroscopeChanged);
		kinc_register_callbacks(foreground, resume, pause, background, shutdown);
		kinc_register_dropfiles(dropFiles);
		kinc_register_copycutpaste(copy, cut, paste);

		Scheduler.start();
		callback(Window.get(0));

		run_kore();
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int->Void, callback: Void->Void): Void {}

	@:keep
	public static function frame(): Void {
		Scheduler.executeFrame();
		System.render([framebuffer]);

		for (i in 0...4) {
			if (gamepads[i].connected && !kinc_gamepad_connected(i)) {
				Gamepad.sendDisconnectEvent(i);
			}
			else if (!gamepads[i].connected && kinc_gamepad_connected(i)) {
				Gamepad.sendConnectEvent(i);
			}
		}
	}

	public static function getTime(): Float {
		return kinc_get_time();
	}

	public static function windowWidth(windowId: Int): Int {
		return kinc_get_window_width(windowId);
	}

	public static function windowHeight(windowId: Int): Int {
		return kinc_get_window_height(windowId);
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getSystemId(): String {
		final b: hl.Bytes = kinc_get_system_id();
		return @:privateAccess String.fromUTF8(b);
	}

	public static function vibrate(ms: Int): Void {
		kinc_vibrate(ms);
	}

	public static function getLanguage(): String {
		final b: hl.Bytes = kinc_get_language();
		return @:privateAccess String.fromUTF8(b);
	}

	public static function requestShutdown(): Bool {
		kinc_request_shutdown();
		return true;
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0)
			return null;
		return mouse;
	}

	public static function getPen(num: Int): Pen {
		if (num != 0)
			return null;
		return pen;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0)
			return null;
		return keyboard;
	}

	public static function lockMouse(windowId: Int = 0): Void {
		if (!isMouseLocked()) {
			kinc_mouse_lock(windowId);
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function unlockMouse(windowId: Int = 0): Void {
		if (isMouseLocked()) {
			kinc_mouse_unlock(windowId);
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function canLockMouse(windowId: Int = 0): Bool {
		return kinc_can_lock_mouse(windowId);
	}

	public static function isMouseLocked(windowId: Int = 0): Bool {
		return kinc_is_mouse_locked(windowId);
	}

	public static function notifyOfMouseLockChange(func: Void->Void, error: Void->Void): Void {
		if (canLockMouse(0) && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func: Void->Void, error: Void->Void): Void {
		if (canLockMouse(0) && func != null) {
			mouseLockListeners.remove(func);
		}
	}

	public static function hideSystemCursor(): Void {
		kinc_show_mouse(false);
	}

	public static function showSystemCursor(): Void {
		kinc_show_mouse(true);
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

	public static function gamepadAxis(gamepad: Int, axis: Int, value: FastFloat): Void {
		gamepads[gamepad].sendAxisEvent(axis, value);
	}

	public static function gamepadButton(gamepad: Int, button: Int, value: FastFloat): Void {
		gamepads[gamepad].sendButtonEvent(button, value);
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

	public static function copy(): hl.Bytes {
		if (System.copyListener != null) {
			final text = System.copyListener();
			if (text == null)
				return null;
			return StringHelper.convert(text);
		}
		else {
			return null;
		}
	}

	public static function cut(): hl.Bytes {
		if (System.cutListener != null) {
			final text = System.cutListener();
			if (text == null)
				return null;
			return StringHelper.convert(text);
		}
		else {
			return null;
		}
	}

	public static function paste(data: hl.Bytes): Void {
		final text = @:privateAccess String.fromUTF8(data);
		if (System.pasteListener != null) {
			System.pasteListener(text);
		}
	}

	static var fullscreenListeners: Array<Void->Void> = new Array();
	static var previousWidth: Int = 0;
	static var previousHeight: Int = 0;

	public static function canSwitchFullscreen(): Bool {
		return true;
	}

	public static function isFullscreen(): Bool {
		return kinc_system_is_fullscreen();
	}

	public static function requestFullscreen(): Void {
		if (!isFullscreen()) {
			previousWidth = kinc_get_window_width(0);
			previousHeight = kinc_get_window_height(0);
			kinc_system_request_fullscreen();
			for (listener in fullscreenListeners) {
				listener();
			}
		}
	}

	public static function exitFullscreen(): Void {
		if (isFullscreen()) {
			if (previousWidth == 0 || previousHeight == 0) {
				previousWidth = kinc_get_window_width(0);
				previousHeight = kinc_get_window_height(0);
			}
			kinc_system_exit_fullscreen(previousWidth, previousHeight);
			for (listener in fullscreenListeners) {
				listener();
			}
		}
	}

	public static function notifyOfFullscreenChange(func: Void->Void, error: Void->Void): Void {
		if (canSwitchFullscreen() && func != null) {
			fullscreenListeners.push(func);
		}
	}

	public static function removeFromFullscreenChange(func: Void->Void, error: Void->Void): Void {
		if (canSwitchFullscreen() && func != null) {
			fullscreenListeners.remove(func);
		}
	}

	public static function changeResolution(width: Int, height: Int): Void {
		kinc_system_change_resolution(width, height);
	}

	public static function setKeepScreenOn(on: Bool): Void {
		kinc_system_set_keepscreenon(on);
	}

	public static function loadUrl(url: String): Void {
		kinc_system_load_url(StringHelper.convert(url));
	}

	public static function getGamepadId(index: Int): String {
		final b: hl.Bytes = kinc_get_gamepad_id(index);
		return @:privateAccess String.fromUTF8(b);
	}

	public static function getGamepadVendor(index: Int): String {
		final b: hl.Bytes = kinc_get_gamepad_vendor(index);
		return @:privateAccess String.fromUTF8(b);
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

	@:hlNative("std", "init_kore") static function init_kore(title: hl.Bytes, width: Int, height: Int, samplesPerPixel: Int, vSync: Bool, windowMode: Int,
		windowFeatures: Int): Void {}

	@:hlNative("std", "run_kore") static function run_kore(): Void {}

	@:hlNative("std", "kinc_init_audio") static function kinc_init_audio(callCallback: Int->Void, readSample: Void->FastFloat,
		outSamplesPerSecond: hl.Ref<Int>): Void {}

	@:hlNative("std", "kinc_log") static function kinc_log(v: hl.Bytes): Void {}

	@:hlNative("std", "kinc_get_time") static function kinc_get_time(): Float {
		return 0;
	}

	@:hlNative("std", "kinc_get_window_width") static function kinc_get_window_width(window: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_get_window_height") static function kinc_get_window_height(window: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_get_system_id") static function kinc_get_system_id(): hl.Bytes {
		return null;
	}

	@:hlNative("std", "kinc_vibrate") static function kinc_vibrate(ms: Int): Void {}

	@:hlNative("std", "kinc_get_language") static function kinc_get_language(): hl.Bytes {
		return null;
	}

	@:hlNative("std", "kinc_request_shutdown") static function kinc_request_shutdown(): Void {}

	@:hlNative("std", "kinc_mouse_lock") static function kinc_mouse_lock(windowId: Int): Void {}

	@:hlNative("std", "kinc_mouse_unlock") static function kinc_mouse_unlock(windowId: Int): Void {}

	@:hlNative("std", "kinc_can_lock_mouse") static function kinc_can_lock_mouse(windowId: Int): Bool {
		return false;
	}

	@:hlNative("std", "kinc_is_mouse_locked") static function kinc_is_mouse_locked(windowId: Int): Bool {
		return false;
	}

	@:hlNative("std", "kinc_show_mouse") static function kinc_show_mouse(show: Bool): Void {}

	@:hlNative("std", "kinc_system_is_fullscreen") static function kinc_system_is_fullscreen(): Bool {
		return false;
	}

	@:hlNative("std", "kinc_system_request_fullscreen") static function kinc_system_request_fullscreen(): Void {}

	@:hlNative("std", "kinc_system_exit_fullscreen") static function kinc_system_exit_fullscreen(previousWidth: Int, previousHeight: Int): Void {}

	@:hlNative("std", "kinc_register_keyboard") static function kinc_register_keyboard(keyDown: KeyCode->Void, keyUp: KeyCode->Void,
		keyPress: Int->Void): Void {}

	@:hlNative("std", "kinc_register_mouse") static function kinc_register_mouse(mouseDown: Int->Int->Int->Int->Void, mouseUp: Int->Int->Int->Int->Void,
		mouseMove: Int->Int->Int->Int->Int->Void, mouseWheel: Int->Int->Void): Void {}

	@:hlNative("std", "kinc_register_pen") static function kinc_register_pen(penDown: Int->Int->Int->Float->Void, penUp: Int->Int->Int->Float->Void,
		penMove: Int->Int->Int->Float->Void): Void {}

	@:hlNative("std", "kinc_register_gamepad") static function kinc_register_gamepad(gamepadAxis: Int->Int->FastFloat->Void,
		gamepadButton: Int->Int->FastFloat->Void): Void {}

	@:hlNative("std", "kinc_register_surface") static function kinc_register_surface(touchStart: Int->Int->Int->Void, touchEnd: Int->Int->Int->Void,
		touchMove: Int->Int->Int->Void): Void {}

	@:hlNative("std", "kinc_register_sensor") static function kinc_register_sensor(accelerometerChanged: Float->Float->Float->Void,
		gyroscopeChanged: Float->Float->Float->Void): Void {}

	@:hlNative("std", "kinc_register_callbacks") static function kinc_register_callbacks(foreground: Void->Void, resume: Void->Void, pause: Void->Void,
		background: Void->Void, shutdown: Void->Void): Void {}

	@:hlNative("std", "kinc_register_dropfiles") static function kinc_register_dropfiles(dropFiles: String->Void): Void {}

	@:hlNative("std", "kinc_register_copycutpaste") static function kinc_register_copycutpaste(copy: Void->hl.Bytes, cut: Void->hl.Bytes,
		paste: hl.Bytes->Void): Void {}

	@:hlNative("std", "kinc_system_change_resolution") static function kinc_system_change_resolution(width: Int, height: Int): Void {}

	@:hlNative("std", "kinc_system_set_keepscreenon") static function kinc_system_set_keepscreenon(on: Bool): Void {}

	@:hlNative("std", "kinc_system_load_url") static function kinc_system_load_url(url: hl.Bytes): Void {}

	@:hlNative("std", "kinc_get_gamepad_id") static function kinc_get_gamepad_id(index: Int): hl.Bytes {
		return null;
	}

	@:hlNative("std", "kinc_get_gamepad_vendor") static function kinc_get_gamepad_vendor(index: Int): hl.Bytes {
		return null;
	}

	@:hlNative("std", "kinc_gamepad_connected") static function kinc_gamepad_connected(index: Int): Bool {
		return false;
	}
}

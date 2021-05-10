package kha;

import kha.input.Gamepad;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Pen;
import kha.input.Sensor;
import kha.input.SensorType;
import kha.input.Surface;
import kha.System;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
#if ANDROID
#if VR_CARDBOARD
import kha.kore.vr.CardboardVrInterface;
#end
#if !VR_CARDBOARD
import kha.kore.vr.VrInterface;
#end
#end
#if !ANDROID
#if VR_RIFT
import kha.kore.vr.VrInterfaceRift;
#end
#if !VR_RIFT
import kha.vr.VrInterfaceEmulated;
#end
#end
@:headerCode("
#include <kinc/system.h>
#include <kinc/input/gamepad.h>
#include <kinc/input/mouse.h>
#include <kinc/input/pen.h>
#include <kinc/display.h>
#include <kinc/window.h>

kinc_window_options_t convertWindowOptions(::kha::WindowOptions win);
kinc_framebuffer_options_t convertFramebufferOptions(::kha::FramebufferOptions frame);

void init_kinc(const char *name, int width, int height, kinc_window_options_t *win, kinc_framebuffer_options_t *frame);
void post_kinc_init();
void run_kinc();
const char *getGamepadId(int index);
const char *getGamepadVendor(int index);
void setGamepadRumble(int index, float left, float right);
")
@:keep
class SystemImpl {
	public static var needs3d: Bool = false;

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

	@:functionCode("return kinc_time();")
	public static function getTime(): Float {
		return 0;
	}

	public static function windowWidth(windowId: Int): Int {
		return untyped __cpp__("kinc_window_width(windowId)");
	}

	public static function windowHeight(windowId: Int): Int {
		return untyped __cpp__("kinc_window_height(windowId)");
	}

	public static function screenDpi(): Int {
		return untyped __cpp__("kinc_display_current_mode(kinc_primary_display()).pixels_per_inch");
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	@:functionCode("return ::String(kinc_system_id());")
	public static function getSystemId(): String {
		return "";
	}

	public static function vibrate(ms: Int): Void {
		untyped __cpp__("kinc_vibrate(ms)");
	}

	@:functionCode("return ::String(kinc_language());")
	public static function getLanguage(): String {
		return "en";
	}

	public static function requestShutdown(): Bool {
		untyped __cpp__("kinc_stop()");
		return true;
	}

	static var framebuffers: Array<Framebuffer> = new Array();
	static var keyboard: Keyboard;
	static var mouse: kha.input.Mouse;
	static var pen: kha.input.Pen;
	static var gamepads: Array<Gamepad>;
	static var surface: Surface;
	static var mouseLockListeners: Array<Void->Void>;

	public static function init(options: SystemOptions, callback: Window->Void): Void {
		initKinc(options.title, options.width, options.height, options.window, options.framebuffer);
		Window._init();

		kha.Worker._mainThread = sys.thread.Thread.current();

		untyped __cpp__("post_kinc_init()");

		Shaders.init();

		#if (!VR_GEAR_VR && !VR_RIFT)
		var g4 = new kha.kore.graphics4.Graphics();
		g4.window = 0;
		// var g5 = new kha.kore.graphics5.Graphics();
		var framebuffer = new Framebuffer(0, null, null, g4 /*, g5*/);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4 /*, g5*/);
		framebuffers.push(framebuffer);
		#end

		postInit(callback);
	}

	static function onWindowCreated(index: Int) {
		var g4 = new kha.kore.graphics4.Graphics();
		g4.window = index;
		var framebuffer = new Framebuffer(index, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4);
		framebuffers.push(framebuffer);
	}

	static function postInit(callback: Window->Void) {
		mouseLockListeners = new Array();
		haxe.Timer.stamp();
		Sensor.get(SensorType.Accelerometer); // force compilation
		keyboard = new kha.kore.Keyboard();
		mouse = new kha.input.MouseImpl();
		pen = new kha.input.Pen();
		gamepads = new Array<Gamepad>();
		for (i in 0...4) {
			gamepads[i] = new Gamepad(i);
			gamepads[i].connected = checkGamepadConnected(i);
		}
		surface = new Surface();
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		Scheduler.init();
		loadFinished();
		callback(Window.get(0));

		untyped __cpp__("run_kinc()");
	}

	static function loadFinished() {
		Scheduler.start();

		/*
			#if ANDROID
				#if VR_GEAR_VR
					kha.vr.VrInterface.instance = new kha.kore.vr.VrInterface();
				#end
				#if !VR_GEAR_VR
					kha.vr.VrInterface.instance = new CardboardVrInterface();
				#end
			#end
			#if !ANDROID
				#if VR_RIFT
					kha.vr.VrInterface.instance = new VrInterfaceRift();
				#end
				#if !VR_RIFT
					kha.vr.VrInterface.instance = new kha.vr.VrInterfaceEmulated();
				#end
			#end
		 */

		// (DK) moved
		/*Shaders.init();

			#if (!VR_GEAR_VR && !VR_RIFT)
			var g4 = new kha.kore.graphics4.Graphics();
			framebuffers.push(new Framebuffer(null, null, g4));
			framebuffers[0].init(new kha.graphics2.Graphics1(framebuffers[0]), new kha.kore.graphics4.Graphics2(framebuffers[0]), g4);

			g4 = new kha.kore.graphics4.Graphics();
			framebuffers.push(new Framebuffer(null, null, g4));
			framebuffers[1].init(new kha.graphics2.Graphics1(framebuffers[1]), new kha.kore.graphics4.Graphics2(framebuffers[1]), g4);
			#end
		 */}

	public static function lockMouse(windowId: Int = 0): Void {
		if (!isMouseLocked()) {
			untyped __cpp__("kinc_mouse_lock(windowId);");
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function unlockMouse(windowId: Int = 0): Void {
		if (isMouseLocked()) {
			untyped __cpp__("kinc_mouse_unlock(windowId);");
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function canLockMouse(windowId: Int = 0): Bool {
		return untyped __cpp__("kinc_mouse_can_lock(windowId)");
	}

	public static function isMouseLocked(windowId: Int = 0): Bool {
		return untyped __cpp__("kinc_mouse_is_locked(windowId)");
	}

	public static function notifyOfMouseLockChange(func: Void->Void, error: Void->Void, windowId: Int = 0): Void {
		if (canLockMouse(windowId) && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func: Void->Void, error: Void->Void, windowId: Int = 0): Void {
		if (canLockMouse(windowId) && func != null) {
			mouseLockListeners.remove(func);
		}
	}

	public static function hideSystemCursor(): Void {
		untyped __cpp__("kinc_mouse_hide();");
	}

	public static function showSystemCursor(): Void {
		untyped __cpp__("kinc_mouse_show();");
	}

	public static function setSystemCursor(cursor: Int): Void {
		untyped __cpp__("kinc_mouse_set_cursor(cursor)");
	}

	public static function frame() {
		/*
			#if !ANDROID
			#if !VR_RIFT
				if (framebuffer == null) return;
				var vrInterface: VrInterfaceEmulated = cast(VrInterface.instance, VrInterfaceEmulated);
				vrInterface.framebuffer = framebuffer;
			#end
			#else
				#if VR_CARDBOARD
					var vrInterface: CardboardVrInterface = cast(VrInterface.instance, CardboardVrInterface);
					vrInterface.framebuffer = framebuffer;
				#end
			#end
		 */

		LoaderImpl.tick();
		Scheduler.executeFrame();
		System.render(framebuffers);
		if (kha.kore.graphics4.Graphics.lastWindow != -1) {
			var win = kha.kore.graphics4.Graphics.lastWindow;
			untyped __cpp__("kinc_g4_end({0})", win);
		}
		else {
			untyped __cpp__("kinc_g4_begin(0)");
			untyped __cpp__("kinc_g4_clear(KINC_G4_CLEAR_COLOR | KINC_G4_CLEAR_DEPTH | KINC_G4_CLEAR_STENCIL, 0, 0.0f, 0)");
			untyped __cpp__("kinc_g4_end(0)");
		}
		kha.kore.graphics4.Graphics.lastWindow = -1;

		for (i in 0...4) {
			if (gamepads[i].connected && !checkGamepadConnected(i)) {
				Gamepad.sendDisconnectEvent(i);
			}
			else if (!gamepads[i].connected && checkGamepadConnected(i)) {
				Gamepad.sendConnectEvent(i);
			}
		}
	}

	@:functionCode("return kinc_gamepad_connected(i);")
	static function checkGamepadConnected(i: Int): Bool {
		return true;
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

	public static var mouseX: Int;
	public static var mouseY: Int;

	public static function mouseDown(windowId: Int, button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendDownEvent(windowId, button, x, y);
	}

	public static function mouseUp(windowId: Int, button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendUpEvent(windowId, button, x, y);
	}

	public static function mouseMove(windowId: Int, x: Int, y: Int, movementX: Int, movementY: Int): Void {
		// var movementX = x - mouseX;
		// var movementY = y - mouseY;
		mouseX = x;
		mouseY = y;
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

	public static function gamepadAxis(gamepad: Int, axis: Int, value: Float): Void {
		gamepads[gamepad].sendAxisEvent(axis, value);
	}

	public static function gamepadButton(gamepad: Int, button: Int, value: Float): Void {
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

	@:functionCode("kinc_copy_to_clipboard(text.c_str());")
	public static function copyToClipboard(text: String) {}

	@:functionCode("kinc_login();")
	public static function login(): Void {}

	@:functionCode("return kinc_waiting_for_login();")
	public static function waitingForLogin(): Bool {
		return false;
	}

	@:functionCode("kinc_disallow_user_change();")
	public static function disallowUserChange(): Void {}

	@:functionCode("kinc_allow_user_change();")
	public static function allowUserChange(): Void {}

	public static function loginevent(): Void {
		if (System.loginListener != null) {
			System.loginListener();
		}
	}

	public static function logoutevent(): Void {
		if (System.logoutListener != null) {
			System.logoutListener();
		}
	}

	@:functionCode("
		kinc_window_options_t window = convertWindowOptions(win);
		kinc_framebuffer_options_t framebuffer = convertFramebufferOptions(frame);
		init_kinc(name, width, height, &window, &framebuffer);
	")
	static function initKinc(name: String, width: Int, height: Int, win: WindowOptions, frame: FramebufferOptions): Void {}

	public static function setKeepScreenOn(on: Bool): Void {
		untyped __cpp__("kinc_set_keep_screen_on(on)");
	}

	public static function loadUrl(url: String): Void {
		untyped __cpp__("kinc_load_url(url)");
	}

	@:functionCode("return ::String(::getGamepadId(index));")
	public static function getGamepadId(index: Int): String {
		return "unknown";
	}

	@:functionCode("return ::String(::getGamepadVendor(index));")
	public static function getGamepadVendor(index: Int): String {
		return "unknown";
	}

	public static function setGamepadRumble(index: Int, leftAmount: Float, rightAmount: Float): Void {
		untyped __cpp__("::setGamepadRumble(index, leftAmount, rightAmount)");
	}

	public static function safeZone(): Float {
		return untyped __cpp__("kinc_safe_zone()");
	}

	public static function automaticSafeZone(): Bool {
		return untyped __cpp__("kinc_automatic_safe_zone()");
	}

	public static function setSafeZone(value: Float): Void {
		untyped __cpp__("kinc_set_safe_zone(value)");
	}

	public static function unlockAchievement(id: Int): Void {
		untyped __cpp__("kinc_unlock_achievement(id)");
	}
}

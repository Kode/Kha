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

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Input/Pen.h>
#include <Kore/Display.h>
#include <Kore/Window.h>

Kore::WindowOptions convertWindowOptions(::kha::WindowOptions win);
Kore::FramebufferOptions convertFramebufferOptions(::kha::FramebufferOptions frame);

void init_kore(const char* name, int width, int height, Kore::WindowOptions* win, Kore::FramebufferOptions* frame);
void post_kore_init();
void run_kore();
const char* getGamepadId(int index);
')
@:keep
class SystemImpl {
	public static var needs3d: Bool = false;

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

	@:functionCode('
		return Kore::System::time();
	')
	public static function getTime(): Float {
		return 0;
	}

	public static function windowWidth(windowId: Int): Int {
		return untyped __cpp__('Kore::System::windowWidth(windowId)');
	}

	public static function windowHeight(windowId: Int): Int {
		return untyped __cpp__('Kore::System::windowHeight(windowId)');
	}

	public static function screenDpi(): Int {
		return untyped __cpp__('Kore::Display::primary()->pixelsPerInch()');
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

	@:functionCode('return ::String(Kore::System::systemId());')
	public static function getSystemId(): String {
		return '';
	}

	public static function vibrate(ms:Int): Void {
		untyped __cpp__("Kore::System::vibrate(ms)");
	}

	@:functionCode('return ::String(Kore::System::language());')
	public static function getLanguage(): String {
		return "en";
	}

	public static function requestShutdown(): Bool {
		untyped __cpp__('Kore::System::stop()');
		return true;
	}

	private static var framebuffers: Array<Framebuffer> = new Array();
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
		initKore(options.title, options.width, options.height, options.window, options.framebuffer);
		Window._init();

		kha.Worker._mainThread = sys.thread.Thread.current();

		untyped __cpp__('post_kore_init()');

		Shaders.init();

#if (!VR_GEAR_VR && !VR_RIFT)
		var g4 = new kha.kore.graphics4.Graphics();
		g4.window = 0;
		//var g5 = new kha.kore.graphics5.Graphics();
		var framebuffer = new Framebuffer(0, null, null, g4 /*, g5*/);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4/*, g5*/);
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

	static function postInit(callback: Window -> Void) {
		mouseLockListeners = new Array();
		haxe.Timer.stamp();
		Sensor.get(SensorType.Accelerometer); // force compilation
		keyboard = new kha.kore.Keyboard();
		mouse = new kha.input.MouseImpl();
		pen = new kha.input.Pen();
		gamepad1 = new Gamepad(0);
		gamepad2 = new Gamepad(1);
		gamepad3 = new Gamepad(2);
		gamepad4 = new Gamepad(3);
		surface = new Surface();
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		Scheduler.init();
		loadFinished();
		callback(Window.get(0));

		untyped __cpp__('run_kore()');
	}

	private static function loadFinished() {
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
/*		Shaders.init();

		#if (!VR_GEAR_VR && !VR_RIFT)
		var g4 = new kha.kore.graphics4.Graphics();
		framebuffers.push(new Framebuffer(null, null, g4));
		framebuffers[0].init(new kha.graphics2.Graphics1(framebuffers[0]), new kha.kore.graphics4.Graphics2(framebuffers[0]), g4);

		g4 = new kha.kore.graphics4.Graphics();
		framebuffers.push(new Framebuffer(null, null, g4));
		framebuffers[1].init(new kha.graphics2.Graphics1(framebuffers[1]), new kha.kore.graphics4.Graphics2(framebuffers[1]), g4);
		#end
*/	}

	public static function lockMouse(windowId: Int = 0): Void {
		if(!isMouseLocked()){
			untyped __cpp__("Kore::Mouse::the()->lock(windowId);");
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function unlockMouse(windowId: Int = 0): Void {
		if(isMouseLocked()){
			untyped __cpp__("Kore::Mouse::the()->unlock(windowId);");
			for (listener in mouseLockListeners) {
				listener();
			}
		}
	}

	public static function canLockMouse(windowId: Int = 0): Bool {
		return untyped __cpp__('Kore::Mouse::the()->canLock(windowId)');
	}

	public static function isMouseLocked(windowId: Int = 0): Bool {
		return untyped __cpp__('Kore::Mouse::the()->isLocked(windowId)');
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void, windowId: Int = 0): Void {
		if (canLockMouse(windowId) && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void, windowId: Int = 0): Void {
		if (canLockMouse(windowId) && func != null) {
			mouseLockListeners.remove(func);
		}
	}

	public static function hideSystemCursor(): Void {
		untyped __cpp__("Kore::Mouse::the()->show(false);");
	}

	public static function showSystemCursor(): Void {
		untyped __cpp__("Kore::Mouse::the()->show(true);");
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
			untyped __cpp__('Kore::Graphics4::end(win);');
		}
		kha.kore.graphics4.Graphics.lastWindow = -1;
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

	@:functionCode('
		Kore::WindowOptions window = convertWindowOptions(win);
		Kore::FramebufferOptions framebuffer = convertFramebufferOptions(frame);
		init_kore(name, width, height, &window, &framebuffer);
	')
	private static function initKore(name: String, width: Int, height: Int, win: WindowOptions, frame: FramebufferOptions): Void {

	}

	public static function setKeepScreenOn(on: Bool): Void {
		untyped __cpp__("Kore::System::setKeepScreenOn(on)");
	}

	public static function loadUrl(url: String): Void {
		untyped __cpp__("Kore::System::loadURL(url)");
	}

	@:functionCode('return ::String(::getGamepadId(index));')
	public static function getGamepadId(index: Int): String {
		return "unknown";
	}

	public static function safeZone(): Float {
		return untyped __cpp__('Kore::System::safeZone()');
	}
}

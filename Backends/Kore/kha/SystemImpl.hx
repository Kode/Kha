package kha;

import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
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
#include <Kore/Window.h>

void init_kore(const char* name, int width, int height, int antialiasing);
void init_kore_ex(const char* name);
void post_kore_init();
void run_kore();
int init_window(Kore::WindowOptions windowOptions);
')

class SystemImpl {
	public static var needs3d: Bool = false;

	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
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

	public static function requestShutdown() {
		untyped __cpp__('Kore::System::stop()');
	}

	private static var framebuffers: Array<Framebuffer> = new Array();
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad1: Gamepad;
	private static var gamepad2: Gamepad;
	private static var gamepad3: Gamepad;
	private static var gamepad4: Gamepad;
	private static var surface: Surface;
	private static var mouseLockListeners: Array<Int->Void>;

	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		initKore(options.title, options.width, options.height, options.samplesPerPixel);

		//Shaders.init();

		untyped __cpp__('post_kore_init()');

		Shaders.init();

#if (!VR_GEAR_VR && !VR_RIFT)
		var g4 = new kha.kore.graphics4.Graphics();
		var framebuffer = new Framebuffer(0, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4);
		framebuffers.push(framebuffer);
#end

		postInit(callback);
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void) {
		untyped __cpp__('init_kore_ex(title)');

		//Shaders.init();
		var windowIds: Array<Int> = [];

		Lambda.iter(options, initWindow.bind(_, function(windowId: Int) {
			windowIds.push(windowId);
			windowCallback(windowId);
		}));

		Shaders.init();

#if (!VR_GEAR_VR && !VR_RIFT)
		for (index in 0 ... windowIds.length) {
			var windowId = windowIds[index];
			var g4 = new kha.kore.graphics4.Graphics();
			var framebuffer = new Framebuffer(index, null, null, g4);
			framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4);
			framebuffers[windowId] = framebuffer;
		}
#end

		untyped __cpp__('post_kore_init()');

		postInit(callback);
	}

	static function postInit(callback: Void -> Void) {
		mouseLockListeners = new Array();
		haxe.Timer.stamp();
		Sensor.get(SensorType.Accelerometer); // force compilation
		keyboard = new kha.kore.Keyboard();
		mouse = new kha.input.Mouse();
		gamepad1 = new Gamepad(0);
		gamepad2 = new Gamepad(1);
		gamepad3 = new Gamepad(2);
		gamepad4 = new Gamepad(3);
		surface = new Surface();
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		Scheduler.init();
		loadFinished();
		callback();

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
				listener(windowId);
			}
		}
	}

	public static function unlockMouse(windowId: Int = 0): Void {
		if(isMouseLocked()){
			untyped __cpp__("Kore::Mouse::the()->unlock(windowId);");
			for (listener in mouseLockListeners) {
				listener(windowId);
			}
		}
	}

	public static function canLockMouse(windowId: Int = 0): Bool {
		return untyped __cpp__('Kore::Mouse::the()->canLock(windowId)');
	}

	public static function isMouseLocked(windowId: Int = 0): Bool {
		return untyped __cpp__('Kore::Mouse::the()->isLocked(windowId)');
	}

	public static function notifyOfMouseLockChange(func: Int -> Void, error: Int -> Void, windowId: Int = 0): Void {
		if (canLockMouse(windowId) && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func: Int -> Void, error: Void -> Void, windowId: Int = 0): Void {
		if (canLockMouse(windowId) && func != null) {
			mouseLockListeners.remove(func);
		}
	}

	public static function frame(id: Int) {
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

		if (id == 0) {
			Scheduler.executeFrame();
		}

		System.render(id, framebuffers[id]);
	}

	public static function pushUp(): Void {
		keyboard.sendDownEvent(Key.UP, null);
	}

	public static function pushDown(): Void {
		keyboard.sendDownEvent(Key.DOWN, null);
	}

	public static function pushLeft(): Void {
		keyboard.sendDownEvent(Key.LEFT, null);
	}

	public static function pushRight(): Void {
		keyboard.sendDownEvent(Key.RIGHT, null);
	}

	public static function releaseUp(): Void {
		keyboard.sendUpEvent(Key.UP, null);
	}

	public static function releaseDown(): Void {
		keyboard.sendUpEvent(Key.DOWN, null);
	}

	public static function releaseLeft(): Void {
		keyboard.sendUpEvent(Key.LEFT, null);
	}

	public static function releaseRight(): Void {
		keyboard.sendUpEvent(Key.RIGHT, null);
	}

	public static function pushChar(charCode: Int): Void {
		keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(charCode));
	}

	public static function releaseChar(charCode: Int): Void {
		keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(charCode));
	}

	public static function pushShift(): Void {
		keyboard.sendDownEvent(Key.SHIFT, null);
	}

	public static function releaseShift(): Void {
		keyboard.sendUpEvent(Key.SHIFT, null);
	}

	public static function pushBackspace(): Void {
		keyboard.sendDownEvent(Key.BACKSPACE, null);
	}

	public static function releaseBackspace(): Void {
		keyboard.sendUpEvent(Key.BACKSPACE, null);
	}

	public static function pushTab(): Void {
		keyboard.sendDownEvent(Key.TAB, null);
	}

	public static function releaseTab(): Void {
		keyboard.sendUpEvent(Key.TAB, null);
	}

	public static function pushEnter(): Void {
		keyboard.sendDownEvent(Key.ENTER, null);
	}

	public static function releaseEnter(): Void {
		keyboard.sendUpEvent(Key.ENTER, null);
	}

	public static function pushControl(): Void {
		keyboard.sendDownEvent(Key.CTRL, null);
	}

	public static function releaseControl(): Void {
		keyboard.sendUpEvent(Key.CTRL, null);
	}

	public static function pushAlt(): Void {
		keyboard.sendDownEvent(Key.ALT, null);
	}

	public static function releaseAlt(): Void {
		keyboard.sendUpEvent(Key.ALT, null);
	}

	public static function pushEscape(): Void {
		keyboard.sendDownEvent(Key.ESC, null);
	}

	public static function releaseEscape(): Void {
		keyboard.sendUpEvent(Key.ESC, null);
	}

	public static function pushDelete(): Void {
		keyboard.sendDownEvent(Key.DEL, null);
	}

	public static function releaseDelete(): Void {
		keyboard.sendUpEvent(Key.DEL, null);
	}

	public static function pushBack(): Void {
		keyboard.sendDownEvent(Key.BACK, null);
	}

	public static function releaseBack(): Void {
		keyboard.sendUpEvent(Key.BACK, null);
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

	@:functionCode('init_kore(name, width, height, antialiasing);')
	private static function initKore(name: String, width: Int, height: Int, antialiasing: Int): Void {
	}

	static function translatePosition(value: Null<WindowOptions.Position>): Int {
		if (value == null) {
			return -1;
		}

		return switch (value) {
			case Center: -1;
			case Fixed(v): v;
		}
	}

	static function translateDisplay(value: Null<WindowOptions.TargetDisplay>): Int {
		if (value == null) {
			return -1;
		}

		return switch (value) {
			case Primary: -1;
			case ById(id): id;
		}
	}

	static function translateWindowMode(value: Null<WindowOptions.Mode>): Int {
		if (value == null) {
			return 0;
		}

		return switch (value) {
			case Window: 0;
			case BorderlessWindow: 1;
			case Fullscreen: 2;
		}
	}

	static function translateDepthBufferFormat(value: Null<DepthStencilFormat>): Int {
		if (value == null) {
			return 16;
		}

		return switch (value) {
			case NoDepthAndStencil: -1;
			case DepthOnly: 16;
			case DepthAutoStencilAuto: 16;
			case Depth24Stencil8: 24;
			case Depth32Stencil8: 32;
		}
	}

	static function translateStencilBufferFormat(value: Null<DepthStencilFormat>): Int {
		if (value == null) {
			return -1;
		}

		return switch (value) {
			case NoDepthAndStencil: -1;
			case DepthOnly: -1;
			case DepthAutoStencilAuto: 8;
			case Depth24Stencil8: 8;
			case Depth32Stencil8: 8;
		}
	}

	static function translateTextureFormat(value: Null<TextureFormat>): Int {
		if (value == null) {
			return 0;
		}

		return switch(value) {
			case RGBA32: 0;
			case L8: 1;
			case RGBA128: 2;
			case DEPTH16: 3;
			case RGBA64: 4;
			case A32: 5;
			case A16: 6;
		}
	}

	private static function initWindow(options: WindowOptions, callback: Int -> Void) {
		// TODO (DK) find a better way to call the cpp code
		var x = translatePosition(options.x);
		var y = translatePosition(options.y);
		var mode = translateWindowMode(options.mode != null ? options.mode : WindowOptions.Mode.Window);
		var targetDisplay = translateDisplay(options.targetDisplay != null ? options.targetDisplay : WindowOptions.TargetDisplay.Primary);
		var depthBufferBits = translateDepthBufferFormat(options.rendererOptions != null ? options.rendererOptions.depthStencilFormat : DepthStencilFormat.DepthOnly);
		var stencilBufferBits = translateStencilBufferFormat(options.rendererOptions != null ? options.rendererOptions.depthStencilFormat : DepthStencilFormat.DepthOnly);
		var textureFormat = translateTextureFormat(options.rendererOptions != null ? options.rendererOptions.textureFormat : TextureFormat.RGBA32);
		var windowId: Int = -1;
		var title = options.title;
		var width = options.width;
		var height = options.height;
		var resizable = options.windowedModeOptions != null ? options.windowedModeOptions.resizable : false;
		var maximizable = options.windowedModeOptions != null ? options.windowedModeOptions.maximizable : false;
		var minimizable = options.windowedModeOptions != null ? options.windowedModeOptions.minimizable : true;

		untyped __cpp__('
			Kore::WindowOptions wo;
			wo.title = title;
			wo.x = x;
			wo.y = y;
			wo.width = width;
			wo.height = height;
			//wo.mode = mode;
			wo.targetDisplay = targetDisplay;
			wo.rendererOptions.textureFormat = textureFormat;
			wo.rendererOptions.depthBufferBits = depthBufferBits;
			wo.rendererOptions.stencilBufferBits = stencilBufferBits;

			wo.resizable = resizable;
			wo.maximizable = maximizable;
			wo.minimizable = minimizable;

			switch (mode) {
				default: // fall through
				case 0: wo.mode = Kore::WindowModeWindow; break;
				case 1: wo.mode = Kore::WindowModeBorderless; break;
				case 2: wo.mode = Kore::WindowModeFullscreen; break;
			}

			windowId = init_window(wo);
		');

//#if (!VR_GEAR_VR && !VR_RIFT)
		//var g4 = new kha.kore.graphics4.Graphics();
		//var framebuffer = new Framebuffer(width, height, null, null, g4);
		//framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4);
		//framebuffers[windowId] = framebuffer;
//#end

		if (callback != null) {
			callback(windowId);
		}
	}

	private static var fullscreenListeners: Array<Void->Void> = new Array();
	private static var previousWidth: Int = 0;
	private static var previousHeight: Int = 0;

	public static function canSwitchFullscreen(): Bool {
		return true;
	}

	public static function isFullscreen(): Bool {
		return untyped __cpp__('Kore::System::isFullscreen()');
	}

	public static function requestFullscreen(): Void {
		if(!isFullscreen()){
			previousWidth = untyped __cpp__("Kore::System::windowWidth(0)");
			previousHeight = untyped __cpp__("Kore::System::windowHeight(0)");
			untyped __cpp__("Kore::System::changeResolution(Kore::System::desktopWidth(), Kore::System::desktopHeight(), true)");
			for (listener in fullscreenListeners) {
				listener();
			}
		}

	}

	public static function exitFullscreen(): Void {
		if (isFullscreen()) {
			if (previousWidth == 0 || previousHeight == 0){
				previousWidth = untyped __cpp__("Kore::System::windowWidth(0)");
				previousHeight = untyped __cpp__("Kore::System::windowHeight(0)");
			}
			untyped __cpp__("Kore::System::changeResolution(previousWidth, previousHeight, false)");
			for (listener in fullscreenListeners) {
				listener();
			}
		}
  	}

	public function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		if (canSwitchFullscreen() && func != null) {
			fullscreenListeners.push(func);
		}
	}


	public function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		if (canSwitchFullscreen() && func != null) {
			fullscreenListeners.remove(func);
		}
	}

	public static function changeResolution(width: Int, height: Int): Void {

	}

	public static function setKeepScreenOn(on: Bool): Void {
		untyped __cpp__("Kore::System::setKeepScreenOn(on)");
	}
}

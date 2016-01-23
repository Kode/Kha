package kha;

import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Sensor;
import kha.input.SensorType;
import kha.input.Surface;

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
#include <Kore/Application.h>
#include <Kore/System.h>
#include <Kore/Input/Mouse.h>

void init_kore(const char* name, int width, int height);
void run_kore();
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
	
	@:functionCode('return Kore::System::screenWidth();')
	public static function getPixelWidth(): Int {
		return 0;
	}
	
	@:functionCode('return Kore::System::screenHeight();')
	public static function getPixelHeight(): Int {
		return 0;
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
	
	@:functionCode('Kore::Application::the()->stop();')
	public static function requestShutdown(): Void {
		
	}
	
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	private static var surface: Surface;
	private static var mouseLockListeners: Array<Void->Void>;
	
	//public function new(?backbufferFormat: TextureFormat) {
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void): Void {
		initKore(title, width, height);
		mouseLockListeners = new Array();
		haxe.Timer.stamp();
		Sensor.get(SensorType.Accelerometer); // force compilation
		keyboard = new kha.kore.Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();
		surface = new Surface();
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		Scheduler.init();
		loadFinished();
		callback();
		runKore();
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

		Shaders.init();
		#if (!VR_GEAR_VR && !VR_RIFT)
		var g4 = new kha.kore.graphics4.Graphics();
		framebuffer = new Framebuffer(null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4);
		#end
	}

	public static function lockMouse(): Void {
		if(!isMouseLocked()){
			untyped __cpp__("Kore::Mouse::the()->lock();");
			for (listener in mouseLockListeners) {
				listener();
			}	
		}
	}
	
	public static function unlockMouse(): Void {
		if(isMouseLocked()){
			untyped __cpp__("Kore::Mouse::the()->unlock();");	
			for (listener in mouseLockListeners) {
				listener();
			}	
		}
	}

	@:functionCode('return Kore::Mouse::the()->canLock();')
	public static function canLockMouse(): Bool {
		return false;
	}

	@:functionCode('return Kore::Mouse::the()->isLocked();')
	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		if (canLockMouse() && func != null) {
			mouseLockListeners.push(func);
		}
	}

	public static function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		if (canLockMouse() && func != null) {
			mouseLockListeners.remove(func);
		}
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
		
		Scheduler.executeFrame();
		System.render(framebuffer);
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
	
	public static function mouseDown(button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendDownEvent(button, x, y);
	}

	public static function mouseUp(button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendUpEvent(button, x, y);
	}
	
	public static function mouseMove(x: Int, y: Int, movementX : Int, movementY : Int): Void {
		// var movementX = x - mouseX;
		// var movementY = y - mouseY;
		mouseX = x;
		mouseY = y;
		mouse.sendMoveEvent(x, y, movementX, movementY);
	}

	public static function mouseWheel(delta: Int): Void {
		mouse.sendWheelEvent(delta);
	}
	
	public static function gamepadAxis(axis: Int, value: Float): Void {
		gamepad.sendAxisEvent(axis, value);
	}
	
	public static function gamepadButton(button: Int, value: Float): Void {
		gamepad.sendButtonEvent(button, value);
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
	
	@:functionCode('init_kore(name, width, height);')
	private static function initKore(name: String, width: Int, height: Int): Void {
		
	}
	
	@:functionCode('run_kore();')
	private static function runKore(): Void {
		
	}

	private static var fullscreenListeners: Array<Void->Void> = new Array();
	private static var previousWidth : Int = 0;
	private static var previousHeight : Int = 0;

	public static function canSwitchFullscreen(): Bool {
		return true;
	}

	@:functionCode('return Kore::Application::the()->fullscreen();')
	public static function isFullscreen(): Bool {
		return false;
	}

	public static function requestFullscreen(): Void {
		if(!isFullscreen()){
			previousWidth = untyped __cpp__("Kore::Application::the()->width();");
			previousHeight = untyped __cpp__("Kore::Application::the()->height();");
			untyped __cpp__("Kore::System::changeResolution(Kore::System::desktopWidth(),Kore::System::desktopHeight(), true);");
			for (listener in fullscreenListeners) {
				listener();
			}
		}
		
	}

	public static function exitFullscreen(): Void {
		if (isFullscreen()) {
			if (previousWidth == 0 || previousHeight == 0){
				previousWidth = untyped __cpp__("Kore::Application::the()->width();");
				previousHeight = untyped __cpp__("Kore::Application::the()->height();");
			}
			untyped __cpp__("Kore::System::changeResolution(previousWidth,previousHeight, false);");
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
}

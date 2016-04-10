package kha;

import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.input.Surface;
import kha.System;

class SystemImpl {
	private static var framebuffer: Framebuffer;
	
	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		init_kore(StringHelper.convert(options.title), options.width, options.height);
		Shaders.init();
		var g4 = new kha.korehl.graphics4.Graphics();
		framebuffer = new Framebuffer(0, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.korehl.graphics4.Graphics2(framebuffer), g4);
		//kha.audio2.Audio._init();
		//kha.audio1.Audio._init();
		Scheduler.init();
		Scheduler.start();
		callback();
	}
	
	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void): Void {

	}
	
	public static function frame(): Void {
		Scheduler.executeFrame();
		System.render(0, framebuffer);
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

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	//@:functionCode('return ::String(Kore::System::systemId());')
	public static function getSystemId(): String {
		return 'HL';
	}
	
	public static function requestShutdown(): Void {
		
	}
	
	public static function getMouse(num: Int): Mouse {
		return null;
	}
	
	public static function getKeyboard(num: Int): Keyboard {
		return null;
	}
		
	public static function lockMouse(): Void {
		
	}
	
	public static function unlockMouse(): Void {
		
	}

	public static function canLockMouse(): Bool {
		return false;
	}

	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void{
		
	}

	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}

	static function unload(): Void {
		
	}
	
	public static function canSwitchFullscreen(): Bool {
		return false;
	}

	public static function isFullscreen(): Bool {
		return false;
	}

	public static function requestFullscreen(): Void {
		
	}

	public static function exitFullscreen(): Void {
		
	}

	public function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}


	public function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function changeResolution(width: Int, height: Int): Void {
		
	}
	
	public static function setKeepScreenOn(on: Bool): Void {
		
	}
	
	@:hlNative("std", "init_kore") static function init_kore(title: hl.types.Bytes, width: Int, height: Int): Void { }
	@:hlNative("std", "kore_get_time") static function kore_get_time(): Float { return 0; }
	@:hlNative("std", "kore_get_window_width") static function kore_get_window_width(window: Int): Int { return 0; }
	@:hlNative("std", "kore_get_window_height") static function kore_get_window_height(window: Int): Int { return 0; }
}

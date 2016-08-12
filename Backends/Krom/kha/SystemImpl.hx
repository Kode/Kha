package kha;

import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.input.Surface;
import kha.System;

class SystemImpl {
	private static var start: Float;
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: Mouse;
	
	private static function renderCallback(): Void {
		Scheduler.executeFrame();
		System.render(0, framebuffer);
	}
	
	private static function convertCode(code: Int): Key {
		switch (code) {
			case 0x00000112:
				return Key.LEFT;
			case 0x00000113:
				return Key.UP;
			case 0x00000114:
				return Key.RIGHT;
			case 0x00000115:
				return Key.DOWN;
			case 0x00000104, 0x00000105:
				return Key.ENTER;
			default:
				return null;
		}
	}
	
	private static function keyboardDownCallback(code: Int): Void {
		var key = convertCode(code);
		if (key != null) keyboard.sendDownEvent(key, " ");
	}
	
	private static function keyboardUpCallback(code: Int): Void {
		var key = convertCode(code);
		if (key != null) keyboard.sendUpEvent(key, " ");
	}
	
	private static function mouseDownCallback(button: Int, x: Int, y: Int): Void {
		mouse.sendDownEvent(0, button, x, y);
	}
	
	private static function mouseUpCallback(button: Int, x: Int, y: Int): Void {
		mouse.sendUpEvent(0, button, x, y);
	}
	
	private static function mouseMoveCallback(x: Int, y: Int): Void {
		mouse.sendMoveEvent(0, x, y, 0, 0);
	}
	
	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		start = Krom.getTime();
		
		Scheduler.init();
		Shaders.init();
		
		var g4 = new kha.krom.Graphics();
		framebuffer = new Framebuffer(0, null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.graphics4.Graphics2(framebuffer), g4);
		Krom.setCallback(renderCallback);
		
		keyboard = new Keyboard();
		mouse = new Mouse();
		
		Krom.setKeyboardDownCallback(keyboardDownCallback);
		Krom.setKeyboardUpCallback(keyboardUpCallback);
		Krom.setMouseDownCallback(mouseDownCallback);
		Krom.setMouseUpCallback(mouseUpCallback);
		Krom.setMouseMoveCallback(mouseMoveCallback);
		
		Scheduler.start();
		
		callback();
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void): Void {

	}
	
	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}
	
	public static function getTime(): Float {
		return Krom.getTime() - start;
	}
	
	public static function windowWidth(id: Int): Int {
		return 1024;
	}
	
	public static function windowHeight(id: Int): Int {
		return 768;
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
	
	public static function getSystemId(): String {
		return "Krom";
	}
	
	public static function requestShutdown(): Void {
		
	}
	
	public static function getMouse(num: Int): Mouse {
		return mouse;
	}
	
	public static function getKeyboard(num: Int): Keyboard {
		return keyboard;
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
}

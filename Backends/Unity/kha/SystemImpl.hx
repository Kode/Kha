package kha;

import kha.graphics4.Graphics2;
import kha.input.Keyboard;
import system.diagnostics.Stopwatch;

class SystemImpl {
	private static var watch: Stopwatch;
	
	//public static var graphics: Graphics;
	
	public static function init2(): Void {
		//graphics = new Graphics();
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
	
	public static function getPixelWidth(): Int {
		return unityEngine.Screen.width;
	}
	
	public static function getPixelHeight(): Int {
		return unityEngine.Screen.height;
	}
	
	public static function getVsync(): Bool {
		return true;
	}
	
	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function canSwitchFullscreen() : Bool{
		return false;
	}

	public static function isFullscreen() : Bool{
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
	
	public static function requestShutdown(): Void {
		
	}
	
	public static function getSystemId(): String {
		return "unity";
	}
	
	private static var frame: Framebuffer;
	
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void) {
		init2();
		Scheduler.init();
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		Scheduler.init();
		Shaders.init();
		var g4 = new kha.unity.Graphics(null);
		frame = new Framebuffer(null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new Graphics2(frame), g4);
		Scheduler.start();
		callback();
	}
	
	public static function getKeyboard(num: Int): Keyboard {
		if (num == 0) return keyboard;
		else return null;
	}
	
	public static function getMouse(num: Int): kha.input.Mouse {
		if (num == 0) return mouse;
		else return null;
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

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}


	public static function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	
	public static function leftDown(): Void {
		Keyboard.get().sendDownEvent(Key.LEFT, '');
	}
	
	public static function rightDown(): Void {
		Keyboard.get().sendDownEvent(Key.RIGHT, '');
	}
	
	public static function upDown(): Void {
		Keyboard.get().sendDownEvent(Key.UP, '');
	}
	
	public static function downDown(): Void {
		Keyboard.get().sendDownEvent(Key.DOWN, '');
	}
	
	public static function leftUp(): Void {
		Keyboard.get().sendUpEvent(Key.LEFT, '');
	}
	
	public static function rightUp(): Void {
		Keyboard.get().sendUpEvent(Key.RIGHT, '');
	}
	
	public static function upUp(): Void {
		Keyboard.get().sendUpEvent(Key.UP, '');
	}
	
	public static function downUp(): Void {
		Keyboard.get().sendUpEvent(Key.DOWN, '');
	}

	public static function mouseDown(button: Int, x: Int, y: Int): Void {
		kha.input.Mouse.get().sendDownEvent(button, x, y);
	}

	public static function mouseUp(button: Int, x: Int, y: Int): Void {
		kha.input.Mouse.get().sendUpEvent(button, x, y);
	}
	
	public static function update(): Void {
		Scheduler.executeFrame();
		System.render(frame);
	}
}

package kha;

import js.Browser;
import js.html.CanvasElement;
import js.Node;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.js.EmptyGraphics1;
import kha.js.EmptyGraphics2;
import kha.js.EmptyGraphics4;
import kha.network.Session;

class SystemImpl {
	private static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	private static var width: Int;
	private static var height: Int;
	
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void): Void {
		SystemImpl.width = width;
		SystemImpl.height = height;
		init2();
		callback();
	}
	
	public static function _updateSize(width: Int, height: Int): Void {
		SystemImpl.width = width;
		SystemImpl.height = height;
	}
	
	public static function _updateScreenRotation(value: Int): Void {
		screenRotation = ScreenRotation.createByIndex(value);
	}
	
	public static function getTime(): Float {
		var time = Node.process.hrtime();
		return cast(time[0], Float) + cast(time[1], Float) / 1000000000;
	}
	
	public static function getPixelWidth(): Int {
		return width;
	}
	
	public static function getPixelHeight(): Int {
		return height;
	}
	
	public static function getScreenRotation(): ScreenRotation {
		return screenRotation;
	}
	
	public static function getVsync(): Bool {
		return false;
	}
	
	public static function getRefreshRate(): Int {
		return 60;
	}
	
	public static function getSystemId(): String {
		return "nodejs";
	}
	
	public static function requestShutdown(): Void {
		Node.process.exit(0);
	}
	
	private static var frame: Framebuffer = null;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	
	public static var mouseX: Int;
	public static var mouseY: Int;

	private static var lastTime: Float = 0;
	
	private static function init2() {
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();
		
		Scheduler.init();

		Shaders.init();
		frame = new Framebuffer(new EmptyGraphics1(width, height), new EmptyGraphics2(width, height), new EmptyGraphics4(width, height));
		Scheduler.start();
		
		lastTime = Scheduler.time();
		run();
	}
	
	private static function run() {
		Scheduler.executeFrame();
		if (Session.the() != null) {
			Session.the().update();
		}
		var time = Scheduler.time();
		if (time >= lastTime + 10) {
			lastTime += 10;
			Node.console.log(lastTime + " seconds.");
		}
		Node.setTimeout(run, 0);
	}
	
	public static function getMouse(num: Int): Mouse {
		return mouse;
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

	public function notifyOfFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public function removeFromFullscreenChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}
	
	public static function setKeepScreenOn(on: Bool): Void {
		
	}
}

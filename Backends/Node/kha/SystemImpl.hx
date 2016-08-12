package kha;

import js.Browser;
import js.html.CanvasElement;
import js.Node;
import kha.System.SystemOptions;
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

	private static inline var networkSendRate = 0.05;
	
	public static function init(options: SystemOptions, callback: Void -> Void): Void {
		SystemImpl.width = options.width;
		SystemImpl.height = options.height;
		init2();
		callback();
	}
	
	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void) {
		trace('initEx is not supported on the node target, running init() with first window options');

		init({ title : title, width : options[0].width, height : options[0].height}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}
	
	public static function changeResolution(width: Int, height: Int): Void {

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
	
	public static function windowWidth(id: Int): Int {
		return width;
	}
	
	public static function windowHeight(id: Int): Int {
		return height;
	}

	public static function screenDpi(): Int {
		return 96;
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
		frame = new Framebuffer(0, new EmptyGraphics1(width, height), new EmptyGraphics2(width, height), new EmptyGraphics4(width, height));
		Scheduler.start();
		
		lastTime = Scheduler.time();
		run();
		synch();
	}
	
	private static function run() {
		Scheduler.executeFrame();
		var time = Scheduler.time();
		if (time >= lastTime + 10) {
			lastTime += 10;
			Node.console.log(lastTime + " seconds.");
		}
		Node.setTimeout(run, 0);
	}
	
	private static function synch() {
		if (Session.the() != null) {
			Session.the().update();
		}
		Node.setTimeout(synch, Std.int(networkSendRate * 1000));
	}
	
	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
		return keyboard;
	}
	
	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
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

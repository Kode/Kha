package kha;

import com.ktxsoftware.kha.KhaActivity;
import kha.android.Graphics;
import kha.android.Keyboard;
import kha.graphics4.Graphics2;
import android.view.KeyEvent;
import kha.input.Mouse;
import kha.input.Surface;
import kha.System;

class SystemImpl {
	public static var w: Int = 640;
	public static var h: Int = 480;
	private static var startTime: Float;

	@:functionCode('
		android.util.DisplayMetrics metrics = new android.util.DisplayMetrics();
		com.ktxsoftware.kha.KhaActivity.the().getWindowManager().getDefaultDisplay().getMetrics(metrics);
		return metrics.widthPixels;
	')
	public static function windowWidth(windowId: Int = 0): Int {
		return 0;
	}

	@:functionCode('
		android.util.DisplayMetrics metrics = new android.util.DisplayMetrics();
		com.ktxsoftware.kha.KhaActivity.the().getWindowManager().getDefaultDisplay().getMetrics(metrics);
		return metrics.heightPixels;
	')
	public static function windowHeight(windowId: Int = 0): Int {
		return 0;
	}

	@:functionCode('
		android.util.DisplayMetrics metrics = new android.util.DisplayMetrics();
		com.ktxsoftware.kha.KhaActivity.the().getWindowManager().getDefaultDisplay().getMetrics(metrics);
		return (int)(metrics.density * android.util.DisplayMetrics.DENSITY_DEFAULT);
	')
	public static function screenDpi(): Int {
		return 0;
	}
	
	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getFrequency(): Int {
		return 1000;
	}

	@:functionCode('
		return java.lang.System.currentTimeMillis();
	')
	public static function getTimestamp(): Float {
		return 0;
	}

	public static function getTime(): Float {
		return (getTimestamp() - startTime) / getFrequency();
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "Android";
	}

	public static function requestShutdown(): Void {
		shutdown();
		untyped __java__("java.lang.System.exit(0)");	
	}

	public static function changeResolution(width: Int, height: Int): Void {

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

	private static var framebuffer: Framebuffer;
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	private static var keyboard: Keyboard;
	private static var shift = false;
	private static var mouse: Mouse;
	private static var surface: Surface;

	public static function init(options: SystemOptions, done: Void->Void) {
		w = options.width;
		h = options.height;
		KhaActivity.the();
		keyboard = new Keyboard();
		mouse = new Mouse();
		//gamepad = new Gamepad();
		surface = new Surface();

		LoaderImpl.init(KhaActivity.the().getApplicationContext());
		Scheduler.init();

		Shaders.init();
		var graphics = new Graphics();
		framebuffer = new Framebuffer(0, null, null, graphics);
		var g1 = new kha.graphics2.Graphics1(framebuffer);
		var g2 = new Graphics2(framebuffer);
		framebuffer.init(g1, g2, graphics);

		Scheduler.start();

		done();
	}

	public static function initEx( title : String, options : Array<kha.WindowOptions>, windowCallback : Int -> Void, callback : Void -> Void ) {
		trace('initEx is not supported on android target, falling back to init() with first window options');
		init( { title: title, width: options[0].width, height : options[0].height, samplesPerPixel : options[0].rendererOptions != null ? options[0].rendererOptions.samplesPerPixel : 0}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}

	public static function getKeyboard(num: Int = 0): Keyboard {
		if (num == 0) return keyboard;
		else return null;
	}

	public static function getMouse(num: Int = 0): Mouse {
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

	public static function preinit(width: Int, height: Int): Void {
		w = width;
		h = height;
		startTime = getTimestamp();
		Main.main();
	}

	public static function setWidthHeight(width: Int, height: Int): Void {
		w = width;
		h = height;
	}

	public static function step(): Void {
		Scheduler.executeFrame();
		System.render(0, framebuffer);
	}

	private static function setMousePosition(x : Int, y : Int){
		mouseX = x;
		mouseY = y;
	}

	public static function touch(index: Int, x: Int, y: Int, action: Int): Void {

		switch (action) {
		case 0: //DOWN
			if (index == 0) {
				setMousePosition(x,y);
				mouse.sendDownEvent(0, 0, x, y);
			}
			surface.sendTouchStartEvent(index, x, y);
		case 1: //MOVE
			if (index == 0) {
				var movementX = x - mouseX;
				var movementY = y - mouseY;
				setMousePosition(x,y);
				mouse.sendMoveEvent(0, x, y, movementX, movementY);
			}
			surface.sendMoveEvent(index, x, y);
		case 2: //UP
			if (index == 0) {
				setMousePosition(x,y);
				mouse.sendUpEvent(0, 0, x, y);
			}
			surface.sendTouchEndEvent(index, x, y);
		}
	}

	public static function keyDown(code: Int): Void {
		switch (code) {
		case 0x00000120:
			shift = true;
			keyboard.sendDownEvent(Key.SHIFT, " ");
		case 0x00000103:
			keyboard.sendDownEvent(Key.BACKSPACE, " ");
		case 0x00000104:
			keyboard.sendDownEvent(Key.ENTER, " ");
		case 0x00000004: // KeyEvent.KEYCODE_BACK
			keyboard.sendDownEvent(Key.BACK, " ");
		default:
			var char: String;
			if (shift) {
				char = String.fromCharCode(code);
			}
			else {
				char = String.fromCharCode(code + "a".charCodeAt(0) - "A".charCodeAt(0));
			}
			keyboard.sendDownEvent(Key.CHAR, char);
		}
	}

	public static function keyUp(code: Int): Void {
		switch (code) {
		case 0x00000120:
			shift = false;
			keyboard.sendUpEvent(Key.SHIFT, " ");
		case 0x00000103:
			keyboard.sendUpEvent(Key.BACKSPACE, " ");
		case 0x00000104:
			keyboard.sendUpEvent(Key.ENTER, " ");
		case 0x00000004: // KeyEvent.KEYCODE_BACK
			keyboard.sendUpEvent(Key.BACK, " ");
		default:
			var char: String;
			if (shift) {
				char = String.fromCharCode(code);
			}
			else {
				char = String.fromCharCode(code + "a".charCodeAt(0) - "A".charCodeAt(0));
			}
			keyboard.sendUpEvent(Key.CHAR, char);
		}
	}

	public static var showKeyboard: Bool;

	public static function keyboardShown(): Bool {
		return showKeyboard;
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

	public static function setKeepScreenOn(on: Bool): Void {

	}
}

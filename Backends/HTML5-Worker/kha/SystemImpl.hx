package kha;

import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Mouse;
import kha.input.Surface;
import kha.System;

class GamepadStates {
	public var axes: Array<Float>;
	public var buttons: Array<Float>;

	public function new() {
		axes = new Array<Float>();
		buttons = new Array<Float>();
	}
}

class SystemImpl {
	static var options: SystemOptions;
	static var width: Int = 800;
	static var height: Int = 600;
	static var dpi: Int = 96;
	static inline var maxGamepads: Int = 4;
	static var frame: Framebuffer;
	static var keyboard: Keyboard = null;
	static var mouse: kha.input.Mouse;
	static var surface: Surface;
	static var gamepads: Array<Gamepad>;

	public static function init(options: SystemOptions, callback: Void -> Void) {
		Worker.handleMessages(messageHandler);
		
		Shaders.init();
		var shaders = new Array<Dynamic>();
		for (field in Reflect.fields(Shaders)) {
			if (field != "init" && field != "__name__" && field.substr(field.length - 5, 4) != "Data") {
				var shader = Reflect.field(Shaders, field);
				shaders.push({
					name: field,
					files: shader.files,
					sources: shader.sources
				});
			}
		}
		Worker.postMessage({ command: 'setShaders', shaders: shaders });
			
		SystemImpl.options = options;
		
		//haxe.Log.trace = untyped js.Boot.__trace; // Hack for JS trace problems
		
		keyboard = new Keyboard();
		mouse = new Mouse();
		surface = new Surface();
		gamepads = new Array<Gamepad>();
		for (i in 0...maxGamepads) {
			gamepads[i] = new Gamepad(i);
		}
		
		var g4 = new kha.html5worker.Graphics();
		frame = new Framebuffer(0, null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new kha.graphics4.Graphics2(frame), g4);

		Scheduler.init();
		Scheduler.start();
		
		callback();
	}
	
	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Void -> Void) {
		trace('initEx is not supported on the html5 target, running init() with first window options');

		init({title : title, width : options[0].width, height : options[0].height}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}

	public static function windowWidth(windowId: Int = 0): Int {
		return width;
	}

	public static function windowHeight(windowId: Int = 0): Int {
		return height;
	}

	public static function screenDpi(): Int {
		return dpi;
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getTime(): Float {
		return untyped __js__("Date.now()") / 1000;
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "HTML5-Worker";
	}

	public static function requestShutdown(): Void {
		
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
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

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void {

	}

	static function unload(_): Void {

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

	public static function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function changeResolution(width: Int, height: Int): Void {

	}

	public static function setKeepScreenOn(on: Bool): Void {

	}

	public static function loadUrl(url: String): Void {
		
	}

	public static function getGamepadId(index: Int): String {
		return "unkown";
	}
	
	static function messageHandler(value: Dynamic): Void {
		switch (value.data.command) {
		case 'patch':
			js.Lib.eval(value.data.source);
		case 'loadedImage':
			LoaderImpl._loadedImage(value.data);
		case 'loadedSound':
			LoaderImpl._loadedSound(value.data);
		case 'loadedBlob':
			LoaderImpl._loadedBlob(value.data);
		case 'uncompressedSound':
			LoaderImpl._uncompressedSound(value.data);
		case 'frame':
			if (frame != null) {
				Scheduler.executeFrame();
				Worker.postMessage({ command: 'beginFrame' });
				System.render(0, frame);
				Worker.postMessage({ command: 'endFrame' });
			}
		case 'setWindowSize':
			width = value.data.width;
			height = value.data.height;
		case 'keyDown':
			keyboard.sendDownEvent(cast value.data.key);
		case 'keyUp':
			keyboard.sendUpEvent(cast value.data.key);
		case 'keyPress':
			keyboard.sendPressEvent(value.data.character);
		case 'mouseDown':
			mouse.sendDownEvent(0, value.data.button, value.data.x, value.data.y);
		case 'mouseUp':
			mouse.sendUpEvent(0, value.data.button, value.data.x, value.data.y);
		case 'mouseMove':
			mouse.sendMoveEvent(0, value.data.x, value.data.y, value.data.mx, value.data.my);
		case 'mouseWheel':
			mouse.sendWheelEvent(0, value.data.delta);
		}
	}
}

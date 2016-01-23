package kha;

import js.html.webgl.GL;
import js.html.WheelEvent;
import js.Browser;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.Touch;
import js.html.TouchEvent;
import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.input.Surface;
import kha.js.AudioElementAudio;
import kha.js.CanvasGraphics;

class GamepadStates {
	public var axes: Array<Float>;
	public var buttons: Array<Float>;
	
	public function new() {
		axes = new Array<Float>();
		buttons = new Array<Float>();
	}
}

class SystemImpl {
	public static var gl: GL;
	public static var drawBuffers: Dynamic;
	@:noCompletion public static var _hasWebAudio: Bool;
	//public static var graphics(default, null): Graphics;
	public static var khanvas: CanvasElement;
	private static var performance: Dynamic;
	
	public static function initPerformanceTimer(): Void {
		if (Browser.window.performance != null) {
			performance = Browser.window.performance;
		}
		else {
			performance = untyped __js__("window.Date");
		}
	}
	
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void) {
        #if sys_debug_html5
        // Wait a second so the debugger can attach
		untyped require('web-frame').setZoomLevelLimits(1, 1);
        Browser.window.setTimeout(function () {
            init2();
            callback();   
        }, 1000);
        #else
		init2();
		callback();
        #end
	}
	
	public static function setCanvas(canvas: CanvasElement): Void {
		khanvas = canvas;
	}
	
	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}
	
	public static function getTime(): Float {
		return performance.now() / 1000;
	}
	
	public static function getPixelWidth(): Int {
		return khanvas.width;
	}
	
	public static function getPixelHeight(): Int {
		return khanvas.height;
	}
	
	public static function getVsync(): Bool {
		return true;
	}
	
	public static function getRefreshRate(): Int {
		return 60;
	}
	
	public static function getSystemId(): String {
		return "HTML5";
	}
	
	public static function requestShutdown(): Void {
		Browser.window.close();
	}
	
	private static var maxGamepads : Int = 4;
	private static var frame: Framebuffer;
	private static var pressedKeys: Array<Bool>;
	private static var buttonspressed: Array<Bool>;
	private static var leftMouseCtrlDown: Bool = false;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var surface: Surface;
	private static var gamepads: Array<Gamepad>;
	private static var gamepadStates: Array<GamepadStates>;
	
	private static var mouseX: Int;
	private static var mouseY: Int;
	private static var touchX: Int;
	private static var touchY: Int;
	private static var lastFirstTouchX: Int = 0;
	private static var lastFirstTouchY: Int = 0;

	public static function init2(?backbufferFormat: TextureFormat) {
		haxe.Log.trace = untyped js.Boot.__trace; // Hack for JS trace problems
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		surface = new Surface();
		gamepads = new Array<Gamepad>();
		gamepadStates = new Array<GamepadStates>();
		for (i in 0...maxGamepads) {
			gamepads[i] = new Gamepad(i);
			gamepadStates[i] = new GamepadStates();
		}
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		for (i in 0...256) pressedKeys.push(null);
		buttonspressed = new Array<Bool>();
		for (i in 0...10) buttonspressed.push(false);
		CanvasImage.init();
		//Loader.init(new kha.js.Loader());
		SystemImpl.initPerformanceTimer();
		Scheduler.init();
		
		loadFinished();
		EnvironmentVariables.instance = new kha.js.EnvironmentVariables();
	}
	
	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}
	
	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
		return keyboard;
	}
	
	static function checkGamepadButton(pad: Dynamic, num: Int) {
		if (buttonspressed[num]) {
			if (pad.buttons[num] < 0.5) {
				buttonspressed[num] = false;
			}
		}
		else {
			if (pad.buttons[num] > 0.5) {
				buttonspressed[num] = true;
			}
		}
	}
	
	static function checkGamepad(pad: Dynamic) {
		for (i in 0...pad.axes.length) {
			if (pad.axes[i] != null) {
				if (gamepadStates[pad.index].axes[i] != pad.axes[i]) {
					gamepadStates[pad.index].axes[i] = pad.axes[i];
					gamepads[pad.index].sendAxisEvent(i, pad.axes[i]);
				}
			}
		}
		for (i in 0...pad.buttons.length) {
			if (pad.buttons[i] != null) {
				if (gamepadStates[pad.index].buttons[i] != pad.buttons[i].value) {
					gamepadStates[pad.index].buttons[i] = pad.buttons[i].value;
					gamepads[pad.index].sendButtonEvent(i, pad.buttons[i].value);
				}
			}
		}
	}
	
	//public function start(game: Game): Void {
	//	gameToStart = game;
	//	Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
	//	Loader.the.loadProject(loadFinished);
	//}
	
	private static function loadFinished() {
		var canvas: Dynamic = Browser.document.getElementById("khanvas");
		
		var gl: Bool = false;
		
		try {
			SystemImpl.gl = canvas.getContext("experimental-webgl", { alpha: false, antialias: false } ); // , preserveDrawingBuffer: true } ); // Firefox 36 does not like the preserveDrawingBuffer option
			if (SystemImpl.gl != null) {
				SystemImpl.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
				SystemImpl.gl.getExtension("OES_texture_float");
				drawBuffers = SystemImpl.gl.getExtension('WEBGL_draw_buffers');
				gl = true;
				Shaders.init();
			}
		}
		catch (e: Dynamic) {
			trace(e);
		}
		
		setCanvas(canvas);
		//var widthTransform: Float = canvas.width / Loader.the.width;
		//var heightTransform: Float = canvas.height / Loader.the.height;
		//var transform: Float = Math.min(widthTransform, heightTransform);
		if (gl) {
			var g4 = gl ? new kha.js.graphics4.Graphics() : null;
			frame = new Framebuffer(null, null, g4);
			frame.init(new kha.graphics2.Graphics1(frame), new kha.js.graphics4.Graphics2(frame), g4);
		}
		else {
			var g2 = new CanvasGraphics(canvas.getContext("2d"), 640, 480); // Math.round(Loader.the.width * transform), Math.round(Loader.the.height * transform));
			frame = new Framebuffer(null, g2, null);
			frame.init(new kha.graphics2.Graphics1(frame), g2, null);
		}
		//canvas.getContext("2d").scale(transform, transform);

		if (kha.audio2.Audio._init()) {
			SystemImpl._hasWebAudio = true;
			kha.audio2.Audio1._init();
		}
		else {
			SystemImpl._hasWebAudio = false;
			AudioElementAudio._compile();
			untyped __js__ ("kha_audio2_Audio1 = kha_js_AudioElementAudio");
		}

		Scheduler.start();
		
		var window: Dynamic = Browser.window;
		var requestAnimationFrame = window.requestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.mozRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.webkitRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.msRequestAnimationFrame;
		
		function animate(timestamp) {
			var window : Dynamic = Browser.window;
			if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
			else requestAnimationFrame(animate);
			
			var sysGamepads: Dynamic = untyped __js__("(navigator.getGamepads && navigator.getGamepads()) || (navigator.webkitGetGamepads && navigator.webkitGetGamepads())");
			if (sysGamepads != null) {
				for (i in 0...sysGamepads.length) {
					var pad = sysGamepads[i];
					if (pad != null) {
						checkGamepadButton(pad, 0);
						checkGamepadButton(pad, 1);
						checkGamepadButton(pad, 12);
						checkGamepadButton(pad, 13);
						checkGamepadButton(pad, 14);
						checkGamepadButton(pad, 15);
						
						checkGamepad(pad);
					}					
				}
			}
			
			Scheduler.executeFrame();
			
			if (canvas.getContext) {

				// Lookup the size the browser is displaying the canvas.
				//TODO deal with window.devicePixelRatio ?
				var displayWidth  = canvas.clientWidth;
				var displayHeight = canvas.clientHeight;

				// Check if the canvas is not the same size.
				if (canvas.width  != displayWidth ||
					canvas.height != displayHeight) {

					// Make the canvas the same size
					canvas.width  = displayWidth;
					canvas.height = displayHeight;
				}

				System.render(frame);
				if (SystemImpl.gl != null) {
					// Clear alpha for IE11
					SystemImpl.gl.clearColor(1, 1, 1, 1);
					SystemImpl.gl.colorMask(false, false, false, true);
					SystemImpl.gl.clear(GL.COLOR_BUFFER_BIT);
					SystemImpl.gl.colorMask(true, true, true, true);
				}
			}
		}
		
		if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
		else requestAnimationFrame(animate);
		
		// Autofocus
		if (canvas.getAttribute("tabindex") == null) {
			canvas.setAttribute("tabindex", "0"); // needed for keypress events
		}
		canvas.focus();
		
		// disable context menu
		canvas.oncontextmenu = function(event: Dynamic) { event.stopPropagation(); event.preventDefault(); }
		
		canvas.onmousedown = mouseDown;
		canvas.onmousemove = mouseMove;
		canvas.onkeydown = keyDown;
		canvas.onkeyup = keyUp;
		canvas.onblur = onBlur;
		canvas.onfocus = onFocus;
		untyped if (canvas.onwheel) canvas.onwheel = mouseWheel;
		else if (canvas.onmousewheel) canvas.onmousewheel = mouseWheel;
		canvas.addEventListener("wheel mousewheel", mouseWheel, false);
		canvas.addEventListener("touchstart", touchDown, false);
		canvas.addEventListener("touchend", touchUp, false);
		canvas.addEventListener("touchmove", touchMove, false);
		
		Browser.window.addEventListener("unload", unload);
	}

	public static function lockMouse(): Void {
		untyped if (SystemImpl.khanvas.requestPointerLock) {
        	SystemImpl.khanvas.requestPointerLock();
        }
		else if (canvas.mozRequestPointerLock) {
        	SystemImpl.khanvas.mozRequestPointerLock();
        }
		else if (canvas.webkitRequestPointerLock) {
        	SystemImpl.khanvas.webkitRequestPointerLock();
        }
	}
	
	public static function unlockMouse(): Void {
		untyped if (document.exitPointerLock) {
			document.exitPointerLock();
        }
		else if (document.mozExitPointerLock) {
         	document.mozExitPointerLock();
        }
		else if (document.webkitExitPointerLock) {
        	document.webkitExitPointerLock();
        }
	}

	public static function canLockMouse(): Bool {
		return untyped __js__("'pointerLockElement' in document ||
        'mozPointerLockElement' in document ||
        'webkitPointerLockElement' in document");
	}

	public static function isMouseLocked(): Bool {
		return untyped __js__("document.pointerLockElement === kha_Sys.khanvas ||
  			document.mozPointerLockElement === kha_Sys.khanvas ||
  			document.webkitPointerLockElement === kha_Sys.khanvas");
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void{
		js.Browser.document.addEventListener('pointerlockchange', func, false);
		js.Browser.document.addEventListener('mozpointerlockchange', func, false);
		js.Browser.document.addEventListener('webkitpointerlockchange', func, false);

		js.Browser.document.addEventListener('pointerlockerror', error, false);
		js.Browser.document.addEventListener('mozpointerlockerror', error, false);
		js.Browser.document.addEventListener('webkitpointerlockerror', error, false);
	}

	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		js.Browser.document.removeEventListener('pointerlockchange', func, false);
		js.Browser.document.removeEventListener('mozpointerlockchange', func, false);
		js.Browser.document.removeEventListener('webkitpointerlockchange', func, false);

		js.Browser.document.removeEventListener('pointerlockerror', error, false);
		js.Browser.document.removeEventListener('mozpointerlockerror', error, false);
		js.Browser.document.removeEventListener('webkitpointerlockerror', error, false);
	}

	static function unload(_): Void {
		//Game.the.onPause();
		//Game.the.onBackground();
		//Game.the.onShutdown();
	}
	
	private static function setMouseXY(event: MouseEvent): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		mouseX = Std.int((event.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		mouseY = Std.int((event.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}

	private static function mouseWheel(event: WheelEvent): Void{
		mouse.sendWheelEvent(Std.int(event.deltaY));
	}
	
	private static function mouseDown(event: MouseEvent): Void {
		Browser.document.addEventListener('mouseup', mouseUp);
		setMouseXY(event);
		if (event.which == 1) { //left button
			if (event.ctrlKey) {
				leftMouseCtrlDown = true;
				mouse.sendDownEvent(1, mouseX, mouseY);
			}
			else {
				leftMouseCtrlDown = false;
				mouse.sendDownEvent(0, mouseX, mouseY);
			}
		}
		else if(event.which == 2){ //middle button
			mouse.sendDownEvent(2, mouseX, mouseY);
		}
		else if(event.which == 3){ //right button
			mouse.sendDownEvent(1, mouseX, mouseY);
		}
	}
	
	private static function mouseUp(event: MouseEvent): Void {
		Browser.document.removeEventListener('mouseup', mouseUp);
		setMouseXY(event);
		if (event.which == 1) { //left button
			if (leftMouseCtrlDown) {
				mouse.sendUpEvent(1, mouseX, mouseY);
			}
			else {
				mouse.sendUpEvent(0, mouseX, mouseY);
			}
			leftMouseCtrlDown = false;
		}
		else if(event.which == 2){ //middle button
			mouse.sendUpEvent(2, mouseX, mouseY);
		}
		else if(event.which == 3){ //right button
			mouse.sendUpEvent(1, mouseX, mouseY);
		}
	}
	
	private static function mouseMove(event: MouseEvent): Void {
		var lastMouseX = mouseX;
		var lastMouseY = mouseY;
		setMouseXY(event);
		var movementX = untyped event.movementX || event.mozMovementX || event.webkitMovementX || mouseX - lastMouseX;
		var movementY = untyped event.movementY || event.mozMovementY || event.webkitMovementY || mouseY - lastMouseY;
		mouse.sendMoveEvent(mouseX, mouseY, movementX, movementY);
	}
	
	private static function setTouchXY(touch: Touch): Void {
		var rect = SystemImpl.khanvas.getBoundingClientRect();
		var borderWidth = SystemImpl.khanvas.clientLeft;
		var borderHeight = SystemImpl.khanvas.clientTop;
		touchX = Std.int((touch.clientX - rect.left - borderWidth) * SystemImpl.khanvas.width / (rect.width - 2 * borderWidth));
		touchY = Std.int((touch.clientY - rect.top - borderHeight) * SystemImpl.khanvas.height / (rect.height - 2 * borderHeight));
	}
	
	private static function touchDown(event: TouchEvent): Void {
		for (touch in event.changedTouches)	{
			setTouchXY(touch);
			mouse.sendDownEvent(0, touchX, touchY);
			surface.sendTouchStartEvent(touch.identifier, touchX, touchY);
		}
	}
	
	private static function touchUp(event: TouchEvent): Void {
		for (touch in event.changedTouches)	{
			setTouchXY(touch);
			mouse.sendUpEvent(0, touchX, touchY);
			surface.sendTouchEndEvent(touch.identifier, touchX, touchY);
		}
	}
	
	private static function touchMove(event: TouchEvent): Void {
		var index = 0;
		for (touch in event.changedTouches) {
			setTouchXY(touch);
			if(index == 0){
				var movementX = touchX - lastFirstTouchX;
				var movementY = touchY - lastFirstTouchY;
				lastFirstTouchX = touchX;
				lastFirstTouchY = touchY;
				
				mouse.sendMoveEvent(touchX, touchY, movementX, movementY);
			}
			
			surface.sendMoveEvent(touch.identifier, touchX, touchY);
			index++;
		}
	}

	private static function onBlur() {
		// System.pause();
		System.background();
	}

	private static function onFocus() {
		// System.resume();
		System.foreground();
	}
	
	private static function keycodeToChar(key: String, keycode: Int, shift: Bool): String {
		if (key != null) {
			if (key.length == 1) return key;
			switch (key) {
				case "Add":
					return "+";
				case "Subtract":
					return "-";
				case "Multiply":
					return "*";
				case "Divide":
					return "/";
			}
		}
		switch (keycode) {
			case 187:
				if (shift) return "*";
				else return "+";
			case 188:
				if (shift) return ";";
				else return ",";
			case 189:
				if (shift) return "_";
				else return "-";
			case 190:
				if (shift) return ":";
				else return ".";
			case 191:
				if (shift) return "'";
				else return "#";
			case 226:
				if (shift) return ">";
				else return "<";
			case 106:
				return "*";
			case 107:
				return "+";
			case 109:
				return "-";
			case 111:
				return "/";
			case 49:
				if (shift) return "!";
				else return "1";
			case 50:
				if (shift) return "\"";
				else return "2";
			case 51:
				if (shift) return "§";
				else return "3";
			case 52:
				if (shift) return "$";
				else return "4";
			case 53:
				if (shift) return "%";
				else return "5";
			case 54:
				if (shift) return "&";
				else return "6";
			case 55:
				if (shift) return "/";
				else return "7";
			case 56:
				if (shift) return "(";
				else return "8";
			case 57:
				if (shift) return ")";
				else return "9";
			case 48:
				if (shift) return "=";
				else return "0";
			case 219:
				if (shift) return "?";
				else return "ß";
			case 212:
				if (shift) return "`";
				else return "´";
		}
		if (keycode >= 96 && keycode <= 105) { // num block
			return String.fromCharCode('0'.code - 96 + keycode);
		}
		if (keycode >= 'A'.code && keycode <= 'Z'.code) {
			if (shift) return String.fromCharCode(keycode);
			else return String.fromCharCode(keycode - 'A'.code + 'a'.code);
		}
		return String.fromCharCode(keycode);
	}
	
	private static function keyDown(event: KeyboardEvent): Void {
		event.stopPropagation();
		
		// prevent key repeat
		if (pressedKeys[event.keyCode]) {
			event.preventDefault();
			return;
		}
		
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 8:
			keyboard.sendDownEvent(Key.BACKSPACE, "");
			event.preventDefault();
		case 9:
			keyboard.sendDownEvent(Key.TAB, "");
			event.preventDefault();
		case 13:
			keyboard.sendDownEvent(Key.ENTER, "");
			event.preventDefault();
		case 16:
			keyboard.sendDownEvent(Key.SHIFT, "");
			event.preventDefault();
		case 17:
			keyboard.sendDownEvent(Key.CTRL, "");
			event.preventDefault();
		case 18:
			keyboard.sendDownEvent(Key.ALT, "");
			event.preventDefault();
		case 27:
			keyboard.sendDownEvent(Key.ESC, "");
			event.preventDefault();
		case 32:
			keyboard.sendDownEvent(Key.CHAR, " ");
			event.preventDefault(); // don't scroll down in IE
		case 46:
			keyboard.sendDownEvent(Key.DEL, "");
			event.preventDefault();
		case 38:
			keyboard.sendDownEvent(Key.UP, "");
			event.preventDefault();
		case 40:
			keyboard.sendDownEvent(Key.DOWN, "");
			event.preventDefault();
		case 37:
			keyboard.sendDownEvent(Key.LEFT, "");
			event.preventDefault();
		case 39:
			keyboard.sendDownEvent(Key.RIGHT, "");
			event.preventDefault();
		default:
			if (!event.altKey) {
				var char = keycodeToChar(event.key, event.keyCode, event.shiftKey);
				keyboard.sendDownEvent(Key.CHAR, char);
			}
		}
	}

	private static function keyUp(event: KeyboardEvent): Void {
		event.preventDefault();
		event.stopPropagation();
		
		pressedKeys[event.keyCode] = false;
		
		switch (event.keyCode) {
		case 8:
			keyboard.sendUpEvent(Key.BACKSPACE, "");
		case 9:
			keyboard.sendUpEvent(Key.TAB, "");
		case 13:
			keyboard.sendUpEvent(Key.ENTER, "");
		case 16:
			keyboard.sendUpEvent(Key.SHIFT, "");
		case 17:
			keyboard.sendUpEvent(Key.CTRL, "");
		case 18:
			keyboard.sendUpEvent(Key.ALT, "");
		case 27:
			keyboard.sendUpEvent(Key.ESC, "");
		case 32:
			keyboard.sendUpEvent(Key.CHAR, " ");
		case 46:
			keyboard.sendUpEvent(Key.DEL, "");
		case 38:
			keyboard.sendUpEvent(Key.UP, "");
		case 40:
			keyboard.sendUpEvent(Key.DOWN, "");
		case 37:
			keyboard.sendUpEvent(Key.LEFT, "");
		case 39:
			keyboard.sendUpEvent(Key.RIGHT, "");
		default:
			if (!event.altKey) {
				var char = keycodeToChar(event.key, event.keyCode, event.shiftKey);
				keyboard.sendUpEvent(Key.CHAR, char);
			}
		}
	}

	public static function canSwitchFullscreen(): Bool {
		return untyped __js__("'fullscreenElement ' in document ||
        'mozFullScreenElement' in document ||
        'webkitFullscreenElement' in document ||
        'msFullscreenElement' in document
        ");
	}

	public static function isFullscreen(): Bool {
		return untyped __js__("document.fullscreenElement === this.khanvas ||
  			document.mozFullScreenElement === this.khanvas ||
  			document.webkitFullscreenElement === this.khanvas ||
  			document.msFullscreenElement === this.khanvas ");
	}

	public static function requestFullscreen(): Void {
		untyped if (khanvas.requestFullscreen) {
        	khanvas.requestFullscreen();
        } else if (khanvas.msRequestFullscreen) {
        	khanvas.msRequestFullscreen();
        } else if (khanvas.mozRequestFullScreen) {
        	khanvas.mozRequestFullScreen();
        } else if(khanvas.webkitRequestFullscreen){
        	khanvas.webkitRequestFullscreen();
        }
	}

	public static function exitFullscreen(): Void {
		untyped if (document.exitFullscreen) {
	      document.exitFullscreen();
	    } else if (document.msExitFullscreen) {
	      document.msExitFullscreen();
	    } else if (document.mozCancelFullScreen) {
	      document.mozCancelFullScreen();
	    } else if (document.webkitExitFullscreen) {
	      document.webkitExitFullscreen();
	    }
  	}

	public function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		js.Browser.document.addEventListener('fullscreenchange', func, false);
		js.Browser.document.addEventListener('mozfullscreenchange', func, false);
		js.Browser.document.addEventListener('webkitfullscreenchange', func, false);
		js.Browser.document.addEventListener('MSFullscreenChange', func, false);

		js.Browser.document.addEventListener('fullscreenerror', error, false);
		js.Browser.document.addEventListener('mozfullscreenerror', error, false);
		js.Browser.document.addEventListener('webkitfullscreenerror', error, false);
		js.Browser.document.addEventListener('MSFullscreenError', error, false);
	}


	public function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		js.Browser.document.removeEventListener('fullscreenchange', func, false);
		js.Browser.document.removeEventListener('mozfullscreenchange', func, false);
		js.Browser.document.removeEventListener('webkitfullscreenchange', func, false);
		js.Browser.document.removeEventListener('MSFullscreenChange', func, false);

		js.Browser.document.removeEventListener('fullscreenerror', error, false);
		js.Browser.document.removeEventListener('mozfullscreenerror', error, false);
		js.Browser.document.removeEventListener('webkitfullscreenerror', error, false);
		js.Browser.document.removeEventListener('MSFullscreenError', error, false);
	}

	public static function changeResolution(width: Int, height: Int): Void {
		
	}
}

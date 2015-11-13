package kha;

import js.html.WheelEvent;
import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.CanvasElement;
import js.html.Document;
import js.html.Event;
import js.html.EventListener;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.Touch;
import js.html.TouchEvent;
import kha.Game;
import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Surface;
import kha.js.AudioElementAudio;
import kha.js.CanvasGraphics;
import kha.Key;
import kha.Loader;
import js.Lib;
import js.Browser;
import js.html.DOMWindow;

class GamepadStates {
	public var axes: Array<Float>;
	public var buttons: Array<Float>;
	
	public function new() {
		axes = new Array<Float>();
		buttons = new Array<Float>();
	}
}

class Starter {
	private static var maxGamepads : Int = 4;
	
	private var gameToStart: Game;
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

	public function new(?backbufferFormat: TextureFormat) {
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
		Loader.init(new kha.js.Loader());
		Sys.initPerformanceTimer();
		Scheduler.init();
		
		// TODO: Move?
		EnvironmentVariables.instance = new kha.js.EnvironmentVariables();
	}
	
	static function checkGamepadButton(pad: Dynamic, num: Int, button: kha.Button) {
		if (buttonspressed[num]) {
			if (pad.buttons[num] < 0.5) {
				Game.the.buttonUp(button);
				buttonspressed[num] = false;
			}
		}
		else {
			if (pad.buttons[num] > 0.5) {
				Game.the.buttonDown(button);
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
	
	public function start(game: Game): Void {
		gameToStart = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public function loadFinished() {
		Loader.the.initProject();
		
		gameToStart.width = Loader.the.width;
		gameToStart.height = Loader.the.height;
		
		var canvas: Dynamic = Browser.document.getElementById("khanvas");
		
		var gl: Bool = false;
		
		try {
			Sys.gl = canvas.getContext("experimental-webgl", { alpha: false, antialias: Loader.the.antiAliasingSamples > 1 } ); // , preserveDrawingBuffer: true } ); // Firefox 36 does not like the preserveDrawingBuffer option
			if (Sys.gl != null) {
				Sys.gl.pixelStorei(Sys.gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
				Sys.gl.getExtension("OES_texture_float");
				gl = true;
			}
		}
		catch (e: Dynamic) {
			trace(e);
		}
		
		Sys.init(canvas);
		var widthTransform: Float = canvas.width / Loader.the.width;
		var heightTransform: Float = canvas.height / Loader.the.height;
		var transform: Float = Math.min(widthTransform, heightTransform);
		if (gl) {
			var g4 = gl ? new kha.js.graphics4.Graphics() : null;
			frame = new Framebuffer(null, null, g4);
			frame.init(new kha.graphics2.Graphics1(frame), new kha.js.graphics4.Graphics2(frame), g4);
		}
		else {
			var g2 = new CanvasGraphics(canvas.getContext("2d"), Math.round(Loader.the.width * transform), Math.round(Loader.the.height * transform));
			frame = new Framebuffer(null, g2, null);
			frame.init(new kha.graphics2.Graphics1(frame), g2, null);
		}
		//canvas.getContext("2d").scale(transform, transform);

		if (kha.audio2.Audio._init()) {
			Sys._hasWebAudio = true;
			kha.audio2.Audio1._init();
		}
		else {
			Sys._hasWebAudio = false;
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
						checkGamepadButton(pad, 0, Button.BUTTON_1);
						checkGamepadButton(pad, 1, Button.BUTTON_2);
						checkGamepadButton(pad, 12, Button.UP);
						checkGamepadButton(pad, 13, Button.DOWN);
						checkGamepadButton(pad, 14, Button.LEFT);
						checkGamepadButton(pad, 15, Button.RIGHT);
						
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

				Configuration.screen().render(frame);
				if (Sys.gl != null) {
					// Clear alpha for IE11
					Sys.gl.clearColor(1, 1, 1, 1);
					Sys.gl.colorMask(false, false, false, true);
					Sys.gl.clear(Sys.gl.COLOR_BUFFER_BIT);
					Sys.gl.colorMask(true, true, true, true);
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
		untyped __js__('if(canvas.onwheel !== undefined)
			canvas.onwheel = kha_Starter.mouseWheel;
		else if(canvas.onmousewheel  !== undefined)
			canvas.onmousewheel = kha_Starter.mouseWheel');
		canvas.addEventListener("wheel mousewheel", mouseWheel, false);
		canvas.addEventListener("touchstart", touchDown, false);
		canvas.addEventListener("touchend", touchUp, false);
		canvas.addEventListener("touchmove", touchMove, false);
		
		Browser.window.addEventListener("unload", unload);

		Configuration.setScreen(gameToStart);
		
		gameToStart.loadFinished();
	}

	public static function lockMouse(): Void {
		untyped if (Sys.khanvas.requestPointerLock) {
        	Sys.khanvas.requestPointerLock();
        }
		else if (canvas.mozRequestPointerLock) {
        	Sys.khanvas.mozRequestPointerLock();
        }
		else if (canvas.webkitRequestPointerLock) {
        	Sys.khanvas.webkitRequestPointerLock();
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
		Game.the.onPause();
		Game.the.onBackground();
		Game.the.onShutdown();
	}
	
	private static function setMouseXY(event: MouseEvent): Void {
		var rect = Sys.khanvas.getBoundingClientRect();
		var borderWidth = Sys.khanvas.clientLeft;
		var borderHeight = Sys.khanvas.clientTop;
		mouseX = Std.int((event.clientX - rect.left - borderWidth) * Sys.khanvas.width / (rect.width - 2 * borderWidth));
		mouseY = Std.int((event.clientY - rect.top - borderHeight) * Sys.khanvas.height / (rect.height - 2 * borderHeight));
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
				Game.the.rightMouseDown(mouseX, mouseY);
				mouse.sendDownEvent(1, mouseX, mouseY);
			}
			else {
				leftMouseCtrlDown = false;
				Game.the.mouseDown(mouseX, mouseY);
				mouse.sendDownEvent(0, mouseX, mouseY);
			}
		}
		else if(event.which == 2){ //middle button
			Game.the.middleMouseDown(mouseX, mouseY);
			mouse.sendDownEvent(2, mouseX, mouseY);
		}
		else if(event.which == 3){ //right button
			Game.the.rightMouseDown(mouseX, mouseY);
			mouse.sendDownEvent(1, mouseX, mouseY);
		}
	}
	
	private static function mouseUp(event: MouseEvent): Void {
		Browser.document.removeEventListener('mouseup', mouseUp);
		setMouseXY(event);
		if (event.which == 1) { //left button
			if (leftMouseCtrlDown) {
				Game.the.rightMouseUp(mouseX, mouseY);
				mouse.sendUpEvent(1, mouseX, mouseY);
			}
			else {
				Game.the.mouseUp(mouseX, mouseY);
				mouse.sendUpEvent(0, mouseX, mouseY);
			}
			leftMouseCtrlDown = false;
		}
		else if(event.which == 2){ //middle button
			Game.the.middleMouseUp(mouseX, mouseY);
			mouse.sendUpEvent(2, mouseX, mouseY);
		}
		else if(event.which == 3){ //right button
			Game.the.rightMouseUp(mouseX, mouseY);
			mouse.sendUpEvent(1, mouseX, mouseY);
		}
	}
	
	private static function mouseMove(event: MouseEvent): Void {
		var lastMouseX = mouseX;
		var lastMouseY = mouseY;
		setMouseXY(event);
		var movementX = untyped event.movementX || event.mozMovementX || event.webkitMovementX || mouseX - lastMouseX;
		var movementY = untyped event.movementY || event.mozMovementY || event.webkitMovementY || mouseY - lastMouseY;
		Game.the.mouseMove(mouseX, mouseY);
		mouse.sendMoveEvent(mouseX, mouseY, movementX, movementY);
	}
	
	private static function setTouchXY(touch: Touch): Void {
		var rect = Sys.khanvas.getBoundingClientRect();
		var borderWidth = Sys.khanvas.clientLeft;
		var borderHeight = Sys.khanvas.clientTop;
		touchX = Std.int((touch.clientX - rect.left - borderWidth) * Sys.khanvas.width / (rect.width - 2 * borderWidth));
		touchY = Std.int((touch.clientY - rect.top - borderHeight) * Sys.khanvas.height / (rect.height - 2 * borderHeight));
	}
	
	private static function touchDown(event: TouchEvent): Void {
		for (touch in event.changedTouches)	{
			setTouchXY(touch);
			Game.the.mouseDown(touchX, touchY);
			mouse.sendDownEvent(0, touchX, touchY);
			surface.sendTouchStartEvent(touch.identifier, touchX, touchY);
		}
	}
	
	private static function touchUp(event: TouchEvent): Void {
		for (touch in event.changedTouches)	{
			setTouchXY(touch);
			Game.the.mouseUp(touchX, touchY);
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
				
				Game.the.mouseMove(touchX, touchY);
				mouse.sendMoveEvent(touchX, touchY, movementX, movementY);
			}
			
			surface.sendMoveEvent(touch.identifier, touchX, touchY);
			index++;
		}
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
			Game.the.keyDown(Key.BACKSPACE, "");
			keyboard.sendDownEvent(Key.BACKSPACE, "");
			event.preventDefault();
		case 9:
			Game.the.keyDown(Key.TAB, "");
			keyboard.sendDownEvent(Key.TAB, "");
			event.preventDefault();
		case 13:
			Game.the.keyDown(Key.ENTER, "");
			keyboard.sendDownEvent(Key.ENTER, "");
			event.preventDefault();
		case 16:
			Game.the.keyDown(Key.SHIFT, "");
			keyboard.sendDownEvent(Key.SHIFT, "");
			event.preventDefault();
		case 17:
			Game.the.keyDown(Key.CTRL, "");
			keyboard.sendDownEvent(Key.CTRL, "");
			event.preventDefault();
		case 18:
			Game.the.keyDown(Key.ALT, "");
			keyboard.sendDownEvent(Key.ALT, "");
			event.preventDefault();
		case 27:
			Game.the.keyDown(Key.ESC, "");
			keyboard.sendDownEvent(Key.ESC, "");
			event.preventDefault();
		case 32:
			Game.the.keyDown(Key.CHAR, " ");
			keyboard.sendDownEvent(Key.CHAR, " ");
			event.preventDefault(); // don't scroll down in IE
		case 46:
			Game.the.keyDown(Key.DEL, "");
			keyboard.sendDownEvent(Key.DEL, "");
			event.preventDefault();
		case 38:
			Game.the.buttonDown(Button.UP);
			keyboard.sendDownEvent(Key.UP, "");
			event.preventDefault();
		case 40:
			Game.the.buttonDown(Button.DOWN);
			keyboard.sendDownEvent(Key.DOWN, "");
			event.preventDefault();
		case 37:
			Game.the.buttonDown(Button.LEFT);
			keyboard.sendDownEvent(Key.LEFT, "");
			event.preventDefault();
		case 39:
			Game.the.buttonDown(Button.RIGHT);
			keyboard.sendDownEvent(Key.RIGHT, "");
			event.preventDefault();
		default:
			if (!event.altKey) {
				var char = keycodeToChar(event.key, event.keyCode, event.shiftKey);
				Game.the.keyDown(Key.CHAR, char);
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
			Game.the.keyUp(Key.BACKSPACE, "");
			keyboard.sendUpEvent(Key.BACKSPACE, "");
		case 9:
			Game.the.keyUp(Key.TAB, "");
			keyboard.sendUpEvent(Key.TAB, "");
		case 13:
			Game.the.keyUp(Key.ENTER, "");
			keyboard.sendUpEvent(Key.ENTER, "");
		case 16:
			Game.the.keyUp(Key.SHIFT, "");
			keyboard.sendUpEvent(Key.SHIFT, "");
		case 17:
			Game.the.keyUp(Key.CTRL, "");
			keyboard.sendUpEvent(Key.CTRL, "");
		case 18:
			Game.the.keyUp(Key.ALT, "");
			keyboard.sendUpEvent(Key.ALT, "");
		case 27:
			Game.the.keyUp(Key.ESC, "");
			keyboard.sendUpEvent(Key.ESC, "");
		case 32:
			Game.the.keyUp(Key.CHAR, " ");
			keyboard.sendUpEvent(Key.CHAR, " ");
		case 46:
			Game.the.keyUp(Key.DEL, "");
			keyboard.sendUpEvent(Key.DEL, "");
		case 38:
			Game.the.buttonUp(Button.UP);
			keyboard.sendUpEvent(Key.UP, "");
		case 40:
			Game.the.buttonUp(Button.DOWN);
			keyboard.sendUpEvent(Key.DOWN, "");
		case 37:
			Game.the.buttonUp(Button.LEFT);
			keyboard.sendUpEvent(Key.LEFT, "");
		case 39:
			Game.the.buttonUp(Button.RIGHT);
			keyboard.sendUpEvent(Key.RIGHT, "");
		default:
			if (!event.altKey) {
				var char = keycodeToChar(event.key, event.keyCode, event.shiftKey);
				Game.the.keyUp(Key.CHAR, char);
				keyboard.sendUpEvent(Key.CHAR, char);
			}
		}
	}
}

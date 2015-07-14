package kha;

import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.CanvasElement;
import js.html.Document;
import js.html.Event;
import js.html.EventListener;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
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
	private var gameToStart: Game;
	private static var frame: Framebuffer;
	private static var pressedKeys: Array<Bool>;
	private static var buttonspressed: Array<Bool>;
	private static var leftMouseCtrlDown: Bool = false;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var surface: Surface;
	private static var gamepad: Gamepad;
	private static var gamepadStates: Array<GamepadStates>;
	
	private static var mouseX: Int;
	private static var mouseY: Int;
	private static var touchX: Int;
	private static var touchY: Int;
	
	public function new(?backbufferFormat: TextureFormat) {
		haxe.Log.trace = untyped js.Boot.__trace; // Hack for JS trace problems
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		surface = new Surface();
		gamepad = new Gamepad();
		gamepadStates = new Array<GamepadStates>();
		gamepadStates.push(new GamepadStates());
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
				if (gamepadStates[0].axes[i] != pad.axes[i]) {
					gamepadStates[0].axes[i] = pad.axes[i];
					gamepad.sendAxisEvent(i, pad.axes[i]);
				}
			}
		}
		for (i in 0...pad.buttons.length) {
			if (pad.buttons[i] != null) {
				if (gamepadStates[0].buttons[i] != pad.buttons[i].value) {
					gamepadStates[0].buttons[i] = pad.buttons[i].value;
					gamepad.sendButtonEvent(i, pad.buttons[i].value);
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
		
		var canvas: Dynamic = Browser.document.getElementById("khanvas");
		
		gameToStart.width = Loader.the.width;
		gameToStart.height = Loader.the.height;
		
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
			var g4 = gl ? new kha.js.graphics4.Graphics(true) : null;
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
			
			var gamepads: Dynamic = untyped __js__("navigator.getGamepads && navigator.getGamepads()");
			if (gamepads == null) gamepads = untyped __js__("navigator.webkitGetGamepads && navigator.webkitGetGamepads()");
			if (gamepads != null) {
				for (i in 0...gamepads.length) {
					var pad = gamepads[i];
					if (pad != null) {
						checkGamepadButton(pad, 0, Button.BUTTON_1);
						checkGamepadButton(pad, 1, Button.BUTTON_2);
						checkGamepadButton(pad, 12, Button.UP);
						checkGamepadButton(pad, 13, Button.DOWN);
						checkGamepadButton(pad, 14, Button.LEFT);
						checkGamepadButton(pad, 15, Button.RIGHT);
						
						if (pad.index == 0) {
							checkGamepad(pad);
						}
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
		canvas.addEventListener("touchstart", touchDown, false);
		canvas.addEventListener("touchend", touchUp, false);
		canvas.addEventListener("touchmove", touchMove, false);
		
		Browser.window.addEventListener("unload", unload);

		Configuration.setScreen(gameToStart);
		
		gameToStart.loadFinished();
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
	
	private static function mouseDown(event: MouseEvent): Void {
		Browser.document.addEventListener('mouseup', mouseUp);
		setMouseXY(event);
		if (event.button == 0) {
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
		else {
			Game.the.rightMouseDown(mouseX, mouseY);
			mouse.sendDownEvent(1, mouseX, mouseY);
		}
	}
	
	private static function mouseUp(event: MouseEvent): Void {
		Browser.document.removeEventListener('mouseup', mouseUp);
		setMouseXY(event);
		if (event.button == 0) {
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
		else {
			Game.the.rightMouseUp(mouseX, mouseY);
			mouse.sendUpEvent(1, mouseX, mouseY);
		}
	}
	
	private static function mouseMove(event: MouseEvent): Void {
		setMouseXY(event);
		Game.the.mouseMove(mouseX, mouseY);
		mouse.sendMoveEvent(mouseX, mouseY);
	}
	
	private static function setTouchXY(event: TouchEvent): Void {
		var rect = Sys.khanvas.getBoundingClientRect();
		var borderWidth = Sys.khanvas.clientLeft;
		var borderHeight = Sys.khanvas.clientTop;
		touchX = Std.int((event.touches[0].clientX - rect.left - borderWidth) * Sys.khanvas.width / (rect.width - 2 * borderWidth));
		touchY = Std.int((event.touches[0].clientY - rect.top - borderHeight) * Sys.khanvas.height / (rect.height - 2 * borderHeight));
	}
	
	private static function touchDown(event: TouchEvent): Void {
		setTouchXY(event);
		Game.the.mouseDown(touchX, touchY);
		mouse.sendDownEvent(0, touchX, touchY);
		surface.sendTouchStartEvent(0, touchX, touchY);
	}
	
	private static function touchUp(event: TouchEvent): Void {
		setTouchXY(event);
		Game.the.mouseUp(touchX, touchY);
		mouse.sendUpEvent(0, touchX, touchY);
		surface.sendTouchEndEvent(0, touchX, touchY);
	}
	
	private static function touchMove(event: TouchEvent): Void {
		setTouchXY(event);
		Game.the.mouseMove(touchX, touchY);
		mouse.sendMoveEvent(touchX, touchY);
		surface.sendMoveEvent(0, touchX, touchY);
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

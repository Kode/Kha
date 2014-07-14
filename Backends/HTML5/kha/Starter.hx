package kha;

import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.CanvasElement;
import js.html.Document;
import js.html.Event;
import js.html.EventListener;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import kha.Game;
import kha.input.Gamepad;
import kha.input.Keyboard;
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
	private static var game: Game;
	private static var painter: Painter;
	private static var frame: Framebuffer;
	private static var pressedKeys: Array<Bool>;
	private static var lastPressedKey: Int;
	private static var pressedKeyToChar: Array<String>;
	private static var buttonspressed: Array<Bool>;
	private static var leftMouseCtrlDown: Bool = false;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	private static var gamepadStates: Array<GamepadStates>;
	
	@:allow(kha.Scheduler) static var mouseX: Int;
	@:allow(kha.Scheduler) static var mouseY: Int;
	
	public function new() {
		haxe.Log.trace = untyped js.Boot.__trace; // Hack for JS trace problems
		
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();
		gamepadStates = new Array<GamepadStates>();
		gamepadStates.push(new GamepadStates());
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		lastPressedKey = null;
		pressedKeyToChar = new Array<String>();
		for (i in 0...256) pressedKeys.push(null);
		buttonspressed = new Array<Bool>();
		for (i in 0...10) buttonspressed.push(false);
		kha.js.Image.init();
		Loader.init(new kha.js.Loader());
		Scheduler.init();
		
		// TODO: Move?
		EnvironmentVariables.instance = new kha.js.EnvironmentVariables();
	}
	
	private function checkGamepadButton(pad: Dynamic, num: Int, button: kha.Button) {
		if (buttonspressed[num]) {
			if (pad.buttons[num] < 0.5) {
				game.buttonUp(button);
				buttonspressed[num] = false;
			}
		}
		else {
			if (pad.buttons[num] > 0.5) {
				game.buttonDown(button);
				buttonspressed[num] = true;
			}
		}
	}
	
	private function checkGamepad(pad: Dynamic) {
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
		Starter.game = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public function loadFinished() {
		Loader.the.initProject();
		
		var canvas: Dynamic = Browser.document.getElementById("khanvas");
		
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		
		/*try {
			Sys.gl = canvas.getContext("experimental-webgl", { alpha: false });
			if (Sys.gl != null) {
				//Sys.gl.scale(transform, transform);
				Sys.gl.pixelStorei(Sys.gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
				Sys.init(true);
				painter = new kha.js.ShaderPainter(game.width, game.height);
			}
		}
		catch (e: Dynamic) {
			trace(e);
		}*/
		if (painter == null) {
			Sys.init(false);
			var widthTransform: Float = canvas.width / Loader.the.width;
			var heightTransform: Float = canvas.height / Loader.the.height;
			var transform: Float = Math.min(widthTransform, heightTransform);
			painter = new kha.js.Painter(canvas.getContext("2d"), Math.round(Loader.the.width * transform), Math.round(Loader.the.height * transform));
		}
		
		{
			var widthTransform: Float = canvas.width / Loader.the.width;
			var heightTransform: Float = canvas.height / Loader.the.height;
			var transform: Float = Math.min(widthTransform, heightTransform);
			frame = new Framebuffer();
			frame.g2 = new CanvasGraphics(canvas.getContext("2d"), Math.round(Loader.the.width * transform), Math.round(Loader.the.height * transform));
			canvas.getContext("2d").scale(transform, transform);
		}
		
		try {
			Sys.audio = null;
			Sys.audio = untyped __js__("new AudioContext()");
		}
		catch (e: Dynamic) {
			
		}
		if (Sys.audio == null) {
			try {
				Sys.audio = untyped __js__("new webkitAudioContext()");
			}
			catch (e: Dynamic) {
				
			}
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

		function mouseUp(event: MouseEvent): Void {
			Browser.document.removeEventListener('mouseup', mouseUp);
			checkMouseShift(event);
			//trace ( 'mouse (${event.button}) UP' );
			var x = Std.int(event.pageX - canvas.offsetLeft);
			var y = Std.int(event.pageY - canvas.offsetTop);
			mouseX = x;
			mouseY = y;
			if (event.button == 0) {
				if (leftMouseCtrlDown) {
					game.rightMouseUp(x, y);
					mouse.sendUpEvent(1, x, y);
				}
				else {
					game.mouseUp(x, y);
					mouse.sendUpEvent(0, x, y);
				}
				leftMouseCtrlDown = false;
			}
			else {
				game.rightMouseUp(x, y);
				mouse.sendUpEvent(1, x, y);
			}
		}

		//Lib.document.onmousedown = function(event : js.Event) {
		canvas.onmousedown = function(event: MouseEvent) {
			Browser.document.addEventListener('mouseup', mouseUp);
			checkMouseShift(event);
			//trace ( 'mouse (${event.button}) DOWN' );
			var x = Std.int(event.pageX - canvas.offsetLeft);
			var y = Std.int(event.pageY - canvas.offsetTop);
			mouseX = x;
			mouseY = y;
			if (event.button == 0) {
				if (event.ctrlKey) {
					leftMouseCtrlDown = true;
					game.rightMouseDown(x, y);
					mouse.sendDownEvent(1, x, y);
				}
				else {
					leftMouseCtrlDown = false;
					game.mouseDown(x, y);
					mouse.sendDownEvent(0, x, y);
				}
			}
			else {
				game.rightMouseDown(x, y);
				mouse.sendDownEvent(1, x, y);
			}
		}
		
		//Lib.document.onmousemove = function(event : js.Event) {
		canvas.onmousemove = function(event : MouseEvent) {
			checkMouseShift(event);
			var x = Std.int(event.pageX - canvas.offsetLeft);
			var y = Std.int(event.pageY - canvas.offsetTop);
			mouseX = x;
			mouseY = y;
			game.mouseMove(x, y);
			mouse.sendMoveEvent(x, y);
		}

		//Lib.document.onkeydown = function(event : js.Event) {
		canvas.onkeydown = keyDown;
		
		//Lib.document.onkeypress = keyPress;
		canvas.onkeypress = keyPress;
		
		//Lib.document.onkeyup = keyUp;
		canvas.onkeyup = keyUp;
		
		Browser.window.onunload = function(event: Dynamic) {
			game.onClose();
		}

		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		
		game.loadFinished();
	}
	
	static function checkMouseShift(event: MouseEvent) {
		if (event.shiftKey && !pressedKeys[16]) {
			//trace ("SHIFT DOWN (mouse event)");
			pressedKeys[16] = true;
			game.keyDown(Key.SHIFT, "");
		} else if (pressedKeys[16] && !event.shiftKey) {
			//trace ("SHIFT UP (mouse event)");
			pressedKeys[16] = false;
			game.keyUp(Key.SHIFT, "");
		}
	}
	
	static function checkKeyShift(event: Dynamic) {
		if (event.shiftKey && !pressedKeys[16]) {
			//trace ("SHIFT DOWN (key event)");
			pressedKeys[16] = true;
			game.keyDown(Key.SHIFT, "");
		} else if (pressedKeys[16] && event.keyCode != 16 && !event.shiftKey) {
			//trace ("SHIFT UP (key event)");
			pressedKeys[16] = false;
			game.keyUp(Key.SHIFT, "");
		}
	}
	
	static function keyDown(event: KeyboardEvent) {
		//trace ("keyDown(keyCode: " + event.keyCode + "; charCode: " + event.charCode + "; char: '" + event.char + "'; key: '" + event.key + "')");
		
		event.stopPropagation();
		
		if (pressedKeys[event.keyCode]) {
			lastPressedKey = 0;
			event.preventDefault();
			return;
		}
		lastPressedKey = event.keyCode;
		pressedKeys[event.keyCode] = true;
		switch (lastPressedKey) {
		case 8:
			game.keyDown(Key.BACKSPACE, "");
			keyboard.sendDownEvent(Key.BACKSPACE, "");
			event.preventDefault();
		case 9:
			game.keyDown(Key.TAB, "");
			keyboard.sendDownEvent(Key.TAB, "");
			event.preventDefault();
		case 13:
			game.keyDown(Key.ENTER, "");
			keyboard.sendDownEvent(Key.ENTER, "");
			event.preventDefault();
		case 16:
			game.keyDown(Key.SHIFT, "");
			keyboard.sendDownEvent(Key.SHIFT, "");
			//trace ("SHIFT DOWN (keyDown)");
			event.preventDefault();
		case 17:
			game.keyDown(Key.CTRL, "");
			keyboard.sendDownEvent(Key.CTRL, "");
			event.preventDefault();
		case 18:
			game.keyDown(Key.ALT, "");
			keyboard.sendDownEvent(Key.ALT, "");
			event.preventDefault();
		case 27:
			game.keyDown(Key.ESC, "");
			keyboard.sendDownEvent(Key.ESC, "");
			event.preventDefault();
		case 32:
			game.keyDown(Key.CHAR, " ");
			keyboard.sendDownEvent(Key.CHAR, " ");
			lastPressedKey = 0;
			event.preventDefault(); // don't scroll down in IE
		case 46:
			game.keyDown(Key.DEL, "");
			keyboard.sendDownEvent(Key.DEL, "");
			event.preventDefault();
		case 38:
			game.buttonDown(Button.UP);
			keyboard.sendDownEvent(Key.UP, "");
			event.preventDefault();
		case 40:
			game.buttonDown(Button.DOWN);
			keyboard.sendDownEvent(Key.DOWN, "");
			event.preventDefault();
		case 37:
			game.buttonDown(Button.LEFT);
			keyboard.sendDownEvent(Key.LEFT, "");
			event.preventDefault();
		case 39:
			game.buttonDown(Button.RIGHT);
			keyboard.sendDownEvent(Key.RIGHT, "");
			event.preventDefault();
		default:
			if (!event.altKey) {
				var char = String.fromCharCode(lastPressedKey);
				if (lastPressedKey >= 96 && lastPressedKey <= 105) { // num block seems to return special key codes
					char = String.fromCharCode('0'.code - 96 + lastPressedKey);
				}
				if (lastPressedKey >= 'A'.code && lastPressedKey <= 'Z'.code) {
					if (event.shiftKey) char = String.fromCharCode(lastPressedKey);
					else char = String.fromCharCode(lastPressedKey - 'A'.code + 'a'.code);
				}
				pressedKeyToChar[lastPressedKey] = char;
				//trace ('"$char" DOWN');
				game.keyDown(Key.CHAR, char);
				keyboard.sendDownEvent(Key.CHAR, char);
				lastPressedKey = 0;
			}
		}
	}
	
	static function keyPress(event: Dynamic) {
		//trace ("keyPress(keyCode: " + event.keyCode + "; charCode: " + event.charCode + "; char: '" + event.char + "'; key: '" + event.key + "')");
		
		event.preventDefault();
		event.stopPropagation();
		
		// Determine the keycode crossplatform is a bit tricky.
		// Situation will be better when Gecko implements key and char: https://developer.mozilla.org/en-US/docs/DOM/KeyboardEvent
		// We saved the keycode in keyDown() and map pressed char to that code.
		// In keyUp() we can then get the char from keycode again.
		if (lastPressedKey == 0) return;
		
		if (event.keyCode == 0) {
			// current Gecko
			var char = String.fromCharCode(event.charCode);
			
			checkKeyShift(event);
			
			game.keyDown(Key.CHAR, char);
			keyboard.sendDownEvent(Key.CHAR, char);
			//trace ('"$char" DOWN');
			pressedKeyToChar[lastPressedKey] = char;
			
		}
		// DOM3
		else if (event.char != null) { // IE
			if (event.char != "") { // Gecko (planned)
				game.keyDown(Key.CHAR, event.char);
				keyboard.sendDownEvent(Key.CHAR, event.char);
				//trace ('"${event.char}" DOWN');
				pressedKeyToChar[lastPressedKey] = event.char;
			}
		}
		
		lastPressedKey = 0;
	}
	
	static function keyUp(event: KeyboardEvent) {
		//trace ("keyUp(keyCode: " + event.keyCode + "; charCode: " + event.charCode + "; char: '" + event.char + "'; key: '" + event.key + "')");
		
		event.preventDefault();
		event.stopPropagation();
		
		checkKeyShift(event);
		
		pressedKeys[event.keyCode] = false;
		
		switch (event.keyCode) {
		case 8:
			game.keyUp(Key.BACKSPACE, "");
			keyboard.sendUpEvent(Key.BACKSPACE, "");
		case 9:
			game.keyUp(Key.TAB, "");
			keyboard.sendUpEvent(Key.TAB, "");
		case 13:
			game.keyUp(Key.ENTER, "");
			keyboard.sendUpEvent(Key.ENTER, "");
		case 16:
			game.keyUp(Key.SHIFT, "");
			keyboard.sendUpEvent(Key.SHIFT, "");
			//trace ("SHIFT UP (keyUp)");
		case 17:
			game.keyUp(Key.CTRL, "");
			keyboard.sendUpEvent(Key.CTRL, "");
		case 18:
			game.keyUp(Key.ALT, "");
			keyboard.sendUpEvent(Key.ALT, "");
		case 27:
			game.keyUp(Key.ESC, "");
			keyboard.sendUpEvent(Key.ESC, "");
		case 32:
			game.keyUp(Key.CHAR, " ");
			keyboard.sendUpEvent(Key.CHAR, " ");
		case 46:
			game.keyUp(Key.DEL, "");
			keyboard.sendUpEvent(Key.DEL, "");
		case 38:
			game.buttonUp(Button.UP);
			keyboard.sendUpEvent(Key.UP, "");
		case 40:
			game.buttonUp(Button.DOWN);
			keyboard.sendUpEvent(Key.DOWN, "");
		case 37:
			game.buttonUp(Button.LEFT);
			keyboard.sendUpEvent(Key.LEFT, "");
		case 39:
			game.buttonUp(Button.RIGHT);
			keyboard.sendUpEvent(Key.RIGHT, "");
		}
		
		if (pressedKeyToChar[event.keyCode] != null) {
			game.keyUp(Key.CHAR, pressedKeyToChar[event.keyCode]);
			keyboard.sendUpEvent(Key.CHAR, pressedKeyToChar[event.keyCode]);
			//trace ('"${pressedKeyToChar[event.keyCode]}" UP');
			pressedKeyToChar[event.keyCode] = null;
		}
	}
	
	// TODO: Check if this function would have to do something else
	// TODO: Implement on all platforms
	public static function quit() {
		// TODO: This will only work if the window has been opened by javascript in the first place.
		var window: DOMWindow = Browser.window;
		window.close();		
	}
}

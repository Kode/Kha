package kha;

import kha.js.PainterGL;
import kha.Game;
import kha.Key;
import kha.Loader;
import js.Lib;
import js.Dom;

class Starter {
	static var game : Game;
	static var painter : Painter;
	static var pressedKeys : Array<Bool>;
	static var lastPressedKey : Int;
	static var pressedKeyToChar : Array<String>;
	static var buttonspressed : Array<Bool>;
	
	public function new() {
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		lastPressedKey = null;
		pressedKeyToChar = new Array<String>();
		for (i in 0...256) pressedKeys.push(null);
		buttonspressed = new Array<Bool>();
		for (i in 0...10) buttonspressed.push(false);
		kha.js.Image.init();
		Loader.init(new kha.js.Loader());
		Storage.init(new Storage());
	}
	
	function checkGamepadButton(pad : Dynamic, num : Int, button : kha.Button) {
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
	
	public function start(game: Game): Void {
		Starter.game = game;
		
		var canvas : Dynamic = Lib.document.getElementById("haxvas");
		
		try {
			//if (canvas.getContext("experimental-webgl") != null) painter = new PainterGL(canvas.getContext("experimental-webgl"), game.getWidth(), game.getHeight());
		}
		catch (e : Dynamic) {
			trace(e);
		}
		if (painter == null) painter = new kha.js.Painter(canvas.getContext("2d"), game.width, game.height);
		
		var window : Dynamic = Lib.window;
		var requestAnimationFrame = window.requestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.mozRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.webkitRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.msRequestAnimationFrame;
		
		function animate(timestamp) {
			var window : Dynamic = Lib.window;
			if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
			else requestAnimationFrame(animate);
			
			var gamepads : Dynamic = untyped __js__("navigator.gamepads");
			if (gamepads == null) gamepads = untyped __js__("navigator.webkitGamepads");
			if (gamepads == null) gamepads = untyped __js__("navigator.mozGamepads");
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
					}
				}
			}
			
			Configuration.screen().update();
			
			if (canvas.getContext) {
				painter.begin();
				Configuration.screen().render(painter);
				painter.end();
			}
		}
		
		if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
		else requestAnimationFrame(animate);
	
		if (Loader.the.width > 0 && Loader.the.height > 0) {
			game.width = Loader.the.width;
			game.height = Loader.the.height;
		}
		Configuration.setScreen(new EmptyScreen(new Color(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public static function loadFinished() {
		if (Loader.the.width > 0 && Loader.the.height > 0) {
			game.width = Loader.the.width;
			game.height = Loader.the.height;
		}
		Loader.the.initProject();
		
		var canvas : Dynamic = Lib.document.getElementById("haxvas");
		
		Lib.document.onmousedown = function(event : js.Event) {
			game.mouseDown(Std.int(event.clientX - canvas.offsetLeft), Std.int(event.clientY - canvas.offsetTop));
		}
		
		Lib.document.onmouseup = function(event : js.Event) {
			game.mouseUp(Std.int(event.clientX - canvas.offsetLeft), Std.int(event.clientY - canvas.offsetTop));
		}
		
		Lib.document.onmousemove = function(event : js.Event) {
			game.mouseMove(Std.int(event.clientX - canvas.offsetLeft), Std.int(event.clientY - canvas.offsetTop));
		}

		Lib.document.onkeydown = function(event : js.Event) {
			keyDown(cast event);
		};
		
		Lib.document.onkeypress = function(event : js.Event) {
			keyPress(cast event);
		}
		
		Lib.document.onkeyup = function(event : js.Event) {
			keyUp(cast event);
		};
		
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
	}
	
	static function keyDown(event : { > js.Event, char : String, key : String, charCode : Null<Int>}) {
		trace ("keyDown(keyCode: " + event.keyCode + "; charCode: " + event.charCode + "; char: '" + event.char + "'; key: '"+event.key+"')");
		if (pressedKeys[event.keyCode]) {
			lastPressedKey = 0;
			return;
		}
		lastPressedKey = event.keyCode;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 8:
			game.keyDown(Key.BACKSPACE, "");
		case 9:
			game.keyDown(Key.TAB, "");
		case 13:
			game.keyDown(Key.ENTER, "");
		case 16:
			game.keyDown(Key.SHIFT, "");
		case 17:
			game.keyDown(Key.CTRL, "");
		case 18:
			game.keyDown(Key.ALT, "");
		case 27:
			game.keyDown(Key.ESC, "");
		case 46:
			game.keyDown(Key.DEL, "");
		case 38:
			game.buttonDown(Button.UP);
		case 40:
			game.buttonDown(Button.DOWN);
		case 37:
			game.buttonDown(Button.LEFT);
		case 39:
			game.buttonDown(Button.RIGHT);
		case 65:
			game.buttonDown(Button.BUTTON_1);
		case 83:
			game.buttonDown(Button.BUTTON_2);
		}
	}
	
	static function keyPress(event : { > js.Event, charCode : Int, char : String, key : String } ) {
		trace ("keyPress(keyCode: " + event.keyCode + "; charCode: " + event.charCode + "; char: '" + event.char + "'; key: '" + event.key + "')");
		// we cannot determine the keycode crossplatform yet. Situation will be better when Gecko implements key and char:
		// https://developer.mozilla.org/en-US/docs/DOM/KeyboardEvent
		if (lastPressedKey == 0) return;
		lastPressedKey = 0;
		
		if (event.keyCode == 0) {
			// current Gecko
			var char = String.fromCharCode(event.charCode);
			game.keyDown(Key.CHAR, char);
			pressedKeyToChar[lastPressedKey] = char;
			
		}
		// DOM3
		else if (event.char != null) { // IE
			if (event.char != "") { // Gecko (planned)
				game.keyDown(Key.CHAR, event.char);
				pressedKeyToChar[lastPressedKey] = event.char;
			}
		}
	}
	
	static function keyUp(event : { > js.Event, charCode : Int, char : String, key : String }) {
		trace ("keyUp(keyCode: " + event.keyCode + "; charCode: " + event.charCode + "; char: '" + event.char + "'; key: '"+event.key+"')");
		pressedKeys[event.keyCode] = false;
		
		switch (event.keyCode) {
		case 8:
			game.keyUp(Key.BACKSPACE, "");
		case 9:
			game.keyUp(Key.TAB, "");
		case 13:
			game.keyUp(Key.ENTER, "");
		case 17:
			game.keyUp(Key.CTRL, "");
		case 18:
			game.keyUp(Key.ALT, "");
		case 27:
			game.keyUp(Key.ESC, "");
		case 46:
			game.keyUp(Key.DEL, "");
		case 38:
			game.buttonUp(Button.UP);
		case 40:
			game.buttonUp(Button.DOWN);
		case 37:
			game.buttonUp(Button.LEFT);
		case 39:
			game.buttonUp(Button.RIGHT);
		case 65:
			game.buttonUp(Button.BUTTON_1); // This is also an 'a'
		case 83:
			game.buttonUp(Button.BUTTON_2); // This is also an 's'
		}
		
		if (pressedKeyToChar[event.keyCode] != null) {
			// Key.Char
			game.keyUp(Key.CHAR, pressedKeyToChar[event.keyCode]);
			pressedKeyToChar[event.keyCode] = null;
		}
	}
}
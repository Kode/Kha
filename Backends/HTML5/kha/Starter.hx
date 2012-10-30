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
	static var keyreleased : Array<Bool>;
	static var buttonspressed : Array<Bool>;
	
	public function new() {
		keyreleased = new Array<Bool>();
		for (i in 0...256) keyreleased.push(true);
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
			pressKey(event.keyCode);
		};
		
		Lib.document.onkeyup = function(event : js.Event) {
			releaseKey(event.keyCode);
		};
		
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
	}
	
	static function pressKey(keycode : Int) {
		if (keyreleased[keycode]) { //avoid auto-repeat
			keyreleased[keycode] = false;
			switch (keycode) {
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
			if (keycode >= 48 && keycode <= 90) game.keyDown(Key.CHAR, String.fromCharCode(keycode));
			else {
				switch (keycode) {
				case 8:
					game.keyDown(Key.BACKSPACE, null);
				case 9:
					game.keyDown(Key.TAB, null);
				case 13:
					game.keyDown(Key.ENTER, null);
				case 16:
					game.keyDown(Key.SHIFT, null);
				case 17:
					game.keyDown(Key.CTRL, null);
				case 18:
					game.keyDown(Key.ALT, null);
				case 27:
					game.keyDown(Key.ESC, null);
				case 127:
					game.keyDown(Key.DEL, null);
				}
			}
		}
	}
	
	static function releaseKey(keycode : Int) {
		keyreleased[keycode] = true;
		switch (keycode) {
		case 38:
			game.buttonUp(Button.UP);
		case 40:
			game.buttonUp(Button.DOWN);
		case 37:
			game.buttonUp(Button.LEFT);
		case 39:
			game.buttonUp(Button.RIGHT);
		case 65:
			game.buttonUp(Button.BUTTON_1);
		case 83:
			game.buttonUp(Button.BUTTON_2);
		}
		if (keycode >= 48 && keycode <= 90) game.keyUp(Key.CHAR, String.fromCharCode(keycode));
		else {
			switch (keycode) {
			case 8:
				game.keyUp(Key.BACKSPACE, null);
			case 9:
				game.keyUp(Key.TAB, null);
			case 13:
				game.keyUp(Key.ENTER, null);
			case 16:
				game.keyUp(Key.SHIFT, null);
			case 17:
				game.keyUp(Key.CTRL, null);
			case 18:
				game.keyUp(Key.ALT, null);
			case 27:
				game.keyUp(Key.ESC, null);
			case 127:
				game.keyUp(Key.DEL, null);
			}
		}
	}
}
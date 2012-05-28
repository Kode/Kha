package kha;

import kha.js.PainterGL;
import kha.Game;
import kha.Key;
import kha.Loader;
import js.Lib;
import js.Dom;

class Starter {
	static var screen : Game;
	static var game : Game;
	static var painter : Painter;
	
	public function new() {
		kha.js.Image.init();
		Loader.init(new kha.js.Loader());
	}
	
	public function start(game : Game) : Void {
		Starter.game = game;
		screen = new LoadingScreen(game.getWidth(), game.getHeight());
		
		var canvas : Dynamic = Lib.document.getElementById("haxvas");
		
		try {
			//if (canvas.getContext("experimental-webgl") != null) painter = new PainterGL(canvas.getContext("experimental-webgl"), game.getWidth(), game.getHeight());
		}
		catch (e : Dynamic) {
			trace(e);
		}
		if (painter == null) painter = new kha.js.Painter(canvas.getContext("2d"), game.getWidth(), game.getHeight());
		
		var window : Dynamic = Lib.window;
		var requestAnimationFrame = window.requestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.mozRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.webkitRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.msRequestAnimationFrame;
		
		function animate(timestamp) {
			var window : Dynamic = Lib.window;
			if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
			else requestAnimationFrame(animate);			
			screen.update();
			
			if (canvas.getContext) {
				painter.begin();
				screen.render(painter);
				painter.end();
			}
		}
		
		if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
		else requestAnimationFrame(animate);
		
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
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
			switch (event.keyCode) {
			case 38:
				game.key(new kha.KeyEvent(Key.UP, true));
			case 40:
				game.key(new kha.KeyEvent(Key.DOWN, true));
			case 37:
				game.key(new kha.KeyEvent(Key.LEFT, true));
			case 39:
				game.key(new kha.KeyEvent(Key.RIGHT, true));
			case 65:
				game.key(new kha.KeyEvent(Key.BUTTON_1, true));
			case 83:
				game.key(new kha.KeyEvent(Key.BUTTON_2, true));
			default:
				game.charKey(String.fromCharCode(event.keyCode));
			}
		};
		Lib.document.onkeyup = function(event : js.Event) {
			switch (event.keyCode) {
			case 38:
				game.key(new kha.KeyEvent(Key.UP, false));
			case 40:
				game.key(new kha.KeyEvent(Key.DOWN, false));
			case 37:
				game.key(new kha.KeyEvent(Key.LEFT, false));
			case 39:
				game.key(new kha.KeyEvent(Key.RIGHT, false));
			case 65:
				game.key(new kha.KeyEvent(Key.BUTTON_1, false));
			case 83:
				game.key(new kha.KeyEvent(Key.BUTTON_2, false));
			}
		};
		
		game.loadFinished();
		screen = game;
	}
}
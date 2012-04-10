package com.ktxsoftware.kha;

import com.ktxsoftware.kha.backends.js.PainterGL;
import com.ktxsoftware.kha.Game;
import com.ktxsoftware.kha.Key;
import com.ktxsoftware.kha.Loader;
import js.Lib;
import js.Dom;

class Starter {
	static var game : Game;
	static var painter : Painter;
	
	public function new() {
		Loader.init(new com.ktxsoftware.kha.backends.js.Loader());
	}
	
	public function start(game : Game) : Void {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.init();
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
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.UP, true));
			case 40:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.DOWN, true));
			case 37:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.LEFT, true));
			case 39:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.RIGHT, true));
			case 65:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.BUTTON_1, true));
			case 83:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.BUTTON_2, true));
			}
		};
		Lib.document.onkeyup = function(event : js.Event) {
			switch (event.keyCode) {
			case 38:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.UP, false));
			case 40:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.DOWN, false));
			case 37:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.LEFT, false));
			case 39:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.RIGHT, false));
			case 65:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.BUTTON_1, false));
			case 83:
				game.key(new com.ktxsoftware.kha.KeyEvent(Key.BUTTON_2, false));
			}
		};
		
		if (canvas.getContext("experimental-webgl") != null) painter = new PainterGL(canvas.getContext("experimental-webgl"), 640, 512);
		else painter = new com.ktxsoftware.kha.backends.js.Painter(canvas.getContext("2d"));
		
		var window : Dynamic = Lib.window;
		var requestAnimationFrame = window.requestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.mozRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.webkitRequestAnimationFrame;
		if (requestAnimationFrame == null) requestAnimationFrame = window.msRequestAnimationFrame;
		
		function animate(timestamp) {
			var window : Dynamic = Lib.window;
			if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
			else requestAnimationFrame(animate);			
			game.update();
			
			if (canvas.getContext) {
				painter.begin();
				game.render(painter);
				painter.end();
			}
		}
		
		if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
		else requestAnimationFrame(animate);
	}
}
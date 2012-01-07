package com.ktxsoftware.kha;

import com.ktxsoftware.kha.Game;
import com.ktxsoftware.kha.Key;
import com.ktxsoftware.kha.Loader;

#if flash

import com.ktxsoftware.kha.backends.flash.Painter;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.display.MovieClip;
import flash.display.Sprite;

class Starter extends MovieClip {
	var game : Game;
	var painter : Painter;
	
	public function new() {
		super();
		Loader.init(new com.ktxsoftware.kha.backends.flash.Loader(this));
	}
	
	public function start(game : Game) {
		this.game = game;
		Loader.getInstance().load();
	}
	
	public function loadFinished() {
		game.init();
		painter = new Painter();
		Lib.current.addChild(this);
		stage.frameRate = 60;
		Lib.current.addEventListener(Event.ENTER_FRAME, draw);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	}

	function draw(e : Event) {
		//game.update();
		game.update();
		painter.setGraphics(graphics);
		painter.begin();
		game.render(painter);
		painter.end();
	}
	
	function keyDownHandler(event : KeyboardEvent) {
		switch (event.keyCode) {
		case 38:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.UP, true));
		case 40:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.DOWN, true));
		case 37:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.LEFT, true));
		case 39:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.RIGHT, true));
		}
	}

	function keyUpHandler(event : KeyboardEvent) {
		switch (event.keyCode) {
		case 38:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.UP, false));
		case 40:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.DOWN, false));
		case 37:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.LEFT, false));
		case 39:
			game.key(new com.ktxsoftware.kha.KeyEvent(Key.RIGHT, false));
		}
	}
}

#end

#if js

import js.Lib;
import js.Dom;

class Starter {
	static var game : Game;
	static var painter : com.ktxsoftware.kha.backends.js.Painter;
	
	public function new() {
		Loader.init(new com.ktxsoftware.kha.backends.js.Loader());
	}
	
	public function start(game : Game) : Void {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.init();
		painter = new com.ktxsoftware.kha.backends.js.Painter();

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
			}
		};
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
			var canvas : Dynamic = Lib.document.getElementById("haxvas");
			if (canvas.getContext) {
				canvas = canvas.getContext('2d');
				painter.setCanvas(canvas);
				painter.begin();
				game.render(painter);
				painter.end();
			}
		}
		
		if (requestAnimationFrame == null) window.setTimeout(animate, 1000.0 / 60.0);
		else requestAnimationFrame(animate);
	}
}

#end

#if cpp

class Main {
	static var game : Game;
	static var painter : com.ktxsoftware.kje.backend.cpp.Painter;
	
	static function main() {
		Loader.init(new com.ktxsoftware.kje.backend.cpp.Loader());
		game = new SuperMarioLand();
		Loader.getInstance().load();
	}
	
	public static function start() {
		game.init();
		painter = new com.ktxsoftware.kje.backend.cpp.Painter();
	}

	public static function frame() {
		game.update();
		painter.begin();
		game.render(painter);
		painter.end();
	}
	
	public static function pushUp() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.UP, true));
	}
	
	public static function pushDown() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.DOWN, true));
	}

	public static function pushLeft() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.LEFT, true));
	}

	public static function pushRight() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.RIGHT, true));
	}

	public static function releaseUp() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.UP, false));
	}

	public static function releaseDown() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.DOWN, false));
	}

	public static function releaseLeft() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.LEFT, false));
	}
	
	public static function releaseRight() : Void {
		game.key(new com.ktxsoftware.kje.KeyEvent(Key.RIGHT, false));
	}
}

#end
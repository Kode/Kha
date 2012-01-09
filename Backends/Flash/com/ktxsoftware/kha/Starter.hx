package com.ktxsoftware.kha;

import com.ktxsoftware.kha.Game;
import com.ktxsoftware.kha.Key;
import com.ktxsoftware.kha.Loader;
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
	var pressedKeys : Array<Bool>;
	
	public function new() {
		super();
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
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
		if (pressedKeys[event.keyCode]) return;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 38:
			game.key(new KeyEvent(Key.UP, true));
		case 40:
			game.key(new KeyEvent(Key.DOWN, true));
		case 37:
			game.key(new KeyEvent(Key.LEFT, true));
		case 39:
			game.key(new KeyEvent(Key.RIGHT, true));
		case 65:
			game.key(new KeyEvent(Key.BUTTON_1, true));
		}
	}

	function keyUpHandler(event : KeyboardEvent) {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 38:
			game.key(new KeyEvent(Key.UP, false));
		case 40:
			game.key(new KeyEvent(Key.DOWN, false));
		case 37:
			game.key(new KeyEvent(Key.LEFT, false));
		case 39:
			game.key(new KeyEvent(Key.RIGHT, false));
		case 65:
			game.key(new KeyEvent(Key.BUTTON_1, false));
		}
	}
}
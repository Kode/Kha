package com.ktxsoftware.kha;

import com.ktxsoftware.kha.Game;
import com.ktxsoftware.kha.Key;
import com.ktxsoftware.kha.Loader;

class Starter {
	static var game : Game;
	static var painter : com.ktxsoftware.kha.backends.cpp.Painter;
	
	public function new() {
		Loader.init(new com.ktxsoftware.kha.backends.cpp.Loader());
	}
	
	public function start(game : Game) {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.loadFinished();
		painter = new com.ktxsoftware.kha.backends.cpp.Painter();
	}

	public static function frame() {
		game.update();
		painter.begin();
		game.render(painter);
		painter.end();
	}
	
	public static function pushUp() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.UP, true));
	}
	
	public static function pushDown() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.DOWN, true));
	}

	public static function pushLeft() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.LEFT, true));
	}

	public static function pushRight() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.RIGHT, true));
	}
	
	public static function pushButton1() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.BUTTON_1, true));
	}

	public static function releaseUp() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.UP, false));
	}

	public static function releaseDown() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.DOWN, false));
	}

	public static function releaseLeft() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.LEFT, false));
	}
	
	public static function releaseRight() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.RIGHT, false));
	}
	
	public static function releaseButton1() : Void {
		game.key(new com.ktxsoftware.kha.KeyEvent(Key.BUTTON_1, false));
	}
}
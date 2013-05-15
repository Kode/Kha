package kha;

import kha.Game;
import kha.Key;
import kha.Loader;

class Starter {
	static var game: Game;
	static var painter: kha.cpp.Painter;
	
	public function new() {
		Storage.init(new kha.cpp.Storage());
		Loader.init(new kha.cpp.Loader());
	}
	
	public function start(game: Game) {
		Starter.game = game;
		Configuration.setScreen(new EmptyScreen(new Color(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public static function loadFinished() {
		Loader.the.initProject();
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
		painter = new kha.cpp.Painter();
	}

	public static function frame() {
		game.update();
		painter.begin();
		game.render(painter);
		painter.end();
	}
	
	public static function pushUp(): Void {
		game.buttonDown(Button.UP);
	}
	
	public static function pushDown(): Void {
		game.buttonDown(Button.DOWN);
	}

	public static function pushLeft(): Void {
		game.buttonDown(Button.LEFT);
	}

	public static function pushRight(): Void {
		game.buttonDown(Button.RIGHT);
	}
	
	public static function pushButton1(): Void {
		game.buttonDown(Button.BUTTON_1);
	}

	public static function releaseUp(): Void {
		game.buttonUp(Button.UP);
	}

	public static function releaseDown(): Void {
		game.buttonUp(Button.DOWN);
	}

	public static function releaseLeft(): Void {
		game.buttonUp(Button.LEFT);
	}
	
	public static function releaseRight(): Void {
		game.buttonUp(Button.RIGHT);
	}
	
	public static function releaseButton1(): Void {
		game.buttonUp(Button.BUTTON_1);
	}
	
	public static function pushChar(c: Int): Void {
		game.keyDown(Key.CHAR, String.fromCharCode(c));
	}
	
	public static function releaseChar(c: Int): Void {
		game.keyUp(Key.CHAR, String.fromCharCode(c));
	}

	public static function backspaceDown(): Void {
		game.keyDown(Key.BACKSPACE, "");
	}
	
	public static function backspaceUp(): Void {
		game.keyUp(Key.BACKSPACE, "");
	}
	
	public static function tabDown(): Void {
		game.keyDown(Key.TAB, "");
	}
	
	public static function tabUp(): Void {
		game.keyUp(Key.TAB, "");
	}
	
	public static function enterDown(): Void {
		game.keyDown(Key.ENTER, "");
	}
	
	public static function enterUp(): Void {
		game.keyUp(Key.ENTER, "");
	}
	
	public static function shiftDown(): Void {
		game.keyDown(Key.SHIFT, "");
	}
	
	public static function shiftUp(): Void {
		game.keyUp(Key.SHIFT, "");
	}
	
	public static function controlDown(): Void {
		game.keyDown(Key.CTRL, "");
	}
	
	public static function controlUp(): Void {
		game.keyUp(Key.CTRL, "");
	}
	
	public static function altDown(): Void {
		game.keyDown(Key.ALT, "");
	}
	
	public static function altUp(): Void {
		game.keyUp(Key.ALT, "");
	}
	
	public static function escapeDown(): Void {
		game.keyDown(Key.ESC, "");
	}
	
	public static function escapeUp(): Void {
		game.keyUp(Key.ESC, "");
	}
	
	public static function deleteDown(): Void {
		game.keyDown(Key.DEL, "");
	}
	
	public static function deleteUp(): Void {
		game.keyUp(Key.DEL, "");
	}
	
	public static function mouseDown(x: Int, y: Int) : Void {
		game.mouseDown(x, y);
	}

	public static function mouseUp(x: Int, y: Int) : Void {
		game.mouseUp(x, y);
	}
	
	public static function mouseMove(x: Int, y: Int): Void {
		game.mouseMove(x, y);
	}
}
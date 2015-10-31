package kha;

import kha.graphics4.Graphics2;
import kha.input.Keyboard;

class Starter {
	static public var game: Game;
	private static var frame: Framebuffer;
	
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	
	public function new() {
		Sys.init();
		kha.Loader.init(new kha.unity.Loader());
		Scheduler.init();
		new Keyboard();
		new kha.input.Mouse();
		Scheduler.init();
	}
	
	public function start(game: Game) {
		Starter.game = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public static function loadFinished(): Void {
		Loader.the.initProject();
		var g4 = new kha.unity.Graphics(null);
		frame = new Framebuffer(null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new Graphics2(frame), g4);
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		Scheduler.start();
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
	}

	public static function lockMouse() : Void{
		
	}
	
	public static function unlockMouse() : Void{
		
	}

	public static function canLockMouse() : Bool{
		return false;
	}

	public static function isMouseLocked() : Bool{
		return false;
	}

	public static function notifyOfMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public static function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}

	
	public static function leftDown(): Void {
		Game.the.buttonDown(Button.LEFT);
		Keyboard.get().sendDownEvent(Key.LEFT, '');
	}
	
	public static function rightDown(): Void {
		Game.the.buttonDown(Button.RIGHT);
		Keyboard.get().sendDownEvent(Key.RIGHT, '');
	}
	
	public static function upDown(): Void {
		Game.the.buttonDown(Button.UP);
		Keyboard.get().sendDownEvent(Key.UP, '');
	}
	
	public static function downDown(): Void {
		Game.the.buttonDown(Button.DOWN);
		Keyboard.get().sendDownEvent(Key.DOWN, '');
	}
	
	public static function leftUp(): Void {
		Game.the.buttonUp(Button.LEFT);
		Keyboard.get().sendUpEvent(Key.LEFT, '');
	}
	
	public static function rightUp(): Void {
		Game.the.buttonUp(Button.RIGHT);
		Keyboard.get().sendUpEvent(Key.RIGHT, '');
	}
	
	public static function upUp(): Void {
		Game.the.buttonUp(Button.UP);
		Keyboard.get().sendUpEvent(Key.UP, '');
	}
	
	public static function downUp(): Void {
		Game.the.buttonUp(Button.DOWN);
		Keyboard.get().sendUpEvent(Key.DOWN, '');
	}

	public static function mouseDown(button: Int, x: Int, y: Int): Void {
		Game.the.mouseDown(x, y);
		kha.input.Mouse.get().sendDownEvent(button, x, y);
	}

	public static function mouseUp(button: Int, x: Int, y: Int): Void {
		Game.the.mouseUp(x, y);
		kha.input.Mouse.get().sendUpEvent(button, x, y);
	}
	
	public static function update(): Void {
		Scheduler.executeFrame();
		if (game != null) {
			//game.update();
			game.render(frame);
		}
	}
}

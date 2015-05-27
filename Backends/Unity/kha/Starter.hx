package kha;

import kha.graphics4.Graphics2;
import kha.input.Keyboard;

class Starter {
	static public var game: Game;
	private static var frame: Framebuffer;
	
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	
	public function new() {
		kha.Loader.init(new kha.unity.Loader());
		Scheduler.init();
		Keyboard.instance = new Keyboard();
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
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
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
	
	public static function update(): Void {
		checkEvents();
		checkGamepad();
		if (game != null) {
			game.update();
			game.render(frame);
		}
	}
	
	/*@:functionCode('
		Sce.PlayStation.Core.Input.GamePadData gamePadData = Sce.PlayStation.Core.Input.GamePad.GetData(0);
		if ((gamePadData.Buttons & Sce.PlayStation.Core.Input.GamePadButtons.Left) != 0) {
			if (!left) {
				game.buttonDown(Button.LEFT);
				left = true;
			}
		}
		else {
			if (left) {
				game.buttonUp(Button.LEFT);
				left = false;
			}
		}
		if ((gamePadData.Buttons & Sce.PlayStation.Core.Input.GamePadButtons.Right) != 0) {
			if (!right) {
				game.buttonDown(Button.RIGHT);
				right = true;
			}
		}
		else {
			if (right) {
				game.buttonUp(Button.RIGHT);
				right = false;
			}
		}
		if ((gamePadData.Buttons & Sce.PlayStation.Core.Input.GamePadButtons.Up) != 0) {
			if (!up) {
				game.buttonDown(Button.UP);
				up = true;
			}
		}
		else {
			if (up) {
				game.buttonUp(Button.UP);
				up = false;
			}
		}
		if ((gamePadData.Buttons & Sce.PlayStation.Core.Input.GamePadButtons.Down) != 0) {
			if (!down) {
				game.buttonDown(Button.DOWN);
				down = true;
			}
		}
		else {
			if (down) {
				game.buttonUp(Button.DOWN);
				down = false;
			}
		}
	')*/
	static function checkGamepad(): Void {
		
	}
	
	/*@:functionCode('
		Sce.PlayStation.Core.Environment.SystemEvents.CheckEvents();
	')*/
	static function checkEvents(): Void {
		
	}
}

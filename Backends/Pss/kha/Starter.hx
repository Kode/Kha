package kha;

class Starter {
	static public var game : Game;
	static public var painter : kha.pss.Painter;
	static var left : Bool;
	static var right : Bool;
	static var up : Bool;
	static var down : Bool;
	
	public function new() {
		painter = new kha.pss.Painter();
		kha.Loader.init(new kha.pss.Loader());
		left = false;
		right = false;
		up = false;
		down = false;
	}
	
	public function start(game : Game) {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.loadFinished();
		while (true) {
			checkEvents();
			checkGamepad();
			game.update();
			painter.begin();
			game.render(painter);
			painter.end();
		}
	}
	
	@:functionBody('
		Sce.Pss.Core.Input.GamePadData gamePadData = Sce.Pss.Core.Input.GamePad.GetData(0);
		if ((gamePadData.Buttons & Sce.Pss.Core.Input.GamePadButtons.Left) != 0) {
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
		if ((gamePadData.Buttons & Sce.Pss.Core.Input.GamePadButtons.Right) != 0) {
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
		if ((gamePadData.Buttons & Sce.Pss.Core.Input.GamePadButtons.Up) != 0) {
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
		if ((gamePadData.Buttons & Sce.Pss.Core.Input.GamePadButtons.Down) != 0) {
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
	')
	static function checkGamepad() {
		
	}
	
	@:functionBody('
		Sce.Pss.Core.Environment.SystemEvents.CheckEvents();
	')
	static function checkEvents() : Void {
		
	}
}
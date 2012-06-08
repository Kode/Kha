package kha;

class Starter {
	static public var game : Game;
	static public var painter : kha.pss.Painter;
	
	public function new() {
		painter = new kha.pss.Painter();
		kha.Loader.init(new kha.pss.Loader());
	}
	
	public function start(game : Game) {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.loadFinished();
		while (true) {
			checkEvents();
			game.update();
			painter.begin();
			game.render(painter);
			painter.end();
		}
	}
	
	@:functionBody('
		Sce.Pss.Core.Environment.SystemEvents.CheckEvents();
	')
	static function checkEvents() : Void {
		
	}
}
package kha;

class Starter {
	static var game : Game;
	//static var painter : kha.wpf.Painter;
	
	public function new() {
		//kha.Loader.init(new kha.wpf.Loader());
	}
	
	public function start(game : Game) {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.loadFinished();
		//painter = new kha.wpf.Painter();
		//startWindow();
	}
}
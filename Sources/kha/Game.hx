package kha;

class Game {
	static var instance : Game;
	var scene : Scene;
	var name : String;
	var width : Int;
	var height : Int;
	var highscores : HighscoreList;
	
	public static function getInstance() : Game {
		return instance;
	}
	
	public function new(name : String, width : Int, height : Int, hasHighscores : Bool = true) {
		instance = this;
		this.name = name;
		this.width = width;
		this.height = height;
		if (hasHighscores) highscores = new HighscoreList(name);
		scene = Scene.getInstance();
	}
	
	public function getWidth() : Int {
		return width;
	}
	
	public function getHeight() : Int {
		return height;
	}
	
	public function loadFinished() : Void {
		init();
	}
	
	public function init() { }
	
	public function update() {
		scene.update();
	}
	
	public function render(painter : Painter) {
		scene.render(painter);
	}
	
	public function getHighscores() : HighscoreList {
		return highscores;
	}
	
	public function key(event : KeyEvent) { }
	public function charKey(c : String) { }
	
	public function mouseDown(x : Int, y : Int) { }
	public function mouseUp(x : Int, y : Int) { }
	public function mouseMove(x : Int, y : Int) { }
}
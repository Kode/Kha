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
	
	public function setInstance() {
		instance = this;
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
	
	public function init() : Void { }
	
	public function update() : Void {
		scene.update();
	}
	
	public function render(painter : Painter) : Void {
		scene.render(painter);
	}
	
	public function getHighscores() : HighscoreList {
		return highscores;
	}
	
	public function buttonDown(button : Button) : Void { }
	public function buttonUp(button : Button) : Void { }
	
	public function keyDown(key : Key, char : String) : Void { }
	public function keyUp(key : Key, char : String) : Void { }
	
	public function mouseDown(x : Int, y : Int) : Void { }
	public function mouseUp(x : Int, y : Int) : Void { }
	public function mouseMove(x : Int, y : Int) : Void { }
}
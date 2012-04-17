package com.ktxsoftware.kha;

class Game {
	static var instance : Game;
	var scene : Scene;
	var width : Int;
	var height : Int;
	
	public static function getInstance() : Game {
		return instance;
	}
	
	public function new(width : Int, height : Int) {
		instance = this;
		this.width = width;
		this.height = height;
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
	
	public function hasScores() : Bool {
		return true;
	}
	
	public function key(event : KeyEvent) { }
	public function charKey(c : String) { }
	
	public function mouseDown(x : Int, y : Int) { }
	public function mouseUp(x : Int, y : Int) { }
	public function mouseMove(x : Int, y : Int) { }
}
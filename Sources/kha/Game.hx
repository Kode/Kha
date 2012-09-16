package kha;

class Game {
	static var instance : Game;
	var scene : Scene;
	var name : String;
	var width : Int;
	var height : Int;
	var highscores : HighscoreList;
	var timers : Array<FrameCountTimer>;
	public static var FPS : Int = 60;
	
	public static function getInstance() : Game {
		return instance;
	}
	
	public function new(name : String, width : Int, height : Int, hasHighscores : Bool = true) {
		instance = this;
		timers = new Array<FrameCountTimer>();
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
		var w = Loader.getInstance().getWidth();
		if (w > 0) width = w;
		var h = Loader.getInstance().getHeight();
		if (h > 0) height = h;
		init();
	}
	
	public function init() : Void { }
	
	public function update() : Void {
		for (timer in timers)
			timer.update();
		
		scene.update();
	}
	
	public function registerTimer(timer : FrameCountTimer) {
		for (existingTimer in timers) {
			if (existingTimer == timer)
				return;
		}
		
		timers.push(timer);
	}
	
	public function removeTimer(timer : FrameCountTimer) {
		timers.remove(timer);
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
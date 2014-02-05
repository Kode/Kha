package kha;

class Game {
	private var scene: Scene;
	private var name: String;
	
	public static var FPS: Int = 60;
	
	public static var the(default, null): Game;
	
	public var width(default, default): Int;
	public var height(default, default): Int;
	public var highscores(default, null): HighscoreList;
	
	public function new(name: String, hasHighscores: Bool = false) {
		setInstance();
		this.name = name;
		if (hasHighscores) highscores = new HighscoreList();
		scene = Scene.the;
		width = Loader.the.width;
		height = Loader.the.height;
	}
	
	public function setInstance(): Void {
		the = this;
	}
	
	public function loadFinished(): Void {
		var w = Loader.the.width;
		if (w > 0) width = w;
		var h = Loader.the.height;
		if (h > 0) height = h;
		init();
	}
	
	public function init(): Void { }
	
	public function update(): Void {
		scene.update();
	}
	
	private function startRender(painter: Painter): Void {
		painter.begin();
	}
	
	private function endRender(painter: Painter): Void {
		Sys.mouse.render(painter);
		painter.end();
	}
	
	public function render(painter: Painter): Void {
		startRender(painter);
		scene.render(painter);
		endRender(painter);
	}
	
	public function getHighscores(): HighscoreList {
		return highscores;
	}
	
	public function buttonDown(button: Button): Void { }
	public function buttonUp  (button: Button): Void { }
	
	public function keyDown(key: Key, char: String): Void { }
	public function keyUp  (key: Key, char: String): Void { }
	
	public function mouseDown     (x: Int, y: Int): Void { }
	public function mouseUp       (x: Int, y: Int): Void { }
	public function rightMouseDown(x: Int, y: Int): Void { }
	public function rightMouseUp  (x: Int, y: Int): Void { }
	public function mouseMove     (x: Int, y: Int): Void { }
	
	public function onClose(): Void { }
}
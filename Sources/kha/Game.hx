package kha;

class Game {
	private var scene: Scene;
	private var name: String;
	private var timers: Array<FrameCountTimer>;
	
	public static var FPS: Int = 60;
	
	public static var the(default, null): Game;
	
	public var width(default, default): Int;
	public var height(default, default): Int;
	public var highscores(default, null): HighscoreList;
	
	public function new(name: String, hasHighscores: Bool = true) {
		setInstance();
		timers = new Array<FrameCountTimer>();
		this.name = name;
		if (hasHighscores) highscores = new HighscoreList(name);
		scene = Scene.getInstance();
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
		for (timer in timers) timer.update();
		scene.update();
	}
	
	public function registerTimer(timer: FrameCountTimer) {
		for (existingTimer in timers) {
			if (existingTimer == timer)
				return;
		}
		timers.push(timer);
	}
	
	public function removeTimer(timer: FrameCountTimer) {
		timers.remove(timer);
	}
	
	public function render(painter: Painter): Void {
		scene.render(painter);
	}
	
	public function getHighscores(): HighscoreList {
		return highscores;
	}
	
	public function buttonDown(button: Button): Void { }
	public function buttonUp  (button: Button): Void { }
	
	public function keyDown(key: Key, char: String): Void { }
	public function keyUp  (key: Key, char: String): Void { }
	
	public function mouseDown(x: Int, y: Int): Void { }
	public function mouseUp  (x: Int, y: Int): Void { }
	public function mouseMove(x: Int, y: Int): Void { }
}
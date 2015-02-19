package kha;

import kha.graphics4.TextureFormat;

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
		width = Std.int(Loader.the.width);
		height = Std.int(Loader.the.height);
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
	
	private function startRender(frame: Framebuffer): Void {
		frame.g2.begin();
	}
	
	private function endRender(frame: Framebuffer): Void {
		//Sys.mouse.render(frame.g2);
		frame.g2.end();
	}
	
	public function render(frame: Framebuffer): Void {
		startRender(frame);
		scene.render(frame.g2);
		endRender(frame);
	}
	
	public function getHighscores(): HighscoreList {
		return highscores;
	}
	
	private var deprecatedImage: Image = null;

	private function initDeprecatedImage(): Void {
		if (deprecatedImage != null) return;
		deprecatedImage = Image.create(width, height, TextureFormat.L8);
	}
	
	// deprecated - please use kha.Scaler.transformX
	public function painterTransformMouseX(x: Int, y: Int): Int {
		initDeprecatedImage();
		return Scaler.transformX(x, y, deprecatedImage, ScreenCanvas.the, kha.Sys.screenRotation);
	}
	
	// deprecated - please use kha.Scaler.transformY
	public function painterTransformMouseY(x: Int, y: Int): Int {
		initDeprecatedImage();
		return Scaler.transformY(x, y, deprecatedImage, ScreenCanvas.the, kha.Sys.screenRotation);
	}
	
	// deprecated - please use kha.input.Gamepad
	public function buttonDown(button: Button): Void { }
	public function buttonUp  (button: Button): Void { }
	
	// deprecated - please use kha.input.Keyboard
	public function keyDown(key: Key, char: String): Void { }
	public function keyUp  (key: Key, char: String): Void { }
	
	// deprecated - please use kha.input.Mouse and kha.input.Surface
	public function mouseDown     (x: Int, y: Int): Void { }
	public function mouseUp       (x: Int, y: Int): Void { }
	public function rightMouseDown(x: Int, y: Int): Void { }
	public function rightMouseUp  (x: Int, y: Int): Void { }
	public function middleMouseDown(x: Int, y: Int): Void { }
	public function middleMouseUp  (x: Int, y: Int): Void { }
	public function mouseMove     (x: Int, y: Int): Void { }
	public function mouseWheel    (delta: Int):     Void { }
	
	public function onForeground(): Void { }
	public function onResume(): Void { }
	public function onPause(): Void { }
	public function onBackground(): Void { }
	public function onShutdown(): Void { }
}
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
	
	@:deprecated("kha.Game.painterTransformMouseX(x, y) is deprecated, use kha.Scaler.transformX instead.")
	public function painterTransformMouseX(x: Int, y: Int): Int {
		initDeprecatedImage();
		return Scaler.transformX(x, y, deprecatedImage, ScreenCanvas.the, kha.Sys.screenRotation);
	}
	
	@:deprecated("kha.Game.painterTransformMouseY(x, y) is deprecated, use kha.Scaler.transformY instead.")
	public function painterTransformMouseY(x: Int, y: Int): Int {
		initDeprecatedImage();
		return Scaler.transformY(x, y, deprecatedImage, ScreenCanvas.the, kha.Sys.screenRotation);
	}
	
	//@:deprecated("kha.Game.buttonDown(button) is deprecated, use kha.input.Gamepad instead.")
	public function buttonDown(button: Button): Void { }
	//@:deprecated("kha.Game.buttonUp(button) is deprecated, use kha.input.Gamepad instead.")
	public function buttonUp  (button: Button): Void { }
	
	//@:deprecated("kha.Game.keyDown(key, char) is deprecated, use kha.input.Keyboard instead.")
	public function keyDown(key: Key, char: String): Void { }
	//@:deprecated("kha.Game.keyUp(key, char) is deprecated, use kha.input.Keyboard instead.")
	public function keyUp  (key: Key, char: String): Void { }
	
	//@:deprecated("kha.Game.mouseDown(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function mouseDown(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.mouseUp(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function mouseUp(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.rightMouseDown(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function rightMouseDown(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.rightMouseUp(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function rightMouseUp(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.middleMouseDown(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function middleMouseDown(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.middleMouseUp(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function middleMouseUp(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.mouseMove(x, y) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function mouseMove(x: Int, y: Int): Void { }
	//@:deprecated("kha.Game.mouseWheel(delta) is deprecated, use kha.input.Mouse or kha.input.Surface instead.")
	public function mouseWheel(delta: Int):     Void { }
	
	public function onForeground(): Void { }
	public function onResume(): Void { }
	public function onPause(): Void { }
	public function onBackground(): Void { }
	public function onShutdown(): Void { }
}

package kha;

import kha.graphics4.TextureFormat;

/**
 * Main Kha class.
 * Inherit from this in your game or application.
 */
class Game {
	/**
	 * ID name.
	 */
	private var name: String;
	/**
	 * The current FPS.
	 */	
	public static var FPS: Int = 60;
	/**
	 * Static instance.
	 */
	public static var the(default, null): Game;
	/**
	 * Defined width.
	 */
	public var width(default, default): Int;
	/**
	 * Defined height.
	 */
	public var height(default, default): Int;
	/**
	 * The high scores list.
	 */
	public var highscores(default, null): HighscoreList;
	
	/**
	 * Instantiate a new game object.
	 * 
	 * @param name				The ID name.
	 * @param hasHighscores		If it has high scores or not.
	 */
	public function new(name: String, hasHighscores: Bool = false) {
		setInstance();
		this.name = name;
		if (hasHighscores) highscores = new HighscoreList();
		width = Std.int(Loader.the.width);
		height = Std.int(Loader.the.height);
	}
	
	/**
	 * Set the static instance.
	 */
	public function setInstance(): Void {
		the = this;
	}
	
	/**
	 * Callback from when the loaded finished.
	 * This updates the game width and height values 
	 * and also call init().
	 */
	public function loadFinished(): Void {
		var w = Loader.the.width;
		if (w > 0) width = w;
		var h = Loader.the.height;
		if (h > 0) height = h;
		init();
	}
	
	/**
	 * Override this to get your own custom init behavior.
	 * Called after the loading process.
	 */
	public function init(): Void { }
	
	/**
	 * Override this to get your own custom update behavior.
	 * Called per frame or various times per frame.
	 */
	public function update(): Void {
		
	}
	
	/**
	 * Start render mode for the passed frame.
	 * 
	 * @param frame		The frame buffer we will be rendering on.
	 */
	private function startRender(frame: Framebuffer): Void {
		#if !VR_GEAR_VR
			frame.g2.begin();
		#end
	}

	/**
	 * Finish render mode for the passed frame.
	 * 
	 * @param frame		The frame buffer we will be rendering on.
	 */
	private function endRender(frame: Framebuffer): Void {
		//Sys.mouse.render(frame.g2);
		#if !VR_GEAR_VR
			frame.g2.end();
		#end
	}
	
	/**
	 * Override this to get your own custom render behavior.
	 * Called per frame.
	 */
	public function render(frame: Framebuffer): Void {
		#if !ANDROID
		startRender(frame);
		#end
		// scene.render(frame.g2);
		#if !ANDROID
		endRender(frame);
		#end
	}
	
	/**
	 * Return the high score list.
	 */
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
	
	/**
	 * Override this to get your own custom foreground behavior.
	 * Called when this application frame is moved from background of the screen to the top.
	 */
	public function onForeground(): Void { }
	/**
	 * Override this to get your own custom resume behavior.
	 * Called when resuming the application from pause.
	 */
	public function onResume(): Void { }
	/**
	 * Override this to get your own custom shutdown behavior.
	 * Called when pausing the application.
	 */
	public function onPause(): Void { }
	/**
	 * Override this to get your own custom background behavior.
	 * Called when this app frame is moved from top of the screen to the background.
	 */
	public function onBackground(): Void { }
	/**
	 * Override this to get your own custom shutdown behavior.
	 * Called when shutting down the system.
	 */
	public function onShutdown(): Void { }
}

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
	
	public function painterScale(): Float {
		if (Sys.screenRotation == ScreenRotation.RotationNone || Sys.screenRotation == ScreenRotation.Rotation180) {
			if (width / height > Sys.pixelWidth / Sys.pixelHeight) {
				return Sys.pixelWidth / width;
			}
			else {
				return Sys.pixelHeight / height;
			}
		}
		else {
			if (width / height > Sys.pixelWidth / Sys.pixelHeight) {
				return Sys.pixelHeight / width;
			}
			else {
				return Sys.pixelWidth / height;
			}
		}
	}
	
	public function painterTargetRect(): Rectangle {
		var rect = new Rectangle(0, 0, 1, 1);
		if (Sys.screenRotation == ScreenRotation.RotationNone || Sys.screenRotation == ScreenRotation.Rotation180) {
			if (width / height > Sys.pixelWidth / Sys.pixelHeight) {
				var scale = Sys.pixelWidth / width;
				rect.width = width * scale;
				rect.height = height * scale;
				rect.x = 0;
				rect.y = (Sys.pixelHeight - rect.height) * 0.5;
			}
			else {
				var scale = Sys.pixelHeight / height;
				rect.width = width * scale;
				rect.height = height * scale;
				rect.x = (Sys.pixelWidth - rect.width) * 0.5;
				rect.y = 0;
			}
		}
		else if (Sys.screenRotation == ScreenRotation.Rotation90) {
			if (width / height > Sys.pixelWidth / Sys.pixelHeight) {
				var scale = Sys.pixelHeight / width;
				rect.width = width * scale;
				rect.height = height * scale;
				rect.x = (Sys.pixelWidth - rect.height) * 0.5 + rect.height;
				rect.y = 0;
			}
			else {
				var scale = Sys.pixelWidth / height;
				rect.width = width * scale;
				rect.height = height * scale;
				rect.x = 0 + rect.height;
				rect.y = (Sys.pixelHeight - rect.width) * 0.5;
			}
		}
		else { // ScreenRotation.Rotation270
			if (width / height > Sys.pixelHeight / Sys.pixelWidth) {
				var scale = Sys.pixelHeight / width;
				rect.width = width * scale;
				rect.height = height * scale;
				rect.x = (Sys.pixelWidth - rect.height) * 0.5;
				rect.y = 0 + rect.width;
			}
			else {
				var scale = Sys.pixelWidth / height;
				rect.width = width * scale;
				rect.height = height * scale;
				rect.x = 0;
				rect.y = (Sys.pixelHeight - rect.width) * 0.5 + rect.width;
			}
		}
		return rect;
	}

	public function painterTransformMouseX(x: Int, y: Int): Int {
		switch (Sys.screenRotation) {
		case ScreenRotation.RotationNone:
			return Std.int((x - painterTargetRect().x) / painterScale());
		case ScreenRotation.Rotation90:
			return Std.int((y - painterTargetRect().y) / painterScale());
		case ScreenRotation.Rotation180:
			return Std.int((Sys.pixelWidth - x - painterTargetRect().x) / painterScale());
		case ScreenRotation.Rotation270:
			return Std.int((Sys.pixelHeight - y - (Sys.pixelHeight - painterTargetRect().y)) / painterScale());
		}
	}
	
	public function painterTransformMouseY(x: Int, y: Int): Int {
		switch (Sys.screenRotation) {
		case ScreenRotation.RotationNone:
			return Std.int((y - painterTargetRect().y) / painterScale());
		case ScreenRotation.Rotation90:
			return Std.int((Sys.pixelWidth - x - painterTargetRect().x) / painterScale());
		case ScreenRotation.Rotation180:
			return Std.int((y - painterTargetRect().y) / painterScale());
		case ScreenRotation.Rotation270:
			return Std.int((x - painterTargetRect().x) / painterScale());
		}
	}
	
	public function buttonDown(button: Button): Void { }
	public function buttonUp  (button: Button): Void { }
	
	public function keyDown(key: Key, char: String): Void { }
	public function keyUp  (key: Key, char: String): Void { }
	
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

	public function onClose(): Void { } // check me out
}
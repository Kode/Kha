package kha;

import kha.Game;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.js.WorkerGraphics;
import kha.Key;
import kha.Loader;

class Starter {
	private var gameToStart: Game;
	private static var frame: Framebuffer = null;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	
	public static var mouseX: Int;
	public static var mouseY: Int;

	public function new() {
		Worker.handleMessages(messageHandler);
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();
		
		Loader.init(new kha.js.Loader());
		Scheduler.init();
	}
	
	public function start(game: Game): Void {
		gameToStart = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public function loadFinished() {
		Loader.the.initProject();
		
		gameToStart.width = Loader.the.width;
		gameToStart.height = Loader.the.height;
			
		Sys.init(gameToStart.width, gameToStart.height);
		frame = new Framebuffer(new WorkerGraphics(gameToStart.width, gameToStart.height), null);
		Scheduler.start();
		
		Configuration.setScreen(gameToStart);
		
		gameToStart.loadFinished();
	}

	public function lockMouse() : Void{
		
	}
	
	public function unlockMouse() : Void{
		
	}

	public function canLockMouse() : Bool{
		return false;
	}

	public function isMouseLocked() : Bool{
		return false;
	}

	public function notifyOfMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}

	
	private function messageHandler(value: Dynamic): Void {
		switch (value.data.command) {
		case 'loadedBlob':
			cast(Loader.the, kha.js.Loader).loadedBlob(value.data);
		case 'loadedImage':
			cast(Loader.the, kha.js.Loader).loadedImage(value.data);
		case 'loadedSound':
			cast(Loader.the, kha.js.Loader).loadedSound(value.data);
		case 'loadedMusic':
			cast(Loader.the, kha.js.Loader).loadedMusic(value.data);
		case 'frame':
			if (frame != null) {
				Scheduler.executeFrame();
				Configuration.screen().render(frame);
			}
		case 'keyDown':
			Configuration.screen().keyDown(Key.createByIndex(value.data.key), value.data.char);
		case 'keyUp':
			Configuration.screen().keyUp(Key.createByIndex(value.data.key), value.data.char);
		}
	}
}

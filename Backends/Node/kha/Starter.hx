package kha;

import js.Node;
import kha.Game;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.js.EmptyGraphics1;
import kha.js.EmptyGraphics2;
import kha.js.EmptyGraphics4;
import kha.Key;
import kha.Loader;
import kha.network.Session;

class Starter {
	private var gameToStart: Game;
	private static var frame: Framebuffer = null;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	
	public static var mouseX: Int;
	public static var mouseY: Int;

	public function new() {
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
		frame = new Framebuffer(new EmptyGraphics1(gameToStart.width, gameToStart.height), new EmptyGraphics2(gameToStart.width, gameToStart.height), new EmptyGraphics4(gameToStart.width, gameToStart.height));
		Scheduler.start();
		
		Configuration.setScreen(gameToStart);
		
		gameToStart.loadFinished();
		
		var lastTime = 0;
		Node.setInterval(function () {
			Scheduler.executeFrame();
			if (Session.the() != null) {
				Session.the().update();
			}
			var time = Scheduler.time();
			if (time >= lastTime + 10) {
				lastTime += 10;
				Node.console.log(lastTime + " seconds.");
			}
		}, 100);
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

}

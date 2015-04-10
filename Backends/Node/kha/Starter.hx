package kha;

import js.Node;
import kha.Game;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.js.EmptyGraphics2;
import kha.js.EmptyGraphics4;
import kha.Key;
import kha.Loader;
import kha.networking.Session;

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
		frame = new Framebuffer(new EmptyGraphics2(gameToStart.width, gameToStart.height), new EmptyGraphics4(gameToStart.width, gameToStart.height));
		Scheduler.start();
		
		Configuration.setScreen(gameToStart);
		
		gameToStart.loadFinished();
		
		Node.setInterval(function () {
			Scheduler.executeFrame();
			Session.the().update();
		}, 100);
	}
}

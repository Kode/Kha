package kha;

import com.ktxsoftware.kha.KhaActivity;
import kha.graphics4.Graphics2;
import kha.android.Graphics;
import kha.input.Keyboard;
import kha.input.Surface;

/*class Starter {
	//static var instance : Starter;
	//static var game : Game;
	//static var painter : kha.android.Painter;
	
	public function new() {
		//instance = this;
		//kha.Loader.init(new kha.android.Loader());
	}
	
	public function start(game : Game) {
		//Starter.game = game;
		//Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		//game.loadFinished();
	}
	
	public static var mouseX: Int;
	public static var mouseY: Int;
}*/

class Starter {
	public static var game: Game;
	private static var framebuffer: Framebuffer;
	private static var w: Int;
	private static var h: Int;
	public static var mouseX: Int = 0;
	public static var mouseY: Int = 0;
	private static var keyboard: Keyboard;
	private static var shift = false;
	private static var mouse: kha.input.Mouse;
	private static var surface: Surface;
	
	public function new() {
		KhaActivity.the();
		new Keyboard();
		mouse = new kha.input.Mouse();
		//gamepad = new Gamepad();
		surface = new Surface();
		
		Loader.init(new kha.android.Loader(KhaActivity.the().getApplicationContext()));
		Scheduler.init();
	}
	
	public function start(game: Game) {
		Starter.game = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public function loadFinished(): Void {
		Loader.the.initProject();
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		Sys.init(w, h);
		
		var graphics = new Graphics();
		framebuffer = new Framebuffer(null, null, graphics);
		var g1 = new kha.graphics2.Graphics1(framebuffer);
		var g2 = new Graphics2(framebuffer);
		framebuffer.init(g1, g2, graphics);
		
		Scheduler.start();
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
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

	
	public static function init(width: Int, height: Int): Void {
		w = width;
		h = height;
		Sys.initTime();
		Main.main();
	}
	
	public static function setWidthHeight(width: Int, height: Int): Void {
		w = width;
		h = height;
		Sys.w = w;
		Sys.h = h;
	}
	
	public static function step(): Void {
		Scheduler.executeFrame();
		Configuration.screen().render(framebuffer);
	}

	private static function setMousePosition(x : Int, y : Int){
		mouseX = x;
		mouseY = y;
	}
	
	public static function touch(index: Int, x: Int, y: Int, action: Int): Void {
		
		switch (action) {
		case 0: //DOWN
			if (index == 0) {
				setMousePosition(x,y);
				mouse.sendDownEvent(0, x, y);
				if (Game.the != null) Game.the.mouseDown(x, y);
			}
			surface.sendTouchStartEvent(index, x, y);
		case 1: //MOVE
			if (index == 0) {
				var movementX = x - mouseX;
				var movementY = y - mouseY;
				setMousePosition(x,y);
				mouse.sendMoveEvent(x, y, movementX, movementY);
				if (Game.the != null) Game.the.mouseMove(x, y);
			}
			surface.sendMoveEvent(index, x, y);
		case 2: //UP
			if (index == 0) {
				setMousePosition(x,y);
				mouse.sendUpEvent(0, x, y);
				if (Game.the != null) Game.the.mouseUp(x, y);
			}
			surface.sendTouchEndEvent(index, x, y);
		}
	}
	
	public static function keyDown(code: Int): Void {
		switch (code) {
		case 0x00000120:
			shift = true;
			keyboard.sendDownEvent(Key.SHIFT, " ");
			if (Game.the != null) Game.the.keyDown(Key.SHIFT, " ");
		case 0x00000103:
			keyboard.sendDownEvent(Key.BACKSPACE, " ");
			if (Game.the != null) Game.the.keyDown(Key.BACKSPACE, " ");
		case 0x00000104:
			keyboard.sendDownEvent(Key.ENTER, " ");
			if (Game.the != null) Game.the.keyDown(Key.ENTER, " ");
		default:
			var char: String;
			if (shift) {
				char = String.fromCharCode(code);
			}
			else {
				char = String.fromCharCode(code + "a".charCodeAt(0) - "A".charCodeAt(0));
			}
			keyboard.sendDownEvent(Key.CHAR, char);
			if (Game.the != null) Game.the.keyDown(Key.CHAR, char);
		}
	}
	
	public static function keyUp(code: Int): Void {
		switch (code) {
		case 0x00000120:
			shift = false;
			keyboard.sendUpEvent(Key.SHIFT, " ");
			if (Game.the != null) Game.the.keyUp(Key.SHIFT, " ");
		case 0x00000103:
			keyboard.sendUpEvent(Key.BACKSPACE, " ");
			if (Game.the != null) Game.the.keyUp(Key.BACKSPACE, " ");
		case 0x00000104:
			keyboard.sendUpEvent(Key.ENTER, " ");
			if (Game.the != null) Game.the.keyUp(Key.ENTER, " ");
		default:
			var char: String;
			if (shift) {
				char = String.fromCharCode(code);
			}
			else {
				char = String.fromCharCode(code + "a".charCodeAt(0) - "A".charCodeAt(0));
			}
			keyboard.sendUpEvent(Key.CHAR, char);
			if (Game.the != null) Game.the.keyUp(Key.CHAR, char);
		}
	}
	
	public static var showKeyboard: Bool;
	
	public static function keyboardShown(): Bool {
		return showKeyboard;
	}
	
	public static function foreground(): Void {
		if (Game.the != null) Game.the.onForeground();
	}

	public static function resume(): Void {
		if (Game.the != null) Game.the.onResume();
	}

	public static function pause(): Void {
		if (Game.the != null) Game.the.onPause();
	}

	public static function background(): Void {
		if (Game.the != null) Game.the.onBackground();
	}

	public static function shutdown(): Void {
		if (Game.the != null) Game.the.onShutdown();
	}
}

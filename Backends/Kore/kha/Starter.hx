package kha;

import kha.Game;
import kha.graphics4.Graphics2;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Surface;
import kha.Key;
import kha.Loader;
import kha.input.Sensor;
import kha.input.SensorType;

class Starter {
	private static var game: Game;
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	private static var surface: Surface;
	
	public function new() {
		haxe.Timer.stamp();
		Sensor.get(SensorType.Accelerometer); // force compilation
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();
		surface = new Surface();
		Sys.init();
		Loader.init(new kha.cpp.Loader());
		Scheduler.init();
	}
	
	public function start(game: Game) {
		Starter.game = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public static function loadFinished() {
		Loader.the.initProject();
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		Scheduler.start();
		game.loadFinished();
		var g4 = new kha.cpp.graphics4.Graphics();
		framebuffer = new Framebuffer(null, g4);
		framebuffer.init(new Graphics2(framebuffer), g4);
	}

	public static function frame() {
		if (framebuffer == null) return;
		Scheduler.executeFrame();
		game.render(framebuffer);
	}
	
	public static function pushUp(): Void {
		game.buttonDown(Button.UP);
		game.keyDown(Key.UP, null);
		keyboard.sendDownEvent(Key.UP, null);
	}
	
	public static function pushDown(): Void {
		game.buttonDown(Button.DOWN);
		game.keyDown(Key.DOWN, null);
		keyboard.sendDownEvent(Key.DOWN, null);
	}

	public static function pushLeft(): Void {
		game.buttonDown(Button.LEFT);
		game.keyDown(Key.LEFT, null);
		keyboard.sendDownEvent(Key.LEFT, null);
	}

	public static function pushRight(): Void {
		game.buttonDown(Button.RIGHT);
		game.keyDown(Key.RIGHT, null);
		keyboard.sendDownEvent(Key.RIGHT, null);
	}
	
	public static function pushButton1(): Void {
		game.buttonDown(Button.BUTTON_1);
	}

	public static function releaseUp(): Void {
		game.buttonUp(Button.UP);
		game.keyUp(Key.UP, null);
		keyboard.sendUpEvent(Key.UP, null);
	}

	public static function releaseDown(): Void {
		game.buttonUp(Button.DOWN);
		game.keyUp(Key.DOWN, null);
		keyboard.sendUpEvent(Key.DOWN, null);
	}

	public static function releaseLeft(): Void {
		game.buttonUp(Button.LEFT);
		game.keyUp(Key.LEFT, null);
		keyboard.sendUpEvent(Key.LEFT, null);
	}
	
	public static function releaseRight(): Void {
		game.buttonUp(Button.RIGHT);
		game.keyUp(Key.RIGHT, null);
		keyboard.sendUpEvent(Key.RIGHT, null);
	}
	
	public static function releaseButton1(): Void {
		game.buttonUp(Button.BUTTON_1);
	}
	
	public static function pushChar(charCode: Int): Void {
		game.keyDown(Key.CHAR, String.fromCharCode(charCode));
		keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(charCode));
	}
	
	public static function releaseChar(charCode: Int): Void {
		game.keyUp(Key.CHAR, String.fromCharCode(charCode));
		keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(charCode));
	}
	
	public static function pushShift(): Void {
		game.keyDown(Key.SHIFT, null);
		keyboard.sendDownEvent(Key.SHIFT, null);
	}
	
	public static function releaseShift(): Void {
		game.keyUp(Key.SHIFT, null);
		keyboard.sendUpEvent(Key.SHIFT, null);
	}
	
	public static function pushBackspace(): Void {
		game.keyDown(Key.BACKSPACE, null);
		keyboard.sendDownEvent(Key.BACKSPACE, null);
	}
	
	public static function releaseBackspace(): Void {
		game.keyUp(Key.BACKSPACE, null);
		keyboard.sendUpEvent(Key.BACKSPACE, null);
	}
	
	public static function pushTab(): Void {
		game.keyDown(Key.TAB, null);
		keyboard.sendDownEvent(Key.TAB, null);
	}
	
	public static function releaseTab(): Void {
		game.keyUp(Key.TAB, null);
		keyboard.sendUpEvent(Key.TAB, null);
	}

	public static function pushEnter(): Void {
		game.keyDown(Key.ENTER, null);
		keyboard.sendDownEvent(Key.ENTER, null);
	}
	
	public static function releaseEnter(): Void {
		game.keyUp(Key.ENTER, null);
		keyboard.sendUpEvent(Key.ENTER, null);
	}
	
	public static function pushControl(): Void {
		game.keyDown(Key.CTRL, null);
		keyboard.sendDownEvent(Key.CTRL, null);
	}
	
	public static function releaseControl(): Void {
		game.keyUp(Key.CTRL, null);
		keyboard.sendUpEvent(Key.CTRL, null);
	}
	
	public static function pushAlt(): Void {
		game.keyDown(Key.ALT, null);
		keyboard.sendDownEvent(Key.ALT, null);
	}
	
	public static function releaseAlt(): Void {
		game.keyUp(Key.ALT, null);
		keyboard.sendUpEvent(Key.ALT, null);
	}
	
	public static function pushEscape(): Void {
		game.keyDown(Key.ESC, null);
		keyboard.sendDownEvent(Key.ESC, null);
	}
	
	public static function releaseEscape(): Void {
		game.keyUp(Key.ESC, null);
		keyboard.sendUpEvent(Key.ESC, null);
	}
	
	public static function pushDelete(): Void {
		game.keyDown(Key.DEL, null);
		keyboard.sendDownEvent(Key.DEL, null);
	}
	
	public static function releaseDelete(): Void {
		game.keyUp(Key.DEL, null);
		keyboard.sendUpEvent(Key.DEL, null);
	}
	
	public static var mouseX: Int;
	public static var mouseY: Int;
	
	public static function mouseDown(button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		game.mouseDown(x, y);
		mouse.sendDownEvent(button, x, y);
	}

	public static function mouseUp(button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		game.mouseUp(x, y);
		mouse.sendUpEvent(button, x, y);
	}
	
	public static function mouseMove(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		game.mouseMove(x, y);
		mouse.sendMoveEvent(x, y);
	}
	
	public static function gamepadAxis(axis: Int, value: Float): Void {
		gamepad.sendAxisEvent(axis, value);
	}
	
	public static function gamepadButton(button: Int, value: Float): Void {
		gamepad.sendButtonEvent(button, value);
	}
	
	public static function touchStart(index: Int, x: Int, y: Int): Void {
		surface.sendTouchStartEvent(index, x, y);
	}
	
	public static function touchEnd(index: Int, x: Int, y: Int): Void {
		surface.sendTouchEndEvent(index, x, y);
	}
	
	public static function touchMove(index: Int, x: Int, y: Int): Void {
		surface.sendMoveEvent(index, x, y);
	}

	public static function foreground(): Void {
		game.onForeground();
	}

	public static function resume(): Void {
		game.onResume();
	}

	public static function pause(): Void {
		game.onPause();
	}

	public static function background(): Void {
		game.onBackground();
	}

	public static function shutdown(): Void {
		game.onShutdown();
	}
}

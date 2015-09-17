package kha;

import kha.Game;
import kha.graphics4.Graphics2;
import kha.graphics4.TextureFormat;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Surface;
import kha.Key;
import kha.Loader;
import kha.input.Sensor;
import kha.input.SensorType;
import kha.vr.VrInterface;

#if ANDROID 
	#if VR_CARDBOARD
		import kha.kore.vr.CardboardVrInterface;
	#end
	#if !VR_CARDBOARD
		import kha.kore.vr.VrInterface;
	#end
#end
#if !ANDROID
	#if VR_RIFT
		import kha.kore.vr.VrInterfaceRift;
	#end
	#if !VR_RIFT
		import kha.vr.VrInterfaceEmulated;
	#end
#end

class Starter {
	private var gameToStart: Game;
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var gamepad: Gamepad;
	private static var surface: Surface;
	
	public function new(?backbufferFormat: TextureFormat) {
		haxe.Timer.stamp();
		Sensor.get(SensorType.Accelerometer); // force compilation
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		gamepad = new Gamepad();
		surface = new Surface();
		Sys.init();
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		Loader.init(new kha.kore.Loader());
		Scheduler.init();
	}
	
	public function start(game: Game) {
		gameToStart = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public function loadFinished() {
		trace("Project files loaded.");
		Loader.the.initProject();
		gameToStart.width = Loader.the.width;
		gameToStart.height = Loader.the.height;
		Configuration.setScreen(gameToStart);
		Configuration.screen().setInstance();
		Scheduler.start();
		
		/*
		#if ANDROID
			#if VR_GEAR_VR
				kha.vr.VrInterface.instance = new kha.kore.vr.VrInterface();
			#end
			#if !VR_GEAR_VR
				kha.vr.VrInterface.instance = new CardboardVrInterface();
			#end
		#end
        #if !ANDROID
			#if VR_RIFT
				kha.vr.VrInterface.instance = new VrInterfaceRift();
			#end
			#if !VR_RIFT
				kha.vr.VrInterface.instance = new kha.vr.VrInterfaceEmulated();
			#end
		#end
		*/

		#if (!VR_GEAR_VR && !VR_RIFT)
		var g4 = new kha.kore.graphics4.Graphics();
		framebuffer = new Framebuffer(null, null, g4);
		framebuffer.init(new kha.graphics2.Graphics1(framebuffer), new kha.kore.graphics4.Graphics2(framebuffer), g4);
		#end
		
		trace("Initializing application.");
		gameToStart.loadFinished();
	}

	public static function frame() {
		/*
		#if !ANDROID
		#if !VR_RIFT
			if (framebuffer == null) return;
			var vrInterface: VrInterfaceEmulated = cast(VrInterface.instance, VrInterfaceEmulated);
			vrInterface.framebuffer = framebuffer;
		#end
		#else 
			#if VR_CARDBOARD
				var vrInterface: CardboardVrInterface = cast(VrInterface.instance, CardboardVrInterface);
				vrInterface.framebuffer = framebuffer;
			#end
		#end
		*/
		
		Scheduler.executeFrame();
		Game.the.render(framebuffer);
	}
	
	public static function pushUp(): Void {
		Game.the.buttonDown(Button.UP);
		Game.the.keyDown(Key.UP, null);
		keyboard.sendDownEvent(Key.UP, null);
	}
	
	public static function pushDown(): Void {
		Game.the.buttonDown(Button.DOWN);
		Game.the.keyDown(Key.DOWN, null);
		keyboard.sendDownEvent(Key.DOWN, null);
	}

	public static function pushLeft(): Void {
		Game.the.buttonDown(Button.LEFT);
		Game.the.keyDown(Key.LEFT, null);
		keyboard.sendDownEvent(Key.LEFT, null);
	}

	public static function pushRight(): Void {
		Game.the.buttonDown(Button.RIGHT);
		Game.the.keyDown(Key.RIGHT, null);
		keyboard.sendDownEvent(Key.RIGHT, null);
	}
	
	public static function pushButton1(): Void {
		Game.the.buttonDown(Button.BUTTON_1);
	}

	public static function releaseUp(): Void {
		Game.the.buttonUp(Button.UP);
		Game.the.keyUp(Key.UP, null);
		keyboard.sendUpEvent(Key.UP, null);
	}

	public static function releaseDown(): Void {
		Game.the.buttonUp(Button.DOWN);
		Game.the.keyUp(Key.DOWN, null);
		keyboard.sendUpEvent(Key.DOWN, null);
	}

	public static function releaseLeft(): Void {
		Game.the.buttonUp(Button.LEFT);
		Game.the.keyUp(Key.LEFT, null);
		keyboard.sendUpEvent(Key.LEFT, null);
	}
	
	public static function releaseRight(): Void {
		Game.the.buttonUp(Button.RIGHT);
		Game.the.keyUp(Key.RIGHT, null);
		keyboard.sendUpEvent(Key.RIGHT, null);
	}
	
	public static function releaseButton1(): Void {
		Game.the.buttonUp(Button.BUTTON_1);
	}
	
	public static function pushChar(charCode: Int): Void {
		Game.the.keyDown(Key.CHAR, String.fromCharCode(charCode));
		keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(charCode));
	}
	
	public static function releaseChar(charCode: Int): Void {
		Game.the.keyUp(Key.CHAR, String.fromCharCode(charCode));
		keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(charCode));
	}
	
	public static function pushShift(): Void {
		Game.the.keyDown(Key.SHIFT, null);
		keyboard.sendDownEvent(Key.SHIFT, null);
	}
	
	public static function releaseShift(): Void {
		Game.the.keyUp(Key.SHIFT, null);
		keyboard.sendUpEvent(Key.SHIFT, null);
	}
	
	public static function pushBackspace(): Void {
		Game.the.keyDown(Key.BACKSPACE, null);
		keyboard.sendDownEvent(Key.BACKSPACE, null);
	}
	
	public static function releaseBackspace(): Void {
		Game.the.keyUp(Key.BACKSPACE, null);
		keyboard.sendUpEvent(Key.BACKSPACE, null);
	}
	
	public static function pushTab(): Void {
		Game.the.keyDown(Key.TAB, null);
		keyboard.sendDownEvent(Key.TAB, null);
	}
	
	public static function releaseTab(): Void {
		Game.the.keyUp(Key.TAB, null);
		keyboard.sendUpEvent(Key.TAB, null);
	}

	public static function pushEnter(): Void {
		Game.the.keyDown(Key.ENTER, null);
		keyboard.sendDownEvent(Key.ENTER, null);
	}
	
	public static function releaseEnter(): Void {
		Game.the.keyUp(Key.ENTER, null);
		keyboard.sendUpEvent(Key.ENTER, null);
	}
	
	public static function pushControl(): Void {
		Game.the.keyDown(Key.CTRL, null);
		keyboard.sendDownEvent(Key.CTRL, null);
	}
	
	public static function releaseControl(): Void {
		Game.the.keyUp(Key.CTRL, null);
		keyboard.sendUpEvent(Key.CTRL, null);
	}
	
	public static function pushAlt(): Void {
		Game.the.keyDown(Key.ALT, null);
		keyboard.sendDownEvent(Key.ALT, null);
	}
	
	public static function releaseAlt(): Void {
		Game.the.keyUp(Key.ALT, null);
		keyboard.sendUpEvent(Key.ALT, null);
	}
	
	public static function pushEscape(): Void {
		Game.the.keyDown(Key.ESC, null);
		keyboard.sendDownEvent(Key.ESC, null);
	}
	
	public static function releaseEscape(): Void {
		Game.the.keyUp(Key.ESC, null);
		keyboard.sendUpEvent(Key.ESC, null);
	}
	
	public static function pushDelete(): Void {
		Game.the.keyDown(Key.DEL, null);
		keyboard.sendDownEvent(Key.DEL, null);
	}
	
	public static function releaseDelete(): Void {
		Game.the.keyUp(Key.DEL, null);
		keyboard.sendUpEvent(Key.DEL, null);
	}
	
	public static var mouseX: Int;
	public static var mouseY: Int;
	
	public static function mouseDown(button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseDown(x, y);
		mouse.sendDownEvent(button, x, y);
	}

	public static function mouseUp(button: Int, x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseUp(x, y);
		mouse.sendUpEvent(button, x, y);
	}
	
	public static function mouseMove(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseMove(x, y);
		mouse.sendMoveEvent(x, y);
	}

	public static function mouseWheel(delta: Int): Void {
		Game.the.mouseWheel(delta);
		mouse.sendWheelEvent(delta);
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
		Game.the.onForeground();
	}

	public static function resume(): Void {
		Game.the.onResume();
	}

	public static function pause(): Void {
		Game.the.onPause();
	}

	public static function background(): Void {
		Game.the.onBackground();
	}

	public static function shutdown(): Void {
		Game.the.onShutdown();
	}
}

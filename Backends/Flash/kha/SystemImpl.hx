package kha;

import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import kha.flash.utils.AGALMiniAssembler;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.MouseImpl;
import kha.Key;
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.Vector;
import kha.System;

class SystemImpl {
	private static var width: Int;
	private static var height: Int;
	private static var frame: Framebuffer;
	private static var pressedKeys: Array<Bool>;
	private static var stage: Stage;
	private static var stage3D: Stage3D;
	private static var keyboard: Keyboard;
	private static var mouse: Mouse;
	private static var callback: Void -> Void;
	public static var context: Context3D;

	public static function init(options: SystemOptions, callback: Void -> Void) {
		SystemImpl.callback = callback;
		SystemImpl.width = options.width;
		SystemImpl.height = options.height;
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		//Loader.init(new kha.flash.Loader(this));
		Scheduler.init();

		stage = flash.Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.addEventListener(Event.RESIZE, resizeHandler);
		stage3D = stage.stage3Ds[0];
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, onReady);

		stage3D.requestContext3D(cast Context3DRenderMode.AUTO /* Context3DRenderMode.SOFTWARE */, Context3DProfile.STANDARD);

		// TODO: Move?
		kha.EnvironmentVariables.instance = new kha.flash.EnvironmentVariables();
	}

	public static function initEx( title  : String, options : Array<WindowOptions>, windowCallback : Int -> Void, callback : Void -> Void ) {
		trace('initEx is not supported on the flash-target, running init() with first window options');
		init({ title : title, width : options[0].width, height : options[0].height}, callback);

		if (windowCallback != null) {
			windowCallback(0);
		}
	}

	private static function onReady(_): Void {
		context = stage3D.context3D;
		context.configureBackBuffer(width, height, 0, true);
		keyboard = new Keyboard();
		mouse = new MouseImpl();

		#if debug
		context.enableErrorChecking = true;
		#end

		Shaders.init();
		//painter = new kha.flash.ShaderPainter(game.width, game.height); //new Painter(context);
		kha.flash.graphics4.Graphics.initContext(context);
		var g4 = new kha.flash.graphics4.Graphics();
		frame = new Framebuffer(0, null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new kha.flash.graphics4.Graphics2(frame), g4);

		kha.audio2.Audio._init();
		kha.audio1.Audio._init();

		Scheduler.start();

		callback();

		resizeHandler(null);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownHandler);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, middleMouseDownHandler);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, middleMouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);

		stage.addEventListener(Event.ENTER_FRAME, update);
	}

	private static function update(_): Void {
		Scheduler.executeFrame();
		context.setRenderToBackBuffer();
		context.clear(0, 0, 0, 0);
		System.render(0, frame);
		context.present();
	}

	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
		return keyboard;
	}

	private static function keyDownHandler(event: KeyboardEvent): Void {
		if (pressedKeys[event.keyCode]) return;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 8:
			keyboard.sendDownEvent(Key.BACKSPACE, "");
		case 9:
			keyboard.sendDownEvent(Key.TAB, "");
		case 13:
			keyboard.sendDownEvent(Key.ENTER, "");
		case 16:
			keyboard.sendDownEvent(Key.SHIFT, "");
		case 17:
			keyboard.sendDownEvent(Key.CTRL, "");
		case 18:
			keyboard.sendDownEvent(Key.ALT, "");
		case 27:
			keyboard.sendDownEvent(Key.ESC, "");
		case 46:
			keyboard.sendDownEvent(Key.DEL, "");
		case 38:
			keyboard.sendDownEvent(Key.UP, "");
		case 40:
			keyboard.sendDownEvent(Key.DOWN, "");
		case 37:
			keyboard.sendDownEvent(Key.LEFT, "");
		case 39:
			keyboard.sendDownEvent(Key.RIGHT, "");
		case 65:
			keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0) {
				keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
			}
		}
	}

	private static function keyUpHandler(event: KeyboardEvent): Void {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 8:
			keyboard.sendUpEvent(Key.BACKSPACE, "");
		case 9:
			keyboard.sendUpEvent(Key.TAB, "");
		case 13:
			keyboard.sendUpEvent(Key.ENTER, "");
		case 16:
			keyboard.sendUpEvent(Key.SHIFT, "");
		case 17:
			keyboard.sendUpEvent(Key.CTRL, "");
		case 18:
			keyboard.sendUpEvent(Key.ALT, "");
		case 27:
			keyboard.sendUpEvent(Key.ESC, "");
		case 46:
			keyboard.sendUpEvent(Key.DEL, "");
		case 38:
			keyboard.sendUpEvent(Key.UP, "");
		case 40:
			keyboard.sendUpEvent(Key.DOWN, "");
		case 37:
			keyboard.sendUpEvent(Key.LEFT, "");
		case 39:
			keyboard.sendUpEvent(Key.RIGHT, "");
		case 65:
			keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0) {
				keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
			}
		}
	}

	private static var mouseX: Int;
	private static var mouseY: Int;

	private static function setMousePosition(event: MouseEvent): Void {
		mouseX = Std.int(event.stageX);
		mouseY = Std.int(event.stageY);
	}

	private static function mouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendDownEvent(0, 0, mouseX, mouseY);
	}

	private static function mouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendUpEvent(0, 0, mouseX, mouseY);
	}

	private static function rightMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendDownEvent(0, 1, mouseX, mouseY);
	}

	private static function rightMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendUpEvent(0, 1, mouseX, mouseY);
	}

	private static function middleMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendDownEvent(0, 2, mouseX, mouseY);
	}

	private static function middleMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendUpEvent(0, 2, mouseX, mouseY);
	}

	private static function mouseMoveHandler(event: MouseEvent): Void {
		var movementX = Std.int(event.stageY) - mouseX;
		var movementY = Std.int(event.stageY) - mouseY;
		setMousePosition(event);
		mouse.sendMoveEvent(0, mouseX, mouseY, movementX, movementX);
	}

	private static function mouseWheelHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendWheelEvent(0, event.delta);
	}

	private static function resizeHandler(event: Event): Void {
		if (frame != null && stage.stageWidth >= 32 && stage.stageHeight >= 32) {
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);
		}
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getTime(): Float {
		return Lib.getTimer() / 1000;
	}

	public static function windowWidth( windowId : Int = 0 ): Int {
		return Lib.current.stage.stageWidth;
	}

	public static function windowHeight( windowId : Int = 0 ): Int {
		return Lib.current.stage.stageHeight;
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "Flash";
	}

	public static function requestShutdown(): Void {
		System.pause();
		System.background();
		System.shutdown();
		flash.Lib.fscommand("quit");
	}

	public static function canSwitchFullscreen(): Bool{
		return false;
	}

	public static function isFullscreen(): Bool{
		return false;
	}

	public static function requestFullscreen(): Void {

	}

	public static function exitFullscreen(): Void {

  	}

	public function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {

	}


	public function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {

	}

	public static function changeResolution(width: Int, height: Int): Void {

	}
	
	public static function setKeepScreenOn(on: Bool): Void {
		
	}
}

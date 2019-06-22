package kha;

import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.net.URLRequest;
import flash.system.Capabilities;
import kha.flash.utils.AGALMiniAssembler;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Mouse;
import kha.input.MouseImpl;
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
	private static var callback: Window -> Void;
	public static var context: Context3D;

	public static function init(options: SystemOptions, callback: Window -> Void) {
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
	}

	private static function onReady(_): Void {
		context = stage3D.context3D;
		context.configureBackBuffer(width, height, 0, true);
		keyboard = new Keyboard();
		mouse = new MouseImpl();

		#if debug
		context.enableErrorChecking = true;
		#end

		new Window();
		Shaders.init();
		//painter = new kha.flash.ShaderPainter(game.width, game.height); //new Painter(context);
		kha.flash.graphics4.Graphics.initContext(context);
		var g4 = new kha.flash.graphics4.Graphics();
		frame = new Framebuffer(0, null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new kha.flash.graphics4.Graphics2(frame), g4);

		kha.audio2.Audio._init();
		kha.audio1.Audio._init();

		Scheduler.start();

		callback(Window.get(0));

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
		stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);

		stage.addEventListener(Event.ENTER_FRAME, update);
	}

	private static function update(_): Void {
		Scheduler.executeFrame();
		context.setRenderToBackBuffer();
		context.clear(0, 0, 0, 0);
		System.render([frame]);
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
		keyboard.sendDownEvent(cast event.keyCode);
		if (event.charCode != 0) {
			keyboard.sendPressEvent(String.fromCharCode(event.charCode));
		}
	}

	private static function keyUpHandler(event: KeyboardEvent): Void {
		pressedKeys[event.keyCode] = false;
		keyboard.sendUpEvent(cast event.keyCode);
	}

	private static var mouseX: Int;
	private static var mouseY: Int;

	private static function setMousePosition(event: MouseEvent): Void {
		mouseX = Std.int(event.stageX);
		mouseY = Std.int(event.stageY);
	}

	private static function mouseLeaveHandler(event: Event): Void {
		mouse.sendLeaveEvent(0);
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
		var movementX = Std.int(event.stageX) - mouseX;
		var movementY = Std.int(event.stageY) - mouseY;
		setMousePosition(event);
		mouse.sendMoveEvent(0, mouseX, mouseY, movementX, movementY);
	}

	private static function mouseWheelHandler(event: MouseEvent): Void {
		setMousePosition(event);
		mouse.sendWheelEvent(0, -event.delta);
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

	public static function getSystemId(): String {
		return "Flash";
	}

	public static function vibrate(ms:Int): Void {

	}

	public static function getLanguage(): String {
		return Capabilities.language;
	}

	public static function requestShutdown(): Bool {
		System.pause();
		System.background();
		System.shutdown();
		flash.Lib.fscommand("quit");
		return true;
	}

	public static function setKeepScreenOn(on: Bool): Void {

	}

	public static function loadUrl(url: String): Void {
		Lib.getURL(new URLRequest(url), "_blank");
	}

	public static function getGamepadId(index: Int): String {
		return "unkown";
	}

	public static function getPen(num: Int): kha.input.Pen {
		return null;
	}

	public static function safeZone(): Float {
		return 1.0;
	}
}

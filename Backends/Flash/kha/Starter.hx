package kha;

import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import kha.flash.utils.AGALMiniAssembler;
import kha.flash.utils.PerspectiveMatrix3D;
import kha.Game;
import kha.input.Keyboard;
import kha.Key;
import kha.Loader;
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

class Starter {
	private var gameToStart: Game;
	private var frame: Framebuffer;
	private var pressedKeys: Array<Bool>;
	private var stage: Stage;
	private var stage3D: Stage3D;
	private var keyboard: Keyboard;
	private var mouse: kha.input.Mouse;
	public static var context: Context3D;
	
	public function new() {
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		Loader.init(new kha.flash.Loader(this));
		Scheduler.init();
	}
	
	public function start(game: Game): Void {
		stage = flash.Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.addEventListener(Event.RESIZE, resizeHandler);
		stage3D = stage.stage3Ds[0];
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, onReady);
		gameToStart = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
		
		// TODO: Move?
		kha.EnvironmentVariables.instance = new kha.flash.EnvironmentVariables();
	}
	
	public function loadFinished(): Void {
		Loader.the.initProject();
		gameToStart.width = Loader.the.width;
		gameToStart.height = Loader.the.height;
		stage3D.requestContext3D(Context3DRenderMode.AUTO /* Context3DRenderMode.SOFTWARE */, Context3DProfile.STANDARD);
	}
	
	private function onReady(_): Void {
		context = stage3D.context3D;
		context.configureBackBuffer(Loader.the.width, Loader.the.height, 0, false);
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		Sys.init();
		#if debug
		context.enableErrorChecking = true;
		#end
		
		//painter = new kha.flash.ShaderPainter(game.width, game.height); //new Painter(context);
		kha.flash.graphics4.Graphics.initContext(context);
		var g4 = new kha.flash.graphics4.Graphics();
		frame = new Framebuffer(null, null, g4);
		frame.init(new kha.graphics2.Graphics1(frame), new kha.flash.graphics4.Graphics2(frame), g4);
		
		kha.audio2.Audio._init();
		kha.audio1.Audio._init();
		
		Configuration.setScreen(gameToStart);
		Scheduler.start();
		gameToStart.loadFinished();
		
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
	
	private function update(_): Void {
		Scheduler.executeFrame();
		context.clear(0, 0, 0, 0);
		Configuration.screen().render(frame);
		context.present();
	}
	
	private function keyDownHandler(event: KeyboardEvent): Void {
		if (pressedKeys[event.keyCode]) return;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 8:
			Game.the.keyDown(Key.BACKSPACE, "");
			keyboard.sendDownEvent(Key.BACKSPACE, "");
		case 9:
			Game.the.keyDown(Key.TAB, "");
			keyboard.sendDownEvent(Key.TAB, "");
		case 13:
			Game.the.keyDown(Key.ENTER, "");
			keyboard.sendDownEvent(Key.ENTER, "");
		case 16:
			Game.the.keyDown(Key.SHIFT, "");
			keyboard.sendDownEvent(Key.SHIFT, "");
		case 17:
			Game.the.keyDown(Key.CTRL, "");
			keyboard.sendDownEvent(Key.CTRL, "");
		case 18:
			Game.the.keyDown(Key.ALT, "");
			keyboard.sendDownEvent(Key.ALT, "");
		case 27:
			Game.the.keyDown(Key.ESC, "");
			keyboard.sendDownEvent(Key.ESC, "");
		case 46:
			Game.the.keyDown(Key.DEL, "");
			keyboard.sendDownEvent(Key.DEL, "");
		case 38:
			Game.the.buttonDown(Button.UP);
			keyboard.sendDownEvent(Key.UP, "");
		case 40:
			Game.the.buttonDown(Button.DOWN);
			keyboard.sendDownEvent(Key.DOWN, "");
		case 37:
			Game.the.buttonDown(Button.LEFT);
			keyboard.sendDownEvent(Key.LEFT, "");
		case 39:
			Game.the.buttonDown(Button.RIGHT);
			keyboard.sendDownEvent(Key.RIGHT, "");
		case 65:
			Game.the.buttonDown(Button.BUTTON_1); // This is also an 'a'
			Game.the.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			Game.the.buttonDown(Button.BUTTON_2); // This is also an 's'
			Game.the.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0) {
				Game.the.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
				keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
			}
		}
	}

	private function keyUpHandler(event: KeyboardEvent): Void {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 8:
			Game.the.keyUp(Key.BACKSPACE, "");
			keyboard.sendUpEvent(Key.BACKSPACE, "");
		case 9:
			Game.the.keyUp(Key.TAB, "");
			keyboard.sendUpEvent(Key.TAB, "");
		case 13:
			Game.the.keyUp(Key.ENTER, "");
			keyboard.sendUpEvent(Key.ENTER, "");
		case 16:
			Game.the.keyUp(Key.SHIFT, "");
			keyboard.sendUpEvent(Key.SHIFT, "");
		case 17:
			Game.the.keyUp(Key.CTRL, "");
			keyboard.sendUpEvent(Key.CTRL, "");
		case 18:
			Game.the.keyUp(Key.ALT, "");
			keyboard.sendUpEvent(Key.ALT, "");
		case 27:
			Game.the.keyUp(Key.ESC, "");
			keyboard.sendUpEvent(Key.ESC, "");
		case 46:
			Game.the.keyUp(Key.DEL, "");
			keyboard.sendUpEvent(Key.DEL, "");
		case 38:
			Game.the.buttonUp(Button.UP);
			keyboard.sendUpEvent(Key.UP, "");
		case 40:
			Game.the.buttonUp(Button.DOWN);
			keyboard.sendUpEvent(Key.DOWN, "");
		case 37:
			Game.the.buttonUp(Button.LEFT);
			keyboard.sendUpEvent(Key.LEFT, "");
		case 39:
			Game.the.buttonUp(Button.RIGHT);
			keyboard.sendUpEvent(Key.RIGHT, "");
		case 65:
			Game.the.buttonUp(Button.BUTTON_1); // This is also an 'a'
			Game.the.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			Game.the.buttonUp(Button.BUTTON_2); // This is also an 's'
			Game.the.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0) {
				Game.the.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
				keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
			}
		}
	}
	
	private static var mouseX: Int;
	private static var mouseY: Int;
	
	private function setMousePosition(event: MouseEvent): Void {
		mouseX = Std.int(event.stageX);
		mouseY = Std.int(event.stageY);
	}
	
	private function mouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.mouseDown(mouseX, mouseY);
		mouse.sendDownEvent(0, mouseX, mouseY);
	}
	
	private function mouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.mouseUp(mouseX, mouseY);
		mouse.sendUpEvent(0, mouseX, mouseY);
	}
	
	private function rightMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.rightMouseDown(mouseX, mouseY);
		mouse.sendDownEvent(1, mouseX, mouseY);
	}
	
	private function rightMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.rightMouseUp(mouseX, mouseY);
		mouse.sendUpEvent(1, mouseX, mouseY);
	}
	
	private function middleMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.middleMouseDown(mouseX, mouseY);
		mouse.sendDownEvent(2, mouseX, mouseY);
	}
	
	private function middleMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.middleMouseUp(mouseX, mouseY);
		mouse.sendUpEvent(2, mouseX, mouseY);
	}
	
	private function mouseMoveHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.mouseMove(mouseX, mouseY);
		mouse.sendMoveEvent(mouseX, mouseY);
	}

	private function mouseWheelHandler(event: MouseEvent): Void {
		setMousePosition(event);
		Game.the.mouseWheel(event.delta);
		mouse.sendWheelEvent(event.delta);
	}
	
	private function resizeHandler(event: Event): Void {
		if (frame != null && stage.stageWidth >= 32 && stage.stageHeight >= 32) {
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
		}
	}
}

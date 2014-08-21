package kha;

import flash.display.StageScaleMode;
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
	private var game: Game;
	//private var painter: kha.flash.ShaderPainter;
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
		this.game = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
		
		// TODO: Move?
		kha.EnvironmentVariables.instance = new kha.flash.EnvironmentVariables();
	}
	
	public function loadFinished(): Void {
		Loader.the.initProject();
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		stage3D.requestContext3D("auto" /*"software"*/); //, Context3DProfile.BASELINE_EXTENDED);
	}
	
	private function onReady(_): Void {
		context = stage3D.context3D;
		context.configureBackBuffer(game.width, game.height, 0, false);
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		Sys.init();
		#if debug
		context.enableErrorChecking = true;
		#end
		
		//painter = new kha.flash.ShaderPainter(game.width, game.height); //new Painter(context);
		kha.flash.graphics4.Graphics.initContext(context);
		var g4 = new kha.flash.graphics4.Graphics();
		frame = new Framebuffer(new kha.flash.graphics4.Graphics2(g4, game.width, game.height), g4);
		
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		Scheduler.start();
		game.loadFinished();
		
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
			game.keyDown(Key.BACKSPACE, "");
			keyboard.sendDownEvent(Key.BACKSPACE, "");
		case 9:
			game.keyDown(Key.TAB, "");
			keyboard.sendDownEvent(Key.TAB, "");
		case 13:
			game.keyDown(Key.ENTER, "");
			keyboard.sendDownEvent(Key.ENTER, "");
		case 16:
			game.keyDown(Key.SHIFT, "");
			keyboard.sendDownEvent(Key.SHIFT, "");
		case 17:
			game.keyDown(Key.CTRL, "");
			keyboard.sendDownEvent(Key.CTRL, "");
		case 18:
			game.keyDown(Key.ALT, "");
			keyboard.sendDownEvent(Key.ALT, "");
		case 27:
			game.keyDown(Key.ESC, "");
			keyboard.sendDownEvent(Key.ESC, "");
		case 46:
			game.keyDown(Key.DEL, "");
			keyboard.sendDownEvent(Key.DEL, "");
		case 38:
			game.buttonDown(Button.UP);
			keyboard.sendDownEvent(Key.UP, "");
		case 40:
			game.buttonDown(Button.DOWN);
			keyboard.sendDownEvent(Key.DOWN, "");
		case 37:
			game.buttonDown(Button.LEFT);
			keyboard.sendDownEvent(Key.LEFT, "");
		case 39:
			game.buttonDown(Button.RIGHT);
			keyboard.sendDownEvent(Key.RIGHT, "");
		case 65:
			game.buttonDown(Button.BUTTON_1); // This is also an 'a'
			game.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			game.buttonDown(Button.BUTTON_2); // This is also an 's'
			game.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0) {
				game.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
				keyboard.sendDownEvent(Key.CHAR, String.fromCharCode(event.charCode));
			}
		}
	}

	private function keyUpHandler(event: KeyboardEvent): Void {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 8:
			game.keyUp(Key.BACKSPACE, "");
			keyboard.sendUpEvent(Key.BACKSPACE, "");
		case 9:
			game.keyUp(Key.TAB, "");
			keyboard.sendUpEvent(Key.TAB, "");
		case 13:
			game.keyUp(Key.ENTER, "");
			keyboard.sendUpEvent(Key.ENTER, "");
		case 16:
			game.keyUp(Key.SHIFT, "");
			keyboard.sendUpEvent(Key.SHIFT, "");
		case 17:
			game.keyUp(Key.CTRL, "");
			keyboard.sendUpEvent(Key.CTRL, "");
		case 18:
			game.keyUp(Key.ALT, "");
			keyboard.sendUpEvent(Key.ALT, "");
		case 27:
			game.keyUp(Key.ESC, "");
			keyboard.sendUpEvent(Key.ESC, "");
		case 46:
			game.keyUp(Key.DEL, "");
			keyboard.sendUpEvent(Key.DEL, "");
		case 38:
			game.buttonUp(Button.UP);
			keyboard.sendUpEvent(Key.UP, "");
		case 40:
			game.buttonUp(Button.DOWN);
			keyboard.sendUpEvent(Key.DOWN, "");
		case 37:
			game.buttonUp(Button.LEFT);
			keyboard.sendUpEvent(Key.LEFT, "");
		case 39:
			game.buttonUp(Button.RIGHT);
			keyboard.sendUpEvent(Key.RIGHT, "");
		case 65:
			game.buttonUp(Button.BUTTON_1); // This is also an 'a'
			game.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			game.buttonUp(Button.BUTTON_2); // This is also an 's'
			game.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
			keyboard.sendUpEvent(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0) {
				game.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
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
		game.mouseDown(mouseX, mouseY);
		mouse.sendDownEvent(0, mouseX, mouseY);
	}
	
	private function mouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.mouseUp(mouseX, mouseY);
		mouse.sendUpEvent(0, mouseX, mouseY);
	}
	
	private function rightMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.rightMouseDown(mouseX, mouseY);
		mouse.sendDownEvent(1, mouseX, mouseY);
	}
	
	private function rightMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.rightMouseUp(mouseX, mouseY);
		mouse.sendUpEvent(1, mouseX, mouseY);
	}
	
	private function middleMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.middleMouseDown(mouseX, mouseY);
		mouse.sendDownEvent(2, mouseX, mouseY);
	}
	
	private function middleMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.middleMouseUp(mouseX, mouseY);
		mouse.sendUpEvent(2, mouseX, mouseY);
	}
	
	private function mouseMoveHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.mouseMove(mouseX, mouseY);
		mouse.sendMoveEvent(mouseX, mouseY);
	}

	private function mouseWheelHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.mouseWheel(event.delta);
		mouse.sendWheelEvent(event.delta);
	}
	
	private function resizeHandler(event: Event): Void {
		if (frame != null) {
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
		}
	}
}

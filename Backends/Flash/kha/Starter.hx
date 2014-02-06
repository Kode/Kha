package kha;

import flash.display.StageScaleMode;
import kha.flash.utils.AGALMiniAssembler;
import kha.flash.utils.PerspectiveMatrix3D;
import kha.Game;
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
	var game: Game;
	var painter: kha.flash.ShaderPainter;
	var pressedKeys: Array<Bool>;
	var stage: Stage;
	var stage3D: Stage3D;
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
	
	function onReady(_): Void {
		context = stage3D.context3D;
		context.configureBackBuffer(game.width, game.height, 0, false);
		Sys.init(context);
		#if debug
		context.enableErrorChecking = true;
		#end
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		Scheduler.start();
		game.loadFinished();
		
		painter = new kha.flash.ShaderPainter(game.width, game.height); //new Painter(context);
		resizeHandler(null);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownHandler);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler);
		
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	function update(_): Void {
		Scheduler.executeFrame();
		context.clear(0, 0, 0, 0);
		Configuration.screen().render(painter);
		context.present();
	}
	
	function keyDownHandler(event: KeyboardEvent): Void {
		if (pressedKeys[event.keyCode]) return;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 8:
			game.keyDown(Key.BACKSPACE, "");
		case 9:
			game.keyDown(Key.TAB, "");
		case 13:
			game.keyDown(Key.ENTER, "");
		case 16:
			game.keyDown(Key.SHIFT, "");
		case 17:
			game.keyDown(Key.CTRL, "");
		case 18:
			game.keyDown(Key.ALT, "");
		case 27:
			game.keyDown(Key.ESC, "");
		case 46:
			game.keyDown(Key.DEL, "");
		case 38:
			game.buttonDown(Button.UP);
		case 40:
			game.buttonDown(Button.DOWN);
		case 37:
			game.buttonDown(Button.LEFT);
		case 39:
			game.buttonDown(Button.RIGHT);
		case 65:
			game.buttonDown(Button.BUTTON_1); // This is also an 'a'
			game.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			game.buttonDown(Button.BUTTON_2); // This is also an 's'
			game.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0)
				game.keyDown(Key.CHAR, String.fromCharCode(event.charCode));
		}
	}

	function keyUpHandler(event: KeyboardEvent): Void {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 8:
			game.keyUp(Key.BACKSPACE, "");
		case 9:
			game.keyUp(Key.TAB, "");
		case 13:
			game.keyUp(Key.ENTER, "");
		case 16:
			game.keyUp(Key.SHIFT, "");
		case 17:
			game.keyUp(Key.CTRL, "");
		case 18:
			game.keyUp(Key.ALT, "");
		case 27:
			game.keyUp(Key.ESC, "");
		case 46:
			game.keyUp(Key.DEL, "");
		case 38:
			game.buttonUp(Button.UP);
		case 40:
			game.buttonUp(Button.DOWN);
		case 37:
			game.buttonUp(Button.LEFT);
		case 39:
			game.buttonUp(Button.RIGHT);
		case 65:
			game.buttonUp(Button.BUTTON_1); // This is also an 'a'
			game.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
		case 83:
			game.buttonUp(Button.BUTTON_2); // This is also an 's'
			game.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
		default:
			if (event.charCode != 0)
				game.keyUp(Key.CHAR, String.fromCharCode(event.charCode));
		}
	}
	
	private static var mouseX: Int;
	private static var mouseY: Int;
	
	private function setMousePosition(event: MouseEvent): Void {
		mouseX = Std.int((event.stageX - borderX) / scale);
		mouseY = Std.int((event.stageY - borderY) / scale);
	}
	
	function mouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.mouseDown(mouseX, mouseY);
	}
	
	function mouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.mouseUp(mouseX, mouseY);
	}
	
	function rightMouseDownHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.rightMouseDown(mouseX, mouseY);
	}
	
	function rightMouseUpHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.rightMouseUp(mouseX, mouseY);
	}
	
	function mouseMoveHandler(event: MouseEvent): Void {
		setMousePosition(event);
		game.mouseMove(mouseX, mouseY);
	}
	
	private var borderX: Float;
	private var borderY: Float;
	private var scale: Float;
	
	function resizeHandler(event: Event): Void {
		var gameRatio = Game.the.width / Game.the.height;
		var screenRatio = stage.stageWidth / stage.stageHeight;
		var realHeight;
		var realWidth;
		if (gameRatio > screenRatio) {
			scale = stage.stageWidth / Game.the.width;
			realWidth = Game.the.width * scale;
			realHeight = Game.the.height * scale;
			borderX = 0;
			// 1000:100 = 10
			// 100:100 = 1
			// => scale = 100/1000 = 0.1
			// => borderY = 100*0.1
			borderY = (stage.stageHeight - realHeight) * 0.5;
		} else {
			scale = stage.stageHeight / Game.the.height;
			realWidth = Game.the.width * scale;
			realHeight = Game.the.height * scale;
			// 100:1000 = 0.1
			// 100:100 = 1
			// => scale = 100/1000 = 0.1
			// => borderX = 100 - 100*0.1
			borderX= (stage.stageWidth - realWidth) * 0.5;
			borderY = 0;
		}
		if (painter != null) {
			#if debug
			trace( 'stageSize = ${stage.stageWidth} / ${stage.stageHeight}' );
			trace( ' gameSize = ${Game.the.width} / ${Game.the.height}' );
			trace( ' realSize = $realWidth / $realHeight' );
			trace( '   border = $borderX / $borderY' );
			#end
			context.configureBackBuffer( stage.stageWidth, stage.stageHeight, 0, false );
			//painter.setScreenSize(Game.the.width, Game.the.height, borderX/scale, borderY/scale);
		}
	}
}

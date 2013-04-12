package kha;

import flash.display.StageScaleMode;
import kha.flash.utils.AGALMiniAssembler;
import kha.flash.utils.PerspectiveMatrix3D;
import kha.Game;
import kha.Key;
import kha.Loader;
import kha.flash.Painter;
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
	var painter: ShaderPainter;
	var pressedKeys: Array<Bool>;
	var stage: Stage;
	var stage3D: Stage3D;
	public static var context: Context3D;
	
	public function new() {
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		Storage.init(new kha.flash.Storage());
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
	}
	
	public function loadFinished(): Void {
		Loader.the.initProject();
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		stage3D.requestContext3D(
			//"software"
		);
	}
	
	function onReady(_): Void {
		context = stage3D.context3D;
		Sys.init(context);
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		Scheduler.start();
		game.loadFinished();
		
		painter = new ShaderPainter(game.width, game.height); //new Painter(context);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	function update(_): Void {
		Scheduler.executeFrame();
		painter.begin();
		Configuration.screen().render(painter);
		painter.end();
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
	
	function mouseDownHandler(event: MouseEvent): Void {
		//var xy = painter.calculateGamePosition(event.stageX, event.stageY);
		//game.mouseDown(Std.int(xy.x), Std.int(xy.y));
	}
	
	function mouseUpHandler(event: MouseEvent): Void {
		//var xy = painter.calculateGamePosition(event.stageX, event.stageY);
		//game.mouseUp(Std.int(xy.x), Std.int(xy.y));
	}
	
	function mouseMoveHandler(event: MouseEvent): Void {
		//var xy = painter.calculateGamePosition(event.stageX, event.stageY);
		//game.mouseMove(Std.int(xy.x), Std.int(xy.y));
	}
	
	function resizeHandler(event: Event): Void {
		//painter.resize();
	}
}

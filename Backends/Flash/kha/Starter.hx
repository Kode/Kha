package kha;

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
	var screen : Game;
	var game : Game;
	var painter : Painter;
	var pressedKeys : Array<Bool>;
	var stage : Stage;
	var stage3D : Stage3D;
	public static var context : Context3D;
	
	public function new() {
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		Storage.init(new kha.flash.Storage());
		Loader.init(new kha.flash.Loader(this));
	}
	
	public function start(game : Game) {
		stage = flash.Lib.current.stage;
		stage3D = stage.stage3Ds[0];
		stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onReady);
		this.game = game;
		Loader.getInstance().preLoad();
		if (Loader.getInstance().getWidth() > 0 && Loader.getInstance().getHeight() > 0) {
			game.setWidth(Loader.getInstance().getWidth());
			game.setHeight(Loader.getInstance().getHeight());
		}
		screen = new LoadingScreen(game.getWidth(), game.getHeight());
		Loader.getInstance().load();
	}
	
	public function loadFinished() {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage3D.requestContext3D(
			//"software"
		);
		screen = game;
		screen.setInstance();
		game.loadFinished();
	}
	
	function onReady(_) : Void {
		context = stage3D.context3D;
		painter = new Painter(context, stage.stageWidth, stage.stageHeight);

		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	function update(_) {
		screen.update();
		painter.begin();
		screen.render(painter);
		painter.end();
	}
	
	function keyDownHandler(event : KeyboardEvent) : Void {
		if (pressedKeys[event.keyCode]) return;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 8:
			game.keyDown(Key.BACKSPACE, "");
		case 13:
			game.keyDown(Key.ENTER, "");
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

	function keyUpHandler(event : KeyboardEvent) : Void {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 8:
			game.keyUp(Key.BACKSPACE, "");
		case 13:
			game.keyUp(Key.ENTER, "");
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
	
	function mouseDownHandler(event : MouseEvent) : Void {
		game.mouseDown(Std.int(event.stageX), Std.int(event.stageY));
	}
	
	function mouseUpHandler(event : MouseEvent) : Void {
		game.mouseUp(Std.int(event.stageX), Std.int(event.stageY));
	}
	
	function mouseMoveHandler(event : MouseEvent) : Void {
		game.mouseMove(Std.int(event.stageX), Std.int(event.stageY));
	}
}
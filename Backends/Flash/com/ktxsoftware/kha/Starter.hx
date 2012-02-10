package com.ktxsoftware.kha;

import com.ktxsoftware.flash.utils.AGALMiniAssembler;
import com.ktxsoftware.flash.utils.PerspectiveMatrix3D;
import com.ktxsoftware.kha.Game;
import com.ktxsoftware.kha.Key;
import com.ktxsoftware.kha.Loader;
import com.ktxsoftware.kha.backends.flash.Painter;
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
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

class Starter /*extends MovieClip*/ {
	var game : Game;
	var painter : Painter;
	var pressedKeys : Array<Bool>;
	var stage : Stage;
	var stage3D : Stage3D;
	var context : Context3D;
	var indexBuffer : IndexBuffer3D;
	
	public function new() {
		//super();
		pressedKeys = new Array<Bool>();
		for (i in 0...256) pressedKeys.push(false);
		Loader.init(new com.ktxsoftware.kha.backends.flash.Loader(this));
	}
	
	public function start(game : Game) {
		this.game = game;
		Loader.getInstance().load();
	}
	
	public function loadFinished() {
		game.init();
		painter = new Painter();
		//Lib.current.addChild(this);
		//stage.frameRate = 60;
		stage = flash.Lib.current.stage;
		stage3D = stage.stage3Ds[0];
		stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onReady);
		//flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage3D.requestContext3D();
		//Lib.current.addEventListener(Event.ENTER_FRAME, draw);
	}
	
	function onReady( _ ) : Void {
		context = stage3D.context3D;
		context.enableErrorChecking = true;
		context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);

		var vertexShader : Array<String> =
		[
			  // Transform our vertices by our projection matrix and move it into temporary register
			  "m44 vt0, va0, vc0",
			  // Move the temporary register to out position for this vertex
			  "mov op, vt0"
		];
		
		var fragmentShader : Array<String> =
		[
			  // Simply assing the fragment constant to our out color
			  "mov oc, fc0"
		];

		var program : Program3D = context.createProgram();
		var vertexAssembler : AGALMiniAssembler = new AGALMiniAssembler();
		vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join("\n"));
		var fragmentAssembler : AGALMiniAssembler = new AGALMiniAssembler();
		fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.join("\n"));
		program.upload(vertexAssembler.agalcode(), fragmentAssembler.agalcode());
		context.setProgram(program);
   
		indexBuffer = context.createIndexBuffer(3);
		var vec = new Vector<UInt>(3);
		vec[0] = 0; vec[1] = 1; vec[2] = 2;
		indexBuffer.uploadFromVector(vec, 0, 3);
   
		var vertexBuffer = context.createVertexBuffer(3, 3);
		var vec2 = new Vector<Float>(9);
		vec2[0] = 100; vec2[1] = 100; vec2[2] = 5;
		vec2[3] = 300; vec2[4] = 100; vec2[5] = 5;
		vec2[6] = 200; vec2[7] = 300; vec2[8] = 5;
		vertexBuffer.uploadFromVector(vec2, 0, 3);

		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);

		var projection : PerspectiveMatrix3D = new PerspectiveMatrix3D();
		projection.orthoLH(640, 480, 0.1, 512);
		//projection.perspectiveFieldOfViewLH(45 * Math.PI / 180, 1.2, 0.1, 512);
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, projection, true);
		var vec3 = new Vector<Float>(4);
		vec3[0] = 1; vec3[1] = 1; vec3[2] = 1; vec3[3] = 0;
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vec3);
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	function update(_) {
		context.clear(0, 0, 0, 0);
		context.drawTriangles(indexBuffer, 0, 1);
		context.present();
	}

	function draw(e : Event) {
		//game.update();
		game.update();
		//painter.setGraphics(graphics);
		painter.begin();
		game.render(painter);
		painter.end();
	}
	
	function keyDownHandler(event : KeyboardEvent) {
		if (pressedKeys[event.keyCode]) return;
		pressedKeys[event.keyCode] = true;
		switch (event.keyCode) {
		case 38:
			game.key(new KeyEvent(Key.UP, true));
		case 40:
			game.key(new KeyEvent(Key.DOWN, true));
		case 37:
			game.key(new KeyEvent(Key.LEFT, true));
		case 39:
			game.key(new KeyEvent(Key.RIGHT, true));
		case 65:
			game.key(new KeyEvent(Key.BUTTON_1, true));
		}
	}

	function keyUpHandler(event : KeyboardEvent) {
		pressedKeys[event.keyCode] = false;
		switch (event.keyCode) {
		case 38:
			game.key(new KeyEvent(Key.UP, false));
		case 40:
			game.key(new KeyEvent(Key.DOWN, false));
		case 37:
			game.key(new KeyEvent(Key.LEFT, false));
		case 39:
			game.key(new KeyEvent(Key.RIGHT, false));
		case 65:
			game.key(new KeyEvent(Key.BUTTON_1, false));
		}
	}
}
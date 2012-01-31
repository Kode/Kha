package com.ktxsoftware.kha;

import com.ktxsoftware.kha.backends.flash.AGALMiniAssembler;
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
		vec2[0] = -1; vec2[1] = -1; vec2[2] = 5;
		vec2[3] = 1; vec2[4] = -1; vec2[5] = 5;
		vec2[6] = 0; vec2[7] = 1; vec2[8] = 5;
		vertexBuffer.uploadFromVector(vec2, 0, 3);

		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);

		var projection : PerspectiveMatrix3D = new PerspectiveMatrix3D();
		projection.perspectiveFieldOfViewLH(45 * Math.PI / 180, 1.2, 0.1, 512);
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

class PerspectiveMatrix3D extends Matrix3D
	{
		public function new(v:Vector<Float> = null)
		{
			super(v);
			_x = new Vector3D();
			_y = new Vector3D();
			_z = new Vector3D();
			_w = new Vector3D();
		}

		public function lookAtLH(eye:Vector3D, at:Vector3D, up:Vector3D):Void {
			_z.copyFrom(at);
			_z.subtract(eye);
			_z.normalize();
			_z.w = 0.0;

			_x.copyFrom(up);
			_crossProductTo(_x,_z);
			_x.normalize();
			_x.w = 0.0;

			_y.copyFrom(_z);
			_crossProductTo(_y,_x);
			_y.w = 0.0;

			_w.x = _x.dotProduct(eye);
			_w.y = _y.dotProduct(eye);
			_w.z = _z.dotProduct(eye);
			_w.w = 1.0;

			copyRowFrom(0,_x);
			copyRowFrom(1,_y);
			copyRowFrom(2,_z);
			copyRowFrom(3,_w);
		}

		public function lookAtRH(eye:Vector3D, at:Vector3D, up:Vector3D):Void {
			_z.copyFrom(eye);
			_z.subtract(at);
			_z.normalize();
			_z.w = 0.0;

			_x.copyFrom(up);
			_crossProductTo(_x,_z);
			_x.normalize();
			_x.w = 0.0;

			_y.copyFrom(_z);
			_crossProductTo(_y,_x);
			_y.w = 0.0;

			_w.x = _x.dotProduct(eye);
			_w.y = _y.dotProduct(eye);
			_w.z = _z.dotProduct(eye);
			_w.w = 1.0;

			copyRowFrom(0,_x);
			copyRowFrom(1,_y);
			copyRowFrom(2,_z);
			copyRowFrom(3,_w);
		}

		/*public function perspectiveLH(width:Float, 
									  height:Float, 
									  zNear:Float, 
									  zFar:Float):Void {
			this.copyRawDataFrom(new Vector<Float>([
				2.0*zNear/width, 0.0, 0.0, 0.0,
				0.0, 2.0*zNear/height, 0.0, 0.0,
				0.0, 0.0, zFar/(zFar-zNear), 1.0,
				0.0, 0.0, zNear*zFar/(zNear-zFar), 0.0
			]));
		}

		public function perspectiveRH(width:Float, 
									  height:Float, 
									  zNear:Float, 
									  zFar:Float):Void {
			this.copyRawDataFrom(new Vector<Float>([
				2.0*zNear/width, 0.0, 0.0, 0.0,
				0.0, 2.0*zNear/height, 0.0, 0.0,
				0.0, 0.0, zFar/(zNear-zFar), -1.0,
				0.0, 0.0, zNear*zFar/(zNear-zFar), 0.0
			]));
		}*/

		public function perspectiveFieldOfViewLH(fieldOfViewY:Float, aspectRatio:Float, zNear:Float, zFar : Float) : Void {
			var yScale:Float = 1.0/Math.tan(fieldOfViewY/2.0);
			var xScale:Float = yScale / aspectRatio;
			var vec = new Vector<Float>(16);
			vec[0] = xScale; vec[1] = 0.0; vec[2] = 0.0; vec[3] = 0.0;
			vec[4] = 0.0; vec[5] = yScale; vec[6] = 0.0; vec[7] = 0.0;
			vec[8] = 0.0; vec[9] = 0.0; vec[10] = zFar / (zFar - zNear); vec[11] = 1.0;
			vec[12] = 0.0; vec[13] = 0.0; vec[14] = (zNear * zFar) / (zNear - zFar); vec[15] = 0.0;
			this.copyRawDataFrom(vec);
		}

		/*public function perspectiveFieldOfViewRH(fieldOfViewY:Float, 
												 aspectRatio:Float, 
												 zNear:Float, 
												 zFar:Float):Void {
			var yScale:Float = 1.0/Math.tan(fieldOfViewY/2.0);
			var xScale:Float = yScale / aspectRatio; 
			this.copyRawDataFrom(new Vector<Float>([
				xScale, 0.0, 0.0, 0.0,
				0.0, yScale, 0.0, 0.0,
				0.0, 0.0, zFar/(zNear-zFar), -1.0,
				0.0, 0.0, (zNear*zFar)/(zNear-zFar), 0.0
			]));
		}*/

		public function perspectiveOffCenterLH(left:Float, right:Float, bottom:Float, top:Float, zNear:Float, zFar:Float) : Void {
			var vec : Vector<Float> = new Vector<Float>(16);
			vec[0] = 2.0 * zNear / (right - left); vec[1] = 0.0; vec[2] = 0.0; vec[3] = 0.0;
			vec[4] = 0.0; vec[5] = -2.0 * zNear / (bottom - top); vec[6] = 0.0; vec[7] = 0.0;
			vec[8] = -1.0 - 2.0 * left / (right - left); vec[9] = 1.0 + 2.0 * top / (bottom - top); vec[10] = -zFar / (zNear - zFar); vec[11] = 1.0;
			vec[12] = 0.0; vec[13] = 0.0; vec[14] = (zNear * zFar) / (zNear - zFar); vec[15] = 0.0;
			this.copyRawDataFrom(vec);
		}

		/*public function perspectiveOffCenterRH(left:Float, 
											   right:Float,
											   bottom:Float,
											   top:Float,
											   zNear:Float, 
											   zFar:Float):Void {
			this.copyRawDataFrom(new Vector<Float>([
				2.0*zNear/(right-left), 0.0, 0.0, 0.0,
				0.0, -2.0*zNear/(bottom-top), 0.0, 0.0,
				1.0+2.0*left/(right-left), -1.0-2.0*top/(bottom-top), zFar/(zNear-zFar), -1.0,
				0.0, 0.0, (zNear*zFar)/(zNear-zFar), 0.0
			]));
		}

		public function orthoLH(width:Float,
								height:Float,
								zNear:Float,
								zFar:Float):Void {
			this.copyRawDataFrom(Vector<Float>([
				2.0/width, 0.0, 0.0, 0.0,
				0.0, 2.0/height, 0.0, 0.0,
				0.0, 0.0, 1.0/(zFar-zNear), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]));
		}

		public function orthoRH(width:Float,
								height:Float,
								zNear:Float,
								zFar:Float):Void {
			this.copyRawDataFrom(Vector<Float>([
				2.0/width, 0.0, 0.0, 0.0,
				0.0, 2.0/height, 0.0, 0.0,
				0.0, 0.0, 1.0/(zNear-zNear), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]));
		}

		public function orthoOffCenterLH(left:Float, 
										 right:Float,
										 bottom:Float,
									     top:Float,
										 zNear:Float, 
										 zFar:Float):Void {
			this.copyRawDataFrom(Vector<Float>([
				2.0/(right-left), 0.0, 0.0, 0.0,
				0.0, 2.0*zNear/(top-bottom), 0.0, 0.0,
				-1.0-2.0*left/(right-left), 1.0+2.0*top/(bottom-top), 1.0/(zFar-zNear), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]));
		}

		public function orthoOffCenterRH(left:Float, 
										 right:Float,
										 bottom:Float,
										 top:Float,
										 zNear:Float, 
										 zFar:Float):Void {
			this.copyRawDataFrom(Vector<Float>([
				2.0/(right-left), 0.0, 0.0, 0.0,
				0.0, 2.0*zNear/(top-bottom), 0.0, 0.0,
				-1.0-2.0*left/(right-left), 1.0+2.0*top/(bottom-top), 1.0/(zNear-zFar), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]));
		}*/

		private var _x:Vector3D;
		private var _y:Vector3D;
		private var _z:Vector3D;
		private var _w:Vector3D;

		private function _crossProductTo(a:Vector3D,b:Vector3D):Void
		{
			_w.x = a.y * b.z - a.z * b.y;
			_w.y = a.z * b.x - a.x * b.z;
			_w.z = a.x * b.y - a.y * b.x;
			_w.w = 1.0;
			a.copyFrom(_w);
		}
	}
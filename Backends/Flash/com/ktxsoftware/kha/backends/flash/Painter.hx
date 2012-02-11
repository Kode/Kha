package com.ktxsoftware.kha.backends.flash;

import com.ktxsoftware.flash.utils.AGALMiniAssembler;
import com.ktxsoftware.kha.Color;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;

class Painter extends com.ktxsoftware.kha.Painter {
	var graphics : Graphics;
	var tx : Float;
	var ty : Float;
	var matrix : Matrix;
	var color : Color;
	var context : Context3D;
	var indexBuffer : IndexBuffer3D;
	
	public function new(context : Context3D, width : Int, height : Int) {
		this.context = context;
		tx = 0;
		ty = 0;
		matrix = new Matrix();
		
		context.enableErrorChecking = true;
		context.configureBackBuffer(width, height, 0, true);

		var vertexShader : Array<String> = [
			// Transform our vertices by our projection matrix and move it into temporary register
			"m44 vt0, va0, vc0",
			// Move the temporary register to out position for this vertex
			"mov op, vt0",
			"mov v0, va1"
		];
		
		var fragmentShader : Array<String> = [
			// Simply assing the fragment constant to our out color
			//"mov oc, fc0"
			"tex ft1, v0, fs0 <2d,linear,nomip>",
			"mov oc, ft1"
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
   
		var vertexBuffer = context.createVertexBuffer(3, 5);
		var vec2 = new Vector<Float>(15);
		vec2[ 0] = 100; vec2[ 1] = 100; vec2[ 2] = 1; vec2[ 3] = 0; vec2[ 4] = 0;
		vec2[ 5] = 300; vec2[ 6] = 200; vec2[ 7] = 1; vec2[ 8] = 1; vec2[ 9] = 0;
		vec2[10] = 200; vec2[11] = 300; vec2[12] = 1; vec2[13] = 0; vec2[14] = 1;
		vertexBuffer.uploadFromVector(vec2, 0, 3);

		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
		context.setTextureAt(0, cast(com.ktxsoftware.kha.Loader.getInstance().getImage("Bub.png"), com.ktxsoftware.kha.backends.flash.Image).getTexture());

		var projection : Matrix3D = new Matrix3D();
		var right : Float = 640;
		var left : Float = 0;
		var top : Float = 0;
		var bottom : Float = 480;
		var zNear : Float = 0.1;
		var zFar : Float = 512;
		
		var tx : Float = -(right + left) / (right - left);
		var ty : Float = -(top + bottom) / (top - bottom);
		var tz : Float = -zNear / (zFar - zNear);
			
		var vec : Vector<Float> = new Vector<Float>(16);
		
		vec[ 0] = 2.0 / (right - left); vec[ 1] = 0.0;                  vec[ 2] = 0.0;                  vec[ 3] = 0.0;
		vec[ 4] = 0.0;                  vec[ 5] = 2.0 / (top - bottom); vec[ 6] = 0.0;                  vec[ 7] = 0.0;
		vec[ 8] = 0.0;                  vec[ 9] = 0.0;                  vec[10] = 1.0 / (zFar - zNear); vec[11] = 0.0;
		vec[12] = tx;                   vec[13] = ty;                   vec[14] = tz;                   vec[15] = 1.0;
		
		projection.copyRawDataFrom(vec);
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, projection, true);
		var vec3 = new Vector<Float>(4);
		vec3[0] = 1; vec3[1] = 1; vec3[2] = 1; vec3[3] = 0;
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vec3);
	}
	
	public function setGraphics(graphics : Graphics) {
		this.graphics = graphics;
	}
	
	public override function begin() {
		//graphics.clear();
		context.clear(0, 0, 0, 0);
	}
	
	public override function end() {
		context.drawTriangles(indexBuffer, 0, 1);
		context.present();
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	public override function drawImage(img : com.ktxsoftware.kha.Image, x : Float, y : Float) {
		var image : Image = cast(img, Image);
		
	}
	
	public override function drawImage2(img : com.ktxsoftware.kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		var image : Image = cast(img, Image);
		matrix.tx = tx + dx - sx;
		matrix.ty = ty + dy - sy;
		graphics.beginBitmapFill(image.image.bitmapData, matrix);
		graphics.drawRect(tx + dx, ty + dy, dw, dh);
		graphics.endFill();
	}
	
	public override function setColor(r : Int, g : Int, b : Int) {
		color = new Color(r, g, b);
	}
	
	public override function fillRect(x : Float, y : Float, width : Float, height : Float) {
		graphics.beginFill(color.r << 16 | color.g << 8 | color.b);
		graphics.drawRect(tx + x, ty + y, width, height);
		graphics.endFill();
	}
}
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
	var tx : Float;
	var ty : Float;
	var color : Color;
	var context : Context3D;
	var indexBuffer : IndexBuffer3D;
	var projection : Matrix3D;
	
	public function new(context : Context3D, width : Int, height : Int) {
		this.context = context;
		tx = 0;
		ty = 0;
		
		projection = new Matrix3D();
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
		
		context.enableErrorChecking = true;
		context.configureBackBuffer(width, height, 0, false);

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
   
		indexBuffer = context.createIndexBuffer(6);
		var vec = new Vector<UInt>(6);
		vec[0] = 0; vec[1] = 1; vec[2] = 2;
		vec[4] = 1; vec[5] = 2; vec[3] = 3;
		indexBuffer.uploadFromVector(vec, 0, 6);
	}
	
	public override function begin() {
		context.clear(0, 0, 0, 0);
	}
	
	public override function end() {
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
		image.getTexture();

		var vertexBuffer = context.createVertexBuffer(4, 5);
		var vec2 = new Vector<Float>(20);
		var u1 = image.correctU(sx / image.getWidth());
		var u2 = image.correctU((sx + sw) / image.getWidth());
		var v1 = image.correctV(sy / image.getHeight());
		var v2 = image.correctV((sy + sh) / image.getHeight());
		vec2[ 0] = tx + dx;      vec2[ 1] = ty + dy;      vec2[ 2] = 1; vec2[ 3] = u1; vec2[ 4] = v1;
		vec2[ 5] = tx + dx + dw; vec2[ 6] = ty + dy;      vec2[ 7] = 1; vec2[ 8] = u2; vec2[ 9] = v1;
		vec2[10] = tx + dx;      vec2[11] = ty + dy + dh; vec2[12] = 1; vec2[13] = u1; vec2[14] = v2;
		vec2[15] = tx + dx + dw; vec2[16] = ty + dy + dh; vec2[17] = 1; vec2[18] = u2; vec2[19] = v2;
		vertexBuffer.uploadFromVector(vec2, 0, 4);

		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
		context.setTextureAt(0, image.getTexture());
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, projection, true);
		var vec3 = new Vector<Float>(4);
		vec3[0] = 1; vec3[1] = 1; vec3[2] = 1; vec3[3] = 0;
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vec3);
		
		context.drawTriangles(indexBuffer, 0, 2);
	}
	
	public override function setColor(r : Int, g : Int, b : Int) {
		color = new Color(r, g, b);
	}
	
	public override function fillRect(x : Float, y : Float, width : Float, height : Float) {
		
	}
}
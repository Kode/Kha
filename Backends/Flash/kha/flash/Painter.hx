package kha.flash;

import kha.flash.utils.AGALMiniAssembler;
import kha.Color;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Vector;

class Painter extends kha.Painter {
	var tx : Float;
	var ty : Float;
	var color : Color;
	var context : Context3D;
	var vertexBuffer : VertexBuffer3D;
	var vertices : Vector<Float>;
	var indexBuffer : IndexBuffer3D;
	var projection : Matrix3D;
	var font : Font;
	var textField : TextField;
	var textBitmap : BitmapData;
	var textTexture : Texture;
	var program : Program3D;
	var noTexProgram : Program3D;
	
	public function new(context : Context3D, width : Int, height : Int) {
		this.context = context;
		tx = 0;
		ty = 0;
		
		font = new Font("Arial", FontStyle.PLAIN, 12);
		
		textField = new TextField();
		textField.width = 1024;
		textField.height = 1024;
		textBitmap = new BitmapData(1024, 1024, true, 0xffffff);
		textTexture = Starter.context.createTexture(1024, 1024, Context3DTextureFormat.BGRA, false);
		
		projection = new Matrix3D();
		var right : Float = width;
		var left : Float = 0;
		var top : Float = 0;
		var bottom : Float = height;
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
		#if debug
		context.enableErrorChecking = true;
		#end
		context.configureBackBuffer(width, height, 0, false);
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

		var vertexShader : Array<String> = [
			// Transform our vertices by our projection matrix and move it into temporary register
			"m44 vt0, va0, vc0",
			// Move the temporary register to out position for this vertex
			"mov op, vt0",
			"mov v0, va1"
		];
		
		var fragmentShader : Array<String> = [
			"tex ft1, v0, fs0 <2d,linear,nomip>",
			"mov oc, ft1"
		];
		
		var noTexFragmentShader : Array<String> = [
			"mov oc, fc0"
		];

		program = context.createProgram();
		var vertexAssembler : AGALMiniAssembler = new AGALMiniAssembler();
		vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join("\n"));
		var fragmentAssembler : AGALMiniAssembler = new AGALMiniAssembler();
		fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.join("\n"));
		program.upload(vertexAssembler.agalcode(), fragmentAssembler.agalcode());
		context.setProgram(program);
		
		noTexProgram = context.createProgram();
		fragmentAssembler = new AGALMiniAssembler();
		fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, noTexFragmentShader.join("\n"));
		noTexProgram.upload(vertexAssembler.agalcode(), fragmentAssembler.agalcode());
		
		indexBuffer = context.createIndexBuffer(6 * maxCount);
		var indices = new Vector<UInt>(6 * maxCount);
		for (i in 0...maxCount) {
			indices[6 * i + 0] = i * 4 + 0;
			indices[6 * i + 1] = i * 4 + 1;
			indices[6 * i + 2] = i * 4 + 2;
			indices[6 * i + 3] = i * 4 + 1;
			indices[6 * i + 4] = i * 4 + 2;
			indices[6 * i + 5] = i * 4 + 3;
		}
		indexBuffer.uploadFromVector(indices, 0, 6 * maxCount);
		
		vertexBuffer = context.createVertexBuffer(4 * maxCount, 5);
		vertices = new Vector<Float>(20 * maxCount);
		vertexBuffer.uploadFromVector(vertices, 0, 4 * maxCount);
		
		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, projection, true);
	}
	
	public override function begin() {
		context.clear(0, 0, 0, 0);
	}
	
	public override function end() {
		if (image != null && count > 0) flushBuffers();
		context.present();
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	var image : Image;
	var count : Int;
	static var maxCount : Int = 500;
	
	function flushBuffers() : Void {
		if (image != null) {
			context.setTextureAt(0, image.getTexture());
			vertexBuffer.uploadFromVector(vertices, 0, 4 * count);
			context.drawTriangles(indexBuffer, 0, 2 * count);
			count = 0;
		}
	}
	
	override public function drawImage(img : kha.Image, x : Float, y : Float) : Void {
		drawImage2(img, 0, 0, img.getWidth(), img.getHeight(), x, y, img.getWidth(), img.getHeight());
	}
	
	override public function drawImage2(img : kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		if (image != img || count >= maxCount) {
			if (image != null) flushBuffers();
			image = cast(img, Image);
			image.getTexture();
			context.setTextureAt(0, image.getTexture());
		}

		var u1 = image.correctU(sx / image.getWidth());
		var u2 = image.correctU((sx + sw) / image.getWidth());
		var v1 = image.correctV(sy / image.getHeight());
		var v2 = image.correctV((sy + sh) / image.getHeight());
		var offset = count * 20;
		vertices[offset +  0] = tx + dx;      vertices[offset +  1] = ty + dy;      vertices[offset +  2] = 1; vertices[offset +  3] = u1; vertices[offset +  4] = v1;
		vertices[offset +  5] = tx + dx + dw; vertices[offset +  6] = ty + dy;      vertices[offset +  7] = 1; vertices[offset +  8] = u2; vertices[offset +  9] = v1;
		vertices[offset + 10] = tx + dx;      vertices[offset + 11] = ty + dy + dh; vertices[offset + 12] = 1; vertices[offset + 13] = u1; vertices[offset + 14] = v2;
		vertices[offset + 15] = tx + dx + dw; vertices[offset + 16] = ty + dy + dh; vertices[offset + 17] = 1; vertices[offset + 18] = u2; vertices[offset + 19] = v2;
		//vertexBuffer.uploadFromVector(vertices, 0, 4);

		//context.drawTriangles(indexBuffer, 0, 2);
		++count;
	}
	
	override public function drawVideo(video : kha.Video, x : Float, y : Float, width : Float, height : Float) : Void {
		// TODO
		var savedColor = color;
		color = new Color(0, 0, 0);
		fillRect(x, y, width, height);
		color = savedColor;
	}
	
	override public function drawString(text : String, x : Float, y : Float) : Void {
		//return;
		textField.defaultTextFormat = new TextFormat(font.name, font.size, getColorInt());
		textField.text = text;
		textBitmap.fillRect(new Rectangle(0, 0, 1024, 1024), 0xffffff);
		textBitmap.draw(textField);
		textTexture.uploadFromBitmapData(textBitmap, 0);
		
		flushBuffers();
		
		var dx = x;
		var dy = y - font.size;
		var dw = 1024;
		var dh = 1024;
		var u1 = 0.0;
		var u2 = 1.0;
		var v1 = 0.0;
		var v2 = 1.0;
		var offset = 0;
		
		vertices[offset +  0] = tx + dx;      vertices[offset +  1] = ty + dy;      vertices[offset +  2] = 1; vertices[offset +  3] = u1; vertices[offset +  4] = v1;
		vertices[offset +  5] = tx + dx + dw; vertices[offset +  6] = ty + dy;      vertices[offset +  7] = 1; vertices[offset +  8] = u2; vertices[offset +  9] = v1;
		vertices[offset + 10] = tx + dx;      vertices[offset + 11] = ty + dy + dh; vertices[offset + 12] = 1; vertices[offset + 13] = u1; vertices[offset + 14] = v2;
		vertices[offset + 15] = tx + dx + dw; vertices[offset + 16] = ty + dy + dh; vertices[offset + 17] = 1; vertices[offset + 18] = u2; vertices[offset + 19] = v2;
		
		context.setTextureAt(0, textTexture);
		vertexBuffer.uploadFromVector(vertices, 0, 4 * 1);
		context.drawTriangles(indexBuffer, 0, 2 * 1);
	}
	
	public override function setColor(r : Int, g : Int, b : Int) {
		color = new Color(r, g, b);
	}
	
	function getColorVector() : Vector<Float> {
		var vec = new Vector<Float>();
		vec.push(color.r / 256);
		vec.push(color.g / 256);
		vec.push(color.b / 256);
		vec.push(1);
		return vec;
	}
	
	function getColorInt() : Int {
		return color.r * 256 * 256 + color.g * 256 + color.b;
	}
	
	public override function fillRect(x : Float, y : Float, width : Float, height : Float) {
		flushBuffers();
		
		var offset = count * 20;
		vertices[offset +  0] = tx + x;         vertices[offset +  1] = ty + y;          vertices[offset +  2] = 1; vertices[offset +  3] = 0; vertices[offset +  4] = 0;
		vertices[offset +  5] = tx + x + width; vertices[offset +  6] = ty + y;          vertices[offset +  7] = 1; vertices[offset +  8] = 0; vertices[offset +  9] = 0;
		vertices[offset + 10] = tx + x;         vertices[offset + 11] = ty + y + height; vertices[offset + 12] = 1; vertices[offset + 13] = 0; vertices[offset + 14] = 0;
		vertices[offset + 15] = tx + x + width; vertices[offset + 16] = ty + y + height; vertices[offset + 17] = 1; vertices[offset + 18] = 0; vertices[offset + 19] = 0;
		
		context.setTextureAt(0, null);
		context.setProgram(noTexProgram);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, getColorVector());
		vertexBuffer.uploadFromVector(vertices, 0, 4 * 1);
		context.drawTriangles(indexBuffer, 0, 2 * 1);
		context.setProgram(program);
	}
	
	public override function drawRect(x : Float, y : Float, width : Float, height : Float) : Void {
		drawLine(tx + x, ty + y, tx + x + width, ty + y);
		drawLine(tx + x + width, ty + y, tx + x + width, ty + y + height);
		drawLine(tx + x + width, ty + y + height, tx + x, ty + y + height);
		drawLine(tx + x, ty + y + height, tx + x, ty + y);
	}
	
	public override function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void {
		flushBuffers();
		
		var nx = -(y2 - y1);
		var ny = x2 - x1;
		var length = Math.sqrt(nx * nx + ny * ny);
		nx /= length;
		ny /= length;
		
		var offset = count * 20;
		vertices[offset +  0] = tx + x1;      vertices[offset +  1] = ty + y1;      vertices[offset +  2] = 1; vertices[offset +  3] = 0; vertices[offset +  4] = 0;
		vertices[offset +  5] = tx + x2;      vertices[offset +  6] = ty + y2;      vertices[offset +  7] = 1; vertices[offset +  8] = 0; vertices[offset +  9] = 0;
		vertices[offset + 10] = tx + x1 + nx; vertices[offset + 11] = ty + y1 + ny; vertices[offset + 12] = 1; vertices[offset + 13] = 0; vertices[offset + 14] = 0;
		vertices[offset + 15] = tx + x2 + nx; vertices[offset + 16] = ty + y2 + ny; vertices[offset + 17] = 1; vertices[offset + 18] = 0; vertices[offset + 19] = 0;
		
		context.setTextureAt(0, null);
		context.setProgram(noTexProgram);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, getColorVector());
		vertexBuffer.uploadFromVector(vertices, 0, 4 * 1);
		context.drawTriangles(indexBuffer, 0, 2 * 1);
		context.setProgram(program);
	}
	
	override public function setFont(font : kha.Font) : Void {
		this.font = cast(font, Font);
	}
}
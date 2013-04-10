package kha.flash;

import flash.media.StageVideo;
import flash.net.NetStream;
import kha.flash.utils.AGALMiniAssembler;
import kha.Color;
import kha.Game;
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
	var borderX : Float;
	var borderY : Float;
	var scaleX : Float;
	var scaleY : Float;
	var color : Color;
	var context : Context3D;
	var vertexBuffer : VertexBuffer3D;
	var vertices : Vector<Float>;
	var indexBuffer : IndexBuffer3D;
	var triangleIndexBuffer: IndexBuffer3D;
	var projection : Matrix3D;
	var font : Font;
	var textField : TextField;
	var textBitmap : BitmapData;
	var textTexture : Texture;
	var program : Program3D;
	var noTexProgram : Program3D;
	
	private static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}
	
	public function new(context : Context3D) {
		this.context = context;
		tx = 0;
		ty = 0;
		
		font = new Font("Arial", new FontStyle(false, false, false), 12);
		
		var gameWidth = Game.the.width;
		var gameHeight = Game.the.height;
		
		var textureWidth = upperPowerOfTwo(gameWidth);
		var textureHeight = upperPowerOfTwo(gameHeight);
		
		textField = new TextField();
		textField.width = textureWidth;
		textField.height = textureHeight;
		textField.border = false;
		textBitmap = new BitmapData(textureWidth , textureHeight, true, 0xffffff);
		textTexture = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, false);
		
		#if debug
		context.enableErrorChecking = true;
		#end
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
		
		triangleIndexBuffer = context.createIndexBuffer(3);
		indices = new Vector<UInt>(3);
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		triangleIndexBuffer.uploadFromVector(indices, 0, 3);
		
		vertexBuffer = context.createVertexBuffer(4 * maxCount, 5);
		vertices = new Vector<Float>(20 * maxCount);
		vertexBuffer.uploadFromVector(vertices, 0, 4 * maxCount);
		
		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
		
		resize();
	}
	
	public function resize() {
		var stageWidth = flash.Lib.current.stage.stageWidth;
		var stageHeight = flash.Lib.current.stage.stageHeight;
		
		var gameWidth : Float = Game.the.width;
		var gameHeight : Float = Game.the.height;
		
		// fix for large text beeing truncated on height resolusion
		if (textField.width < gameWidth || textField.height < gameHeight) {
			var textureWidth = upperPowerOfTwo(Game.the.width);
			var textureHeight = upperPowerOfTwo(Game.the.height);
			
			
			textField.width = textureWidth;
			textField.height = textureHeight;
			
			
			textTexture.dispose();
			textBitmap.dispose();
			
			textBitmap = new BitmapData(textureWidth, textureHeight, true, 0xffffff);
			textTexture = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, false);
		}
		
		var gameRatio = gameWidth / gameHeight;
		var stageRatio = stageWidth / stageHeight;
		
		if (gameRatio > stageRatio) {
			gameHeight = gameWidth / stageRatio;
			borderX = 0;
			borderY = (gameHeight - Game.the.height) * 0.5;
		} else {
			gameWidth = gameHeight * stageRatio;
			borderX = (gameWidth - Game.the.width) * 0.5;
			borderY = 0;
		}
	
		scaleX = gameWidth / stageWidth;
		scaleY = gameHeight / stageHeight;
		
		context.configureBackBuffer(stageWidth, stageHeight, 0, false);
		
		projection = new Matrix3D();
		var right : Float = gameWidth;
		var left : Float = 0;
		var top : Float = 0;
		var bottom : Float = gameHeight;
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
		
		projection.prependTranslation(borderX, borderY, 0.0);
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, projection, true);
	}
	
	public function calculateGamePosition(x : Float, y : Float) : { x : Float, y : Float } {
		var gameX = x * scaleX - borderX;
		var gameY = y * scaleY - borderY;
		return { x: gameX, y: gameY };
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
			context.setTextureAt(0, image.getFlashTexture());
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
			image.getFlashTexture();
			context.setTextureAt(0, image.getFlashTexture());
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
		var stageVideo = new flash.media.Video(Std.int(width), Std.int(height));
		stageVideo.attachNetStream(cast(video, Video).stream);
				
		textBitmap.fillRect(new Rectangle(0, 0, textBitmap.width, textBitmap.height), 0xffffff);
		textBitmap.draw(stageVideo);
		textTexture.uploadFromBitmapData(textBitmap, 0);
		
		flushBuffers();
		
		var dx = x;
		var dy = y;
		var dw = textField.width;
		var dh = textField.height;
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
	
	override public function drawString(text : String, x : Float, y : Float) : Void {
		//return;
		textField.defaultTextFormat = new TextFormat(font.name, font.size, getColorInt(), font.style.getBold(), font.style.getItalic(), font.style.getUnderlined());
		textField.text = text;
		textBitmap.fillRect(new Rectangle(0, 0, textBitmap.width, textBitmap.height), 0xffffff);
		textBitmap.draw(textField);
		textTexture.uploadFromBitmapData(textBitmap, 0);
		
		flushBuffers();
		
		var dx = x;
		var dy = y;
		var dw = textField.width;
		var dh = textField.height;
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
	
	public override function setColor(r: Int, g: Int, b: Int) {
		color = Color.fromBytes(r, g, b);
	}
	
	function getColorVector() : Vector<Float> {
		var vec = new Vector<Float>();
		vec.push(color.R);
		vec.push(color.G);
		vec.push(color.B);
		vec.push(1);
		return vec;
	}
	
	function getColorInt() : Int {
		return color.Rb * 256 * 256 + color.Gb * 256 + color.Bb;
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
		drawLine(x, y, x + width, y);
		drawLine(x + width, y, x + width, y + height);
		drawLine(x + width, y + height, x, y + height);
		drawLine(x, y + height, x, y);
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
	
	override public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void {
		flushBuffers();
		
		var offset = count * 20;
		vertices[offset +  0] = tx + x1; vertices[offset +  1] = ty + y1; vertices[offset +  2] = 1; vertices[offset +  3] = 0; vertices[offset +  4] = 0;
		vertices[offset +  5] = tx + x2; vertices[offset +  6] = ty + y2; vertices[offset +  7] = 1; vertices[offset +  8] = 0; vertices[offset +  9] = 0;
		vertices[offset + 10] = tx + x3; vertices[offset + 11] = ty + y3; vertices[offset + 12] = 1; vertices[offset + 13] = 0; vertices[offset + 14] = 0;
		
		context.setTextureAt(0, null);
		context.setProgram(noTexProgram);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, getColorVector());
		vertexBuffer.uploadFromVector(vertices, 0, 3);
		context.drawTriangles(triangleIndexBuffer, 0, 1);
		context.setProgram(program);
	}
	
	override public function setFont(font : kha.Font) : Void {
		this.font = cast(font, Font);
	}
}
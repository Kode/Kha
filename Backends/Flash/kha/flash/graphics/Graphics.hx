package kha.flash.graphics;

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.Vector;
import kha.Blob;
import kha.flash.Image;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;

class Graphics implements kha.graphics.Graphics {
	public static var context: Context3D;

	public function new(context: Context3D) {
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		Graphics.context = context;
	}
	
	public function vsynced(): Bool {
		return true;
	}
	public function refreshRate(): Int {
		return Std.int(flash.Lib.current.stage.frameRate);
	}
	
	public function clear(?color: Color, ?depth: Float, ?stencil: Int): Void {
		var mask: UInt = 0;
		if (color != null) mask |= Context3DClearMask.COLOR;
		if (depth != null) mask |= Context3DClearMask.DEPTH;
		if (stencil != null) mask |= Context3DClearMask.STENCIL;
		var r = color == null ? 0.0 : color.R;
		var g = color == null ? 0.0 : color.G;
		var b = color == null ? 0.0 : color.B;
		var a = color == null ? 1.0 : color.A;
		context.clear(r, g, b, a, depth == null ? 1.0 : depth, stencil == null ? 0 : stencil, mask);
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: kha.graphics.VertexStructure): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
		cast(indexBuffer, IndexBuffer).set();
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function createTexture(width: Int, height: Int, format: TextureFormat): Texture {
		return new Image(width, height, format);
	}
	
	public function setTexture(unit: kha.graphics.TextureUnit, texture: kha.Image): Void {
		context.setTextureAt(cast(unit, TextureUnit).unit, texture == null ? null : cast(texture, Image).getFlashTexture());
	}
	
	public function setTextureWrap(unit: kha.graphics.TextureUnit, u: kha.graphics.TextureWrap, v: kha.graphics.TextureWrap): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		context.drawTriangles(IndexBuffer.current.indexBuffer, start, count >= 0 ? Std.int(count / 3) : count);
	}
	
	public function createVertexShader(source: Blob): kha.graphics.VertexShader {
		return new Shader(source.toString(), Context3DProgramType.VERTEX);
	}

	public function createFragmentShader(source: Blob): kha.graphics.FragmentShader {
		return new Shader(source.toString(), Context3DProgramType.FRAGMENT);
	}
	
	public function setInt(location: kha.graphics.ConstantLocation, value: Int): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		vec[2] = value3;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}
	
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		var projection = new Matrix3D();
		var vec = new Vector<Float>(16);
		for (i in 0...16) vec[i] = matrix[i];
		projection.copyRawDataFrom(vec);
		var flashLocation = cast(location, ConstantLocation);
		context.setProgramConstantsFromMatrix(flashLocation.type, flashLocation.value, projection, true);
	}
}

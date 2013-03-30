package kha.flash.graphics;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.utils.ByteArray;
import flash.Vector;

class Graphics implements kha.graphics.Graphics {
	public static var context: Context3D;

	public function new(context: Context3D) {
		Graphics.context = context;
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
	
	public function createTexture(image: kha.Image): kha.graphics.Texture {
		return null;
	}

	public function setTextureWrap(stage: Int, u: kha.graphics.TextureWrap, v: kha.graphics.TextureWrap): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		context.drawTriangles(IndexBuffer.current.indexBuffer, start, count);
	}
	
	public function createVertexShader(source: String): kha.graphics.VertexShader {
		return new Shader(source, Context3DProgramType.VERTEX);
	}

	public function createFragmentShader(source: String): kha.graphics.FragmentShader {
		return new Shader(source, Context3DProgramType.FRAGMENT);
	}
	
	public function setInt(location: Int, value: Int): Void {
		
	}

	public function setFloat(location: Int, value: Float): Void {
		
	}
	
	public function setFloat2(location: Int, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(location: Int, value1: Float, value2: Float, value3: Float): Void {
		
	}
}

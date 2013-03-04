package kha.flash.graphics;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;

class Graphics implements kha.graphics.Graphics {
	public static var context: Context3D;
	private var program: Program3D;
	private var vertexShader: Shader;
	private var fragmentShader: Shader;
	
	public function new(context: Context3D) {
		Graphics.context = context;
		program = context.createProgram();
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: kha.graphics.VertexStructure): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function createTexture(image: kha.Image): kha.graphics.Texture {
		return null;
	}

	public function setTextureWrap(stage: Int, u: kha.graphics.TextureWrap, v: kha.graphics.TextureWrap): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		
	}
	
	public function drawArrays(start: Int = 0, ?count: Int): Void {
		context.drawTriangles(IndexBuffer.current.indexBuffer, start, count);
	}
	
	public function createVertexShader(source: String): kha.graphics.VertexShader {
		return new Shader(source, Context3DProgramType.VERTEX);
	}

	public function createFragmentShader(source: String): kha.graphics.FragmentShader {
		return new Shader(source, Context3DProgramType.FRAGMENT);
	}
	
	public function setVertexShader(shader: kha.graphics.VertexShader): Void {
		vertexShader = cast(shader, Shader);
	}

	public function setFragmentShader(shader: kha.graphics.FragmentShader): Void {
		fragmentShader = cast(shader, Shader);
	}
	
	public function linkShaders(): Void {
		program.upload(vertexShader.assembler.agalcode(), fragmentShader.assembler.agalcode());
	}
}

package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexStructure;
import kha.graphics.TextureWrap;
import kha.graphics.VertexShader;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

class Graphics implements kha.graphics.Graphics {
	private var stupidIndexBuffer: IndexBuffer;
	
	public function new() {
		stupidIndexBuffer = new IndexBuffer(3);
		var indices = stupidIndexBuffer.lock();
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		stupidIndexBuffer.unlock();
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function createTexture(image: kha.Image): kha.graphics.Texture {
		return new Texture(image);
	}
	
	public function setTextureWrap(stage: Int, u: TextureWrap, v: TextureWrap): Void {
		
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	@:functionCode("
		Kt::Graphics::drawIndexedVertices(start, count);
	")
	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		
	}
	
	public function drawArrays(start: Int = 0, ?count: Int): Void {
		stupidIndexBuffer.set();
		drawIndexedVertices(start, count);
	}
	
	public function getLocation(name: String): Int {
		return 0;
	}
	
	public function createVertexShader(source: String): VertexShader {
		return new Shader(source, ShaderType.VertexShader);
	}
	
	public function createFragmentShader(source: String): FragmentShader {
		return new Shader(source, ShaderType.FragmentShader);
	}
	
	public function setVertexShader(shader: VertexShader): Void {
		cast(shader, Shader).set();
	}
	
	public function setFragmentShader(shader: FragmentShader): Void {
		cast(shader, Shader).set();
	}
	
	public function linkShaders(): Void {

	}
}
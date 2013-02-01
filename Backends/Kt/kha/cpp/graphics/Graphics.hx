package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexStructure;
import kha.graphics.TextureWrap;
import kha.graphics.VertexShader;

class Graphics implements kha.graphics.Graphics {
	public function new() {
		
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
	
	public function setVertexBuffer(aVertexBuffer: kha.graphics.VertexBuffer): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		
	}
	
	public function drawArrays(start: Int = 0, ?count: Int): Void {
		
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
	
	}
	
	public function setFragmentShader(shader: FragmentShader): Void {
	
	}
	
	public function linkShaders(): Void {

	}
}
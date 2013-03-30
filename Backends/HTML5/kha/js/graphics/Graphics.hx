package kha.js.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexStructure;
import kha.graphics.TextureWrap;
import kha.graphics.VertexShader;

class Graphics implements kha.graphics.Graphics {
	private var indicesCount: Int;
	
	public function new() {
		
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
		indicesCount = indexBuffer.count();
		cast(indexBuffer, IndexBuffer).set();
	}
	
	public function createTexture(image: kha.Image): kha.graphics.Texture {
		return new Texture(image);
	}
	
	public function setTextureWrap(stage: Int, u: TextureWrap, v: TextureWrap): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + stage);
		switch (u) {
		case TextureWrap.ClampToEdge:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		case TextureWrap.Repeat:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.REPEAT);
		}
		switch (v) {
		case TextureWrap.ClampToEdge:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		case TextureWrap.Repeat:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.REPEAT);
		}
	}
	
	public function createVertexShader(source: String): VertexShader {
		return new Shader(source, Sys.gl.VERTEX_SHADER);
	}
	
	public function createFragmentShader(source: String): FragmentShader {
		return new Shader(source, Sys.gl.FRAGMENT_SHADER);
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function setInt(location: Int, value: Int): Void {
		Sys.gl.uniform1i(location, value);
	}
	
	public function setFloat(location: Int, value: Float): Void {
		Sys.gl.uniform1f(location, value);
	}
	
	public function setFloat2(location: Int, value1: Float, value2: Float): Void {
		Sys.gl.uniform2f(location, value1, value2);
	}
	
	public function setFloat3(location, value1: Float, value2: Float, value3: Float): Void {
		Sys.gl.uniform3f(location, value1, value2, value3);
	}

	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		Sys.gl.drawElements(Sys.gl.TRIANGLES, count == null ? indicesCount : count, Sys.gl.UNSIGNED_SHORT, start * 2);
	}
}

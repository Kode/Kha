package kha.js.graphics;

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
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
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
	
	//public function getLocation(name: String): Int {
	//	return Sys.gl.getUniformLocation(program, name);
	//}
	
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
	
	/*public function setVertexShader(shader: VertexShader): Void {
		vertexShader = cast(shader, Shader);
		compileShader(vertexShader);
	}
	
	public function setFragmentShader(shader: FragmentShader): Void {
		fragmentShader = cast(shader, Shader);
		compileShader(fragmentShader);
	}
	
	private function compileShader(shader: Shader): Void {
		if (shader.shader != null) return;
		var s = Sys.gl.createShader(shader.type);
		Sys.gl.shaderSource(s, shader.source);
		Sys.gl.compileShader(s);
		if (!Sys.gl.getShaderParameter(s, Sys.gl.COMPILE_STATUS)) {
			throw "Could not compile shader:\n" + Sys.gl.getShaderInfoLog(s);
		}
		shader.shader = s;
	}
	
	public function linkShaders(): Void {
		program = Sys.gl.createProgram();
		Sys.gl.attachShader(program, vertexShader.shader);
		Sys.gl.attachShader(program, fragmentShader.shader);
		Sys.gl.linkProgram(program);
		if (!Sys.gl.getProgramParameter(program, Sys.gl.LINK_STATUS)) {
			throw "Could not link the shader program.";
		}
		Sys.gl.useProgram(program);
	}*/
	
	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		if (count == null) count = 3;//count = vertexBuffer.size() - start;
		Sys.gl.drawArrays(Sys.gl.TRIANGLE_STRIP, start, count);
	}
}
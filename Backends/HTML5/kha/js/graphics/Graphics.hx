package kha.js.graphics;

import kha.Blob;
import kha.graphics.FragmentShader;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;
import kha.graphics.VertexStructure;
import kha.graphics.TextureWrap;
import kha.graphics.VertexShader;
import kha.js.Image;

class Graphics implements kha.graphics.Graphics {
	private var indicesCount: Int;
	
	public function new() {
		Sys.gl.enable(Sys.gl.BLEND);
		Sys.gl.blendFunc(Sys.gl.SRC_ALPHA, Sys.gl.ONE_MINUS_SRC_ALPHA);
	}
	
	public function vsynced(): Bool {
		return true;
	}
	
	public function refreshRate(): Int {
		return 60;
	}
	
	public function clear(?color: Color, ?depth: Float, ?stencil: Int): Void {
		
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
	
	public function createTexture(width: Int, height: Int, format: TextureFormat): Texture {
		return new Image(width, height, format);
	}
	
	public function setTexture(stage: kha.graphics.TextureUnit, texture: kha.Image): Void {
		if (texture == null) {
			Sys.gl.activeTexture(Sys.gl.TEXTURE0 + cast(stage, TextureUnit).value);
			Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
		}
		else {
			cast(texture, Image).set(cast(stage, TextureUnit).value);
		}
	}
	
	public function setTextureWrap(stage: kha.graphics.TextureUnit, u: TextureWrap, v: TextureWrap): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + cast(stage, TextureUnit).value);
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
	
	public function createVertexShader(source: Blob): VertexShader {
		return new Shader(source.toString(), Sys.gl.VERTEX_SHADER);
	}
	
	public function createFragmentShader(source: Blob): FragmentShader {
		return new Shader(source.toString(), Sys.gl.FRAGMENT_SHADER);
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function setInt(location: kha.graphics.ConstantLocation, value: Int): Void {
		Sys.gl.uniform1i(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		Sys.gl.uniform1f(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		Sys.gl.uniform2f(cast(location, ConstantLocation).value, value1, value2);
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		Sys.gl.uniform3f(cast(location, ConstantLocation).value, value1, value2, value3);
	}
	
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		Sys.gl.uniformMatrix4fv(cast(location, ConstantLocation).value, false, matrix);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Sys.gl.drawElements(Sys.gl.TRIANGLES, count == -1 ? indicesCount : count, Sys.gl.UNSIGNED_SHORT, start * 2);
	}
}

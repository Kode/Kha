package kha.js.graphics;

import kha.graphics.VertexShader;
import kha.graphics.FragmentShader;

class Graphics implements kha.graphics.Graphics {
	private var vertexShader: Shader;
	private var fragmentShader: Shader;
	private var program: Dynamic;
	private var vertexBuffer: VertexBuffer;
	
	public function new() {
		
	}
	
	public function createVertexBuffer(vertexCount: Int, stride: Int): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, stride);
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function createTexture(image: kha.Image): kha.graphics.Texture {
		return new Texture(image);
	}
	
	public function setVertexBuffer(aVertexBuffer: kha.graphics.VertexBuffer): Void {
		vertexBuffer = cast(aVertexBuffer, VertexBuffer);
		
	}
	
	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		Sys.gl.useProgram(program);
		if (count == null) count = vertexBuffer.size() - start;
		Sys.gl.drawArrays(Sys.gl.TRIANGLE_STRIP, start, count);
	}
	
	public function drawArrays(start: Int = 0, ?count: Int): Void {
		Sys.gl.useProgram(program);
		vertexBuffer.bind();
		var attr = Sys.gl.getAttribLocation(program, "pos");
		Sys.gl.enableVertexAttribArray(attr);
		//void vertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, GLintptr offset)
		Sys.gl.vertexAttribPointer(attr, vertexBuffer.size(), Sys.gl.FLOAT, false, vertexBuffer.stride(), 0);
		
		attr = Sys.gl.getAttribLocation(program, "tex");
		Sys.gl.enableVertexAttribArray(attr);
		Sys.gl.vertexAttribPointer(attr, vertexBuffer.size(), Sys.gl.FLOAT, false, vertexBuffer.stride(), 3 * 4);
		
		var location = Sys.gl.getUniformLocation(program, "sampler");
		Sys.gl.uniform1i(location, 0);
		if (count == null) count = vertexBuffer.size() - start;
		Sys.gl.drawArrays(Sys.gl.TRIANGLE_STRIP, start, 4);
	}
	
	public function createVertexShader(source: String): VertexShader {
		return new Shader(source, Sys.gl.VERTEX_SHADER);
	}
	
	public function createFragmentShader(source: String): FragmentShader {
		return new Shader(source, Sys.gl.FRAGMENT_SHADER);
	}
	
	public function setVertexShader(shader: VertexShader): Void {
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
	}
}
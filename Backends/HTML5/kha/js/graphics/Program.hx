package kha.js.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexData;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;

class Program implements kha.graphics.Program {
	private var program: Dynamic;
	private var vertexShader: Shader;
	private var fragmentShader: Shader;
	
	public function new() {
		program = Sys.gl.createProgram();
	}
	
	public function setVertexShader(vertexShader: VertexShader): Void {
		this.vertexShader = cast(vertexShader, Shader);
	}
	
	public function setFragmentShader(fragmentShader: FragmentShader): Void {
		this.fragmentShader = cast(fragmentShader, Shader);
	}
	
	public function link(structure: VertexStructure): Void {
		compileShader(vertexShader);
		compileShader(fragmentShader);
		Sys.gl.attachShader(program, vertexShader.shader);
		Sys.gl.attachShader(program, fragmentShader.shader);
		
		var index = 0;
		for (element in structure.elements) {
			Sys.gl.bindAttribLocation(program, index, element.name);
			++index;
		}
		
		Sys.gl.linkProgram(program);
		if (!Sys.gl.getProgramParameter(program, Sys.gl.LINK_STATUS)) {
			throw "Could not link the shader program.";
		}
	}
	
	public function set(): Void {
		Sys.gl.useProgram(program);
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
	
	public function getConstantLocation(name: String): kha.graphics.ConstantLocation {
		return new ConstantLocation(Sys.gl.getUniformLocation(program, name));
	}
}

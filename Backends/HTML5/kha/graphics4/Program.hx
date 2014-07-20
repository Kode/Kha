package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class Program {
	private var program: Dynamic;
	private var vertexShader: VertexShader;
	private var fragmentShader: FragmentShader;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		program = Sys.gl.createProgram();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function setVertexShader(vertexShader: VertexShader): Void {
		this.vertexShader = vertexShader;
	}
	
	public function setFragmentShader(fragmentShader: FragmentShader): Void {
		this.fragmentShader = fragmentShader;
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
		for (index in 0...textureValues.length) Sys.gl.uniform1i(textureValues[index], index);
	}
	
	private function compileShader(shader: Dynamic): Void {
		if (shader.shader != null) return;
		var s = Sys.gl.createShader(shader.type);
		Sys.gl.shaderSource(s, shader.source);
		Sys.gl.compileShader(s);
		if (!Sys.gl.getShaderParameter(s, Sys.gl.COMPILE_STATUS)) {
			throw "Could not compile shader:\n" + Sys.gl.getShaderInfoLog(s);
		}
		shader.shader = s;
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.js.graphics4.ConstantLocation(Sys.gl.getUniformLocation(program, name));
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = Sys.gl.getUniformLocation(program, name);
			index = textures.length;
			textureValues.push(location);
			textures.push(name);
		}
		return new kha.js.graphics4.TextureUnit(index);
	}
	
	private function findTexture(name: String): Int {
		for (index in 0...textures.length) {
			if (textures[index] == name) return index;
		}
		return -1;
	}
}

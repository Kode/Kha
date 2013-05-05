package kha.js.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexData;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;

class Program implements kha.graphics.Program {
	private var program: Dynamic;
	private var vertexShader: Shader;
	private var fragmentShader: Shader;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		program = Sys.gl.createProgram();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
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
		for (index in 0...textureValues.length) Sys.gl.uniform1i(textureValues[index], index);
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
	
	public function getTextureUnit(name: String): kha.graphics.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = Sys.gl.getUniformLocation(program, name);
			index = textures.length;
			textureValues.push(location);
			textures.push(name);
		}
		return new TextureUnit(index);
	}
	
	private function findTexture(name: String): Int {
		for (index in 0...textures.length) {
			if (textures[index] == name) return index;
		}
		return -1;
	}
}

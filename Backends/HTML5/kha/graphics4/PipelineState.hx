package kha.graphics4;

import js.html.webgl.GL;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var program: Dynamic;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		super();
		program = SystemImpl.gl.createProgram();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
		
	public function compile(): Void {
		compileShader(vertexShader);
		compileShader(fragmentShader);
		SystemImpl.gl.attachShader(program, vertexShader.shader);
		SystemImpl.gl.attachShader(program, fragmentShader.shader);
		
		var index = 0;
		for (structure in inputLayout) {
			for (element in structure.elements) {
				SystemImpl.gl.bindAttribLocation(program, index, element.name);
				if (element.data == VertexData.Float4x4) {
					index += 4;
				}
				else {
					++index;
				}
			}
		}
		
		SystemImpl.gl.linkProgram(program);
		if (!SystemImpl.gl.getProgramParameter(program, GL.LINK_STATUS)) {
			throw "Could not link the shader program.";
		}
	}
	
	public function set(): Void {
		SystemImpl.gl.useProgram(program);
		for (index in 0...textureValues.length) SystemImpl.gl.uniform1i(textureValues[index], index);
	}
	
	private function compileShader(shader: Dynamic): Void {
		if (shader.shader != null) return;
		var s = SystemImpl.gl.createShader(shader.type);
		SystemImpl.gl.shaderSource(s, shader.source);
		SystemImpl.gl.compileShader(s);
		if (!SystemImpl.gl.getShaderParameter(s, GL.COMPILE_STATUS)) {
			throw "Could not compile shader:\n" + SystemImpl.gl.getShaderInfoLog(s);
		}
		shader.shader = s;
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.js.graphics4.ConstantLocation(SystemImpl.gl.getUniformLocation(program, name));
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = SystemImpl.gl.getUniformLocation(program, name);
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

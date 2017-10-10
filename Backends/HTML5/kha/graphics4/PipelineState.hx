package kha.graphics4;

import js.html.webgl.GL;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var program: Dynamic = null;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		super();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function delete(): Void {
		if (program != null) {
			SystemImpl.gl.deleteProgram(program);
		}
	}
		
	public function compile(): Void {
		if (program != null) {
			SystemImpl.gl.deleteProgram(program);
		}
		program = SystemImpl.gl.createProgram();
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
			throw "Could not link the shader program:\n" + SystemImpl.gl.getProgramInfoLog(program);
		}
	}
	
	public function set(): Void {
		SystemImpl.gl.useProgram(program);
		for (index in 0...textureValues.length) SystemImpl.gl.uniform1i(textureValues[index], index);
		SystemImpl.gl.colorMask(colorWriteMaskRed, colorWriteMaskGreen, colorWriteMaskBlue, colorWriteMaskAlpha);
	}
	
	private function compileShader(shader: Dynamic): Void {
		if (shader.shader != null) return;
		var s = SystemImpl.gl.createShader(shader.type);
		var highp = SystemImpl.gl.getShaderPrecisionFormat(GL.FRAGMENT_SHADER, GL.HIGH_FLOAT);
		var highpSupported = highp.precision != 0;
		var files: Array<String> = shader.files;
		for (i in 0...files.length) {
			if (SystemImpl.gl2) {
				if (files[i].indexOf("-webgl2") >= 0 || files[i].indexOf("runtime-string") >= 0) {
					SystemImpl.gl.shaderSource(s, shader.sources[i]);
					break;
				}
			}
			else {
				if (!highpSupported && (files[i].indexOf("-relaxed") >= 0 || files[i].indexOf("runtime-string") >= 0)) {
					SystemImpl.gl.shaderSource(s, shader.sources[i]);
					break;
				}
				if (highpSupported && (files[i].indexOf("-relaxed") < 0 || files[i].indexOf("runtime-string") >= 0)) {
					SystemImpl.gl.shaderSource(s, shader.sources[i]);
					break;
				}
			}
		}
		SystemImpl.gl.compileShader(s);
		if (!SystemImpl.gl.getShaderParameter(s, GL.COMPILE_STATUS)) {
			throw "Could not compile shader:\n" + SystemImpl.gl.getShaderInfoLog(s);
		}
		shader.shader = s;
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var location = SystemImpl.gl.getUniformLocation(program, name);
		var type = GL.FLOAT;
		var count: Int = SystemImpl.gl.getProgramParameter(program, GL.ACTIVE_UNIFORMS);
		for (i in 0...count) {
			var info = SystemImpl.gl.getActiveUniform(program, i);
			if (info.name == name || info.name == name + "[0]") {
				type = info.type;
				break;
			}
		}
		return new kha.js.graphics4.ConstantLocation(location, type);
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

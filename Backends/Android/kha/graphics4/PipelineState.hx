package kha.graphics4;

import android.opengl.GLES20;
import java.NativeArray;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var program: Int;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		super();
		program = GLES20.glCreateProgram();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function compile(): Void {
		compileShader(vertexShader);
		compileShader(fragmentShader);
		GLES20.glAttachShader(program, vertexShader.shader);
		GLES20.glAttachShader(program, fragmentShader.shader);
		
		var index = 0;
		for (element in inputLayout[0].elements) {
			GLES20.glBindAttribLocation(program, index, element.name);
			++index;
		}
		
		GLES20.glLinkProgram(program);
		var values = new NativeArray<Int>(1);
		GLES20.glGetProgramiv(program, GLES20.GL_LINK_STATUS, values, 0);
		if (values[0] == GLES20.GL_FALSE) {
			throw "Could not link the shader program.";
		}
	}
	
	public function set(): Void {
		GLES20.glUseProgram(program);
		for (index in 0...textureValues.length) {
			GLES20.glUniform1i(textureValues[index], index);
		}
		GLES20.glColorMask(colorWriteMaskRed, colorWriteMaskGreen, colorWriteMaskBlue, colorWriteMaskAlpha);
	}
	
	private function compileShader(shader: Dynamic): Void {
		if (shader.shader != -1) return;
		var s = GLES20.glCreateShader(shader.type);
		GLES20.glShaderSource(s, shader.source);
		GLES20.glCompileShader(s);
		var values = new NativeArray<Int>(1);
		GLES20.glGetShaderiv(s, GLES20.GL_COMPILE_STATUS, values, 0);
		if (values[0] == GLES20.GL_FALSE) {
			throw "Could not compile shader:\n" + GLES20.glGetShaderInfoLog(s);
		}
		shader.shader = s;
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.android.graphics4.ConstantLocation(GLES20.glGetUniformLocation(program, name));
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = GLES20.glGetUniformLocation(program, name);
			index = textures.length;
			textureValues.push(location);
			textures.push(name);
		}
		return new kha.android.graphics4.TextureUnit(index);
	}
	
	private function findTexture(name: String): Int {
		for (index in 0...textures.length) {
			if (textures[index] == name) return index;
		}
		return -1;
	}
}

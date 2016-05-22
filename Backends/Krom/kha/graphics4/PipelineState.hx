package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var program: Dynamic;
	
	public function new() {
		super();
		program = Krom.createProgram();
	}
		
	public function compile(): Void {
		Krom.compileProgram(program, inputLayout[0].elements, vertexShader.shader, fragmentShader.shader);
	}
	
	public function set(): Void {
		Krom.setProgram(program);
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return Krom.getConstantLocation(program, name);
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return Krom.getTextureUnit(program, name);
	}
}

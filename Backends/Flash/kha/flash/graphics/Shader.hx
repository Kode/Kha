package kha.flash.graphics;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.utils.JSON;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

class Shader implements FragmentShader, implements VertexShader {
	public var assembler: AGALMiniAssembler;
	
	public function new(shader: String, type: Context3DProgramType) {
		assembler = new AGALMiniAssembler();
		assembler.assemble(type, JSON.parse(shader).agalasm);
	}
	
	public function setInt(name: String, value: Int): Void {
		
	}
	
	public function setFloat(name: String, value: Float): Void {
		
	}
	
	public function setFloat2(name: String, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(name: String, value1: Float, value2: Float, value3: Float): Void {
		
	}
}

package kha.flash.graphics;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.utils.JSON;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

class Shader implements FragmentShader, implements VertexShader {
	public var assembler: AGALMiniAssembler;
	private var constants: Dynamic;
	private var type: Context3DProgramType;
	
	public function new(shader: String, type: Context3DProgramType) {
		assembler = new AGALMiniAssembler();
		var json = JSON.parse(shader);
		assembler.assemble(type, json.agalasm);
		constants = json.consts;
		this.type = type;
	}
	
	public function set(): Void {
		var vec = new flash.Vector<Float>(4);
		if (type == Context3DProgramType.VERTEX) {
			vec[0] = constants.vc0[0];
			vec[1] = constants.vc0[1];
			vec[2] = constants.vc0[2];
			vec[3] = constants.vc0[3];
		}
		else {
			vec[0] = constants.fc0[0];
			vec[1] = constants.fc0[1];
			vec[2] = constants.fc0[2];
			vec[3] = constants.fc0[3];
		}
		Graphics.context.setProgramConstantsFromVector(type, 0, vec, 1);
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

package kha.flash.graphics;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.utils.JSON;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

class Shader implements FragmentShader, implements VertexShader {
	public var source: String;
	public var constants: Dynamic;
	public var names: Dynamic;
	
	public function new(shader: String, type: Context3DProgramType) {
		var json = JSON.parse(shader);
		source = json.agalasm;
		constants = json.consts;
		names = json.varnames;
	}
}

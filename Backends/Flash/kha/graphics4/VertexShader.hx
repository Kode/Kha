package kha.graphics4;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.utils.JSON;
import kha.Blob;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;

class VertexShader {
	public var source: String;
	public var constants: Dynamic;
	public var names: Dynamic;
	
	public function new(shaders: Array<Blob>, files: Array<String>) {
		var json = JSON.parse(shaders[0].toString());
		source = json.agalasm;
		constants = json.consts;
		names = json.varnames;
	}
}

package kha.flash.graphics;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;

class Program implements kha.graphics.Program {
	private var program: Program3D;
	private var fragmentShader: Shader;
	private var vertexShader: Shader;
	
	public function new() {
		program = Graphics.context.createProgram();
	}

	public function setVertexShader(shader: VertexShader): Void {
		vertexShader = cast(shader, Shader);
	}

	public function setFragmentShader(shader: FragmentShader): Void {
		fragmentShader = cast(shader, Shader);
	}
	
	public function link(structure: VertexStructure): Void {
		var vertexAssembler = new AGALMiniAssembler();
		vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.source);
		
		var fragmentAssembler = new AGALMiniAssembler();
		fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.source);
		
		program.upload(vertexAssembler.agalcode(), fragmentAssembler.agalcode());
	}
	
	public function getConstantLocation(name: String): Int {
		return 0;
	}
	
	public function set(): Void {
		Graphics.context.setProgram(program);
		
		var vec = new flash.Vector<Float>(4);
		vec[0] = vertexShader.constants.vc0[0];
		vec[1] = vertexShader.constants.vc0[1];
		vec[2] = vertexShader.constants.vc0[2];
		vec[3] = vertexShader.constants.vc0[3];
		Graphics.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vec, 1);
		vec[0] = fragmentShader.constants.fc0[0];
		vec[1] = fragmentShader.constants.fc0[1];
		vec[2] = fragmentShader.constants.fc0[2];
		vec[3] = fragmentShader.constants.fc0[3];
		Graphics.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vec, 1);
	}
}

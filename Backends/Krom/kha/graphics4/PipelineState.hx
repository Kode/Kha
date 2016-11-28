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

	public function delete() {
		Krom.deleteProgram(program);
		program = null;
	}
	
	public function compile(): Void {
		var structure0 = inputLayout.length > 0 ? inputLayout[0].elements : null;
		var structure1 = inputLayout.length > 1 ? inputLayout[1].elements : null;
		var structure2 = inputLayout.length > 2 ? inputLayout[2].elements : null;
		var structure3 = inputLayout.length > 3 ? inputLayout[3].elements : null;
		var gs = geometryShader != null ? geometryShader.shader : null;
		var tcs = tessellationControlShader != null ? tessellationControlShader.shader : null;
		var tes = tessellationEvaluationShader != null ? tessellationEvaluationShader.shader : null;
		Krom.compileProgram(program, structure0, structure1, structure2, structure3, inputLayout.length, vertexShader.shader, fragmentShader.shader, gs, tcs, tes);
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

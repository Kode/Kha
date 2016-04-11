package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var program: Pointer;
	
	public function new() {
		super();
		init();
	}
	
	private function init(): Void {
		program = kore_create_program();
	}
	
	private function linkWithStructures2(structure0: VertexStructure, structure1: VertexStructure, structure2: VertexStructure, structure3: VertexStructure, size: Int): Void {
		kore_program_set_vertex_shader(program, vertexShader._shader);
		kore_program_set_fragment_shader(program, fragmentShader._shader);
		
		var kore_structure = VertexBuffer.kore_create_vertexstructure();
		for (i in 0...structure0.size()) {
			var data: Int = 0;
			switch (structure0.get(i).data.getIndex()) {
			case 0:
				data = 1;
			case 1:
				data = 2;
			case 2:
				data = 3;
			case 3:
				data = 4;
			case 4:
				data = 5;
			}
			VertexBuffer.kore_vertexstructure_add(kore_structure, StringHelper.convert(structure0.get(i).name), data);
		}
		
		kore_program_link(program, kore_structure);
	}
	
	public function compile(): Void {
		linkWithStructures2(
			inputLayout.length > 0 ? inputLayout[0] : null,
			inputLayout.length > 1 ? inputLayout[1] : null,
			inputLayout.length > 2 ? inputLayout[2] : null,
			inputLayout.length > 3 ? inputLayout[3] : null,
			inputLayout.length);
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.korehl.graphics4.ConstantLocation(kore_program_get_constantlocation(program, StringHelper.convert(name)));
	}
	
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return new kha.korehl.graphics4.TextureUnit(kore_program_get_textureunit(program, StringHelper.convert(name)));
	}
	
	public function set(): Void {
		kore_program_set(program);
	}
	
	public function unused(): Void {
		var include1 = new VertexElement("include", VertexData.Float2);
		var include2 = new VertexShader(null);
		var include3 = new FragmentShader(null);
		var include4 = new GeometryShader(null);
		var include5 = new TesselationControlShader(null);
		var include6 = new TesselationEvaluationShader(null);
	}
	
	@:hlNative("std", "kore_create_program") static function kore_create_program(): Pointer { return null; }
	@:hlNative("std", "kore_program_set_fragment_shader") static function kore_program_set_fragment_shader(program: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_program_set_vertex_shader") static function kore_program_set_vertex_shader(program: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_program_link") static function kore_program_link(program: Pointer, structure: Pointer): Void { }
	@:hlNative("std", "kore_program_get_constantlocation") static function kore_program_get_constantlocation(program: Pointer, name: hl.types.Bytes): Pointer { return null; }
	@:hlNative("std", "kore_program_get_textureunit") static function kore_program_get_textureunit(program: Pointer, name: hl.types.Bytes): Pointer { return null; }
	@:hlNative("std", "kore_program_set") static function kore_program_set(program: Pointer): Void { }
}

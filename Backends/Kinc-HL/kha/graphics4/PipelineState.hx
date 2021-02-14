package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	var _pipeline: Pointer;

	public function new() {
		super();
		init();
	}

	function init(): Void {
		_pipeline = kore_create_pipeline();
	}

	public function delete() {
		kore_delete_pipeline(_pipeline);
	}

	function linkWithStructures2(structure0: VertexStructure, structure1: VertexStructure, structure2: VertexStructure, structure3: VertexStructure,
			count: Int): Void {
		kore_pipeline_set_vertex_shader(_pipeline, vertexShader._shader);
		kore_pipeline_set_fragment_shader(_pipeline, fragmentShader._shader);
		if (geometryShader != null)
			kore_pipeline_set_geometry_shader(_pipeline, geometryShader._shader);
		if (tessellationControlShader != null)
			kore_pipeline_set_tesscontrol_shader(_pipeline, tessellationControlShader._shader);
		if (tessellationEvaluationShader != null)
			kore_pipeline_set_tesseval_shader(_pipeline, tessellationEvaluationShader._shader);

		var structures = [structure0, structure1, structure2, structure3];
		var kore_structures: Array<Pointer> = [];

		for (i in 0...count) {
			var kore_structure = VertexBuffer.kore_create_vertexstructure(structures[i].instanced);
			kore_structures.push(kore_structure);
			for (j in 0...structures[i].size()) {
				var data: Int = 0;
				switch (structures[i].get(j).data) {
					case VertexData.Float1:
						data = 1; // Kore::Graphics4::Float1VertexData;
					case VertexData.Float2:
						data = 2;
					case VertexData.Float3:
						data = 3;
					case VertexData.Float4:
						data = 4;
					case VertexData.Float4x4:
						data = 5; // Kore::Graphics4::Float4x4VertexData;
					case VertexData.Short2Norm:
						data = 6;
					case VertexData.Short4Norm:
						data = 7;
				}
				VertexBuffer.kore_vertexstructure_add(kore_structure, StringHelper.convert(structures[i].get(j).name), data);
			}
		}

		kore_pipeline_compile(_pipeline, kore_structures[0], count > 1 ? kore_structures[1] : null, count > 2 ? kore_structures[2] : null,
			count > 3 ? kore_structures[3] : null);
	}

	static function getDepthBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: 0;
			case DepthOnly: 24;
			case DepthAutoStencilAuto: 24;
			case Depth24Stencil8: 24;
			case Depth32Stencil8: 32;
			case Depth16: 16;
		}
	}

	static function getStencilBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: 0;
			case DepthOnly: 0;
			case DepthAutoStencilAuto: 8;
			case Depth24Stencil8: 8;
			case Depth32Stencil8: 8;
			case Depth16: 0;
		}
	}

	public function compile(): Void {
		var stencilReferenceValue = 0;
		switch (this.stencilReferenceValue) {
			case Static(value):
				stencilReferenceValue = value;
			default:
		}
		kore_pipeline_set_states(_pipeline, cullMode, depthMode, stencilMode, stencilBothPass, stencilDepthFail, stencilFail, getBlendFunc(blendSource),
			getBlendFunc(blendDestination), getBlendFunc(alphaBlendSource), getBlendFunc(alphaBlendDestination), depthWrite, stencilReferenceValue,
			stencilReadMask, stencilWriteMask, colorWriteMaskRed, colorWriteMaskGreen, colorWriteMaskBlue, colorWriteMaskAlpha, colorAttachmentCount,
			colorAttachments[0], colorAttachments[1], colorAttachments[2], colorAttachments[3], colorAttachments[4], colorAttachments[5], colorAttachments[6],
			colorAttachments[7], getDepthBufferBits(depthStencilAttachment), getStencilBufferBits(depthStencilAttachment), conservativeRasterization);
		linkWithStructures2(inputLayout.length > 0 ? inputLayout[0] : null, inputLayout.length > 1 ? inputLayout[1] : null,
			inputLayout.length > 2 ? inputLayout[2] : null, inputLayout.length > 3 ? inputLayout[3] : null, inputLayout.length);
	}

	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.korehl.graphics4.ConstantLocation(kore_pipeline_get_constantlocation(_pipeline, StringHelper.convert(name)));
	}

	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return new kha.korehl.graphics4.TextureUnit(kore_pipeline_get_textureunit(_pipeline, StringHelper.convert(name)));
	}

	static function getBlendFunc(factor: BlendingFactor): Int {
		switch (factor) {
			case BlendOne, Undefined:
				return 0;
			case BlendZero:
				return 1;
			case SourceAlpha:
				return 2;
			case DestinationAlpha:
				return 3;
			case InverseSourceAlpha:
				return 4;
			case InverseDestinationAlpha:
				return 5;
			case SourceColor:
				return 6;
			case DestinationColor:
				return 7;
			case InverseSourceColor:
				return 8;
			case InverseDestinationColor:
				return 9;
			default:
				return 0;
		}
	}

	public function set(): Void {
		kore_pipeline_set(_pipeline);
	}

	@:hlNative("std", "kore_create_pipeline") static function kore_create_pipeline(): Pointer {
		return null;
	}

	@:hlNative("std", "kore_delete_pipeline") static function kore_delete_pipeline(pipeline: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_set_fragment_shader") static function kore_pipeline_set_fragment_shader(pipeline: Pointer, shader: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_set_vertex_shader") static function kore_pipeline_set_vertex_shader(pipeline: Pointer, shader: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_set_geometry_shader") static function kore_pipeline_set_geometry_shader(pipeline: Pointer, shader: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_set_tesscontrol_shader") static function kore_pipeline_set_tesscontrol_shader(pipeline: Pointer, shader: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_set_tesseval_shader") static function kore_pipeline_set_tesseval_shader(pipeline: Pointer, shader: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_compile") static function kore_pipeline_compile(pipeline: Pointer, structure0: Pointer, structure1: Pointer,
		structure2: Pointer, structure3: Pointer): Void {}

	@:hlNative("std", "kore_pipeline_get_constantlocation") static function kore_pipeline_get_constantlocation(pipeline: Pointer, name: hl.Bytes): Pointer {
		return null;
	}

	@:hlNative("std", "kore_pipeline_get_textureunit") static function kore_pipeline_get_textureunit(pipeline: Pointer, name: hl.Bytes): Pointer {
		return null;
	}

	@:hlNative("std", "kore_pipeline_set_states") static function kore_pipeline_set_states(pipeline: Pointer, cullMode: Int, depthMode: Int, stencilMode: Int,
		stencilBothPass: Int, stencilDepthFail: Int, stencilFail: Int, blendSource: Int, blendDestination: Int, alphaBlendSource: Int,
		alphaBlendDestination: Int, depthWrite: Bool, stencilReferenceValue: Int, stencilReadMask: Int, stencilWriteMask: Int, colorWriteMaskRed: Bool,
		colorWriteMaskGreen: Bool, colorWriteMaskBlue: Bool, colorWriteMaskAlpha: Bool, colorAttachmentCount: Int, colorAttachment0: TextureFormat,
		colorAttachment1: TextureFormat, colorAttachment2: TextureFormat, colorAttachment3: TextureFormat, colorAttachment4: TextureFormat,
		colorAttachment5: TextureFormat, colorAttachment6: TextureFormat, colorAttachment7: TextureFormat, depthAttachmentBits: Int,
		stencilAttachmentBits: Int, conservativeRasterization: Bool): Void {}

	@:hlNative("std", "kore_pipeline_set") static function kore_pipeline_set(pipeline: Pointer): Void {}
}

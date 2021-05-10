package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

@:headerCode("
#include <kinc/graphics4/graphics.h>
#include <kinc/graphics4/pipeline.h>
#include <kinc/graphics4/vertexstructure.h>
")
@:cppFileCode("
static kinc_g4_compare_mode_t convertCompareMode(int mode) {
	switch (mode) {
	case 0:
		return KINC_G4_COMPARE_ALWAYS;
	case 1:
		return KINC_G4_COMPARE_NEVER;
	case 2:
		return KINC_G4_COMPARE_EQUAL;
	case 3:
		return KINC_G4_COMPARE_NOT_EQUAL;
	case 4:
		return KINC_G4_COMPARE_LESS;
	case 5:
		return KINC_G4_COMPARE_LESS_EQUAL;
	case 6:
		return KINC_G4_COMPARE_GREATER;
	case 7:
	default:
		return KINC_G4_COMPARE_GREATER_EQUAL;
	}
}

static kinc_g4_stencil_action_t convertStencilAction(int action) {
	switch (action) {
	case 0:
		return KINC_G4_STENCIL_KEEP;
	case 1:
		return KINC_G4_STENCIL_ZERO;
	case 2:
		return KINC_G4_STENCIL_REPLACE;
	case 3:
		return KINC_G4_STENCIL_INCREMENT;
	case 4:
		return KINC_G4_STENCIL_INCREMENT_WRAP;
	case 5:
		return KINC_G4_STENCIL_DECREMENT;
	case 6:
		return KINC_G4_STENCIL_DECREMENT_WRAP;
	case 7:
	default:
		return KINC_G4_STENCIL_INVERT;
	}
}

static kinc_g4_render_target_format_t convertColorAttachment(int format) {
	switch (format) {
	case 0:
		return KINC_G4_RENDER_TARGET_FORMAT_32BIT;
	case 1:
		return KINC_G4_RENDER_TARGET_FORMAT_8BIT_RED;
	case 2:
		return KINC_G4_RENDER_TARGET_FORMAT_128BIT_FLOAT;
	case 3:
		return KINC_G4_RENDER_TARGET_FORMAT_16BIT_DEPTH;
	case 4:
		return KINC_G4_RENDER_TARGET_FORMAT_64BIT_FLOAT;
	case 5:
		return KINC_G4_RENDER_TARGET_FORMAT_32BIT_RED_FLOAT;
	case 6:
	default:
		return KINC_G4_RENDER_TARGET_FORMAT_16BIT_RED_FLOAT;
	}
}
")
@:headerClassCode("kinc_g4_pipeline_t pipeline;")
@:keep
class PipelineState extends PipelineStateBase {
	public function new() {
		super();
		untyped __cpp__("kinc_g4_pipeline_init(&pipeline);");
	}

	public function delete(): Void {
		untyped __cpp__("kinc_g4_pipeline_destroy(&pipeline);");
	}

	@:functionCode("
		pipeline.vertex_shader = &vertexShader->shader;
		pipeline.fragment_shader = &fragmentShader->shader;
		if (geometryShader != null()) pipeline.geometry_shader = &geometryShader->shader;
		if (tessellationControlShader != null()) pipeline.tessellation_control_shader = &tessellationControlShader->shader;
		if (tessellationEvaluationShader != null()) pipeline.tessellation_evaluation_shader = &tessellationEvaluationShader->shader;
		kinc_g4_vertex_structure_t s0, s1, s2, s3;
		kinc_g4_vertex_structure_t* structures2[4] = { &s0, &s1, &s2, &s3 };
		::kha::graphics4::VertexStructure* structures[4] = { &structure0, &structure1, &structure2, &structure3 };
		for (int i1 = 0; i1 < size; ++i1) {
			kinc_g4_vertex_structure_init(structures2[i1]);
			structures2[i1]->instanced = (*structures[i1])->instanced;
			for (int i2 = 0; i2 < (*structures[i1])->size(); ++i2) {
				kinc_g4_vertex_data_t data;
				switch ((*structures[i1])->get(i2)->data) {
				case 0:
					data = KINC_G4_VERTEX_DATA_FLOAT1;
					break;
				case 1:
					data = KINC_G4_VERTEX_DATA_FLOAT2;
					break;
				case 2:
					data = KINC_G4_VERTEX_DATA_FLOAT3;
					break;
				case 3:
					data = KINC_G4_VERTEX_DATA_FLOAT4;
					break;
				case 4:
					data = KINC_G4_VERTEX_DATA_FLOAT4X4;
					break;
				case 5:
					data = KINC_G4_VERTEX_DATA_SHORT2_NORM;
					break;
				case 6:
					data = KINC_G4_VERTEX_DATA_SHORT4_NORM;
					break;
				}
				pipeline.input_layout[i1] = structures2[i1];
				kinc_g4_vertex_structure_add(pipeline.input_layout[i1], (*structures[i1])->get(i2)->name, data);
			}
		}
		for (int i = size; i < 16; ++i) {
			pipeline.input_layout[i] = nullptr;
		}
		kinc_g4_pipeline_compile(&pipeline);
	")
	function linkWithStructures2(structure0: VertexStructure, structure1: VertexStructure, structure2: VertexStructure, structure3: VertexStructure,
		size: Int): Void {}

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
		var stencilReferenceValue = switch (this.stencilReferenceValue) {
			case Static(value): value;
			default: 0;
		}
		setStates(cullMode, depthMode, stencilMode, stencilBothPass, stencilDepthFail, stencilFail, depthWrite, stencilReferenceValue,
			getBlendFunc(blendSource), getBlendFunc(blendDestination), getBlendFunc(alphaBlendSource), getBlendFunc(alphaBlendDestination),
			getDepthBufferBits(depthStencilAttachment), getStencilBufferBits(depthStencilAttachment));
		linkWithStructures2(inputLayout.length > 0 ? inputLayout[0] : null, inputLayout.length > 1 ? inputLayout[1] : null,
			inputLayout.length > 2 ? inputLayout[2] : null, inputLayout.length > 3 ? inputLayout[3] : null, inputLayout.length);
	}

	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var location = new kha.kore.graphics4.ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}

	@:functionCode("location->location = kinc_g4_pipeline_get_constant_location(&pipeline, name.c_str());")
	function initConstantLocation(location: kha.kore.graphics4.ConstantLocation, name: String): Void {}

	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var unit = new kha.kore.graphics4.TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}

	@:functionCode("unit->unit = kinc_g4_pipeline_get_texture_unit(&pipeline, name.c_str());")
	function initTextureUnit(unit: kha.kore.graphics4.TextureUnit, name: String): Void {}

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

	@:functionCode("
		switch (cullMode) {
		case 0:
			pipeline.cull_mode = KINC_G4_CULL_CLOCKWISE;
			break;
		case 1:
			pipeline.cull_mode = KINC_G4_CULL_COUNTER_CLOCKWISE;
			break;
		case 2:
			pipeline.cull_mode = KINC_G4_CULL_NOTHING;
			break;
		}

		pipeline.depth_mode = convertCompareMode(depthMode);
		pipeline.depth_write = depthWrite;

		pipeline.stencil_mode = convertCompareMode(stencilMode);
		pipeline.stencil_both_pass = convertStencilAction(stencilBothPass);
		pipeline.stencil_depth_fail = convertStencilAction(stencilDepthFail);
		pipeline.stencil_fail = convertStencilAction(stencilFail);
		pipeline.stencil_reference_value = stencilReferenceValue;
		pipeline.stencil_read_mask = stencilReadMask;
		pipeline.stencil_write_mask = stencilWriteMask;

		pipeline.blend_source = (kinc_g4_blending_operation_t)blendSource;
		pipeline.blend_destination = (kinc_g4_blending_operation_t)blendDestination;
		pipeline.alpha_blend_source = (kinc_g4_blending_operation_t)alphaBlendSource;
		pipeline.alpha_blend_destination = (kinc_g4_blending_operation_t)alphaBlendDestination;

		for (int i = 0; i < 8; ++i) {
			pipeline.color_write_mask_red[i] = colorWriteMasksRed[i];
			pipeline.color_write_mask_green[i] = colorWriteMasksGreen[i];
			pipeline.color_write_mask_blue[i] = colorWriteMasksBlue[i];
			pipeline.color_write_mask_alpha[i] = colorWriteMasksAlpha[i];
		}

		pipeline.color_attachment_count = colorAttachmentCount;
		for (int i = 0; i < 8; ++i) {
			pipeline.color_attachment[i] = convertColorAttachment(colorAttachments[i]);
		}

		pipeline.depth_attachment_bits = depthAttachmentBits;
		pipeline.stencil_attachment_bits = stencilAttachmentBits;

		pipeline.conservative_rasterization = conservativeRasterization;
	")
	function setStates(cullMode: Int, depthMode: Int, stencilMode: Int, stencilBothPass: Int, stencilDepthFail: Int, stencilFail: Int, depthWrite: Bool,
		stencilReferenceValue: Int, blendSource: Int, blendDestination: Int, alphaBlendSource: Int, alphaBlendDestination: Int, depthAttachmentBits: Int,
		stencilAttachmentBits: Int): Void {}

	@:functionCode("kinc_g4_set_pipeline(&pipeline);")
	function set2(): Void {}

	public function set(): Void {
		set2();
	}

	@:noCompletion
	public static function _unused1(): VertexElement {
		return null;
	}

	@:noCompletion
	public static function _unused2(): VertexData {
		return VertexData.Float1;
	}

	@:noCompletion
	public static function _unused3(): VertexShader {
		return null;
	}

	@:noCompletion
	public static function _unused4(): FragmentShader {
		return null;
	}

	@:noCompletion
	public static function _unused5(): GeometryShader {
		return null;
	}

	@:noCompletion
	public static function _unused6(): TessellationControlShader {
		return null;
	}

	@:noCompletion
	public static function _unused7(): TessellationEvaluationShader {
		return null;
	}
}

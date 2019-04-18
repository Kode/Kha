package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <Kore/Graphics4/PipelineState.h>
')

@:cppFileCode('
static Kore::Graphics4::ZCompareMode convertCompareMode(int mode) {
	switch (mode) {
	case 0:
		return Kore::Graphics4::ZCompareAlways;
	case 1:
		return Kore::Graphics4::ZCompareNever;
	case 2:
		return Kore::Graphics4::ZCompareEqual;
	case 3:
		return Kore::Graphics4::ZCompareNotEqual;
	case 4:
		return Kore::Graphics4::ZCompareLess;
	case 5:
		return Kore::Graphics4::ZCompareLessEqual;
	case 6:
		return Kore::Graphics4::ZCompareGreater;
	case 7:
	default:
		return Kore::Graphics4::ZCompareGreaterEqual;
	}
}

static Kore::Graphics4::StencilAction convertStencilAction(int action) {
	switch (action) {
	case 0:
		return Kore::Graphics4::Keep;
	case 1:
		return Kore::Graphics4::Zero;
	case 2:
		return Kore::Graphics4::Replace;
	case 3:
		return Kore::Graphics4::Increment;
	case 4:
		return Kore::Graphics4::IncrementWrap;
	case 5:
		return Kore::Graphics4::Decrement;
	case 6:
		return Kore::Graphics4::DecrementWrap;
	case 7:
	default:
		return Kore::Graphics4::Invert;
	}
}
')

@:headerClassCode("Kore::Graphics4::PipelineState* pipeline;")
@:keep
class PipelineState extends PipelineStateBase {
	public function new() {
		super();
		untyped __cpp__('pipeline = new Kore::Graphics4::PipelineState;');
	}

	public function delete(): Void {
		untyped __cpp__('delete pipeline; pipeline = nullptr;');
	}

	@:functionCode('
		pipeline->vertexShader = vertexShader->shader;
		pipeline->fragmentShader = fragmentShader->shader;
		if (geometryShader != null()) pipeline->geometryShader = geometryShader->shader;
		if (tessellationControlShader != null()) pipeline->tessellationControlShader = tessellationControlShader->shader;
		if (tessellationEvaluationShader != null()) pipeline->tessellationEvaluationShader = tessellationEvaluationShader->shader;
		Kore::Graphics4::VertexStructure s0, s1, s2, s3;
		Kore::Graphics4::VertexStructure* structures2[4] = { &s0, &s1, &s2, &s3 };
		::kha::graphics4::VertexStructure* structures[4] = { &structure0, &structure1, &structure2, &structure3 };
		for (int i1 = 0; i1 < size; ++i1) {
			structures2[i1]->instanced = (*structures[i1])->instanced;
			for (int i2 = 0; i2 < (*structures[i1])->size(); ++i2) {
				Kore::Graphics4::VertexData data;
				switch ((*structures[i1])->get(i2)->data) {
				case 0:
					data = Kore::Graphics4::Float1VertexData;
					break;
				case 1:
					data = Kore::Graphics4::Float2VertexData;
					break;
				case 2:
					data = Kore::Graphics4::Float3VertexData;
					break;
				case 3:
					data = Kore::Graphics4::Float4VertexData;
					break;
				case 4:
					data = Kore::Graphics4::Float4x4VertexData;
					break;
				case 5:
					data = Kore::Graphics4::Short2NormVertexData;
					break;
				case 6:
					data = Kore::Graphics4::Short4NormVertexData;
					break;
				}
				pipeline->inputLayout[i1] = structures2[i1];
				pipeline->inputLayout[i1]->add((*structures[i1])->get(i2)->name, data);
			}
		}
		for (int i = size; i < 16; ++i) {
			pipeline->inputLayout[i] = nullptr;
		}
		pipeline->compile();
	')
	private function linkWithStructures2(structure0: VertexStructure, structure1: VertexStructure, structure2: VertexStructure, structure3: VertexStructure, size: Int): Void {

	}

	public function compile(): Void {
		var stencilReferenceValue = switch (this.stencilReferenceValue) {
			case Static(value): value;
			default: 0;
		}
		setStates(cullMode, depthMode, stencilMode, stencilBothPass, stencilDepthFail, stencilFail, depthWrite,
		stencilReferenceValue, getBlendFunc(blendSource), getBlendFunc(blendDestination), getBlendFunc(alphaBlendSource), getBlendFunc(alphaBlendDestination));
		linkWithStructures2(
			inputLayout.length > 0 ? inputLayout[0] : null,
			inputLayout.length > 1 ? inputLayout[1] : null,
			inputLayout.length > 2 ? inputLayout[2] : null,
			inputLayout.length > 3 ? inputLayout[3] : null,
			inputLayout.length);
	}

	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var location = new kha.kore.graphics4.ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}

	@:functionCode('location->location = pipeline->getConstantLocation(name.c_str());')
	private function initConstantLocation(location: kha.kore.graphics4.ConstantLocation, name: String): Void {

	}

	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var unit = new kha.kore.graphics4.TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}

	@:functionCode('unit->unit = pipeline->getTextureUnit(name.c_str());')
	private function initTextureUnit(unit: kha.kore.graphics4.TextureUnit, name: String): Void {

	}

	private static function getBlendFunc(factor: BlendingFactor): Int {
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

	@:functionCode('
		switch (cullMode) {
		case 0:
			pipeline->cullMode = Kore::Graphics4::Clockwise;
			break;
		case 1:
			pipeline->cullMode = Kore::Graphics4::CounterClockwise;
			break;
		case 2:
			pipeline->cullMode = Kore::Graphics4::NoCulling;
			break;
		}

		pipeline->depthMode = convertCompareMode(depthMode);
		pipeline->depthWrite = depthWrite;

		pipeline->stencilMode = convertCompareMode(stencilMode);
		pipeline->stencilBothPass = convertStencilAction(stencilBothPass);
		pipeline->stencilDepthFail = convertStencilAction(stencilDepthFail);
		pipeline->stencilFail = convertStencilAction(stencilFail);
		pipeline->stencilReferenceValue = stencilReferenceValue;
		pipeline->stencilReadMask = stencilReadMask;
		pipeline->stencilWriteMask = stencilWriteMask;

		pipeline->blendSource = (Kore::Graphics4::BlendingOperation)blendSource;
		pipeline->blendDestination = (Kore::Graphics4::BlendingOperation)blendDestination;
		pipeline->alphaBlendSource = (Kore::Graphics4::BlendingOperation)alphaBlendSource;
		pipeline->alphaBlendDestination = (Kore::Graphics4::BlendingOperation)alphaBlendDestination;

		for (int i = 0; i < 8; ++i) {
			pipeline->colorWriteMaskRed[i] = colorWriteMasksRed[i];
			pipeline->colorWriteMaskGreen[i] = colorWriteMasksGreen[i];
			pipeline->colorWriteMaskBlue[i] = colorWriteMasksBlue[i];
			pipeline->colorWriteMaskAlpha[i] = colorWriteMasksAlpha[i];
		}

		pipeline->conservativeRasterization = conservativeRasterization;
	')
	private function setStates(cullMode: Int, depthMode: Int, stencilMode: Int, stencilBothPass: Int, stencilDepthFail: Int, stencilFail: Int, depthWrite: Bool,
	stencilReferenceValue: Int, blendSource: Int, blendDestination: Int, alphaBlendSource: Int, alphaBlendDestination: Int): Void {

	}

	@:functionCode('Kore::Graphics4::setPipeline(pipeline);')
	private function set2(): Void {

	}

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

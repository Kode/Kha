package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var pipeline: Dynamic;
	
	public function new() {
		super();
		pipeline = Krom.createPipeline();
	}

	public function delete() {
		Krom.deletePipeline(pipeline);
		pipeline = null;
	}
	
	public function compile(): Void {
		var structure0 = inputLayout.length > 0 ? inputLayout[0] : null;
		var structure1 = inputLayout.length > 1 ? inputLayout[1] : null;
		var structure2 = inputLayout.length > 2 ? inputLayout[2] : null;
		var structure3 = inputLayout.length > 3 ? inputLayout[3] : null;
		var gs = geometryShader != null ? geometryShader.shader : null;
		var tcs = tessellationControlShader != null ? tessellationControlShader.shader : null;
		var tes = tessellationEvaluationShader != null ? tessellationEvaluationShader.shader : null;
		var stencilReferenceValue = 0;
		switch (this.stencilReferenceValue) {
			case Static(value):
				stencilReferenceValue = value;
			default:
		}
		Krom.compilePipeline(pipeline, structure0, structure1, structure2, structure3, inputLayout.length, vertexShader.shader, fragmentShader.shader, gs, tcs, tes, {
			cullMode: convertCullMode(cullMode),
			depthWrite: this.depthWrite,
			depthMode: convertCompareMode(depthMode),
			stencilMode: convertCompareMode(stencilMode),
			stencilBothPass: convertStencilAction(stencilBothPass),
			stencilDepthFail: convertStencilAction(stencilDepthFail),
			stencilFail: convertStencilAction(stencilFail),
			stencilReferenceValue: stencilReferenceValue,
			stencilReadMask: stencilReadMask,
			stencilWriteMask: stencilWriteMask,
			blendSource: convertBlendingFactor(blendSource),
			blendDestination: convertBlendingFactor(blendDestination),
			alphaBlendSource: convertBlendingFactor(alphaBlendSource),
			alphaBlendDestination: convertBlendingFactor(alphaBlendDestination),
			colorWriteMaskRed: colorWriteMasksRed,
			colorWriteMaskGreen: colorWriteMasksGreen,
			colorWriteMaskBlue: colorWriteMasksBlue,
			colorWriteMaskAlpha: colorWriteMasksAlpha,
			conservativeRasterization: conservativeRasterization
		});
	}
	
	public function set(): Void {
		Krom.setPipeline(pipeline);
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return Krom.getConstantLocation(pipeline, name);
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return Krom.getTextureUnit(pipeline, name);
	}

	private static function convertCullMode(mode: CullMode): Int {
		switch (mode) {
			case Clockwise:
				return 0;
			case CounterClockwise:
				return 1;
			case None:
				return 2;
		}
	}
	
	private static function convertCompareMode(mode: CompareMode): Int {
		switch (mode) {
			case Always:
				return 0;
			case Never:
				return 1;
			case Equal:
				return 2;
			case NotEqual:
				return 3;
			case Less:
				return 4;
			case LessEqual:
				return 5;
			case Greater:
				return 6;
			case GreaterEqual:
				return 7;
		}
	}

	private static function convertStencilAction(action: StencilAction): Int {
		switch (action) {
			case Keep:
				return 0;
			case Zero:
				return 1;
			case Replace:
				return 2;
			case Increment:
				return 3;
			case IncrementWrap:
				return 4;
			case Decrement:
				return 5;
			case DecrementWrap:
				return 6;
			case Invert:
				return 7;
		}
	}

	private static function convertBlendingFactor(factor: BlendingFactor): Int {
		switch (factor) {
			case Undefined, BlendOne:
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
		}
	}
}

package kha.graphics5_;

class PipelineStateBase {
	public function new() {
		inputLayout = null;
		vertexShader = null;
		fragmentShader = null;
		// geometryShader = null;
		// tessellationControlShader = null;
		// tessellationEvaluationShader = null;

		cullMode = CullMode.None;

		depthWrite = false;
		depthMode = CompareMode.Always;

		stencilMode = CompareMode.Always;
		stencilBothPass = StencilAction.Keep;
		stencilDepthFail = StencilAction.Keep;
		stencilFail = StencilAction.Keep;
		stencilReferenceValue = 0;
		stencilReadMask = 0xff;
		stencilWriteMask = 0xff;

		blendSource = BlendingFactor.BlendOne;
		blendDestination = BlendingFactor.BlendZero;
		blendOperation = BlendingOperation.Add;
		alphaBlendSource = BlendingFactor.BlendOne;
		alphaBlendDestination = BlendingFactor.BlendZero;
		alphaBlendOperation = BlendingOperation.Add;
		
		colorWriteMasksRed = [];
		colorWriteMasksGreen = [];
		colorWriteMasksBlue = [];
		colorWriteMasksAlpha = [];
		for (i in 0...8) colorWriteMasksRed.push(true);
		for (i in 0...8) colorWriteMasksGreen.push(true);
		for (i in 0...8) colorWriteMasksBlue.push(true);
		for (i in 0...8) colorWriteMasksAlpha.push(true);

		conservativeRasterization = false;
	}

	public var inputLayout: Array<VertexStructure>;
	public var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	// public var geometryShader: GeometryShader;
	// public var tessellationControlShader: TessellationControlShader;
	// public var tessellationEvaluationShader: TessellationEvaluationShader;

	public var cullMode: CullMode;

	public var depthWrite: Bool;
	public var depthMode: CompareMode;

	public var stencilMode: CompareMode;
	public var stencilBothPass: StencilAction;
	public var stencilDepthFail: StencilAction;
	public var stencilFail: StencilAction;
	public var stencilReferenceValue: Int;
	public var stencilReadMask: Int;
	public var stencilWriteMask: Int;

	// One, Zero deactivates blending
	public var blendSource: BlendingFactor;
	public var blendDestination: BlendingFactor;
	public var blendOperation: BlendingOperation;
	public var alphaBlendSource: BlendingFactor;
	public var alphaBlendDestination: BlendingFactor;
	public var alphaBlendOperation: BlendingOperation;
	
	public var colorWriteMask(never, set): Bool;
	public var colorWriteMaskRed(get, set): Bool;
	public var colorWriteMaskGreen(get, set): Bool;
	public var colorWriteMaskBlue(get, set): Bool;
	public var colorWriteMaskAlpha(get, set): Bool;

	public var colorWriteMasksRed: Array<Bool>;
	public var colorWriteMasksGreen: Array<Bool>;
	public var colorWriteMasksBlue: Array<Bool>;
	public var colorWriteMasksAlpha: Array<Bool>;

	inline function set_colorWriteMask(value: Bool): Bool {
		return colorWriteMaskRed = colorWriteMaskBlue = colorWriteMaskGreen = colorWriteMaskAlpha = value;
	}

	inline function get_colorWriteMaskRed(): Bool {
		return colorWriteMasksRed[0];
	}

	inline function set_colorWriteMaskRed(value: Bool): Bool {
		return colorWriteMasksRed[0] = value;
	}

	inline function get_colorWriteMaskGreen(): Bool {
		return colorWriteMasksGreen[0];
	}

	inline function set_colorWriteMaskGreen(value: Bool): Bool {
		return colorWriteMasksGreen[0] = value;
	}

	inline function get_colorWriteMaskBlue(): Bool {
		return colorWriteMasksBlue[0];
	}

	inline function set_colorWriteMaskBlue(value: Bool): Bool {
		return colorWriteMasksBlue[0] = value;
	}

	inline function get_colorWriteMaskAlpha(): Bool {
		return colorWriteMasksAlpha[0];
	}

	inline function set_colorWriteMaskAlpha(value: Bool): Bool {
		return colorWriteMasksAlpha[0] = value;
	}

	public var conservativeRasterization: Bool;
}

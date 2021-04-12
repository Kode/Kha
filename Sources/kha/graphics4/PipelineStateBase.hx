package kha.graphics4;

class PipelineStateBase {
	public function new() {
		inputLayout = null;
		vertexShader = null;
		fragmentShader = null;
		geometryShader = null;
		tessellationControlShader = null;
		tessellationEvaluationShader = null;

		cullMode = CullMode.None;

		depthWrite = false;
		depthMode = CompareMode.Always;

		stencilFrontMode = CompareMode.Always;
		stencilFrontBothPass = StencilAction.Keep;
		stencilFrontDepthFail = StencilAction.Keep;
		stencilFrontFail = StencilAction.Keep;
		stencilFrontReferenceValue = Static(0);
		stencilFrontReadMask = 0xff;
		stencilFrontWriteMask = 0xff;

		stencilBackMode = CompareMode.Always;
		stencilBackBothPass = StencilAction.Keep;
		stencilBackDepthFail = StencilAction.Keep;
		stencilBackFail = StencilAction.Keep;
		stencilBackReferenceValue = Static(0);
		stencilBackReadMask = 0xff;
		stencilBackWriteMask = 0xff;

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
		for (i in 0...8)
			colorWriteMasksRed.push(true);
		for (i in 0...8)
			colorWriteMasksGreen.push(true);
		for (i in 0...8)
			colorWriteMasksBlue.push(true);
		for (i in 0...8)
			colorWriteMasksAlpha.push(true);

		colorAttachmentCount = 1;
		colorAttachments = [];
		for (i in 0...8)
			colorAttachments.push(TextureFormat.RGBA32);

		depthStencilAttachment = DepthStencilFormat.NoDepthAndStencil;

		conservativeRasterization = false;
	}

	public var inputLayout: Array<VertexStructure>;
	public var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	public var geometryShader: GeometryShader;
	public var tessellationControlShader: TessellationControlShader;
	public var tessellationEvaluationShader: TessellationEvaluationShader;

	public var cullMode: CullMode;

	public var depthWrite: Bool;
	public var depthMode: CompareMode;

	public var stencilFrontMode: CompareMode;
	public var stencilFrontBothPass: StencilAction;
	public var stencilFrontDepthFail: StencilAction;
	public var stencilFrontFail: StencilAction;
	public var stencilFrontReferenceValue: StencilValue;
	public var stencilFrontReadMask: Int;
	public var stencilFrontWriteMask: Int;

	public var stencilBackMode: CompareMode;
	public var stencilBackBothPass: StencilAction;
	public var stencilBackDepthFail: StencilAction;
	public var stencilBackFail: StencilAction;
	public var stencilBackReferenceValue: StencilValue;
	public var stencilBackReadMask: Int;
	public var stencilBackWriteMask: Int;

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

	public var colorAttachmentCount: Int;
	public var colorAttachments: Array<TextureFormat>;

	public var depthStencilAttachment: DepthStencilFormat;

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

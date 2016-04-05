package kha.graphics4;

class PipelineStateBase {
	public function new() {
		inputLayout = null;
		vertexShader = null;
		fragmentShader = null;
		geometryShader = null;
		tesselationControlShader = null;
		tesselationEvaluationShader = null;

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
		
		colorWriteMask = true;
	}

	public var inputLayout: Array<VertexStructure>;
	public var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	public var geometryShader: GeometryShader;
	public var tesselationControlShader: TesselationControlShader;
	public var tesselationEvaluationShader: TesselationEvaluationShader;

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
	
	public var colorWriteMask(never, set) : Bool;
	public var colorWriteMaskRed : Bool;
	public var colorWriteMaskGreen : Bool;
	public var colorWriteMaskBlue : Bool;
	public var colorWriteMaskAlpha : Bool;

	inline function set_colorWriteMask( value : Bool ) : Bool {
		return colorWriteMaskRed = colorWriteMaskBlue = colorWriteMaskGreen = colorWriteMaskAlpha = value;
	}
}

package kha.graphics4;

class PipelineStateBase {
	public function new() {
		inputLayout = null;
		vertexShader = null;
		fragmentShader = null;
		
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
		
		blendSource = BlendingOperation.BlendOne;
		blendDestination = BlendingOperation.BlendZero;
	}
	
	public var inputLayout: Array<VertexStructure>;
	public var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	
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
	public var blendSource: BlendingOperation;
	public var blendDestination: BlendingOperation;
}

package kha.flash.graphics4;

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DStencilAction;
import flash.display3D.Context3DTextureFilter;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.Context3DWrapMode;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.Vector;
import kha.Blob;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.StencilAction;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TexDir;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.VertexShader;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;

class Graphics implements kha.graphics4.Graphics {
	public static var context: Context3D;
	private var target: Image;

	public static function initContext(context: Context3D): Void {
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		Graphics.context = context;
	}

	public function new(target: Image = null) {
		this.target = target;
	}

	public function flush(): Void {

	}

	public function init(?backbufferFormat: TextureFormat, antiAliasingSamples: Int = 1): Void {

	}

	public function vsynced(): Bool {
		return true;
	}

	public function refreshRate(): Int {
		return Std.int(flash.Lib.current.stage.frameRate);
	}

	public function clear(?color: Color, ?depth: Float, ?stencil: Int): Void {
		var mask: UInt = 0;
		if (color != null) mask |= Context3DClearMask.COLOR;
		if (depth != null) mask |= Context3DClearMask.DEPTH;
		if (stencil != null) mask |= Context3DClearMask.STENCIL;
		var r = color == null ? 0.0 : color.R;
		var g = color == null ? 0.0 : color.G;
		var b = color == null ? 0.0 : color.B;
		var a = color == null ? 1.0 : color.A;
		context.clear(r, g, b, a, depth == null ? 1.0 : depth, stencil == null ? 0 : stencil, mask);
	}

	public function viewport(x : Int, y : Int, width : Int, height : Int): Void{
		//TODO better access to stage3d
		var stage3D = flash.Lib.current.stage.stage3Ds[0];
		stage3D.x = x;
		stage3D.y = y;
		context.configureBackBuffer(width,height,0,false);
	}

	public function setCullMode(mode: CullMode): Void {
		switch (mode) {
		case Clockwise:
			context.setCulling(Context3DTriangleFace.FRONT);
		case CounterClockwise:
			context.setCulling(Context3DTriangleFace.BACK);
		case None:
			context.setCulling(Context3DTriangleFace.NONE);
		}
	}

	private function getCompareMode(mode: CompareMode): Context3DCompareMode {
		switch (mode) {
		case Always:
			return Context3DCompareMode.ALWAYS;
		case Equal:
			return Context3DCompareMode.EQUAL;
		case Greater:
			return Context3DCompareMode.GREATER;
		case GreaterEqual:
			return Context3DCompareMode.GREATER_EQUAL;
		case Less:
			return Context3DCompareMode.LESS;
		case LessEqual:
			return Context3DCompareMode.LESS_EQUAL;
		case Never:
			return Context3DCompareMode.NEVER;
		case NotEqual:
			return Context3DCompareMode.NOT_EQUAL;
		}
	}

	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		context.setDepthTest(write, getCompareMode(mode));
	}

	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}

	private function getStencilAction(action: StencilAction): Context3DStencilAction {
		switch (action) {
		case Keep:
			return Context3DStencilAction.KEEP;
		case Replace:
			return Context3DStencilAction.SET;
		case Zero:
			return Context3DStencilAction.ZERO;
		case Invert:
			return Context3DStencilAction.INVERT;
		case Increment:
			return Context3DStencilAction.INCREMENT_SATURATE;
		case IncrementWrap:
			return Context3DStencilAction.INCREMENT_WRAP;
		case Decrement:
			return Context3DStencilAction.DECREMENT_SATURATE;
		case DecrementWrap:
			return Context3DStencilAction.DECREMENT_WRAP;
		}
	}

	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		context.setStencilReferenceValue(referenceValue, readMask, writeMask);
		context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, getCompareMode(compareMode), getStencilAction(bothPass), getStencilAction(depthFail), getStencilAction(stencilFail));
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		context.setScissorRectangle(new flash.geom.Rectangle(x, y, width, height));
	}

	public function disableScissor(): Void {

	}

	private function getWrapMode(addressing: TextureAddressing): Context3DWrapMode {
		switch (addressing) {
		case Clamp:
			return Context3DWrapMode.CLAMP;
		case Mirror, Repeat:
			return Context3DWrapMode.REPEAT;
		}
	}

	private function getFilter(filter: TextureFilter): Context3DTextureFilter {
		switch (filter) {
		case PointFilter:
			return Context3DTextureFilter.NEAREST;
		case LinearFilter, AnisotropicFilter:
			return Context3DTextureFilter.LINEAR;
		}
	}

	private function getMipFilter(mipFilter: MipMapFilter): Context3DMipFilter {
		switch (mipFilter) {
		case NoMipFilter:
			return Context3DMipFilter.MIPNONE;
		case PointMipFilter:
			return Context3DMipFilter.MIPNEAREST;
		case LinearMipFilter:
			return Context3DMipFilter.MIPLINEAR;
		}
	}

	// Flash only supports one texture addressing and filtering mode - we use the v and mag values here
	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		context.setSamplerStateAt(cast(texunit, TextureUnit).unit, getWrapMode(vAddressing), getFilter(magnificationFilter), getMipFilter(mipmapFilter));
	}

	private function getBlendFactor(op: BlendingFactor): Context3DBlendFactor {
		switch (op) {
			case BlendZero, Undefined:
				return Context3DBlendFactor.ZERO;
			case BlendOne:
				return Context3DBlendFactor.ONE;
			case SourceAlpha:
				return Context3DBlendFactor.SOURCE_ALPHA;
			case DestinationAlpha:
				return Context3DBlendFactor.DESTINATION_ALPHA;
			case InverseSourceAlpha:
				return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case InverseDestinationAlpha:
				return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
			default:
				return Context3DBlendFactor.ZERO;
		}
	}

	public function setBlendingMode(source: BlendingFactor, destination: BlendingFactor): Void {
		context.setBlendFactors(getBlendFactor(source), getBlendFactor(destination));
	}

	//public function createVertexBuffer(vertexCount: Int, structure: kha.graphics4.VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
	//	return new VertexBuffer(vertexCount, structure, usage);
	//}

	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		vertexBuffer.set();
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {

	}

	//public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics4.IndexBuffer {
	//	return new IndexBuffer(indexCount, usage);
	//}

	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		indexBuffer.set();
	}

	//public function createProgram(): kha.graphics4.Program {
	//	return new Program();
	//}

	public function setPipeline(pipe: PipelineState): Void {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReadMask, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination);
		context.setColorMask(pipe.colorWriteMaskRed, pipe.colorWriteMaskGreen, pipe.colorWriteMaskBlue, pipe.colorWriteMaskAlpha);
		pipe.set();
	}

	//public function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage, canRead: Bool = false, levels: Int = 1): Texture {
	//	return new Image(width, height, format, false, false, canRead);
	//}

	//public function createRenderTargetTexture(width: Int, height: Int, format: TextureFormat, depthStencil: Bool, antiAliasingSamples: Int = 1): Texture {
	//	return new Image(width, height, format, true, depthStencil, false);
	//}

	public function maxTextureSize(): Int {
		return 2048;
	}

	public function supportsNonPow2Textures(): Bool {
		return false;
	}

	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		context.setTextureAt(cast(unit, TextureUnit).unit, texture == null ? null : cast(texture, Image).getFlashTexture());
	}
	
	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
			
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {

	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		context.drawTriangles(IndexBuffer.current.indexBuffer, start, count >= 0 ? Std.int(count / 3) : count);
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {

	}

	public function instancedRenderingAvailable(): Bool {
		return false;
	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value ? 1 : 0;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		vec[2] = value3;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		vec[2] = value3;
		vec[3] = value4;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value.x;
		vec[1] = value.y;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value.x;
		vec[1] = value.y;
		vec[2] = value.z;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value.x;
		vec[1] = value.y;
		vec[2] = value.z;
		vec[3] = value.w;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		var projection = new Matrix3D();
		var vec = new Vector<Float>(16);
		vec[ 0] = matrix._00; vec[ 1] = matrix._01; vec[ 2] = matrix._02; vec[ 3] = matrix._03;
		vec[ 4] = matrix._10; vec[ 5] = matrix._11; vec[ 6] = matrix._12; vec[ 7] = matrix._13;
		vec[ 8] = matrix._20; vec[ 9] = matrix._21; vec[10] = matrix._22; vec[11] = matrix._23;
		vec[12] = matrix._30; vec[13] = matrix._31; vec[14] = matrix._32; vec[15] = matrix._33;
		projection.copyRawDataFrom(vec);
		var flashLocation = cast(location, ConstantLocation);
		context.setProgramConstantsFromMatrix(flashLocation.type, flashLocation.value, projection, true);
	}

	public function setFloats(location: kha.graphics4.ConstantLocation, values: haxe.ds.Vector<FastFloat>): Void {
		var flashLocation: ConstantLocation = cast location;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, values.toData());
	}

	//public function renderToBackbuffer(): Void {
	//	context.setRenderToBackBuffer();
	//}

	//public function renderToTexture(texture: Texture): Void {
	//	context.setRenderToTexture(cast(texture, Image).getFlashTexture(), cast(texture, Image).hasDepthStencil());
	//}

	public function renderTargetsInvertedY(): Bool {
		return false;
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (target == null) context.setRenderToBackBuffer();
		else context.setRenderToTexture(target.getFlashTexture(), enableDepthStencil(target.depthStencilFormat()));
	}

	function enableDepthStencil( format : DepthStencilFormat ) : Bool {
		return switch (format) {
			case NoDepthAndStencil: false;
			case DepthOnly: true;
			case DepthAutoStencilAuto: true;
			case Depth24Stencil8: {
				#if debug
				trace('DepthStencilFormat "Depth24Stencil8" is not supported, using target defaults');
				#end
				true;
			}
			case Depth32Stencil8: {
				#if debug
				trace('DepthStencilFormat "Depth32Stencil8" is not supported, using target defaults');
				#end
				true;
			}
		}
	}

	public function end(): Void {

	}
}

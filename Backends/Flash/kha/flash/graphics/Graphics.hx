package kha.flash.graphics;

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DProgramType;
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
import kha.flash.Image;
import kha.graphics.BlendingOperation;
import kha.graphics.CullMode;
import kha.graphics.DepthCompareMode;
import kha.graphics.MipMapFilter;
import kha.graphics.Texture;
import kha.graphics.TextureAddressing;
import kha.graphics.TextureArgument;
import kha.graphics.TexDir;
import kha.graphics.TextureFilter;
import kha.graphics.TextureFormat;
import kha.graphics.TextureOperation;

class Graphics implements kha.graphics.Graphics {
	public static var context: Context3D;

	public function new(context: Context3D) {
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		Graphics.context = context;
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

	public function setDepthMode(write: Bool, mode: DepthCompareMode): Void {
		switch (mode) {
		case Always:
			context.setDepthTest(write, Context3DCompareMode.ALWAYS);
		case Equal:
			context.setDepthTest(write, Context3DCompareMode.EQUAL);
		case Greater:
			context.setDepthTest(write, Context3DCompareMode.GREATER);
		case GreaterEqual:
			context.setDepthTest(write, Context3DCompareMode.GREATER_EQUAL);
		case Less:
			context.setDepthTest(write, Context3DCompareMode.LESS);
		case LessEqual:
			context.setDepthTest(write, Context3DCompareMode.LESS_EQUAL);
		case Never:
			context.setDepthTest(write, Context3DCompareMode.NEVER);
		case NotEqual:
			context.setDepthTest(write, Context3DCompareMode.NOT_EQUAL);
		}
	}
	
	private function getWrapMode(addressing: TextureAddressing): Context3DWrapMode {
		switch (addressing) {
		case Border, Clamp:
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
	public function setTextureParameters(texunit: Int, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		context.setSamplerStateAt(texunit, getWrapMode(vAddressing), getFilter(magnificationFilter), getMipFilter(mipmapFilter));
	}
	
	private function getBlendFactor(op: BlendingOperation): Context3DBlendFactor {
		switch (op) {
			case BlendZero:
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
		}
	}

	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		context.setBlendFactors(getBlendFactor(source), getBlendFactor(destination));
	}

	public function createVertexBuffer(vertexCount: Int, structure: kha.graphics.VertexStructure): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
		cast(indexBuffer, IndexBuffer).set();
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function createTexture(width: Int, height: Int, format: TextureFormat): Texture {
		return new Image(width, height, format);
	}
	
	public function setTexture(unit: kha.graphics.TextureUnit, texture: kha.Image): Void {
		context.setTextureAt(cast(unit, TextureUnit).unit, texture == null ? null : cast(texture, Image).getFlashTexture());
	}
	
	public function setTextureWrap(unit: kha.graphics.TextureUnit, u: kha.graphics.TextureWrap, v: kha.graphics.TextureWrap): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		context.drawTriangles(IndexBuffer.current.indexBuffer, start, count >= 0 ? Std.int(count / 3) : count);
	}
	
	public function createVertexShader(source: Blob): kha.graphics.VertexShader {
		return new Shader(source.toString(), Context3DProgramType.VERTEX);
	}

	public function createFragmentShader(source: Blob): kha.graphics.FragmentShader {
		return new Shader(source.toString(), Context3DProgramType.FRAGMENT);
	}
	
	public function setInt(location: kha.graphics.ConstantLocation, value: Int): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}

	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		var flashLocation = cast(location, ConstantLocation);
		var vec = new Vector<Float>(4);
		vec[0] = value1;
		vec[1] = value2;
		vec[2] = value3;
		context.setProgramConstantsFromVector(flashLocation.type, flashLocation.value, vec);
	}
	
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		var projection = new Matrix3D();
		var vec = new Vector<Float>(16);
		for (i in 0...16) vec[i] = matrix[i];
		projection.copyRawDataFrom(vec);
		var flashLocation = cast(location, ConstantLocation);
		context.setProgramConstantsFromMatrix(flashLocation.type, flashLocation.value, projection, true);
	}
}

package kha.cpp.graphics4;

import kha.Blob;
import kha.Color;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.MipMapFilter;
import kha.graphics4.StencilAction;
import kha.graphics4.TexDir;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.Image;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Rectangle;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

class Graphics implements kha.graphics4.Graphics {
	private var target: Image;
	
	public function new(target: Image = null) {
		this.target = target;
	}
	
	public function init(?backbufferFormat: TextureFormat, antiAliasingSamples: Int = 1): Void {
		
	}
	
	@:functionCode('
		return Kore::Graphics::vsynced();
	')
	public function vsynced(): Bool {
		return true;
	}

	@:functionCode('
		return (Int)Kore::Graphics::refreshRate();
	')
	public function refreshRate(): Int {
		return 0;
	}
	
	public function clear(?color: Color, ?z: Float, ?stencil: Int): Void {
		var flags: Int = 0;
		if (color != null) flags |= 1;
		if (z != null) flags |= 2;
		if (stencil != null) flags |= 4;
		clear2(flags, color == null ? 0 : color.value, z, stencil);
	}
	
	@:functionCode('
		switch (mode) {
		case 0:
			Kore::Graphics::setRenderState(Kore::DepthTest, false);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareAlways);
			break;
		case 1:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareNever);
			break;
		case 2:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareEqual);
			break;
		case 3:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareNotEqual);
			break;
		case 4:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareLess);
			break;
		case 5:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareLessEqual);
			break;
		case 6:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareGreater);
			break;
		case 7:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareGreaterEqual);
			break;
		}
		Kore::Graphics::setRenderState(Kore::DepthWrite, write);
	')
	private function setDepthMode2(write: Bool, mode: Int): Void {
		
	}
	
	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		setDepthMode2(write, mode.getIndex());
	}
	
	
	private function getBlendingMode(op: BlendingOperation): Int {
		switch (op) {
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
		}
	}
	
	@:functionCode('
		if (source == 0 && destination == 1) {
			Kore::Graphics::setRenderState(Kore::BlendingState, false);
		}
		else {
			Kore::Graphics::setRenderState(Kore::BlendingState, true);
			Kore::Graphics::setBlendingMode((Kore::BlendingOperation)source, (Kore::BlendingOperation)destination);
		}
	')
	private function setBlendingModeNative(source: Int, destination: Int): Void {
		
	}
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		setBlendingModeNative(getBlendingMode(source), getBlendingMode(destination));
	}
	
	@:functionCode('
		Kore::Graphics::clear(flags, color, z, stencil);
	')
	private function clear2(flags: Int, color: Int, z: Float, stencil: Int): Void {
		
	}
	
	//public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
	//	return new VertexBuffer(vertexCount, structure);
	//}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		vertexBuffer.set();
	}
	
	//public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics.IndexBuffer {
	//	return new IndexBuffer(indexCount);
	//}
	
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		indexBuffer.set();
	}
	
	//public function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage, canRead: Bool = false, levels: Int = 1): Texture {
	//	return Image.create(width, height, format, canRead, false, false);
	//}
	
	//public function createRenderTargetTexture(width: Int, height: Int, format: TextureFormat, depthStencil: Bool, antiAliasingSamples: Int = 1): Texture {
	//	return Image.create(width, height, format, false, true, depthStencil);
	//}
	
	public function maxTextureSize(): Int {
		return 4096;
	}
	
	public function supportsNonPow2Textures(): Bool {
		return false;
	}
	
	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		
	}

	public function setScissor(rect: Rectangle): Void {
		
	}
	
	@:functionCode('return Kore::Graphics::renderTargetsInvertedY();')
	public function renderTargetsInvertedY(): Bool {
		return false;
	}
	
	@:functionCode('
		Kore::Graphics::setTextureAddressing(unit->unit, Kore::U, (Kore::TextureAddressing)uWrap);
		Kore::Graphics::setTextureAddressing(unit->unit, Kore::V, (Kore::TextureAddressing)vWrap);
	')
	private function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics::setTextureMinificationFilter(unit->unit, (Kore::TextureFilter)minificationFilter);
		Kore::Graphics::setTextureMagnificationFilter(unit->unit, (Kore::TextureFilter)magnificationFilter);
		Kore::Graphics::setTextureMipmapFilter(unit->unit, (Kore::MipmapFilter)mipMapFilter);
	')
	private function setTextureFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {
		
	}
	
	private function getTextureAddressing(addressing: TextureAddressing): Int {
		switch (addressing) {
		case TextureAddressing.Repeat:
			return 0;
		case TextureAddressing.Mirror:
			return 1;
		case TextureAddressing.Clamp:
			return 2;
		}
	}
	
	private function getTextureFilter(filter: TextureFilter): Int {
		switch (filter) {
		case PointFilter:
			return 0;
		case LinearFilter:
			return 1;
		case AnisotropicFilter:
			return 2;
		}
	}
	
	private function getTextureMipMapFilter(filter: MipMapFilter): Int {
		switch (filter) {
		case NoMipFilter:
			return 0;
		case PointMipFilter:
			return 1;
		case LinearMipFilter:
			return 2;
		}
	}
	
	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTextureWrapNative(cast texunit, getTextureAddressing(uAddressing), getTextureAddressing(vAddressing));
		setTextureFiltersNative(cast texunit, getTextureFilter(minificationFilter), getTextureFilter(magnificationFilter), getTextureMipMapFilter(mipmapFilter));
	}
	
	@:functionCode('
		Kore::Graphics::setRenderState(Kore::BackfaceCulling, value);
	')
	private function setCullModeNative(value: Bool): Void {
		
	}
	
	public function setCullMode(mode: CullMode): Void {
		setCullModeNative(mode != None);
	}
	
	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		texture.set(cast unit);
	}
	
	//public function createVertexShader(source: Blob): VertexShader {
	//	return new Shader(source, ShaderType.VertexShader);
	//}
	
	//public function createFragmentShader(source: Blob): FragmentShader {
	//	return new Shader(source, ShaderType.FragmentShader);
	//}
	
	//public function createProgram(): kha.graphics4.Program {
	//	return new Program();
	//}
	
	public function setProgram(program: kha.graphics4.Program): Void {
		program.set();
	}
	
	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		setBoolPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics::setBool(location->location, value);
	')
	private function setBoolPrivate(location: kha.cpp.graphics4.ConstantLocation, value: Bool): Void {
		
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		setIntPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics::setInt(location->location, value);
	')
	private function setIntPrivate(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void {
		setFloatPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat(location->location, value);
	')
	private function setFloatPrivate(location: ConstantLocation, value: Float): Void {
		
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void {
		setFloat2Private(cast location, value1, value2);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat2(location->location, value1, value2);
	')
	private function setFloat2Private(location: ConstantLocation, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		setFloat3Private(cast location, value1, value2, value3);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat3(location->location, value1, value2, value3);
	')
	private function setFloat3Private(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {
		setFloat4Private(cast location, value1, value2, value3, value4);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat4(location->location, value1, value2, value3, value4);
	')
	private function setFloat4Private(location: ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {
		
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: Vector2): Void {
		setVector2Private(cast location, value.x, value.y);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat2(location->location, x, y);
	')
	private function setVector2Private(location: ConstantLocation, x: Float, y: Float): Void {
		
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: Vector3): Void {
		setVector3Private(cast location, value.x, value.y, value.z);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat3(location->location, x, y, z);
	')
	private function setVector3Private(location: ConstantLocation, x: Float, y: Float, z: Float): Void {
		
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: Vector4): Void {
		setVector4Private(cast location, value.x, value.y, value.z, value.w);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat4(location->location, x, y, z, w);
	')
	private function setVector4Private(location: ConstantLocation, x: Float, y: Float, z: Float, w: Float): Void {
		
	}
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Array<Float>): Void {
		setFloatsPrivate(cast location, values);
	}
	
	@:functionCode('
		float v[100];
		for (int i = 0; i < values->length; ++i) v[i] = values[i];
		Kore::Graphics::setFloats(location->location, v, values->length);
	')
	private function setFloatsPrivate(location: ConstantLocation, values: Array<Float>): Void {
		
	}
	
	@:functionCode('
		Kore::mat4 value;
		for (int y = 0; y < 4; ++y) {
			for (int x = 0; x < 4; ++x) {
				value.Set(x, y, matrix->matrix[y * 4 + x]);
			}
		}
		::kha::cpp::graphics4::ConstantLocation_obj* loc = dynamic_cast< ::kha::cpp::graphics4::ConstantLocation_obj*>(location->__GetRealObject());
		Kore::Graphics::setMatrix(loc->location, value);
	')
	public function setMatrix(location: kha.graphics4.ConstantLocation, matrix: Matrix4): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0) drawAllIndexedVertices();
		else drawSomeIndexedVertices(start, count);
	}
	
	@:functionCode('
		Kore::Graphics::drawIndexedVertices();
	')
	private function drawAllIndexedVertices(): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics::drawIndexedVertices(start, count);
	')
	public function drawSomeIndexedVertices(start: Int, count: Int): Void {
		
	}
	
	@:functionCode('Kore::Graphics::setRenderTarget(target->renderTarget, 0);')
	private function renderToTexture(): Void {
		
	}
	
	@:functionCode('Kore::Graphics::restoreRenderTarget();')
	private function renderToBackbuffer(): Void {
		
	}
	
	public function begin(): Void {
		if (target == null) renderToBackbuffer();
		else renderToTexture();
	}
	
	public function end(): Void {
		
	}
}

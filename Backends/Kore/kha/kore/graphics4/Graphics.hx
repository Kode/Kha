package kha.kore.graphics4;

import haxe.ds.Vector;
import kha.Blob;
import kha.Color;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.StencilAction;
import kha.graphics4.TexDir;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Video;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:cppFileCode('
Kore::ZCompareMode convertCompareMode(int mode) {
	switch (mode) {
	case 0:
		return Kore::ZCompareAlways;
	case 1:
		return Kore::ZCompareNever;
	case 2:
		return Kore::ZCompareEqual;
	case 3:
		return Kore::ZCompareNotEqual;
	case 4:
		return Kore::ZCompareLess;
	case 5:
		return Kore::ZCompareLessEqual;
	case 6:
		return Kore::ZCompareGreater;
	case 7:
	default:
		return Kore::ZCompareGreaterEqual;
	}
}

Kore::StencilAction convertStencilAction(int action) {
	switch (action) {
	case 0:
		return Kore::Keep;
	case 1:
		return Kore::Zero;
	case 2:
		return Kore::Replace;
	case 3:
		return Kore::Increment;
	case 4:
		return Kore::IncrementWrap;
	case 5:
		return Kore::Decrement;
	case 6:
		return Kore::DecrementWrap;
	case 7:
	default:
		return Kore::Invert;	
	}
}
')
class Graphics implements kha.graphics4.Graphics {
	private var target: Image;
	
	public function new(target: Image = null) {
		this.target = target;
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
		Kore::Graphics::viewport(x,y,width,height);
	')
	public function viewport(x : Int, y : Int, width : Int, height : Int): Void{
	
	}
	
	@:functionCode('
		switch (mode) {
		case 0:
			write ? Kore::Graphics::setRenderState(Kore::DepthTest, true) : Kore::Graphics::setRenderState(Kore::DepthTest, false);
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
	
	
	private function getBlendingMode(op: BlendingFactor): Int {
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
	
	private function setBlendingMode(source: BlendingFactor, destination: BlendingFactor): Void {
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
	
	@:functionCode('Kore::Graphics::setVertexBuffer(*vertexBuffer->buffer);')
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		
	}
	
	@:functionCode('
		Kore::VertexBuffer* vertexBuffers[4] = {
			vb0 == null() ? nullptr : vb0->buffer,
			vb1 == null() ? nullptr : vb1->buffer,
			vb2 == null() ? nullptr : vb2->buffer,
			vb3 == null() ? nullptr : vb3->buffer
		};
		Kore::Graphics::setVertexBuffers(vertexBuffers, count);
	')
	private function setVertexBuffersInternal(vb0: VertexBuffer, vb1: VertexBuffer, vb2: VertexBuffer, vb3: VertexBuffer, count: Int): Void {
		
	}
	
	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		setVertexBuffersInternal(
			vertexBuffers.length > 0 ? vertexBuffers[0] : null,
			vertexBuffers.length > 1 ? vertexBuffers[1] : null,
			vertexBuffers.length > 2 ? vertexBuffers[2] : null,
			vertexBuffers.length > 3 ? vertexBuffers[3] : null,
			vertexBuffers.length);
	}
	
	//public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics.IndexBuffer {
	//	return new IndexBuffer(indexCount);
	//}
	
	@:functionCode('Kore::Graphics::setIndexBuffer(*indexBuffer->buffer);')
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		
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
	
	@:functionCode('
		Kore::Graphics::setStencilParameters(convertCompareMode(compareMode), convertStencilAction(bothPass), convertStencilAction(depthFail), convertStencilAction(stencilFail), referenceValue, readMask, writeMask);
	')
	private function setStencilParameters2(compareMode: Int, bothPass: Int, depthFail: Int, stencilFail: Int, referenceValue: Int, readMask: Int, writeMask: Int): Void {
		
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		setStencilParameters2(compareMode.getIndex(), bothPass.getIndex(), depthFail.getIndex(), stencilFail.getIndex(), referenceValue, readMask, writeMask);
	}
	
	@:functionCode('
		Kore::Graphics::scissor(x,y,width,height);
	')
	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics::disableScissor();
	')
	public function disableScissor(): Void {
		
	}
	
	@:functionCode('return Kore::Graphics::renderTargetsInvertedY();')
	public function renderTargetsInvertedY(): Bool {
		return false;
	}
	
	public function instancedRenderingAvailable(): Bool {
		return true;
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
	private function setCullModeNative(value: Int): Void {
		
	}
	
	public function setCullMode(mode: CullMode): Void {
		setCullModeNative(mode.getIndex());
	}
	
	@:functionCode('
		if (texture->texture != nullptr) Kore::Graphics::setTexture(unit->unit, texture->texture);
		else texture->renderTarget->useColorAsTexture(unit->unit);
	')
	private function setTextureInternal(unit: kha.kore.graphics4.TextureUnit, texture: kha.Image): Void {
		
	}
	
	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		setTextureInternal(cast unit, texture);
	}
	
	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("texture->renderTarget->useDepthAsTexture(koreUnit->unit);");
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null) return;
		setTextureInternal(cast unit, Image.createFromVideo(texture));
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
	
	public function setPipeline(pipe: PipelineState): Void {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReadMask, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination);
		setColorMask(pipe.colorWriteMaskRed, pipe.colorWriteMaskGreen, pipe.colorWriteMaskBlue, pipe.colorWriteMaskAlpha);        
		pipe.set();
	}
	
	@:functionCode('Kore::Graphics::setColorMask(red, green, blue, alpha);')
	function setColorMask(red : Bool, green : Bool, blue : Bool, alpha : Bool) {
	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		setBoolPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics::setBool(location->location, value);
	')
	private function setBoolPrivate(location: kha.kore.graphics4.ConstantLocation, value: Bool): Void {
		
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		setIntPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics::setInt(location->location, value);
	')
	private function setIntPrivate(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		setFloatPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat(location->location, value);
	')
	private function setFloatPrivate(location: ConstantLocation, value: FastFloat): Void {
		
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		setFloat2Private(cast location, value1, value2);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat2(location->location, value1, value2);
	')
	private function setFloat2Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		setFloat3Private(cast location, value1, value2, value3);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat3(location->location, value1, value2, value3);
	')
	private function setFloat3Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		setFloat4Private(cast location, value1, value2, value3, value4);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat4(location->location, value1, value2, value3, value4);
	')
	private function setFloat4Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		setVector2Private(cast location, value.x, value.y);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat2(location->location, x, y);
	')
	private function setVector2Private(location: ConstantLocation, x: FastFloat, y: FastFloat): Void {
		
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		setVector3Private(cast location, value.x, value.y, value.z);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat3(location->location, x, y, z);
	')
	private function setVector3Private(location: ConstantLocation, x: FastFloat, y: FastFloat, z: FastFloat): Void {
		
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		setVector4Private(cast location, value.x, value.y, value.z, value.w);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat4(location->location, x, y, z, w);
	')
	private function setVector4Private(location: ConstantLocation, x: FastFloat, y: FastFloat, z: FastFloat, w: FastFloat): Void {
		
	}
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Vector<FastFloat>): Void {
		setFloatsPrivate(cast location, values);
	}
	
	@:functionCode('
		Kore::Graphics::setFloats(location->location, values->Pointer(), values->length);
	')
	private function setFloatsPrivate(location: ConstantLocation, values: Vector<FastFloat>): Void {
		
	}
	
	@:functionCode('
		Kore::mat4 value;
		value.Set(0, 0, matrix->_00); value.Set(0, 1, matrix->_10); value.Set(0, 2, matrix->_20); value.Set(0, 3, matrix->_30);
		value.Set(1, 0, matrix->_01); value.Set(1, 1, matrix->_11); value.Set(1, 2, matrix->_21); value.Set(1, 3, matrix->_31);
		value.Set(2, 0, matrix->_02); value.Set(2, 1, matrix->_12); value.Set(2, 2, matrix->_22); value.Set(2, 3, matrix->_32);
		value.Set(3, 0, matrix->_03); value.Set(3, 1, matrix->_13); value.Set(3, 2, matrix->_23); value.Set(3, 3, matrix->_33);
		::kha::kore::graphics4::ConstantLocation_obj* loc = dynamic_cast< ::kha::kore::graphics4::ConstantLocation_obj*>(location->__GetRealObject());
		Kore::Graphics::setMatrix(loc->location, value);
	')
	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		
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
	
	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		if (count < 0) drawAllIndexedVerticesInstanced(instanceCount);
		else drawSomeIndexedVerticesInstanced(instanceCount, start, count);
	}
	
	@:functionCode('
		Kore::Graphics::drawIndexedVerticesInstanced(instanceCount);
	')
	private function drawAllIndexedVerticesInstanced(instanceCount: Int): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics::drawIndexedVerticesInstanced(instanceCount, start, count);
	')
	private function drawSomeIndexedVerticesInstanced(instanceCount: Int, start: Int, count: Int): Void {
		
	}
	
	private function renderToTexture(additionalRenderTargets: Array<Canvas>): Void {
		if (additionalRenderTargets != null) {
			var len = additionalRenderTargets.length;
			untyped __cpp__("Kore::Graphics::setRenderTarget(target->renderTarget, 0, len)");
			for (i in 0...len) {
				var image = cast(additionalRenderTargets[i], Image);
				var num = i + 1;
				untyped __cpp__("Kore::Graphics::setRenderTarget(image->renderTarget, num, len)");
			}
		}
		else {
			untyped __cpp__("Kore::Graphics::setRenderTarget(target->renderTarget, 0, 0)");
		}
	}
	
	@:functionCode('Kore::Graphics::restoreRenderTarget();')
	private function renderToBackbuffer(): Void {
		
	}
	
	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (target == null) renderToBackbuffer();
		else renderToTexture(additionalRenderTargets);
	}
	
	public function end(): Void {
		
	}
	
	@:functionCode('Kore::Graphics::flush();')
	public function flush(): Void {
		
	}
}

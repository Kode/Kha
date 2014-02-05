package kha.cpp.graphics;

import kha.Blob;
import kha.Color;
import kha.cpp.Image;
import kha.graphics.CubeMap;
import kha.graphics.CullMode;
import kha.graphics.FragmentShader;
import kha.graphics.BlendingOperation;
import kha.graphics.CompareMode;
import kha.graphics.MipMapFilter;
import kha.graphics.StencilAction;
import kha.graphics.TexDir;
import kha.graphics.Texture;
import kha.graphics.TextureAddressing;
import kha.graphics.TextureFilter;
import kha.graphics.TextureFormat;
import kha.graphics.Usage;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;
import kha.Rectangle;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

class Graphics implements kha.graphics.Graphics {
	public function new() {
		
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
		case 1:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareNever);
		case 2:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareEqual);
		case 3:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareNotEqual);
		case 4:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareLess);
		case 5:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareLessEqual);
		case 6:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareGreater);
		case 7:
			Kore::Graphics::setRenderState(Kore::DepthTest, true);
			Kore::Graphics::setRenderState(Kore::DepthTestCompare, Kore::ZCompareGreaterEqual);
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
		case BlendOne:
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
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
		cast(indexBuffer, IndexBuffer).set();
	}
	
	public function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage, canRead: Bool = false, levels: Int = 1): Texture {
		return Image.create(width, height, format, canRead, false);
	}
	
	public function createRenderTargetTexture(width: Int, height: Int, format: TextureFormat, depthStencil: Bool, antiAliasingSamples: Int = 1): Texture {
		return Image.create(width, height, format, false, true);
	}
	
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
	
	@:functionCode('Kore::Graphics::setRenderTarget(texture->renderTarget, 0);')
	public function renderToTexture2(texture: Image): Void {
		
	}
	
	public function renderToTexture(texture: Texture): Void {
		renderToTexture2(cast texture);
	}
	
	@:functionCode('Kore::Graphics::restoreRenderTarget();')
	public function renderToBackbuffer(): Void {
		
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
	
	public function setTextureParameters(texunit: kha.graphics.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
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
	
	public function setTexture(unit: kha.graphics.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		cast(texture, Image).set(cast unit);
	}
	
	public function createVertexShader(source: Blob): VertexShader {
		return new Shader(source, ShaderType.VertexShader);
	}
	
	public function createFragmentShader(source: Blob): FragmentShader {
		return new Shader(source, ShaderType.FragmentShader);
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function setInt(location: kha.graphics.ConstantLocation, value: Int): Void {
		setIntPrivate(cast(location, ConstantLocation), value);
	}
	
	@:functionCode('
		Kore::Graphics::setInt(location->location, value);
	')
	private function setIntPrivate(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		setFloatPrivate(cast(location, ConstantLocation), value);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat(location->location, value);
	')
	private function setFloatPrivate(location: ConstantLocation, value: Float): Void {
		
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		setFloat2Private(cast(location, ConstantLocation), value1, value2);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat2(location->location, value1, value2);
	')
	private function setFloat2Private(location: ConstantLocation, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		setFloat3Private(cast(location, ConstantLocation), value1, value2, value3);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat3(location->location, value1, value2, value3);
	')
	private function setFloat3Private(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		
	}
	
	@:functionCode('
		Kore::mat4 value;
		for (int y = 0; y < 4; ++y) {
			for (int x = 0; x < 4; ++x) {
				value.Set(x, y, matrix[y * 4 + x]);
			}
		}
		::kha::cpp::graphics::ConstantLocation_obj* loc = dynamic_cast< ::kha::cpp::graphics::ConstantLocation_obj*>(location->__GetRealObject());
		Kore::Graphics::setMatrix(loc->location, value);
	')
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		
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
}

package kha.kore.graphics4;

import kha.arrays.Float32Array;
import kha.Blob;
import kha.Canvas;
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
import kha.math.FastMatrix3;
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
#include <Kore/Graphics4/Graphics.h>
#include <Kore/Display.h>
#include <Kore/Window.h>
')

@:headerClassCode("Kore::Graphics4::RenderTarget* renderTarget;")
class Graphics implements kha.graphics4.Graphics {
	private var target: Canvas;
	public var window: Null<Int>;
	public static var lastWindow: Int = -1;
	static var current: Graphics = null;
	
	public function new(target: Canvas = null) {
		this.target = target;
		init();
	}

	function init() {
		if (target == null) return;
		if (Std.is(target, CubeMap)) {
			var cubeMap = cast(target, CubeMap);
			untyped __cpp__("renderTarget = cubeMap->renderTarget");
		}
		else {
			var image = cast(target, Image);
			untyped __cpp__("renderTarget = image->renderTarget");
		}
	}
	
	@:functionCode('return Kore::Window::get(0)->vSynced();')
	public function vsynced(): Bool {
		return true;
	}

	@:functionCode('return Kore::Display::primary()->frequency();')
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
		Kore::Graphics4::viewport(x,y,width,height);
	')
	public function viewport(x : Int, y : Int, width : Int, height : Int): Void{
	
	}
	
	@:functionCode('
		Kore::Graphics4::clear(flags, color, z, stencil);
	')
	private function clear2(flags: Int, color: Int, z: Float, stencil: Int): Void {
		
	}
	
	//public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
	//	return new VertexBuffer(vertexCount, structure);
	//}
	
	@:functionCode('Kore::Graphics4::setVertexBuffer(*vertexBuffer->buffer);')
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics4::VertexBuffer* vertexBuffers[4] = {
			vb0 == null() ? nullptr : vb0->buffer,
			vb1 == null() ? nullptr : vb1->buffer,
			vb2 == null() ? nullptr : vb2->buffer,
			vb3 == null() ? nullptr : vb3->buffer
		};
		Kore::Graphics4::setVertexBuffers(vertexBuffers, count);
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
	
	@:functionCode('Kore::Graphics4::setIndexBuffer(*indexBuffer->buffer);')
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
	
	public function setCubeMap(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null) return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__(
			"if (cubeMap->texture != nullptr) Kore::Graphics4::setTexture(koreUnit->unit, cubeMap->texture);
			else cubeMap->renderTarget->useColorAsTexture(koreUnit->unit)"
		);
	}
	
	public function setCubeMapDepth(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null) return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("cubeMap->renderTarget->useDepthAsTexture(koreUnit->unit);");
	}
	
	@:functionCode('Kore::Graphics4::scissor(x, y, width, height);')
	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		
	}
	
	@:functionCode('Kore::Graphics4::disableScissor();')
	public function disableScissor(): Void {
		
	}

	public function instancedRenderingAvailable(): Bool {
		return true;
	}
	
	@:functionCode('
		Kore::Graphics4::setTextureAddressing(unit->unit, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uWrap);
		Kore::Graphics4::setTextureAddressing(unit->unit, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vWrap);
	')
	private function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {
		
	}

	@:functionCode('
		Kore::Graphics4::setTexture3DAddressing(unit->unit, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uWrap);
		Kore::Graphics4::setTexture3DAddressing(unit->unit, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vWrap);
		Kore::Graphics4::setTexture3DAddressing(unit->unit, Kore::Graphics4::W, (Kore::Graphics4::TextureAddressing)wWrap);
	')
	private function setTexture3DWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int, wWrap: Int): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics4::setTextureMinificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)minificationFilter);
		Kore::Graphics4::setTextureMagnificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)magnificationFilter);
		Kore::Graphics4::setTextureMipmapFilter(unit->unit, (Kore::Graphics4::MipmapFilter)mipMapFilter);
	')
	private function setTextureFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {
		
	}

	@:functionCode('
		Kore::Graphics4::setTexture3DMinificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)minificationFilter);
		Kore::Graphics4::setTexture3DMagnificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)magnificationFilter);
		Kore::Graphics4::setTexture3DMipmapFilter(unit->unit, (Kore::Graphics4::MipmapFilter)mipMapFilter);
	')
	private function setTexture3DFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {
		
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

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTexture3DWrapNative(cast texunit, getTextureAddressing(uAddressing), getTextureAddressing(vAddressing), getTextureAddressing(wAddressing));
		setTexture3DFiltersNative(cast texunit, getTextureFilter(minificationFilter), getTextureFilter(magnificationFilter), getTextureMipMapFilter(mipmapFilter));
	}

	public function setTextureCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool) {
		var koreUnit = cast(texunit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("Kore::Graphics4::setTextureCompareMode(koreUnit->unit, enabled);");
	}

	public function setCubeMapCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool) {
		var koreUnit = cast(texunit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("Kore::Graphics4::setCubeMapCompareMode(koreUnit->unit, enabled);");
	}
	
	@:functionCode('
		if (texture->texture != nullptr) Kore::Graphics4::setTexture(unit->unit, texture->texture);
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
	
	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("if (texture->textureArray != nullptr) Kore::Graphics4::setTextureArray(koreUnit->unit, texture->textureArray);");
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null) return;
		setTextureInternal(cast unit, Image.createFromVideo(texture));
	}

	@:functionCode('
		Kore::Graphics4::setImageTexture(unit->unit, texture->texture);
	')
	private function setImageTextureInternal(unit: kha.kore.graphics4.TextureUnit, texture: kha.Image): Void {
		
	}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		setImageTextureInternal(cast unit, texture);
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
		pipe.set();
	}

	@:functionCode('
		Kore::Graphics4::setStencilReferenceValue(value);
	')
	public function setStencilReferenceValue(value: Int): Void {

	}
	
	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		setBoolPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics4::setBool(location->location, value);
	')
	private function setBoolPrivate(location: kha.kore.graphics4.ConstantLocation, value: Bool): Void {
		
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		setIntPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics4::setInt(location->location, value);
	')
	private function setIntPrivate(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		setFloatPrivate(cast location, value);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat(location->location, value);
	')
	private function setFloatPrivate(location: ConstantLocation, value: FastFloat): Void {
		
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		setFloat2Private(cast location, value1, value2);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat2(location->location, value1, value2);
	')
	private function setFloat2Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		setFloat3Private(cast location, value1, value2, value3);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat3(location->location, value1, value2, value3);
	')
	private function setFloat3Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		setFloat4Private(cast location, value1, value2, value3, value4);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat4(location->location, value1, value2, value3, value4);
	')
	private function setFloat4Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		setVector2Private(cast location, value.x, value.y);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat2(location->location, x, y);
	')
	private function setVector2Private(location: ConstantLocation, x: FastFloat, y: FastFloat): Void {
		
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		setVector3Private(cast location, value.x, value.y, value.z);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat3(location->location, x, y, z);
	')
	private function setVector3Private(location: ConstantLocation, x: FastFloat, y: FastFloat, z: FastFloat): Void {
		
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		setVector4Private(cast location, value.x, value.y, value.z, value.w);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloat4(location->location, x, y, z, w);
	')
	private function setVector4Private(location: ConstantLocation, x: FastFloat, y: FastFloat, z: FastFloat, w: FastFloat): Void {
		
	}
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		setFloatsPrivate(cast location, values);
	}
	
	@:functionCode('
		Kore::Graphics4::setFloats(location->location, values->self.data, values->self.length());
	')
	private function setFloatsPrivate(location: ConstantLocation, values: Float32Array): Void {
		
	}

	public function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		setMatrixPrivate(cast location, matrix);
	}

	@:functionCode('
		Kore::mat4 value;
		value.Set(0, 0, matrix->_00); value.Set(0, 1, matrix->_10); value.Set(0, 2, matrix->_20); value.Set(0, 3, matrix->_30);
		value.Set(1, 0, matrix->_01); value.Set(1, 1, matrix->_11); value.Set(1, 2, matrix->_21); value.Set(1, 3, matrix->_31);
		value.Set(2, 0, matrix->_02); value.Set(2, 1, matrix->_12); value.Set(2, 2, matrix->_22); value.Set(2, 3, matrix->_32);
		value.Set(3, 0, matrix->_03); value.Set(3, 1, matrix->_13); value.Set(3, 2, matrix->_23); value.Set(3, 3, matrix->_33);
		Kore::Graphics4::setMatrix(location->location, value);
	')
	private function setMatrixPrivate(location: ConstantLocation, matrix: FastMatrix4): Void {

	}

	public function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		setMatrix3Private(cast location, matrix);
	}

	@:functionCode('
		Kore::mat3 value;
		value.Set(0, 0, matrix->_00); value.Set(0, 1, matrix->_10); value.Set(0, 2, matrix->_20);
		value.Set(1, 0, matrix->_01); value.Set(1, 1, matrix->_11); value.Set(1, 2, matrix->_21);
		value.Set(2, 0, matrix->_02); value.Set(2, 1, matrix->_12); value.Set(2, 2, matrix->_22);
		Kore::Graphics4::setMatrix(location->location, value);
	')
	private function setMatrix3Private(location: ConstantLocation, matrix: FastMatrix3): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0) drawAllIndexedVertices();
		else drawSomeIndexedVertices(start, count);
	}
	
	@:functionCode('
		Kore::Graphics4::drawIndexedVertices();
	')
	private function drawAllIndexedVertices(): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics4::drawIndexedVertices(start, count);
	')
	public function drawSomeIndexedVertices(start: Int, count: Int): Void {
		
	}
	
	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		if (count < 0) drawAllIndexedVerticesInstanced(instanceCount);
		else drawSomeIndexedVerticesInstanced(instanceCount, start, count);
	}
	
	@:functionCode('
		Kore::Graphics4::drawIndexedVerticesInstanced(instanceCount);
	')
	private function drawAllIndexedVerticesInstanced(instanceCount: Int): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics4::drawIndexedVerticesInstanced(instanceCount, start, count);
	')
	private function drawSomeIndexedVerticesInstanced(instanceCount: Int, start: Int, count: Int): Void {
		
	}
	
	private function renderToTexture(additionalRenderTargets: Array<Canvas>): Void {
		if (additionalRenderTargets != null) {
			var len = additionalRenderTargets.length;

			var image1 = cast(additionalRenderTargets[0], Image);
			var image2 = cast(additionalRenderTargets[1], Image);
			var image3 = cast(additionalRenderTargets[2], Image);
			var image4 = cast(additionalRenderTargets[3], Image);
			var image5 = cast(additionalRenderTargets[4], Image);
			var image6 = cast(additionalRenderTargets[5], Image);
			var image7 = cast(additionalRenderTargets[6], Image);
			
			untyped __cpp__("Kore::Graphics4::RenderTarget* renderTargets[8] = { renderTarget, image1 == null() ? nullptr : image1->renderTarget, image2 == null() ? nullptr : image2->renderTarget, image3 == null() ? nullptr : image3->renderTarget, image4 == null() ? nullptr : image4->renderTarget, image5 == null() ? nullptr : image5->renderTarget, image6 == null() ? nullptr : image6->renderTarget, image7 == null() ? nullptr : image7->renderTarget }; Kore::Graphics4::setRenderTargets(renderTargets, len + 1);");
		}
		else {
			untyped __cpp__("Kore::Graphics4::setRenderTarget(renderTarget)");
		}
	}
	
	@:functionCode('Kore::Graphics4::restoreRenderTarget();')
	private function renderToBackbuffer(): Void {
		
	}
	
	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (current == null) {
			current = this;
		}
		else {
			throw "End before you begin";
		}

		var win: Int = window == null ? 0 : window;
		if (win != lastWindow) {
			if (lastWindow != -1) {
				untyped __cpp__('Kore::Graphics4::end(lastWindow);');
			}
			untyped __cpp__('Kore::Graphics4::begin(win);');
			lastWindow = win;
		}
		if (target == null) {
			renderToBackbuffer();
		}
		else renderToTexture(additionalRenderTargets);
	}
	
	public function beginFace(face: Int): Void {
		if (current == null) {
			current = this;
		}
		else {
			throw "End before you begin";
		}

		untyped __cpp__("Kore::Graphics4::setRenderTargetFace(renderTarget, face)");
	}
	
	public function beginEye(eye: Int): Void {
		
	}
	
	public function end(): Void {
		if (current == this) {
			current = null;
		}
		else {
			throw "Begin before you end";
		}
	}
	
	@:functionCode('Kore::Graphics4::flush();')
	public function flush(): Void {
		
	}
}

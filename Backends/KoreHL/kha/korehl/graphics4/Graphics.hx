package kha.korehl.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.CubeMap;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Image;
import kha.Video;
import kha.Color;

class Graphics implements kha.graphics4.Graphics {
	private var target: Image;
	
	public function new(target: Image = null) {
		this.target = target;
	}
	
	public function vsynced(): Bool {
		return kore_graphics_vsynced();
	}

	public function refreshRate(): Int {
		return kore_graphics_refreshrate();
	}
	
	public function clear(?color: Color, ?z: Float, ?stencil: Int): Void {
		var flags: Int = 0;
		if (color != null) flags |= 1;
		if (z != null) flags |= 2;
		if (stencil != null) flags |= 4;
		kore_graphics_clear(flags, color == null ? 0 : color.value, z, stencil);
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		kore_graphics_viewport(x, y, width, height);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		kore_graphics_set_vertexbuffer(vertexBuffer._buffer);
	}
	
	/*@:functionCode('
		Kore::VertexBuffer* vertexBuffers[4] = {
			vb0 == null() ? nullptr : vb0->buffer,
			vb1 == null() ? nullptr : vb1->buffer,
			vb2 == null() ? nullptr : vb2->buffer,
			vb3 == null() ? nullptr : vb3->buffer
		};
		Kore::Graphics::setVertexBuffers(vertexBuffers, count);
	')*/
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
	
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		kore_graphics_set_indexbuffer(indexBuffer._buffer);
	}	
	
	public function maxTextureSize(): Int {
		return 4096;
	}
	
	public function supportsNonPow2Textures(): Bool {
		return false;
	}
	
	public function setCubeMap(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		
	}
	
	public function setCubeMapDepth(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		
	}
	
	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		kore_graphics_scissor(x, y, width, height);
	}
	
	public function disableScissor(): Void {
		kore_graphics_disable_scissor();
	}
	
	public function renderTargetsInvertedY(): Bool {
		return kore_graphics_render_targets_inverted_y();
	}
	
	public function instancedRenderingAvailable(): Bool {
		return true;
	}
	
	/*@:functionCode('
		Kore::Graphics::setTextureAddressing(unit->unit, Kore::U, (Kore::TextureAddressing)uWrap);
		Kore::Graphics::setTextureAddressing(unit->unit, Kore::V, (Kore::TextureAddressing)vWrap);
	')*/
	private function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {
		
	}
	
	/*@:functionCode('
		Kore::Graphics::setTextureMinificationFilter(unit->unit, (Kore::TextureFilter)minificationFilter);
		Kore::Graphics::setTextureMagnificationFilter(unit->unit, (Kore::TextureFilter)magnificationFilter);
		Kore::Graphics::setTextureMipmapFilter(unit->unit, (Kore::MipmapFilter)mipMapFilter);
	')*/
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

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
	
	}
	
	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		kore_graphics_set_texture(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, texture._texture);
	}

	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
	
	}
	
	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
	
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null) return;
		//setTextureInternal(cast unit, Image.createFromVideo(texture));
	}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {

	}
		
	public function setPipeline(pipe: PipelineState): Void {
		pipe.set();
	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		kore_graphics_set_bool(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value);
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		kore_graphics_set_int(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value);
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		kore_graphics_set_float(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value);
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		kore_graphics_set_float2(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2);
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		kore_graphics_set_float3(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2, value3);
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		kore_graphics_set_float4(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2, value3, value4);
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		kore_graphics_set_float2(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value.x, value.y);
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		kore_graphics_set_float3(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value.x, value.y, value.z);
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		kore_graphics_set_float4(cast (location, kha.korehl.graphics4.ConstantLocation)._location, value.x, value.y, value.z, value.w);
	}
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		kore_graphics_set_floats(cast (location, kha.korehl.graphics4.ConstantLocation)._location, values._data.getData().bytes, values._data.getData().length);
	}
	
	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		kore_graphics_set_matrix(cast(location, ConstantLocation)._location,
			matrix._00, matrix._10, matrix._20, matrix._30,
			matrix._01, matrix._11, matrix._21, matrix._31,
			matrix._02, matrix._12, matrix._22, matrix._32,
			matrix._03, matrix._13, matrix._23, matrix._33);
	}

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		kore_graphics_set_matrix3(cast(location, ConstantLocation)._location,
			matrix._00, matrix._10, matrix._20,
			matrix._01, matrix._11, matrix._21,
			matrix._02, matrix._12, matrix._22);
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0) kore_graphics_draw_all_indexed_vertices();
		else kore_graphics_draw_indexed_vertices(start, count);
	}
	
	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		if (count < 0) kore_graphics_draw_all_indexed_vertices_instanced(instanceCount);
		else kore_graphics_draw_indexed_vertices_instanced(instanceCount, start, count);
	}
	
	private function renderToTexture(additionalRenderTargets: Array<Canvas>): Void {
		/*if (additionalRenderTargets != null) {
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
		}*/
	}
	
	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (target == null) kore_graphics_restore_render_target();
		else renderToTexture(additionalRenderTargets);
	}

	public function beginFace(face: Int): Void {

	}

	public function beginEye(eye: Int): Void {
		
	}
	
	public function end(): Void {
		
	}
	
	public function flush(): Void {
		kore_graphics_flush();
	}
	
	@:hlNative("std", "kore_graphics_clear") static function kore_graphics_clear(flags: Int, color: Int, z: Float, stencil: Int): Void { }
	@:hlNative("std", "kore_graphics_vsynced") static function kore_graphics_vsynced(): Bool { return false; }
	@:hlNative("std", "kore_graphics_refreshrate") static function kore_graphics_refreshrate(): Int { return 0; }
	@:hlNative("std", "kore_graphics_viewport") static function kore_graphics_viewport(x: Int, y: Int, width: Int, height: Int): Void { }
	@:hlNative("std", "kore_graphics_set_vertexbuffer") static function kore_graphics_set_vertexbuffer(buffer: Pointer): Void { }
	@:hlNative("std", "kore_graphics_set_indexbuffer") static function kore_graphics_set_indexbuffer(buffer: Pointer): Void { }
	@:hlNative("std", "kore_graphics_scissor") static function kore_graphics_scissor(x: Int, y: Int, width: Int, height: Int): Void { }
	@:hlNative("std", "kore_graphics_disable_scissor") static function kore_graphics_disable_scissor(): Void { }
	@:hlNative("std", "kore_graphics_render_targets_inverted_y") static function kore_graphics_render_targets_inverted_y(): Bool { return false; }
	@:hlNative("std", "kore_graphics_set_texture") static function kore_graphics_set_texture(unit: Pointer, texture: Pointer): Void { }
	@:hlNative("std", "kore_graphics_set_bool") static function kore_graphics_set_bool(location: Pointer, value: Bool): Void { }
	@:hlNative("std", "kore_graphics_set_int") static function kore_graphics_set_int(location: Pointer, value: Int): Void { }
	@:hlNative("std", "kore_graphics_set_float") static function kore_graphics_set_float(location: Pointer, value: Float): Void { }
	@:hlNative("std", "kore_graphics_set_float2") static function kore_graphics_set_float2(location: Pointer, value1: Float, value2: Float): Void { }
	@:hlNative("std", "kore_graphics_set_float3") static function kore_graphics_set_float3(location: Pointer, value1: Float, value2: Float, value3: Float): Void { }
	@:hlNative("std", "kore_graphics_set_float4") static function kore_graphics_set_float4(location: Pointer, value1: Float, value2: Float, value3: Float, value4: Float): Void { }
	@:hlNative("std", "kore_graphics_set_floats") static function kore_graphics_set_floats(location: Pointer, values: Pointer, count: Int): Void { }
	@:hlNative("std", "kore_graphics_set_matrix") static function kore_graphics_set_matrix(location: Pointer,
		_00: Float, _10: Float, _20: Float, _30: Float,
		_01: Float, _11: Float, _21: Float, _31: Float,
		_02: Float, _12: Float, _22: Float, _32: Float,
		_03: Float, _13: Float, _23: Float, _33: Float): Void { }
	@:hlNative("std", "kore_graphics_set_matrix3") static function kore_graphics_set_matrix3(location: Pointer,
		_00: Float, _10: Float, _20: Float,
		_01: Float, _11: Float, _21: Float,
		_02: Float, _12: Float, _22: Float): Void { }
	@:hlNative("std", "kore_graphics_draw_all_indexed_vertices") static function kore_graphics_draw_all_indexed_vertices(): Void { }
	@:hlNative("std", "kore_graphics_draw_indexed_vertices") static function kore_graphics_draw_indexed_vertices(start: Int, count: Int): Void { }
	@:hlNative("std", "kore_graphics_draw_all_indexed_vertices_instanced") static function kore_graphics_draw_all_indexed_vertices_instanced(instanceCount: Int): Void { }
	@:hlNative("std", "kore_graphics_draw_indexed_vertices_instanced") static function kore_graphics_draw_indexed_vertices_instanced(instanceCount: Int, start: Int, count: Int): Void { }
	@:hlNative("std", "kore_graphics_restore_render_target") static function kore_graphics_restore_render_target(): Void { }
	@:hlNative("std", "kore_graphics_flush") static function kore_graphics_flush(): Void { }
}

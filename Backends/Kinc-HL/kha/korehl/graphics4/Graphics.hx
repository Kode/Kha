package kha.korehl.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.ComputeShader;
import kha.graphics4.CubeMap;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.ShaderStorageBuffer;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Canvas;
import kha.Image;
import kha.Video;
import kha.Color;

class Graphics implements kha.graphics4.Graphics {
	var target: Canvas;

	public function new(target: Canvas = null) {
		this.target = target;
	}

	public function vsynced(): Bool {
		return kinc_graphics_vsynced();
	}

	public function refreshRate(): Int {
		return kinc_graphics_refreshrate();
	}

	public function clear(?color: Color, ?z: FastFloat, ?stencil: Int): Void {
		var flags: Int = 0;
		if (color != null)
			flags |= 1;
		if (z != null)
			flags |= 2;
		if (stencil != null)
			flags |= 4;
		kinc_graphics_clear(flags, color == null ? 0 : color.value, z, stencil);
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		kinc_graphics_viewport(x, y, width, height);
	}

	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		kinc_graphics_set_vertexbuffer(vertexBuffer._buffer);
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		kinc_graphics_set_vertexbuffers(vertexBuffers.length > 0 ? vertexBuffers[0]._buffer : null,
			vertexBuffers.length > 1 ? vertexBuffers[1]._buffer : null, vertexBuffers.length > 2 ? vertexBuffers[2]._buffer : null,
			vertexBuffers.length > 3 ? vertexBuffers[3]._buffer : null, vertexBuffers.length);
	}

	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		kinc_graphics_set_indexbuffer(indexBuffer._buffer);
	}

	public function maxTextureSize(): Int {
		return 4096;
	}

	public function supportsNonPow2Textures(): Bool {
		return false;
	}

	public function setCubeMap(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null)
			return;
		if (cubeMap._texture != null)
			kinc_graphics_set_cubemap_texture(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, cubeMap._texture);
		else
			kinc_graphics_set_cubemap_target(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, cubeMap._renderTarget);
	}

	public function setCubeMapDepth(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null)
			return;
		kinc_graphics_set_cubemap_depth(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, cubeMap._renderTarget);
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		kinc_graphics_scissor(x, y, width, height);
	}

	public function disableScissor(): Void {
		kinc_graphics_disable_scissor();
	}

	public function instancedRenderingAvailable(): Bool {
		return true;
	}

	public function setTextureParameters(unit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		kinc_graphics_set_texture_parameters(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, uAddressing, vAddressing, minificationFilter,
			magnificationFilter, mipmapFilter);
	}

	public function setTexture3DParameters(unit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		kinc_graphics_set_texture3d_parameters(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, uAddressing, vAddressing, wAddressing, minificationFilter,
			magnificationFilter, mipmapFilter);
	}

	public function setTextureCompareMode(unit: kha.graphics4.TextureUnit, enabled: Bool) {
		kinc_graphics_set_texture_compare_mode(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, enabled);
	}

	public function setCubeMapCompareMode(unit: kha.graphics4.TextureUnit, enabled: Bool) {
		kinc_graphics_set_cube_map_compare_mode(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, enabled);
	}

	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		if (texture._texture != null)
			kinc_graphics_set_texture(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, texture._texture);
		else
			kinc_graphics_set_render_target(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, texture._renderTarget);
	}

	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		kinc_graphics_set_texture_array(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, texture._textureArray);
	}

	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		kinc_graphics_set_texture_depth(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, texture._renderTarget);
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null)
			return;
		kinc_graphics_set_texture(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, Image.fromVideo(texture)._texture);
	}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		kinc_graphics_set_image_texture(cast(unit, kha.korehl.graphics4.TextureUnit)._unit, texture._texture);
	}

	public function maxBoundTextures(): Int {
		return 8;
	}

	public function setPipeline(pipe: PipelineState): Void {
		pipe.set();
	}

	public function setStencilReferenceValue(value: Int): Void {}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		kinc_graphics_set_bool(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value);
	}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		kinc_graphics_set_int(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value);
	}

	public function setInt2(location: kha.graphics4.ConstantLocation, value1: Int, value2: Int): Void {
		kinc_graphics_set_int2(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2);
	}

	public function setInt3(location: kha.graphics4.ConstantLocation, value1: Int, value2: Int, value3: Int): Void {
		kinc_graphics_set_int3(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2, value3);
	}

	public function setInt4(location: kha.graphics4.ConstantLocation, value1: Int, value2: Int, value3: Int, value4: Int): Void {
		kinc_graphics_set_int4(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2, value3, value4);
	}

	public function setInts(location: kha.graphics4.ConstantLocation, values: kha.arrays.Int32Array): Void {
		kinc_graphics_set_ints(cast(location, kha.korehl.graphics4.ConstantLocation)._location, values.getData(), values.length);
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		kinc_graphics_set_float(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value);
	}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		kinc_graphics_set_float2(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2);
	}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		kinc_graphics_set_float3(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2, value3);
	}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		kinc_graphics_set_float4(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value1, value2, value3, value4);
	}

	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		kinc_graphics_set_float2(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value.x, value.y);
	}

	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		kinc_graphics_set_float3(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value.x, value.y, value.z);
	}

	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		kinc_graphics_set_float4(cast(location, kha.korehl.graphics4.ConstantLocation)._location, value.x, value.y, value.z, value.w);
	}

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		kinc_graphics_set_floats(cast(location, kha.korehl.graphics4.ConstantLocation)._location, values.getData(), values.length);
	}

	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		kinc_graphics_set_matrix(cast(location, kha.korehl.graphics4.ConstantLocation)._location, matrix._00, matrix._10, matrix._20, matrix._30, matrix._01,
			matrix._11, matrix._21, matrix._31, matrix._02, matrix._12, matrix._22, matrix._32, matrix._03, matrix._13, matrix._23, matrix._33);
	}

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		kinc_graphics_set_matrix3(cast(location, kha.korehl.graphics4.ConstantLocation)._location, matrix._00, matrix._10, matrix._20, matrix._01, matrix._11,
			matrix._21, matrix._02, matrix._12, matrix._22);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0)
			kinc_graphics_draw_all_indexed_vertices();
		else
			kinc_graphics_draw_indexed_vertices(start, count);
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		if (count < 0)
			kinc_graphics_draw_all_indexed_vertices_instanced(instanceCount);
		else
			kinc_graphics_draw_indexed_vertices_instanced(instanceCount, start, count);
	}

	function renderToTexture(additionalRenderTargets: Array<Canvas>): Void {
		if (additionalRenderTargets != null) {
			var len = additionalRenderTargets.length;
			var rt0 = cast(target, Image)._renderTarget;
			var rt1 = len > 0 ? cast(additionalRenderTargets[0], Image)._renderTarget : null;
			var rt2 = len > 1 ? cast(additionalRenderTargets[1], Image)._renderTarget : null;
			var rt3 = len > 2 ? cast(additionalRenderTargets[2], Image)._renderTarget : null;
			var rt4 = len > 3 ? cast(additionalRenderTargets[3], Image)._renderTarget : null;
			var rt5 = len > 4 ? cast(additionalRenderTargets[4], Image)._renderTarget : null;
			var rt6 = len > 5 ? cast(additionalRenderTargets[5], Image)._renderTarget : null;
			var rt7 = len > 6 ? cast(additionalRenderTargets[6], Image)._renderTarget : null;
			kinc_graphics_render_to_textures(rt0, rt1, rt2, rt3, rt4, rt5, rt6, rt7, len + 1);
		}
		else {
			kinc_graphics_render_to_texture(cast(target, Image)._renderTarget);
		}
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (target == null)
			kinc_graphics_restore_render_target();
		else
			renderToTexture(additionalRenderTargets);
	}

	public function beginFace(face: Int): Void {
		kinc_graphics_render_to_face(cast(target, CubeMap)._renderTarget, face);
	}

	public function beginEye(eye: Int): Void {}

	public function end(): Void {}

	public function flush(): Void {
		kinc_graphics_flush();
	}

	public function setShaderStorageBuffer(buffer: ShaderStorageBuffer, index: Int) {
		// Kore::Compute::setBuffer(buffer->buffer, index);
	}

	public function setComputeShader(shader: ComputeShader) {
		kinc_g4_set_compute_shader(shader._shader);
	}

	public function compute(x: Int, y: Int, z: Int) {
		kinc_g4_compute(x, y, z);
	}

	@:hlNative("std", "kinc_graphics_clear") static function kinc_graphics_clear(flags: Int, color: Int, z: FastFloat, stencil: Int): Void {}

	@:hlNative("std", "kinc_graphics_vsynced") static function kinc_graphics_vsynced(): Bool {
		return false;
	}

	@:hlNative("std", "kinc_graphics_refreshrate") static function kinc_graphics_refreshrate(): Int {
		return 0;
	}

	@:hlNative("std", "kinc_graphics_viewport") static function kinc_graphics_viewport(x: Int, y: Int, width: Int, height: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_vertexbuffer") static function kinc_graphics_set_vertexbuffer(buffer: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_vertexbuffers") static function kinc_graphics_set_vertexbuffers(b0: Pointer, b1: Pointer, b2: Pointer, b3: Pointer,
		count: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_indexbuffer") static function kinc_graphics_set_indexbuffer(buffer: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_scissor") static function kinc_graphics_scissor(x: Int, y: Int, width: Int, height: Int): Void {}

	@:hlNative("std", "kinc_graphics_disable_scissor") static function kinc_graphics_disable_scissor(): Void {}

	@:hlNative("std", "kinc_graphics_set_texture_parameters") static function kinc_graphics_set_texture_parameters(unit: Pointer, uAddressing: Int,
		vAddressing: Int, minificationFilter: Int, magnificationFilter: Int, mipmapFilter: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_texture3d_parameters") static function kinc_graphics_set_texture3d_parameters(unit: Pointer, uAddressing: Int,
		vAddressing: Int, wAddressing: Int, minificationFilter: Int, magnificationFilter: Int, mipmapFilter: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_texture_compare_mode") static function kinc_graphics_set_texture_compare_mode(unit: Pointer, enabled: Bool): Void {}

	@:hlNative("std", "kinc_graphics_set_cube_map_compare_mode") static function kinc_graphics_set_cube_map_compare_mode(unit: Pointer, enabled: Bool): Void {}

	@:hlNative("std", "kinc_graphics_set_texture") static function kinc_graphics_set_texture(unit: Pointer, texture: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_texture_depth") static function kinc_graphics_set_texture_depth(unit: Pointer, renderTarget: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_texture_array") static function kinc_graphics_set_texture_array(unit: Pointer, textureArray: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_render_target") static function kinc_graphics_set_render_target(unit: Pointer, renderTarget: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_cubemap_texture") static function kinc_graphics_set_cubemap_texture(unit: Pointer, texture: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_cubemap_target") static function kinc_graphics_set_cubemap_target(unit: Pointer, renderTarget: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_cubemap_depth") static function kinc_graphics_set_cubemap_depth(unit: Pointer, renderTarget: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_image_texture") static function kinc_graphics_set_image_texture(unit: Pointer, texture: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_set_bool") static function kinc_graphics_set_bool(location: Pointer, value: Bool): Void {}

	@:hlNative("std", "kinc_graphics_set_int") static function kinc_graphics_set_int(location: Pointer, value: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_int2") static function kinc_graphics_set_int2(location: Pointer, value1: Int, value2: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_int3") static function kinc_graphics_set_int3(location: Pointer, value1: Int, value2: Int, value3: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_int4") static function kinc_graphics_set_int4(location: Pointer, value1: Int, value2: Int, value3: Int,
		value4: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_ints") static function kinc_graphics_set_ints(location: Pointer, values: Pointer, count: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_float") static function kinc_graphics_set_float(location: Pointer, value: FastFloat): Void {}

	@:hlNative("std", "kinc_graphics_set_float2") static function kinc_graphics_set_float2(location: Pointer, value1: FastFloat, value2: FastFloat): Void {}

	@:hlNative("std", "kinc_graphics_set_float3") static function kinc_graphics_set_float3(location: Pointer, value1: FastFloat, value2: FastFloat,
		value3: FastFloat): Void {}

	@:hlNative("std", "kinc_graphics_set_float4") static function kinc_graphics_set_float4(location: Pointer, value1: FastFloat, value2: FastFloat,
		value3: FastFloat, value4: FastFloat): Void {}

	@:hlNative("std", "kinc_graphics_set_floats") static function kinc_graphics_set_floats(location: Pointer, values: Pointer, count: Int): Void {}

	@:hlNative("std", "kinc_graphics_set_matrix") static function kinc_graphics_set_matrix(location: Pointer, _00: FastFloat, _10: FastFloat, _20: FastFloat,
		_30: FastFloat, _01: FastFloat, _11: FastFloat, _21: FastFloat, _31: FastFloat, _02: FastFloat, _12: FastFloat, _22: FastFloat, _32: FastFloat,
		_03: FastFloat, _13: FastFloat, _23: FastFloat, _33: FastFloat): Void {}

	@:hlNative("std", "kinc_graphics_set_matrix3") static function kinc_graphics_set_matrix3(location: Pointer, _00: FastFloat, _10: FastFloat,
		_20: FastFloat, _01: FastFloat, _11: FastFloat, _21: FastFloat, _02: FastFloat, _12: FastFloat, _22: FastFloat): Void {}

	@:hlNative("std", "kinc_graphics_draw_all_indexed_vertices") static function kinc_graphics_draw_all_indexed_vertices(): Void {}

	@:hlNative("std", "kinc_graphics_draw_indexed_vertices") static function kinc_graphics_draw_indexed_vertices(start: Int, count: Int): Void {}

	@:hlNative("std",
		"kinc_graphics_draw_all_indexed_vertices_instanced") static function kinc_graphics_draw_all_indexed_vertices_instanced(instanceCount: Int): Void {}

	@:hlNative("std", "kinc_graphics_draw_indexed_vertices_instanced") static function kinc_graphics_draw_indexed_vertices_instanced(instanceCount: Int,
		start: Int, count: Int): Void {}

	@:hlNative("std", "kinc_graphics_restore_render_target") static function kinc_graphics_restore_render_target(): Void {}

	@:hlNative("std", "kinc_graphics_render_to_texture") static function kinc_graphics_render_to_texture(renderTarget: Pointer): Void {}

	@:hlNative("std", "kinc_graphics_render_to_textures") static function kinc_graphics_render_to_textures(rt0: Pointer, rt1: Pointer, rt2: Pointer,
		rt3: Pointer, rt4: Pointer, rt5: Pointer, rt6: Pointer, rt7: Pointer, count: Int): Void {}

	@:hlNative("std", "kinc_graphics_render_to_face") static function kinc_graphics_render_to_face(renderTarget: Pointer, face: Int): Void {}

	@:hlNative("std", "kinc_graphics_flush") static function kinc_graphics_flush(): Void {}

	@:hlNative("std", "kinc_g4_set_compute_shader") static function kinc_g4_set_compute_shader(shader: Pointer): Void {}

	@:hlNative("std", "kinc_g4_compute") static function kinc_g4_compute(x: Int, y: Int, z: Int): Void {}
}

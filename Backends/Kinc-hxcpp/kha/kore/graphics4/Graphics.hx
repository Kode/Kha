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

@:headerCode("
#include <kinc/display.h>
#include <kinc/graphics4/graphics.h>
#include <kinc/graphics4/rendertarget.h>
#include <kinc/window.h>
")
@:headerClassCode("kinc_g4_render_target_t renderTarget;")
class Graphics implements kha.graphics4.Graphics {
	var target: Canvas;

	public var window: Null<Int>;

	public static var lastWindow: Int = -1;
	static var current: Graphics = null;

	public function new(target: Canvas = null) {
		this.target = target;
		init();
	}

	function init() {
		if (target == null)
			return;
		if (Std.isOfType(target, CubeMap)) {
			var cubeMap = cast(target, CubeMap);
			untyped __cpp__("renderTarget = {0}->renderTarget", cubeMap);
		}
		else {
			var image = cast(target, Image);
			untyped __cpp__("renderTarget = {0}->renderTarget", image);
		}
	}

	@:functionCode("return kinc_window_vsynced(0);")
	public function vsynced(): Bool {
		return true;
	}

	@:functionCode("return kinc_display_current_mode(kinc_primary_display()).frequency;")
	public function refreshRate(): Int {
		return 0;
	}

	public function clear(?color: Color, ?z: Float, ?stencil: Int): Void {
		var flags: Int = 0;
		if (color != null)
			flags |= 1;
		if (z != null)
			flags |= 2;
		if (stencil != null)
			flags |= 4;
		clear2(flags, color == null ? 0 : color.value, z, stencil);
	}

	@:functionCode("kinc_g4_viewport(x, y, width, height);")
	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {}

	@:functionCode("kinc_g4_clear(flags, color, z, stencil);")
	function clear2(flags: Int, color: Int, z: Float, stencil: Int): Void {}

	// public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
	//	return new VertexBuffer(vertexCount, structure);
	// }

	@:functionCode("kinc_g4_set_vertex_buffer(&vertexBuffer->buffer);")
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {}

	@:functionCode("
		kinc_g4_vertex_buffer_t* vertexBuffers[4] = {
			vb0 == null() ? nullptr : &vb0->buffer,
			vb1 == null() ? nullptr : &vb1->buffer,
			vb2 == null() ? nullptr : &vb2->buffer,
			vb3 == null() ? nullptr : &vb3->buffer
		};
		kinc_g4_set_vertex_buffers(vertexBuffers, count);
	")
	function setVertexBuffersInternal(vb0: VertexBuffer, vb1: VertexBuffer, vb2: VertexBuffer, vb3: VertexBuffer, count: Int): Void {}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		setVertexBuffersInternal(vertexBuffers.length > 0 ? vertexBuffers[0] : null, vertexBuffers.length > 1 ? vertexBuffers[1] : null,
			vertexBuffers.length > 2 ? vertexBuffers[2] : null, vertexBuffers.length > 3 ? vertexBuffers[3] : null, vertexBuffers.length);
	}

	// public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics.IndexBuffer {
	//	return new IndexBuffer(indexCount);
	// }

	@:functionCode("kinc_g4_set_index_buffer(&indexBuffer->buffer);")
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {}

	// public function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage, canRead: Bool = false, levels: Int = 1): Texture {
	//	return Image.create(width, height, format, canRead, false, false);
	// }
	// public function createRenderTargetTexture(width: Int, height: Int, format: TextureFormat, depthStencil: Bool, antiAliasingSamples: Int = 1): Texture {
	//	return Image.create(width, height, format, false, true, depthStencil);
	// }

	public function maxTextureSize(): Int {
		return 4096;
	}

	public function supportsNonPow2Textures(): Bool {
		return false;
	}

	public function setCubeMap(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null)
			return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("kinc_g4_render_target_use_color_as_texture(&cubeMap->renderTarget, {0}->unit)", koreUnit);
	}

	public function setCubeMapDepth(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null)
			return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("kinc_g4_render_target_use_depth_as_texture(&cubeMap->renderTarget, {0}->unit);", koreUnit);
	}

	@:functionCode("kinc_g4_scissor(x, y, width, height);")
	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {}

	@:functionCode("kinc_g4_disable_scissor();")
	public function disableScissor(): Void {}

	public function instancedRenderingAvailable(): Bool {
		return true;
	}

	@:functionCode("
		kinc_g4_set_texture_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uWrap);
		kinc_g4_set_texture_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vWrap);
	")
	function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {}

	@:functionCode("
		kinc_g4_set_texture3d_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uWrap);
		kinc_g4_set_texture3d_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vWrap);
		kinc_g4_set_texture3d_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_W, (kinc_g4_texture_addressing_t)wWrap);
	")
	function setTexture3DWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int, wWrap: Int): Void {}

	@:functionCode("
		kinc_g4_set_texture_minification_filter(unit->unit, (kinc_g4_texture_filter_t)minificationFilter);
		kinc_g4_set_texture_magnification_filter(unit->unit, (kinc_g4_texture_filter_t)magnificationFilter);
		kinc_g4_set_texture_mipmap_filter(unit->unit, (kinc_g4_mipmap_filter_t)mipMapFilter);
	")
	function setTextureFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {}

	@:functionCode("
		kinc_g4_set_texture3d_minification_filter(unit->unit, (kinc_g4_texture_filter_t)minificationFilter);
		kinc_g4_set_texture3d_magnification_filter(unit->unit, (kinc_g4_texture_filter_t)magnificationFilter);
		kinc_g4_set_texture3d_mipmap_filter(unit->unit, (kinc_g4_mipmap_filter_t)mipMapFilter);
	")
	function setTexture3DFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {}

	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTextureWrapNative(cast texunit, uAddressing, vAddressing);
		setTextureFiltersNative(cast texunit, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTexture3DWrapNative(cast texunit, uAddressing, vAddressing, wAddressing);
		setTexture3DFiltersNative(cast texunit, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public function setTextureCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool) {
		var koreUnit = cast(texunit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("kinc_g4_set_texture_compare_mode({0}->unit, enabled);", koreUnit);
	}

	public function setCubeMapCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool) {
		var koreUnit = cast(texunit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("kinc_g4_set_cubemap_compare_mode({0}->unit, enabled);", koreUnit);
	}

	@:functionCode("
		if (texture->imageType == KhaImageTypeTexture) kinc_g4_set_texture(unit->unit, &texture->texture);
		else if (texture->imageType == KhaImageTypeRenderTarget) kinc_g4_render_target_use_color_as_texture(&texture->renderTarget, unit->unit);
	")
	function setTextureInternal(unit: kha.kore.graphics4.TextureUnit, texture: kha.Image): Void {}

	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		setTextureInternal(cast unit, texture);
	}

	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("kinc_g4_render_target_use_depth_as_texture(&texture->renderTarget, {0}->unit);", koreUnit);
	}

	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		var koreUnit = cast(unit, kha.kore.graphics4.TextureUnit);
		untyped __cpp__("if (texture->imageType == KhaImageTypeTextureArray) kinc_g4_set_texture_array({0}->unit, &texture->textureArray);", koreUnit);
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null)
			return;
		setTextureInternal(cast unit, Image.createFromVideo(texture));
	}

	@:functionCode("kinc_g4_set_image_texture(unit->unit, &texture->texture);")
	function setImageTextureInternal(unit: kha.kore.graphics4.TextureUnit, texture: kha.Image): Void {}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null)
			return;
		setImageTextureInternal(cast unit, texture);
	}

	@:functionCode("return kinc_g4_max_bound_textures();")
	public function maxBoundTextures(): Int {
		return 0;
	}

	// public function createVertexShader(source: Blob): VertexShader {
	//	return new Shader(source, ShaderType.VertexShader);
	// }
	// public function createFragmentShader(source: Blob): FragmentShader {
	//	return new Shader(source, ShaderType.FragmentShader);
	// }
	// public function createProgram(): kha.graphics4.Program {
	//	return new Program();
	// }

	public function setPipeline(pipe: PipelineState): Void {
		pipe.set();
	}

	@:functionCode("kinc_g4_set_stencil_reference_value(value);")
	public function setStencilReferenceValue(value: Int): Void {}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		setBoolPrivate(cast location, value);
	}

	@:functionCode("kinc_g4_set_bool(location->location, value);")
	function setBoolPrivate(location: kha.kore.graphics4.ConstantLocation, value: Bool): Void {}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		setIntPrivate(cast location, value);
	}

	@:functionCode("kinc_g4_set_int(location->location, value);")
	function setIntPrivate(location: ConstantLocation, value: Int): Void {}

	public function setInt2(location: kha.graphics4.ConstantLocation, value1: Int, value2: Int): Void {
		setInt2Private(cast location, value1, value2);
	}

	@:functionCode("kinc_g4_set_int2(location->location, value1, value2);")
	function setInt2Private(location: ConstantLocation, value1: Int, value2: Int): Void {}

	public function setInt3(location: kha.graphics4.ConstantLocation, value1: Int, value2: Int, value3: Int): Void {
		setInt3Private(cast location, value1, value2, value3);
	}

	@:functionCode("kinc_g4_set_int3(location->location, value1, value2, value3);")
	function setInt3Private(location: ConstantLocation, value1: Int, value2: Int, value3: Int): Void {}

	public function setInt4(location: kha.graphics4.ConstantLocation, value1: Int, value2: Int, value3: Int, value4: Int): Void {
		setInt4Private(cast location, value1, value2, value3, value4);
	}

	@:functionCode("kinc_g4_set_int4(location->location, value1, value2, value3, value4);")
	function setInt4Private(location: ConstantLocation, value1: Int, value2: Int, value3: Int, value4: Int): Void {}

	public function setInts(location: kha.graphics4.ConstantLocation, values: kha.arrays.Int32Array): Void {
		setIntsPrivate(cast location, values);
	}

	@:functionCode("kinc_g4_set_ints(location->location, values->self.data, values->self.length());")
	function setIntsPrivate(location: ConstantLocation, values: kha.arrays.Int32Array): Void {}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		setFloatPrivate(cast location, value);
	}

	@:functionCode("kinc_g4_set_float(location->location, value);")
	function setFloatPrivate(location: ConstantLocation, value: FastFloat): Void {}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		setFloat2Private(cast location, value1, value2);
	}

	@:functionCode("kinc_g4_set_float2(location->location, value1, value2);")
	function setFloat2Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void {}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		setFloat3Private(cast location, value1, value2, value3);
	}

	@:functionCode("kinc_g4_set_float3(location->location, value1, value2, value3);")
	function setFloat3Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		setFloat4Private(cast location, value1, value2, value3, value4);
	}

	@:functionCode("kinc_g4_set_float4(location->location, value1, value2, value3, value4);")
	function setFloat4Private(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {}

	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		setVector2Private(cast location, value.x, value.y);
	}

	@:functionCode("kinc_g4_set_float2(location->location, x, y);")
	function setVector2Private(location: ConstantLocation, x: FastFloat, y: FastFloat): Void {}

	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		setVector3Private(cast location, value.x, value.y, value.z);
	}

	@:functionCode("kinc_g4_set_float3(location->location, x, y, z);")
	function setVector3Private(location: ConstantLocation, x: FastFloat, y: FastFloat, z: FastFloat): Void {}

	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		setVector4Private(cast location, value.x, value.y, value.z, value.w);
	}

	@:functionCode("kinc_g4_set_float4(location->location, x, y, z, w);")
	function setVector4Private(location: ConstantLocation, x: FastFloat, y: FastFloat, z: FastFloat, w: FastFloat): Void {}

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		setFloatsPrivate(cast location, values);
	}

	@:functionCode("kinc_g4_set_floats(location->location, values->self.data, values->self.length());")
	function setFloatsPrivate(location: ConstantLocation, values: Float32Array): Void {}

	public function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		setMatrixPrivate(cast location, matrix);
	}

	@:functionCode("
		kinc_matrix4x4_t value;
		kinc_matrix4x4_set(&value, 0, 0, matrix->_00); kinc_matrix4x4_set(&value, 0, 1, matrix->_10); kinc_matrix4x4_set(&value, 0, 2, matrix->_20); kinc_matrix4x4_set(&value, 0, 3, matrix->_30);
		kinc_matrix4x4_set(&value, 1, 0, matrix->_01); kinc_matrix4x4_set(&value, 1, 1, matrix->_11); kinc_matrix4x4_set(&value, 1, 2, matrix->_21); kinc_matrix4x4_set(&value, 1, 3, matrix->_31);
		kinc_matrix4x4_set(&value, 2, 0, matrix->_02); kinc_matrix4x4_set(&value, 2, 1, matrix->_12); kinc_matrix4x4_set(&value, 2, 2, matrix->_22); kinc_matrix4x4_set(&value, 2, 3, matrix->_32);
		kinc_matrix4x4_set(&value, 3, 0, matrix->_03); kinc_matrix4x4_set(&value, 3, 1, matrix->_13); kinc_matrix4x4_set(&value, 3, 2, matrix->_23); kinc_matrix4x4_set(&value, 3, 3, matrix->_33);
		kinc_g4_set_matrix4(location->location, &value);
	")
	function setMatrixPrivate(location: ConstantLocation, matrix: FastMatrix4): Void {}

	public function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		setMatrix3Private(cast location, matrix);
	}

	@:functionCode("
		kinc_matrix3x3_t value;
		kinc_matrix3x3_set(&value, 0, 0, matrix->_00); kinc_matrix3x3_set(&value, 0, 1, matrix->_10); kinc_matrix3x3_set(&value, 0, 2, matrix->_20);
		kinc_matrix3x3_set(&value, 1, 0, matrix->_01); kinc_matrix3x3_set(&value, 1, 1, matrix->_11); kinc_matrix3x3_set(&value, 1, 2, matrix->_21);
		kinc_matrix3x3_set(&value, 2, 0, matrix->_02); kinc_matrix3x3_set(&value, 2, 1, matrix->_12); kinc_matrix3x3_set(&value, 2, 2, matrix->_22);
		kinc_g4_set_matrix3(location->location, &value);
	")
	function setMatrix3Private(location: ConstantLocation, matrix: FastMatrix3): Void {}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0)
			drawAllIndexedVertices();
		else
			drawSomeIndexedVertices(start, count);
	}

	@:functionCode("kinc_g4_draw_indexed_vertices();")
	function drawAllIndexedVertices(): Void {}

	@:functionCode("kinc_g4_draw_indexed_vertices_from_to(start, count);")
	public function drawSomeIndexedVertices(start: Int, count: Int): Void {}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		if (count < 0)
			drawAllIndexedVerticesInstanced(instanceCount);
		else
			drawSomeIndexedVerticesInstanced(instanceCount, start, count);
	}

	@:functionCode("kinc_g4_draw_indexed_vertices_instanced(instanceCount);")
	function drawAllIndexedVerticesInstanced(instanceCount: Int): Void {}

	@:functionCode("kinc_g4_draw_indexed_vertices_instanced_from_to(instanceCount, start, count);")
	function drawSomeIndexedVerticesInstanced(instanceCount: Int, start: Int, count: Int): Void {}

	function renderToTexture(additionalRenderTargets: Array<Canvas>): Void {
		if (additionalRenderTargets != null) {
			var len = additionalRenderTargets.length;

			var image1 = cast(additionalRenderTargets[0], Image);
			var image2 = cast(additionalRenderTargets[1], Image);
			var image3 = cast(additionalRenderTargets[2], Image);
			var image4 = cast(additionalRenderTargets[3], Image);
			var image5 = cast(additionalRenderTargets[4], Image);
			var image6 = cast(additionalRenderTargets[5], Image);
			var image7 = cast(additionalRenderTargets[6], Image);

			untyped __cpp__("
				kinc_g4_render_target_t *renderTargets[8] = { &renderTarget, {1} == null() ? nullptr : &{1}->renderTarget, {2} == null() ? nullptr : &{2}->renderTarget, image3 == null() ? nullptr : &{3}->renderTarget, {4} == null() ? nullptr : &{4}->renderTarget, {5} == null() ? nullptr : &{5}->renderTarget, {6} == null() ? nullptr : &{6}->renderTarget, {7} == null() ? nullptr : &{7}->renderTarget };
				kinc_g4_set_render_targets(renderTargets, {0} + 1);
			", len, image1, image2, image3, image4, image5, image6, image7);
		}
		else {
			untyped __cpp__("
				kinc_g4_render_target_t *renderTargets[1] = { &renderTarget };
				kinc_g4_set_render_targets(renderTargets, 1)
			");
		}
	}

	@:functionCode("kinc_g4_restore_render_target();")
	function renderToBackbuffer(): Void {}

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
				untyped __cpp__("kinc_g4_end(lastWindow);");
			}
			untyped __cpp__("kinc_g4_begin(win);");
			lastWindow = win;
		}
		if (target == null) {
			renderToBackbuffer();
		}
		else
			renderToTexture(additionalRenderTargets);
	}

	public function beginFace(face: Int): Void {
		if (current == null) {
			current = this;
		}
		else {
			throw "End before you begin";
		}

		untyped __cpp__("kinc_g4_set_render_target_face(&renderTarget, face)");
	}

	public function beginEye(eye: Int): Void {}

	public function end(): Void {
		if (current == this) {
			current = null;
		}
		else {
			throw "Begin before you end";
		}
	}

	@:functionCode("kinc_g4_flush();")
	public function flush(): Void {}
}

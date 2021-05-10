package kha.compute;

import kha.arrays.Float32Array;
import kha.Image;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.graphics4.CubeMap;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

@:headerCode("
#include <kinc/compute/compute.h>
")
class Compute {
	public static function setBool(location: ConstantLocation, value: Bool) {
		untyped __cpp__("kinc_compute_set_bool(location->location, value);");
	}

	public static function setInt(location: ConstantLocation, value: Int) {
		untyped __cpp__("kinc_compute_set_int(location->location, value);");
	}

	public static function setFloat(location: ConstantLocation, value: FastFloat) {
		untyped __cpp__("kinc_compute_set_float(location->location, value);");
	}

	public static function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat) {
		untyped __cpp__("kinc_compute_set_float2(location->location, value1, value2);");
	}

	public static function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat) {
		untyped __cpp__("kinc_compute_set_float3(location->location, value1, value2, value3);");
	}

	public static function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat) {
		untyped __cpp__("kinc_compute_set_float4(location->location, value1, value2, value3, value4);");
	}

	public static function setFloats(location: ConstantLocation, values: Float32Array) {
		untyped __cpp__("kinc_compute_set_floats(location->location, values->self.data, values->self.length());");
	}

	public static function setVector2(location: ConstantLocation, value: FastVector2): Void {
		Compute.setFloat2(location, value.x, value.y);
	}

	public static function setVector3(location: ConstantLocation, value: FastVector3): Void {
		Compute.setFloat3(location, value.x, value.y, value.z);
	}

	public static function setVector4(location: ConstantLocation, value: FastVector4): Void {
		Compute.setFloat4(location, value.x, value.y, value.z, value.w);
	}

	public static function setMatrix(location: ConstantLocation, value: FastMatrix4): Void {
		setMatrixPrivate(location, value);
	}

	public static function setMatrix3(location: ConstantLocation, value: FastMatrix3): Void {
		setMatrix3Private(location, value);
	}

	@:functionCode("
		kinc_matrix4x4_t value;
		kinc_matrix4x4_set(&value, 0, 0, matrix->_00); kinc_matrix4x4_set(&value, 0, 1, matrix->_10); kinc_matrix4x4_set(&value, 0, 2, matrix->_20); kinc_matrix4x4_set(&value, 0, 3, matrix->_30);
		kinc_matrix4x4_set(&value, 1, 0, matrix->_01); kinc_matrix4x4_set(&value, 1, 1, matrix->_11); kinc_matrix4x4_set(&value, 1, 2, matrix->_21); kinc_matrix4x4_set(&value, 1, 3, matrix->_31);
		kinc_matrix4x4_set(&value, 2, 0, matrix->_02); kinc_matrix4x4_set(&value, 2, 1, matrix->_12); kinc_matrix4x4_set(&value, 2, 2, matrix->_22); kinc_matrix4x4_set(&value, 2, 3, matrix->_32);
		kinc_matrix4x4_set(&value, 3, 0, matrix->_03); kinc_matrix4x4_set(&value, 3, 1, matrix->_13); kinc_matrix4x4_set(&value, 3, 2, matrix->_23); kinc_matrix4x4_set(&value, 3, 3, matrix->_33);
		kinc_compute_set_matrix4(location->location, &value);
	")
	static function setMatrixPrivate(location: ConstantLocation, matrix: FastMatrix4): Void {}

	@:functionCode("
		kinc_matrix3x3_t value;
		kinc_matrix3x3_set(&value, 0, 0, matrix->_00); kinc_matrix3x3_set(&value, 0, 1, matrix->_10); kinc_matrix3x3_set(&value, 0, 2, matrix->_20);
		kinc_matrix3x3_set(&value, 1, 0, matrix->_01); kinc_matrix3x3_set(&value, 1, 1, matrix->_11); kinc_matrix3x3_set(&value, 1, 2, matrix->_21);
		kinc_matrix3x3_set(&value, 2, 0, matrix->_02); kinc_matrix3x3_set(&value, 2, 1, matrix->_12); kinc_matrix3x3_set(&value, 2, 2, matrix->_22);
		kinc_compute_set_matrix3(location->location, &value);
	")
	static function setMatrix3Private(location: ConstantLocation, matrix: FastMatrix3): Void {}

	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int) {
		untyped __cpp__("
			#ifdef KORE_OPENGL
			kinc_compute_set_buffer(buffer->buffer, index);
			#endif
		");
	}

	public static function setTexture(unit: TextureUnit, texture: Image, access: Access) {
		setTexturePrivate(unit, texture, access);
	}

	@:functionCode("
		if (texture->imageType == KhaImageTypeTexture) kinc_compute_set_texture(unit->unit, &texture->texture, (kinc_compute_access_t)access);
		else if (texture->imageType == KhaImageTypeRenderTarget) kinc_compute_set_render_target(unit->unit, &texture->renderTarget, (kinc_compute_access_t)access);
	")
	static function setTexturePrivate(unit: TextureUnit, texture: Image, access: Int): Void {}

	public static function setSampledTexture(unit: TextureUnit, texture: Image) {
		setSampledTexturePrivate(unit, texture);
	}

	@:functionCode("
		if (texture->imageType == KhaImageTypeTexture) kinc_compute_set_sampled_texture(unit->unit, &texture->texture);
		else if (texture->imageType == KhaImageTypeRenderTarget) kinc_compute_set_sampled_render_target(unit->unit, &texture->renderTarget);
	")
	static function setSampledTexturePrivate(unit: TextureUnit, texture: Image): Void {}

	public static function setSampledDepthTexture(unit: TextureUnit, texture: Image) {
		untyped __cpp__("if (texture->imageType == KhaImageTypeRenderTarget) kinc_compute_set_sampled_depth_from_render_target(unit->unit, &texture->renderTarget);");
	}

	public static function setSampledCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		setSampledCubeMapPrivate(unit, cubeMap);
	}

	@:functionCode("kinc_compute_set_sampled_render_target(unit->unit, &cubeMap->renderTarget);")
	static function setSampledCubeMapPrivate(unit: TextureUnit, cubeMap: CubeMap): Void {}

	public static function setSampledDepthCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		untyped __cpp__("kinc_compute_set_sampled_depth_from_render_target(unit->unit, &cubeMap->renderTarget);");
	}

	@:functionCode("
		kinc_compute_set_texture_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uWrap);
		kinc_compute_set_texture_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vWrap);
	")
	static function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {}

	@:functionCode("
		kinc_compute_set_texture3d_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uWrap);
		kinc_compute_set_texture3d_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vWrap);
		kinc_compute_set_texture3d_addressing(unit->unit, KINC_G4_TEXTURE_DIRECTION_W, (kinc_g4_texture_addressing_t)wWrap);
	")
	static function setTexture3DWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int, wWrap: Int): Void {}

	@:functionCode("
		kinc_compute_set_texture_minification_filter(unit->unit, (kinc_g4_texture_filter_t)minificationFilter);
		kinc_compute_set_texture_magnification_filter(unit->unit, (kinc_g4_texture_filter_t)magnificationFilter);
		kinc_compute_set_texture_mipmap_filter(unit->unit, (kinc_g4_mipmap_filter_t)mipMapFilter);
	")
	static function setTextureFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {}

	@:functionCode("
		kinc_compute_set_texture3d_minification_filter(unit->unit, (kinc_g4_texture_filter_t)minificationFilter);
		kinc_compute_set_texture3d_magnification_filter(unit->unit, (kinc_g4_texture_filter_t)magnificationFilter);
		kinc_compute_set_texture3d_mipmap_filter(unit->unit, (kinc_g4_mipmap_filter_t)mipMapFilter);
	")
	static function setTexture3DFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {}

	public static function setTextureParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTextureWrapNative(unit, uAddressing, vAddressing);
		setTextureFiltersNative(unit, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public static function setTexture3DParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTexture3DWrapNative(unit, uAddressing, vAddressing, wAddressing);
		setTexture3DFiltersNative(unit, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public static function setShader(shader: Shader) {
		untyped __cpp__("kinc_compute_set_shader(&shader->shader);");
	}

	public static function compute(x: Int, y: Int, z: Int) {
		untyped __cpp__("kinc_compute(x, y, z);");
	}
}

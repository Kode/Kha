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

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Compute/Compute.h>
')

class Compute {
	public static function setBool(location: ConstantLocation, value: Bool) {
		untyped __cpp__('Kore::Compute::setBool(location->location, value);');
	}

	public static function setInt(location: ConstantLocation, value: Int) {
		untyped __cpp__('Kore::Compute::setInt(location->location, value);');
	}

	public static function setFloat(location: ConstantLocation, value: FastFloat) {
		untyped __cpp__('Kore::Compute::setFloat(location->location, value);');
	}

	public static function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat) {
		untyped __cpp__('Kore::Compute::setFloat2(location->location, value1, value2);');
	}

	public static function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat) {
		untyped __cpp__('Kore::Compute::setFloat3(location->location, value1, value2, value3);');
	}

	public static function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat) {
		untyped __cpp__('Kore::Compute::setFloat4(location->location, value1, value2, value3, value4);');
	}

	public static function setFloats(location: ConstantLocation, values: Float32Array) {
		untyped __cpp__('Kore::Compute::setFloats(location->location, values->self.data, values->self.length());');
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

	@:functionCode('
		Kore::mat4 value;
		value.Set(0, 0, matrix->_00); value.Set(0, 1, matrix->_10); value.Set(0, 2, matrix->_20); value.Set(0, 3, matrix->_30);
		value.Set(1, 0, matrix->_01); value.Set(1, 1, matrix->_11); value.Set(1, 2, matrix->_21); value.Set(1, 3, matrix->_31);
		value.Set(2, 0, matrix->_02); value.Set(2, 1, matrix->_12); value.Set(2, 2, matrix->_22); value.Set(2, 3, matrix->_32);
		value.Set(3, 0, matrix->_03); value.Set(3, 1, matrix->_13); value.Set(3, 2, matrix->_23); value.Set(3, 3, matrix->_33);
		Kore::Compute::setMatrix(location->location, value);
	')
	private static function setMatrixPrivate(location: ConstantLocation, matrix: FastMatrix4): Void {

	}

	@:functionCode('
		Kore::mat3 value;
		value.Set(0, 0, matrix->_00); value.Set(0, 1, matrix->_10); value.Set(0, 2, matrix->_20);
		value.Set(1, 0, matrix->_01); value.Set(1, 1, matrix->_11); value.Set(1, 2, matrix->_21);
		value.Set(2, 0, matrix->_02); value.Set(2, 1, matrix->_12); value.Set(2, 2, matrix->_22);
		Kore::Compute::setMatrix(location->location, value);
	')
	private static function setMatrix3Private(location: ConstantLocation, matrix: FastMatrix3): Void {

	}

	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int) {
		untyped __cpp__('
			#ifdef KORE_OPENGL
			Kore::Compute::setBuffer(buffer->buffer, index);
			#endif
		');
	}

	public static function setTexture(unit: TextureUnit, texture: Image, access: Access) {
		setTexturePrivate(unit, texture, access);
	}

	@:functionCode('
		if (texture->texture != nullptr) Kore::Compute::setTexture(unit->unit, texture->texture, (Kore::Compute::Access)access);
		else Kore::Compute::setTexture(unit->unit, texture->renderTarget, (Kore::Compute::Access)access);
	')
	private static function setTexturePrivate(unit: TextureUnit, texture: Image, access: Int): Void {

	}

	public static function setSampledTexture(unit: TextureUnit, texture: Image) {
		setSampledTexturePrivate(unit, texture);
	}

	@:functionCode('
		if (texture->texture != nullptr) Kore::Compute::setSampledTexture(unit->unit, texture->texture);
		else Kore::Compute::setSampledTexture(unit->unit, texture->renderTarget);
	')
	private static function setSampledTexturePrivate(unit: TextureUnit, texture: Image): Void {

	}

	public static function setSampledDepthTexture(unit: TextureUnit, texture: Image) {
		untyped __cpp__("Kore::Compute::setSampledDepthTexture(unit->unit, texture->renderTarget);");
	}

	public static function setSampledCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		setSampledCubeMapPrivate(unit, cubeMap);
	}

	@:functionCode('
		if (cubeMap->texture != nullptr) Kore::Compute::setSampledTexture(unit->unit, cubeMap->texture);
		else Kore::Compute::setSampledTexture(unit->unit, cubeMap->renderTarget);
	')
	private static function setSampledCubeMapPrivate(unit: TextureUnit, cubeMap: CubeMap): Void {

	}

	public static function setSampledDepthCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		untyped __cpp__("Kore::Compute::setSampledDepthTexture(unit->unit, cubeMap->renderTarget);");
	}

	@:functionCode('
		Kore::Compute::setTextureAddressing(unit->unit, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uWrap);
		Kore::Compute::setTextureAddressing(unit->unit, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vWrap);
	')
	private static function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {

	}

	@:functionCode('
		Kore::Compute::setTexture3DAddressing(unit->unit, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uWrap);
		Kore::Compute::setTexture3DAddressing(unit->unit, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vWrap);
		Kore::Compute::setTexture3DAddressing(unit->unit, Kore::Graphics4::W, (Kore::Graphics4::TextureAddressing)wWrap);
	')
	private static function setTexture3DWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int, wWrap: Int): Void {

	}

	@:functionCode('
		Kore::Compute::setTextureMinificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)minificationFilter);
		Kore::Compute::setTextureMagnificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)magnificationFilter);
		Kore::Compute::setTextureMipmapFilter(unit->unit, (Kore::Graphics4::MipmapFilter)mipMapFilter);
	')
	private static function setTextureFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {

	}

	@:functionCode('
		Kore::Compute::setTexture3DMinificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)minificationFilter);
		Kore::Compute::setTexture3DMagnificationFilter(unit->unit, (Kore::Graphics4::TextureFilter)magnificationFilter);
		Kore::Compute::setTexture3DMipmapFilter(unit->unit, (Kore::Graphics4::MipmapFilter)mipMapFilter);
	')
	private static function setTexture3DFiltersNative(unit: TextureUnit, minificationFilter: Int, magnificationFilter: Int, mipMapFilter: Int): Void {

	}

	public static function setTextureParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTextureWrapNative(unit, uAddressing, vAddressing);
		setTextureFiltersNative(unit, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public static function setTexture3DParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		setTexture3DWrapNative(unit, uAddressing, vAddressing, wAddressing);
		setTexture3DFiltersNative(unit, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public static function setShader(shader: Shader) {
		untyped __cpp__('Kore::Compute::setShader(shader->shader);');
	}

	public static function compute(x: Int, y: Int, z: Int) {
		untyped __cpp__('Kore::Compute::compute(x, y, z);');
	}
}

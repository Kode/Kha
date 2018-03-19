package kha.compute;

import kha.Image;
import kha.FastFloat;
import kha.arrays.Float32Array;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.graphics4.CubeMap;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

class Compute {

	public static function setBool(location: ConstantLocation, value: Bool) {
		Krom.setBoolCompute(location, value);
	}

	public static function setInt(location: ConstantLocation, value: Int) {
		Krom.setIntCompute(location, value);
	}

	public static function setFloat(location: ConstantLocation, value: FastFloat) {
		Krom.setFloatCompute(location, value);
	}

	public static function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat) {
		Krom.setFloat2Compute(location, value1, value2);
	}

	public static function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat) {
		Krom.setFloat3Compute(location, value1, value2, value3);
	}

	public static function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat) {
		Krom.setFloat4Compute(location, value1, value2, value3, value4);
	}

	public static function setFloats(location: ConstantLocation, values: Float32Array) {
		Krom.setFloatsCompute(location, values);
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
		Krom.setMatrixCompute(location, value);
	}

	public static function setMatrix3(location: ConstantLocation, value: FastMatrix3): Void {
		Krom.setMatrix3Compute(location, value);
	}

	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int) {
		
	}

	public static function setTexture(unit: TextureUnit, texture: Image, access: Access) {
		Krom.setTextureCompute(unit, texture, access.getIndex());
	}

	public static function setSampledTexture(unit: TextureUnit, texture: Image) {
		Krom.setSampledTextureCompute(unit, texture);
	}

	public static function setSampledDepthTexture(unit: TextureUnit, texture: Image) {
		Krom.setSampledDepthTextureCompute(unit, texture);
	}

	public static function setSampledCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		Krom.setSampledTextureCompute(unit, cubeMap);
	}

	public static function setSampledDepthCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		Krom.setSampledDepthTextureCompute(unit, cubeMap);
	}

	public static function setTextureParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTextureParametersCompute(unit, uAddressing.getIndex(), vAddressing.getIndex(), minificationFilter.getIndex(), magnificationFilter.getIndex(), mipmapFilter.getIndex());
	}

	public static function setTexture3DParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTexture3DParametersCompute(unit, uAddressing.getIndex(), vAddressing.getIndex(), wAddressing.getIndex(), minificationFilter.getIndex(), magnificationFilter.getIndex(), mipmapFilter.getIndex());
	}

	public static function setShader(shader: Shader) {
		Krom.setShaderCompute(shader.shader_);
	}

	public static function compute(x: Int, y: Int, z: Int) {
		Krom.compute(x, y, z);
	}
}

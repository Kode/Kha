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
		Krom.setFloatsCompute(location, values.buffer);
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

	static var mat = new kha.arrays.Float32Array(16);

	public static function setMatrix(location: ConstantLocation, matrix: FastMatrix4): Void {
		mat[0] = matrix._00;
		mat[1] = matrix._01;
		mat[2] = matrix._02;
		mat[3] = matrix._03;
		mat[4] = matrix._10;
		mat[5] = matrix._11;
		mat[6] = matrix._12;
		mat[7] = matrix._13;
		mat[8] = matrix._20;
		mat[9] = matrix._21;
		mat[10] = matrix._22;
		mat[11] = matrix._23;
		mat[12] = matrix._30;
		mat[13] = matrix._31;
		mat[14] = matrix._32;
		mat[15] = matrix._33;
		Krom.setMatrixCompute(location, mat.buffer);
	}

	public static function setMatrix3(location: ConstantLocation, matrix: FastMatrix3): Void {
		mat[0] = matrix._00;
		mat[1] = matrix._01;
		mat[2] = matrix._02;
		mat[3] = matrix._10;
		mat[4] = matrix._11;
		mat[5] = matrix._12;
		mat[6] = matrix._20;
		mat[7] = matrix._21;
		mat[8] = matrix._22;
		Krom.setMatrix3Compute(location, mat.buffer);
	}

	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int) {}

	public static function setTexture(unit: TextureUnit, texture: Image, access: Access) {
		if (texture == null)
			return;
		texture.texture_ != null ? Krom.setTextureCompute(unit, texture.texture_, access) : Krom.setRenderTargetCompute(unit, texture.renderTarget_, access);
	}

	public static function setSampledTexture(unit: TextureUnit, texture: Image) {
		if (texture == null)
			return;
		texture.texture_ != null ? Krom.setSampledTextureCompute(unit, texture.texture_) : Krom.setSampledRenderTargetCompute(unit, texture.renderTarget_);
	}

	public static function setSampledDepthTexture(unit: TextureUnit, texture: Image) {
		if (texture == null)
			return;
		Krom.setSampledDepthTextureCompute(unit, texture);
	}

	public static function setSampledCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		if (cubeMap == null)
			return;
		cubeMap.texture_ != null ? Krom.setSampledTextureCompute(unit, cubeMap.texture_) : Krom.setSampledRenderTargetCompute(unit, cubeMap.renderTarget_);
	}

	public static function setSampledDepthCubeMap(unit: TextureUnit, cubeMap: CubeMap) {
		if (cubeMap == null)
			return;
		Krom.setSampledDepthTextureCompute(unit, cubeMap);
	}

	public static function setTextureParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTextureParametersCompute(unit, uAddressing, vAddressing, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public static function setTexture3DParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
			wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTexture3DParametersCompute(unit, uAddressing, vAddressing, wAddressing, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public static function setShader(shader: Shader) {
		Krom.setShaderCompute(shader.shader_);
	}

	public static function compute(x: Int, y: Int, z: Int) {
		Krom.compute(x, y, z);
	}
}

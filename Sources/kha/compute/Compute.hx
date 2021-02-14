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

extern class Compute {
	public static function setBool(location: ConstantLocation, value: Bool): Void;
	public static function setInt(location: ConstantLocation, value: Int): Void;
	public static function setFloat(location: ConstantLocation, value: FastFloat): Void;
	public static function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void;
	public static function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void;
	public static function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void;
	public static function setFloats(location: ConstantLocation, values: Float32Array): Void;
	public static function setVector2(location: ConstantLocation, value: FastVector2): Void;
	public static function setVector3(location: ConstantLocation, value: FastVector3): Void;
	public static function setVector4(location: ConstantLocation, value: FastVector4): Void;
	public static function setMatrix(location: ConstantLocation, value: FastMatrix4): Void;
	public static function setMatrix3(location: ConstantLocation, value: FastMatrix3): Void;
	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int): Void;
	public static function setTexture(unit: TextureUnit, texture: Image, access: Access): Void;
	public static function setSampledTexture(unit: TextureUnit, texture: Image): Void;
	public static function setSampledDepthTexture(unit: TextureUnit, texture: Image): Void;
	public static function setSampledCubeMap(unit: TextureUnit, cubeMap: CubeMap): Void;
	public static function setSampledDepthCubeMap(unit: TextureUnit, cubeMap: CubeMap): Void;
	public static function setTextureParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
		minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void;
	public static function setTexture3DParameters(unit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing,
		wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void;
	public static function setShader(shader: Shader): Void;
	public static function compute(x: Int, y: Int, z: Int): Void;
}

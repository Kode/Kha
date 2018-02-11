package kha.compute;

import kha.Image;

extern class Compute {
	public static function setFloat(location: ConstantLocation, value: Float): Void;
	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int): Void;
	public static function setTexture(unit: TextureUnit, texture: Image, access: Access): Void;
	public static function setShader(shader: Shader): Void;
	public static function compute(x: Int, y: Int, z: Int): Void;
}

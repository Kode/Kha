package kha.compute;

import kha.Image;

extern class Compute {
	public static function setFloat(location: ConstantLocation, value: Float);
	public static function setTexture(unit: TextureUnit, texture: Image);
	public static function setShader(shader: Shader);
	public static function compute(x: Int, y: Int, z: Int);
}

package kha.compute;

import kha.Image;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Compute/Compute.h>
')

class Compute {
	public static function setFloat(location: ConstantLocation, value: Float) {
		untyped __cpp__('Kore::Compute::setFloat(location->location, value);');
	}

	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int) {
		untyped __cpp__('Kore::Compute::setBuffer(buffer->buffer, index);');
	}

	public static function setTexture(unit: TextureUnit, texture: Image) {
		untyped __cpp__('Kore::Compute::setTexture(unit->unit, texture->texture);');
	}

	public static function setShader(shader: Shader) {
		untyped __cpp__('Kore::Compute::setShader(shader->shader);');
	}

	public static function compute(x: Int, y: Int, z: Int) {
		untyped __cpp__('Kore::Compute::compute(x, y, z);');
	}
}

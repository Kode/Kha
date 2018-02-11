package kha.compute;

import kha.Image;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Compute/Compute.h>
')

class Compute {
	private static function getAccess(access: Access): Int {
		switch (access) {
		case Access.Read:
			return 0;
		case Access.Write:
			return 1;
		case Access.ReadWrite:
			return 2;
		}
	}

	public static function setFloat(location: ConstantLocation, value: Float) {
		untyped __cpp__('Kore::Compute::setFloat(location->location, value);');
	}

	public static function setBuffer(buffer: ShaderStorageBuffer, index: Int) {
		untyped __cpp__('Kore::Compute::setBuffer(buffer->buffer, index);');
	}

	public static function setTexture(unit: TextureUnit, texture: Image, access: Access) {
		var accessKore: Int = getAccess(access);
		untyped __cpp__('Kore::Compute::setTexture(unit->unit, texture->texture, (Kore::Graphics4::Access)accessKore);');
	}

	public static function setShader(shader: Shader) {
		untyped __cpp__('Kore::Compute::setShader(shader->shader);');
	}

	public static function compute(x: Int, y: Int, z: Int) {
		untyped __cpp__('Kore::Compute::compute(x, y, z);');
	}
}

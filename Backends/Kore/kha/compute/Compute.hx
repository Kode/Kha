package kha.compute;

import haxe.ds.Vector;
import kha.Image;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;

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

	public static function setFloats(location: ConstantLocation, values: Vector<FastFloat>) {
		untyped __cpp__('Kore::Compute::setFloats(location->location, values->Pointer(), values->length);');
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
		untyped __cpp__('Kore::Compute::setBuffer(buffer->buffer, index);');
	}

	public static function setTexture(unit: TextureUnit, texture: Image, access: Access) {
		var accessKore: Int = getAccess(access);
		untyped __cpp__('Kore::Compute::setTexture(unit->unit, texture->texture, (Kore::Compute::Access)accessKore);');
	}

	public static function setShader(shader: Shader) {
		untyped __cpp__('Kore::Compute::setShader(shader->shader);');
	}

	public static function compute(x: Int, y: Int, z: Int) {
		untyped __cpp__('Kore::Compute::compute(x, y, z);');
	}
}

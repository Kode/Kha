package kha.graphics5;

import haxe.ds.Vector;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;

interface ConstantBuffer {
	function setBool(location: ConstantLocation, value: Bool): Void;
	function setInt(location: ConstantLocation, value: Int): Void;
	function setFloat(location: ConstantLocation, value: FastFloat): Void;
	function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void;
	function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void;
	function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void;
	function setFloats(location: ConstantLocation, floats: Vector<FastFloat>): Void;
	function setVector2(location: ConstantLocation, value: FastVector2): Void;
	function setVector3(location: ConstantLocation, value: FastVector3): Void;
	function setVector4(location: ConstantLocation, value: FastVector4): Void;
	function setMatrix(location: ConstantLocation, value: FastMatrix4): Void;
	function setMatrix3(location: ConstantLocation, value: FastMatrix3): Void;
}

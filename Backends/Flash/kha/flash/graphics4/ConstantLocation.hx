package kha.flash.graphics4;

import flash.display3D.Context3DProgramType;

class ConstantLocation implements kha.graphics4.ConstantLocation {
	public function new(value: Int, type: Context3DProgramType) {
		this.value = value;
		this.type = type;
	}
	
	public var value: Int;
	public var type: Context3DProgramType;
}

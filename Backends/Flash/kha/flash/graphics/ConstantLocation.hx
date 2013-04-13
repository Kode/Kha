package kha.flash.graphics;

import flash.display3D.Context3DProgramType;

class ConstantLocation implements kha.graphics.ConstantLocation {
	public function new(value: Int, type: Context3DProgramType) {
		this.value = value;
		this.type = type;
	}
	
	public var value: Int;
	public var type: Context3DProgramType;
}

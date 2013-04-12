package kha.flash.graphics;

class ConstantLocation implements kha.graphics.ConstantLocation {
	public function new(value: Int) {
		this.value = value;
	}
	
	public var value: Int;
}

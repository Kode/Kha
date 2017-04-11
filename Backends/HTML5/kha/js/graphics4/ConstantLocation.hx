package kha.js.graphics4;

class ConstantLocation implements kha.graphics4.ConstantLocation {
	public var value: Dynamic;
	public var type: Int;
	
	public function new(value: Dynamic, type: Int) {
		this.value = value;
		this.type = type;
	}
}

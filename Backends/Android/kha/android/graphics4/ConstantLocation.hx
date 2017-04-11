package kha.android.graphics4;

class ConstantLocation implements kha.graphics4.ConstantLocation {
	public var value: Int;
	public var type: Int;
	
	public function new(value: Int, type: Int) {
		this.value = value;
		this.type = type;
	}
}

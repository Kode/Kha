package kha.html5worker;

class ConstantLocation implements kha.graphics4.ConstantLocation {
	static var lastId: Int = -1;

	public var _id: Int;

	public function new() {
		_id = ++lastId;
	}
}

package kha.korehl.graphics4;

class ConstantLocation implements kha.graphics4.ConstantLocation {
	public var _location: Pointer;
	
	public function new(location: Pointer) {
		_location = location;
	}
}

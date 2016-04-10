package kha.korehl.graphics4;

class TextureUnit implements kha.graphics4.TextureUnit {
	public var _unit: Pointer;
	
	public function new(unit: Pointer) {
		_unit = unit;
	}
}

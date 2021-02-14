package kha.html5worker;

class TextureUnit implements kha.graphics4.TextureUnit {
	static var lastId: Int = -1;

	public var _id: Int;

	public function new() {
		_id = ++lastId;
	}
}

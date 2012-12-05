package kha.graphics;

class VertexElement {
	public var name: String;
	public var type: VertexData;
	
	public function new(name: String, type: VertexData) {
		this.name = name;
		this.type = type;
	}
}
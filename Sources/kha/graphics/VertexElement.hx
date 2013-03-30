package kha.graphics;

class VertexElement {
	public var name: String;
	public var data: VertexData;
	public var type: VertexType;
	
	public function new(name: String, data: VertexData, type: VertexType) {
		this.name = name;
		this.data = data;
		this.type = type;
	}
}

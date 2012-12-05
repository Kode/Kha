package kha.graphics;

class VertexStructure {
	public var elements: Array<VertexElement>;
	
	public function new() {
		elements = new Array<VertexElement>();
	}
	
	public function add(name: String, type: VertexData) {
		elements.push(new VertexElement(name, type));
	}
}
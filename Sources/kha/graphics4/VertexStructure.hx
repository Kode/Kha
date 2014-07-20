package kha.graphics4;

class VertexStructure {
	public var elements: Array<VertexElement>;
	
	public function new() {
		elements = new Array<VertexElement>();
	}
	
	public function add(name: String, data: VertexData) {
		elements.push(new VertexElement(name, data));
	}
	
	public function size(): Int {
		return elements.length;
	}
	
	public function get(index: Int): VertexElement {
		return elements[index];
	}
}

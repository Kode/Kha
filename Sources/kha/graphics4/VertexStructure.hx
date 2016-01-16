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
	
	public function byteSize(): Int {
		var byteSize = 0;
		
		for (i in 0...elements.length) {
			byteSize += dataByteSize(elements[i].data);
		}
		
		return byteSize;
	}
	
	private function dataByteSize(data: VertexData) : Int {
		switch(data) {
			case Float1:
				return 1;
			case Float2:
				return 2;
			case Float3:
				return 3;
			case Float4:
				return 4;
			case Float4x4:
				return 16;
		}
		return 0;
	}
	
	public function get(index: Int): VertexElement {
		return elements[index];
	}
}

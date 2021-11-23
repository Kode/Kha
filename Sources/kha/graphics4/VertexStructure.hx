package kha.graphics4;

class VertexStructure {
	public var elements: Array<VertexElement>;
	public var instanced: Bool;

	public function new() {
		elements = new Array<VertexElement>();
		instanced = false;
	}

	public function add(name: String, data: VertexData) {
		elements.push(new VertexElement(name, data));
	}

	@:keep
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

	function dataByteSize(data: VertexData): Int {
		switch (data) {
			case Float1:
				return 4 * 1;
			case Float2:
				return 4 * 2;
			case Float3:
				return 4 * 3;
			case Float4:
				return 4 * 4;
			case Float4x4:
				return 4 * 4 * 4;
			case Short2Norm:
				return 2 * 2;
			case Short4Norm:
				return 2 * 4;
			case Byte1, UnsignedByte1:
				return 1 * 1;
			case Byte2, UnsignedByte2:
				return 1 * 2;
			case Byte3, UnsignedByte3:
				return 1 * 3;
			case Byte4, UnsignedByte4:
				return 1 * 4;
			case Short1, UnsignedShort1:
				return 2 * 1;
			case Short2, UnsignedShort2:
				return 2 * 2;
			case Short3, UnsignedShort3:
				return 2 * 3;
			case Short4, UnsignedShort4:
				return 2 * 4;
			case Int1, UnsignedInt1:
				return 4 * 1;
			case Int2, UnsignedInt2:
				return 4 * 2;
			case Int3, UnsignedInt3:
				return 4 * 3;
			case Int4, UnsignedInt4:
				return 4 * 4;
		}
		return 0;
	}

	@:keep
	public function get(index: Int): VertexElement {
		return elements[index];
	}
}

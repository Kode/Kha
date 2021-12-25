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

	public static function dataByteSize(data: VertexData): Int {
		switch (data) {
			case Float32_1X:
				return 1 * 4;
			case Float32_2X:
				return 2 * 4;
			case Float32_3X:
				return 3 * 4;
			case Float32_4X:
				return 4 * 4;
			case Float32_4X4:
				return 4 * 4 * 4;
			case Int8_1X, UInt8_1X, Int8_1X_Normalized, UInt8_1X_Normalized:
				return 1 * 1;
			case Int8_2X, UInt8_2X, Int8_2X_Normalized, UInt8_2X_Normalized:
				return 2 * 1;
			case Int8_4X, UInt8_4X, Int8_4X_Normalized, UInt8_4X_Normalized:
				return 4 * 1;
			case Int16_1X, UInt16_1X, Int16_1X_Normalized, UInt16_1X_Normalized:
				return 1 * 2;
			case Int16_2X, UInt16_2X, Int16_2X_Normalized, UInt16_2X_Normalized:
				return 2 * 2;
			case Int16_4X, UInt16_4X, Int16_4X_Normalized, UInt16_4X_Normalized:
				return 4 * 2;
			case Int32_1X, UInt32_1X:
				return 1 * 4;
			case Int32_2X, UInt32_2X:
				return 2 * 4;
			case Int32_3X, UInt32_3X:
				return 3 * 4;
			case Int32_4X,UInt32_4X:
				return 4 * 4;
		}
	}

	@:keep
	public function get(index: Int): VertexElement {
		return elements[index];
	}
}

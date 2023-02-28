package kha.graphics4;

@:enum abstract VertexData(Int) {
	var Float32_1X = 0;
	var Float32_2X = 1;
	var Float32_3X = 2;
	var Float32_4X = 3;
	var Float32_4X4 = 4;
	var Int8_1X = 5;
	var UInt8_1X = 6;
	var Int8_1X_Normalized = 7;
	var UInt8_1X_Normalized = 8;
	var Int8_2X = 9;
	var UInt8_2X = 10;
	var Int8_2X_Normalized = 11;
	var UInt8_2X_Normalized = 12;
	var Int8_4X = 13;
	var UInt8_4X = 14;
	var Int8_4X_Normalized = 15;
	var UInt8_4X_Normalized = 16;
	var Int16_1X = 17;
	var UInt16_1X = 18;
	var Int16_1X_Normalized = 19;
	var UInt16_1X_Normalized = 20;
	var Int16_2X = 21;
	var UInt16_2X = 22;
	var Int16_2X_Normalized = 23;
	var UInt16_2X_Normalized = 24;
	var Int16_4X = 25;
	var UInt16_4X = 26;
	var Int16_4X_Normalized = 27;
	var UInt16_4X_Normalized = 28;
	var Int32_1X = 29;
	var UInt32_1X = 30;
	var Int32_2X = 31;
	var UInt32_2X = 32;
	var Int32_3X = 33;
	var UInt32_3X = 34;
	var Int32_4X = 35;
	var UInt32_4X = 36;
	// deprecated
	var Float1 = Float32_1X;
	var Float2 = Float32_2X;
	var Float3 = Float32_3X;
	var Float4 = Float32_4X;
	var Float4x4 = Float32_4X4;
	var Short2Norm = Int16_2X_Normalized;
	var Short4Norm = Int16_4X_Normalized;

	/**
		Return the element size of the given vertex data type in bytes.
	**/
	public static inline function getStride(vertexData: VertexData): Int {
		return switch (vertexData) {
			case Float32_1X: 4 * 1;
			case Float32_2X: 4 * 2;
			case Float32_3X: 4 * 3;
			case Float32_4X: 4 * 4;
			case Float32_4X4: 4 * 4 * 4;
			case Int8_1X: 1;
			case UInt8_1X: 1;
			case Int8_1X_Normalized: 1;
			case UInt8_1X_Normalized: 1;
			case Int8_2X: 1 * 2;
			case UInt8_2X: 1 * 2;
			case Int8_2X_Normalized: 1 * 2;
			case UInt8_2X_Normalized: 1 * 2;
			case Int8_4X: 1 * 4;
			case UInt8_4X: 1 * 4;
			case Int8_4X_Normalized: 1 * 4;
			case UInt8_4X_Normalized: 1 * 4;
			case Int16_1X: 2 * 1;
			case UInt16_1X: 2 * 1;
			case Int16_1X_Normalized: 2 * 1;
			case UInt16_1X_Normalized: 2 * 1;
			case Int16_2X: 2 * 2;
			case UInt16_2X: 2 * 2;
			case Int16_2X_Normalized: 2 * 2;
			case UInt16_2X_Normalized: 2 * 2;
			case Int16_4X: 2 * 4;
			case UInt16_4X: 2 * 4;
			case Int16_4X_Normalized: 2 * 4;
			case UInt16_4X_Normalized: 2 * 4;
			case Int32_1X: 4 * 1;
			case UInt32_1X: 4 * 1;
			case Int32_2X: 4 * 2;
			case UInt32_2X: 4 * 2;
			case Int32_3X: 4 * 3;
			case UInt32_3X: 4 * 3;
			case Int32_4X: 4 * 4;
			case UInt32_4X: 4 * 4;
		}
	}
}

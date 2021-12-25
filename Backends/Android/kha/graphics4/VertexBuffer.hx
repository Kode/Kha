package kha.graphics4;

import android.opengl.GLES20;
import java.NativeArray;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	var buffer: Int;
	var data: Float32Array;
	var mySize: Int;
	var myStride: Int;
	var sizes: Array<Int>;
	var offsets: Array<Int>;
	var usage: Usage;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = vertexCount;
		for (element in structure.elements) {
			myStride += VertexStructure.dataByteSize(element.data);
		}

		buffer = createBuffer();
		data = new Float32Array(Std.int(vertexCount * myStride / 4));

		sizes = new Array<Int>();
		offsets = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;

		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size;
			switch (element.data) {
				case Float32_1X:
					size = 1;
				case Float32_2X:
					size = 2;
				case Float32_3X:
					size = 3;
				case Float32_4X:
					size = 4;
				case Float32_4X4:
					size = 4 * 4;
				case Int8_1X, UInt8_1X, Int8_1X_Normalized, UInt8_1X_Normalized:
					size = 1;
				case Int8_2X, UInt8_2X, Int8_2X_Normalized, UInt8_2X_Normalized:
					size = 2;
				case Int8_4X, UInt8_4X, Int8_4X_Normalized, UInt8_4X_Normalized:
					size = 4;
				case Int16_1X, UInt16_1X, Int16_1X_Normalized, UInt16_1X_Normalized:
					size = 1;
				case Int16_2X, UInt16_2X, Int16_2X_Normalized, UInt16_2X_Normalized:
					size = 2;
				case Int16_4X, UInt16_4X, Int16_4X_Normalized, UInt16_4X_Normalized:
					size = 4;
				case Int32_1X, UInt32_1X:
					size = 1;
				case Int32_2X, UInt32_2X:
					size = 2;
				case Int32_3X, UInt32_3X:
					size = 3;
				case Int32_4X,UInt32_4X:
					size = 4;
			}
			sizes[index] = size;
			offsets[index] = offset;
			offset += VertexStructure.dataByteSize(element.data);
			++index;
		}
	}

	static function createBuffer(): Int {
		var buffers = new NativeArray<Int>(1);
		GLES20.glGenBuffers(1, buffers, 0);
		return buffers[0];
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
	}

	public function unlock(?count: Int): Void {
		var count = (count != null ? count : mySize) * myStride;
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, buffer);
		GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, count, data.data(count), usage == Usage.DynamicUsage ? GLES20.GL_DYNAMIC_DRAW : GLES20.GL_STATIC_DRAW);
	}

	public function stride(): Int {
		return myStride;
	}

	public function count(): Int {
		return mySize;
	}

	public function set(): Void {
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, buffer);
		for (i in 0...sizes.length) {
			GLES20.glEnableVertexAttribArray(i);
			GLES20.glVertexAttribPointer(i, sizes[i], GLES20.GL_FLOAT, false, myStride, offsets[i]);
		}
	}
}

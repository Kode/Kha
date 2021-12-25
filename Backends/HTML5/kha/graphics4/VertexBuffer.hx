package kha.graphics4;

import kha.arrays.Float32Array;
import js.html.webgl.GL;
import kha.arrays.ByteArray;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;

class VertexBuffer {
	public var _data: ByteArray;

	var buffer: Dynamic;
	var mySize: Int;
	var myStride: Int;
	var sizes: Array<Int>;
	var offsets: Array<Int>;
	var types: Array<Int>;
	var instanceDataStepRate: Int;
	var lockStart: Int = 0;
	var lockEnd: Int = 0;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		this.instanceDataStepRate = instanceDataStepRate;
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			myStride += VertexStructure.dataByteSize(element.data);
		}

		buffer = SystemImpl.gl.createBuffer();
		_data = ByteArray.make(vertexCount * myStride);

		sizes = new Array<Int>();
		offsets = new Array<Int>();
		types = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;
		types[structure.elements.length - 1] = 0;

		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size;
			var type;
			switch (element.data) {
				case Float32_1X:
					size = 1;
					type = GL.FLOAT;
				case Float32_2X:
					size = 2;
					type = GL.FLOAT;
				case Float32_3X:
					size = 3;
					type = GL.FLOAT;
				case Float32_4X:
					size = 4;
					type = GL.FLOAT;
				case Float32_4X4:
					size = 4 * 4;
					type = GL.FLOAT;
				case Int8_1X, Int8_1X_Normalized:
					size = 1;
					type = GL.BYTE;
				case Int8_2X, Int8_2X_Normalized:
					size = 2;
					type = GL.BYTE;
				case Int8_4X, Int8_4X_Normalized:
					size = 4;
					type = GL.BYTE;
				case UInt8_1X, UInt8_1X_Normalized:
					size = 1;
					type = GL.UNSIGNED_BYTE;
				case UInt8_2X, UInt8_2X_Normalized:
					size = 2;
					type = GL.UNSIGNED_BYTE;
				case UInt8_4X, UInt8_4X_Normalized:
					size = 4;
					type = GL.UNSIGNED_BYTE;
				case Int16_1X, Int16_1X_Normalized:
					size = 1;
					type = GL.SHORT;
				case Int16_2X, Int16_2X_Normalized:
					size = 2;
					type = GL.SHORT;
				case Int16_4X, Int16_4X_Normalized:
					size = 4;
					type = GL.SHORT;
				case UInt16_1X, UInt16_1X_Normalized:
					size = 1;
					type = GL.UNSIGNED_SHORT;
				case UInt16_2X, UInt16_2X_Normalized:
					size = 2;
					type = GL.UNSIGNED_SHORT;
				case UInt16_4X, UInt16_4X_Normalized:
					size = 4;
					type = GL.UNSIGNED_SHORT;
				case Int32_1X:
					size = 1;
					type = GL.INT;
				case Int32_2X:
					size = 2;
					type = GL.INT;
				case Int32_3X:
					size = 3;
					type = GL.INT;
				case Int32_4X:
					size = 4;
					type = GL.INT;
				case UInt32_1X:
					size = 1;
					type = GL.UNSIGNED_INT;
				case UInt32_2X:
					size = 2;
					type = GL.UNSIGNED_INT;
				case UInt32_3X:
					size = 3;
					type = GL.UNSIGNED_INT;
				case UInt32_4X:
					size = 4;
					type = GL.UNSIGNED_INT;
			}
			sizes[index] = size;
			offsets[index] = offset;
			types[index] = type;
			offset += VertexStructure.dataByteSize(element.data);
			++index;
		}

		SystemImpl.gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
		SystemImpl.gl.bufferData(GL.ARRAY_BUFFER, _data.subarray(0 * stride(), mySize * stride()),
			usage == Usage.DynamicUsage ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}

	public function delete(): Void {
		_data = null;
		SystemImpl.gl.deleteBuffer(buffer);
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		lockStart = start != null ? start : 0;
		lockEnd = count != null ? start + count : mySize;
		return _data.subarray(lockStart * stride(), lockEnd * stride());
	}

	public function unlock(?count: Int): Void {
		if (count != null)
			lockEnd = lockStart + count;
		SystemImpl.gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
		SystemImpl.gl.bufferSubData(GL.ARRAY_BUFFER, lockStart * stride(), _data.subarray(lockStart * stride(), lockEnd * stride()));
	}

	public function stride(): Int {
		return myStride;
	}

	public function count(): Int {
		return mySize;
	}

	public function set(offset: Int): Int {
		var ext: Dynamic = SystemImpl.gl2 ? true : SystemImpl.gl.getExtension("ANGLE_instanced_arrays");
		SystemImpl.gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
		var attributesOffset = 0;
		for (i in 0...sizes.length) {
			if (sizes[i] > 4) {
				var size = sizes[i];
				var addonOffset = 0;
				while (size > 0) {
					SystemImpl.gl.enableVertexAttribArray(offset + attributesOffset);
					SystemImpl.gl.vertexAttribPointer(offset + attributesOffset, 4, GL.FLOAT, false, myStride, offsets[i] + addonOffset);
					if (ext) {
						if (SystemImpl.gl2) {
							untyped SystemImpl.gl.vertexAttribDivisor(offset + attributesOffset, instanceDataStepRate);
						}
						else {
							ext.vertexAttribDivisorANGLE(offset + attributesOffset, instanceDataStepRate);
						}
					}
					size -= 4;
					addonOffset += 4 * 4;
					++attributesOffset;
				}
			}
			else {
				var normalized = types[i] == GL.FLOAT ? false : true;
				SystemImpl.gl.enableVertexAttribArray(offset + attributesOffset);
				SystemImpl.gl.vertexAttribPointer(offset + attributesOffset, sizes[i], types[i], normalized, myStride, offsets[i]);
				if (ext) {
					if (SystemImpl.gl2) {
						untyped SystemImpl.gl.vertexAttribDivisor(offset + attributesOffset, instanceDataStepRate);
					}
					else {
						ext.vertexAttribDivisorANGLE(offset + attributesOffset, instanceDataStepRate);
					}
				}
				++attributesOffset;
			}
		}
		return attributesOffset;
	}
}

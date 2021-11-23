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
			switch (element.data) {
				case Float1:
					myStride += 4 * 1;
				case Float2:
					myStride += 4 * 2;
				case Float3:
					myStride += 4 * 3;
				case Float4:
					myStride += 4 * 4;
				case Float4x4:
					myStride += 4 * 4 * 4;
				case Short2Norm:
					myStride += 2 * 2;
				case Short4Norm:
					myStride += 2 * 4;
				case Byte1, UnsignedByte1:
					myStride += 1 * 1;
				case Byte2, UnsignedByte2:
					myStride += 1 * 2;
				case Byte3, UnsignedByte3:
					myStride += 1 * 3;
				case Byte4, UnsignedByte4:
					myStride += 1 * 4;
				case Short1, UnsignedShort1:
					myStride += 2 * 1;
				case Short2, UnsignedShort2:
					myStride += 2 * 2;
				case Short3, UnsignedShort3:
					myStride += 2 * 3;
				case Short4, UnsignedShort4:
					myStride += 2 * 4;
				case Int1, UnsignedInt1:
					myStride += 4 * 1;
				case Int2, UnsignedInt2:
					myStride += 4 * 2;
				case Int3, UnsignedInt3:
					myStride += 4 * 3;
				case Int4, UnsignedInt4:
					myStride += 4 * 4;
			}
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
				case Float1:
					size = 1;
					type = GL.FLOAT;
				case Float2:
					size = 2;
					type = GL.FLOAT;
				case Float3:
					size = 3;
					type = GL.FLOAT;
				case Float4:
					size = 4;
					type = GL.FLOAT;
				case Float4x4:
					size = 4 * 4;
					type = GL.FLOAT;
				case Short2Norm:
					size = 2;
					type = GL.SHORT;
				case Short4Norm:
					size = 4;
					type = GL.SHORT;
				case Byte1:
					size = 1;
					type = GL.BYTE;
				case Byte2:
					size = 2;
					type = GL.BYTE;
				case Byte3:
					size = 3;
					type = GL.BYTE;
				case Byte4:
					size = 4;
					type = GL.BYTE;
				case UnsignedByte1:
					size = 1;
					type = GL.UNSIGNED_BYTE;
				case UnsignedByte2:
					size = 2;
					type = GL.UNSIGNED_BYTE;
				case UnsignedByte3:
					size = 3;
					type = GL.UNSIGNED_BYTE;
				case UnsignedByte4:
					size = 4;
					type = GL.UNSIGNED_BYTE;
				case Short1:
					size = 1;
					type = GL.SHORT;
				case Short2:
					size = 2;
					type = GL.SHORT;
				case Short3:
					size = 3;
					type = GL.SHORT;
				case Short4:
					size = 4;
					type = GL.SHORT;
				case UnsignedShort1:
					size = 1;
					type = GL.UNSIGNED_SHORT;
				case UnsignedShort2:
					size = 2;
					type = GL.UNSIGNED_SHORT;
				case UnsignedShort3:
					size = 3;
					type = GL.UNSIGNED_SHORT;
				case UnsignedShort4:
					size = 4;
					type = GL.UNSIGNED_SHORT;
				case Int1:
					size = 1;
					type = GL.INT;
				case Int2:
					size = 2;
					type = GL.INT;
				case Int3:
					size = 3;
					type = GL.INT;
				case Int4:
					size = 4;
					type = GL.INT;
				case UnsignedInt1:
					size = 1;
					type = GL.UNSIGNED_INT;
				case UnsignedInt2:
					size = 2;
					type = GL.UNSIGNED_INT;
				case UnsignedInt3:
					size = 3;
					type = GL.UNSIGNED_INT;
				case UnsignedInt4:
					size = 4;
					type = GL.UNSIGNED_INT;
			}
			sizes[index] = size;
			offsets[index] = offset;
			types[index] = type;
			switch (element.data) {
				case Float1:
					offset += 4 * 1;
				case Float2:
					offset += 4 * 2;
				case Float3:
					offset += 4 * 3;
				case Float4:
					offset += 4 * 4;
				case Float4x4:
					offset += 4 * 4 * 4;
				case Short2Norm:
					offset += 2 * 2;
				case Short4Norm:
					offset += 2 * 4;
				case Byte1, UnsignedByte1:
					offset += 1 * 1;
				case Byte2, UnsignedByte2:
					offset += 1 * 2;
				case Byte3, UnsignedByte3:
					offset += 1 * 3;
				case Byte4, UnsignedByte4:
					offset += 1 * 4;
				case Short1, UnsignedShort1:
					offset += 2 * 1;
				case Short2, UnsignedShort2:
					offset += 2 * 2;
				case Short3, UnsignedShort3:
					offset += 2 * 3;
				case Short4, UnsignedShort4:
					offset += 2 * 4;
				case Int1, UnsignedInt1:
					offset += 4 * 1;
				case Int2, UnsignedInt2:
					offset += 4 * 2;
				case Int3, UnsignedInt3:
					offset += 4 * 3;
				case Int4, UnsignedInt4:
					offset += 4 * 4;
			}
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

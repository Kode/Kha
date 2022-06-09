package kha.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	static var lastId: Int = -1;

	public var _id: Int;
	public var _data: Float32Array;

	var mySize: Int;
	var myStride: Int;
	var sizes: Array<Int>;
	var offsets: Array<Int>;
	var usage: Usage;
	var instanceDataStepRate: Int;
	var lockStart: Int = 0;
	var lockCount: Int = 0;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		this.usage = usage;
		this.instanceDataStepRate = instanceDataStepRate;
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			myStride += VertexStructure.dataByteSize(element.data);
		}

		_data = new Float32Array(Std.int(vertexCount * myStride / 4));

		sizes = new Array<Int>();
		offsets = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;

		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size = 0;
			size += Std.int(VertexStructure.dataByteSize(element.data) / 4);
			sizes[index] = size;
			offsets[index] = offset;
			offset += VertexStructure.dataByteSize(element.data);
			++index;
		}

		_id = ++lastId;
		var elements = new Array<Dynamic>();
		for (element in structure.elements) {
			elements.push({
				name: element.name,
				data: element.data
			});
		}
		Worker.postMessage({
			command: 'createVertexBuffer',
			id: _id,
			size: vertexCount,
			structure: {elements: elements},
			usage: usage
		});
	}

	public function delete(): Void {
		_data = null;
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		lockStart = start != null ? start : 0;
		lockCount = count != null ? count : mySize;
		return _data.subarray(lockStart * stride(), (lockStart + lockCount) * stride());
	}

	public function unlock(?count: Int): Void {
		if (count != null)
			lockCount = count;
		Worker.postMessage({
			command: 'updateVertexBuffer',
			id: _id,
			data: _data.subarray(lockStart * stride(), (lockStart + lockCount) * stride()).buffer,
			start: lockStart,
			count: lockCount
		});
	}

	public function stride(): Int {
		return myStride;
	}

	public function count(): Int {
		return mySize;
	}

	public function set(offset: Int): Int {
		var attributesOffset = 0;
		for (i in 0...sizes.length) {
			if (sizes[i] > 4) {
				var size = sizes[i];
				var addonOffset = 0;
				while (size > 0) {
					size -= 4;
					addonOffset += 4 * 4;
					++attributesOffset;
				}
			}
			else {
				++attributesOffset;
			}
		}
		return attributesOffset;
	}
}

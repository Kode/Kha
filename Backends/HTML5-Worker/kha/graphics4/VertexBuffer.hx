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
	var lockStart: Int = -1;
	var lockEnd: Int = -1;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		this.usage = usage;
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
			}
		}
	
		_data = new Float32Array(Std.int(vertexCount * myStride / 4));
		
		sizes = new Array<Int>();
		offsets = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;
		
		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size;
			switch (element.data) {
			case Float1:
				size = 1;
			case Float2:
				size = 2;
			case Float3:
				size = 3;
			case Float4:
				size = 4;
			case Float4x4:
				size = 4 * 4;
			}
			sizes[index] = size;
			offsets[index] = offset;
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
			}
			++index;
		}
		
		_id = ++lastId;
		var elements = new Array<Dynamic>();
		for (element in structure.elements) {
			elements.push({
				name: element.name,
				data: element.data.getIndex()
			});
		}
		Worker.postMessage({ command: 'createVertexBuffer', id: _id, size: vertexCount, structure: {elements: elements}, usage: usage.getIndex()});
	}

	public function delete(): Void {
		_data = null;
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		if (start == null) start = 0;
		if (count == null) count = mySize;
		if (lockStart < 0 || lockStart > start) {
			lockStart = start;
		}
		if (lockEnd < 0 || lockEnd < start + count) {
			lockEnd = start + count;
		}
		return _data.subarray(start * stride(), (start + count) * stride());
	}
	
	public function unlock(): Void {
		if (lockEnd > lockStart) {
			var start = lockStart;
			var count = lockEnd - lockStart;
			Worker.postMessage({ command: 'updateVertexBuffer', id: _id, data: _data.subarray(start * stride(), (start + count) * stride()).data(), start: start, count: count });
		}
		lockStart = lockEnd = -1;
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

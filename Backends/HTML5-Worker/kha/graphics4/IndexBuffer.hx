package kha.graphics4;

import kha.arrays.Uint32Array;
import kha.graphics4.Usage;

class IndexBuffer {
	static var lastId: Int = -1;

	public var _id: Int;
	public var _data: Uint32Array;

	var mySize: Int;
	var usage: Usage;
	var lockStart: Int = 0;
	var lockEnd: Int = 0;

	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = indexCount;
		_data = new Uint32Array(indexCount);
		_id = ++lastId;
		Worker.postMessage({
			command: 'createIndexBuffer',
			id: _id,
			size: indexCount,
			usage: usage
		});
	}

	public function delete(): Void {
		_data = null;
	}

	public function lock(?start: Int, ?count: Int): Uint32Array {
		lockStart = start != null ? start : 0;
		lockEnd = count != null ? start + count : mySize;
		return _data.subarray(lockStart, lockEnd);
	}

	public function unlock(?count: Int): Void {
		if (count != null)
			lockEnd = lockStart + count;
		Worker.postMessage({command: 'updateIndexBuffer', id: _id, data: _data.subarray(lockStart, lockEnd).data()});
	}

	public function set(): Void {}

	public function count(): Int {
		return mySize;
	}
}

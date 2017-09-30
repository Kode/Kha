package kha.graphics4;

import kha.arrays.Uint32Array;
import kha.graphics4.Usage;

class IndexBuffer {
	static var lastId: Int = -1;
	public var _id: Int;
	public var _data: Uint32Array;
	private var mySize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = indexCount;
		_data = new Uint32Array(indexCount);
		_id = ++lastId;
		Worker.postMessage({ command: 'createIndexBuffer', id: _id, size: indexCount, usage: usage.getIndex() });
	}
	
	public function delete(): Void {
		_data = null;
	}
	
	public function lock(?start: Int, ?count: Int): Uint32Array {
		if (start == null) start = 0;
		if (count == null) count = mySize;
		return _data.subarray(start, start + count);
	}
	
	public function unlock(): Void {
		Worker.postMessage({ command: 'updateIndexBuffer', id: _id, data: _data.data() });
	}
	
	public function set(): Void {

	}
	
	public function count(): Int {
		return mySize;
	}
}

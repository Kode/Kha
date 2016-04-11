package kha.graphics4;

import haxe.io.Bytes;
import haxe.io.BytesData;

class IndexBuffer {
	public var _buffer: Pointer;
	private var data: Array<Int>;
	private var myCount: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
		init(indexCount);
	}
	
	private function init(count: Int) {
		_buffer = kore_create_indexbuffer(count);
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {
		var bytes = Bytes.ofData(new BytesData(kore_indexbuffer_lock(_buffer), myCount * 4));
		for (i in 0...myCount) {
			bytes.setInt32(i * 4, data[i]);
		}
		kore_indexbuffer_unlock(_buffer);
	}
	
	public function count(): Int {
		return myCount;
	}
	
	@:hlNative("std", "kore_create_indexbuffer") static function kore_create_indexbuffer(count: Int): Pointer { return null; }
	@:hlNative("std", "kore_indexbuffer_lock") static function kore_indexbuffer_lock(buffer: Pointer): hl.types.Bytes { return null; }
	@:hlNative("std", "kore_indexbuffer_unlock") static function kore_indexbuffer_unlock(buffer: Pointer): Void { }
}

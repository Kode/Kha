package kha;

import haxe.io.Bytes;

class Blob {
	var bytes : Bytes;
	var position : Int;
	
	public function new(bytes : Bytes) {
		this.bytes = bytes;
		position = 0;
	}
	
	public function readByte() : Int {
		var byte = bytes.get(position);
		++position;
		return byte;
	}
	
	public function readUInt16LE() : Int {
		var second = bytes.get(position + 0);
		var first  = bytes.get(position + 1);
		position += 2;
		return first * 256 + second;
	}

	public function readInt() : Int {
		var fourth = bytes.get(position + 0);
		var third  = bytes.get(position + 1);
		var second = bytes.get(position + 2);
		var first  = bytes.get(position + 3);
		position += 4;
		return first + second * 256 + third * 256 * 256 + fourth * 256 * 256 * 256;
	}
}
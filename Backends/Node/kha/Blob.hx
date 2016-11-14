package kha;

import haxe.io.Bytes;
import js.node.Buffer;

class Blob implements Resource {
	private var buffer: Buffer;
	
	private function new(bytes: Bytes) {
		if (bytes != null) {
			buffer = new Buffer(bytes.length);
			for (i in 0...bytes.length) {
				buffer.writeUInt8(bytes.get(i), i);
			}
		}
	}
	
	public static function fromBytes(bytes: Bytes): Blob {
		return new Blob(bytes);
	}
	
	public static function alloc(size: Int): Blob {
		var blob = new Blob(null);
		var array = new Array();
		array[size - 1] = 0;
		blob.buffer = new Buffer(array);
		return blob;
	}
	
	@:noCompletion
	public static function _fromBuffer(buffer: Buffer): Blob {
		var blob = new Blob(null);
		blob.buffer = buffer;
		return blob;
	}
	
	public function sub(start: Int, length: Int): Blob {
		return _fromBuffer(buffer.slice(start, start + length));
	}
	
	public var length(get, null): Int;
	
	public function get_length(): Int {
		return buffer.length;
	}
	
	public function writeU8(position: Int, value: Int): Void {
		buffer.writeUInt8(value, position);
	}
	
	public function readU8(position: Int): Int {
		var byte = buffer.readUInt8(position);
		++position;
		return byte;
	}
	
	public function readS8(position: Int): Int {
		var byte = buffer.readInt8(position);
		++position;
		return byte;
	}
	
	public function readU16BE(position: Int): Int {
		var value = buffer.readUInt16BE(position);
		position += 2;
		return value;
	}
	
	public function readU16LE(position: Int): Int {
		var value = buffer.readUInt16LE(position);
		position += 2;
		return value;
	}
	
	public function readS16BE(position: Int): Int {
		var value = buffer.readInt16BE(position);
		position += 2;
		return value;
	}
	
	public function readS16LE(position: Int): Int {
		var value = buffer.readInt16LE(position);
		position += 2;
		return value;
	}
	
	public function readS32BE(position: Int): Int {
		var value = buffer.readInt32BE(position);
		position += 4;
		return value;
	}
	
	public function readS32LE(position: Int): Int {
		var value = buffer.readInt32LE(position);
		position += 4;
		return value;
	}

	public function readF32BE(position: Int): Float {
		var value = buffer.readFloatBE(position);
		position += 4;
		return value;
	}
	
	public function readF32LE(position: Int): Float {
		var value = buffer.readFloatLE(position);
		position += 4;
		return value;
	}
	
	public function toString(): String {
		return buffer.toString();
	}
	
	public function readUtf8String(): String {
		return toString();
	}
	
	public function unload(): Void {
		buffer = null;
	}
}

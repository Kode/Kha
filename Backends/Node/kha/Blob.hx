package kha;

import haxe.io.Bytes;
import js.node.Buffer;

class Blob implements Resource {
	private var buffer: Buffer;
	
	public function new(bytes: Bytes) {
		if (bytes != null) {
			buffer = new Buffer(bytes.length);
			for (i in 0...bytes.length) {
				buffer.writeUInt8(bytes.get(i), i);
			}
		}
		position = 0;
	}
	
	public static function fromBuffer(buffer: Buffer): Blob {
		var blob = new Blob(null);
		blob.buffer = buffer;
		return blob;
	}
	
	public function length() {
		return buffer.length;
	}
	
	public function reset() {
		position = 0;
	}
	
	public function seek(pos: Int): Void {
		position = pos;
	}
	
	public var position(default, null): Int;
	
	public function readU8(): Int {
		var byte = buffer.readUInt8(position);
		++position;
		return byte;
	}
	
	public function readS8(): Int {
		var byte = buffer.readInt8(position);
		++position;
		return byte;
	}
	
	public function readU16BE(): Int {
		var value = buffer.readUInt16BE(position);
		position += 2;
		return value;
	}
	
	public function readU16LE(): Int {
		var value = buffer.readUInt16LE(position);
		position += 2;
		return value;
	}
	
	public function readS16BE(): Int {
		var value = buffer.readInt16BE(position);
		position += 2;
		return value;
	}
	
	public function readS16LE(): Int {
		var value = buffer.readInt16LE(position);
		position += 2;
		return value;
	}
	
	public function readS32BE(): Int {
		var value = buffer.readInt32BE(position);
		position += 4;
		return value;
	}
	
	public function readS32LE(): Int {
		var value = buffer.readInt32LE(position);
		position += 4;
		return value;
	}

	public function readF32BE(): Float {
		var value = buffer.readFloatBE(position);
		position += 4;
		return value;
	}
	
	public function readF32LE(): Float {
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

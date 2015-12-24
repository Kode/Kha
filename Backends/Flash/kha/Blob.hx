package kha;

import flash.utils.Endian;
import haxe.io.Bytes;
import haxe.io.BytesData;

class Blob implements Resource {
	public var bytes: BytesData;
	
	@:allow(kha.LoaderImpl)
	private function new(bytes: BytesData) {
		this.bytes = bytes;
	}
	
	public static function fromBytes(bytes: Bytes): Blob {
		return new Blob(bytes.getData());
	}
	
	public static function alloc(size: Int): Blob {
		var b = new BytesData();
		b.length = size;
		return new Blob(b);
	}
	
	public function sub(start: Int, length: Int): Blob {
		var b = new BytesData();
		bytes.position = start;
		bytes.readBytes(b, 0, length);
		return new Blob(b);
	}
	
	public var length(get, null): Int;
	
	public function get_length(): Int {
		return bytes.length;
	}
	
	public function writeU8(position: Int, value: Int): Void {
		bytes[position] = value;
	}
	
	private function le(): Void {
		bytes.endian = Endian.LITTLE_ENDIAN;
	}
	
	private function be(): Void {
		bytes.endian = Endian.BIG_ENDIAN;
	}
	
	public function readS8(position: Int): Int {
		bytes.position = position;
		return bytes.readByte();
	}
	
	public function readU8(position: Int): Int {
		bytes.position = position;
		var value = bytes.readUnsignedByte();
		return value;
	}
		
	public function readS16LE(position: Int): Int {
		le();
		bytes.position = position;
		return bytes.readShort();
	}
	
	public function readS16BE(position: Int): Int {
		be();
		bytes.position = position;
		return bytes.readShort();
	}
	
	public function readU16LE(position: Int): Int {
		le();
		bytes.position = position;
		return bytes.readUnsignedShort();
	}
	
	public function readU16BE(position: Int): Int {
		be();
		bytes.position = position;
		return bytes.readUnsignedShort();
	}

	public function readS32LE(position: Int): Int {
		le();
		bytes.position = position;
		return bytes.readInt();
	}
	
	public function readS32BE(position: Int): Int {
		be();
		bytes.position = position;
		return bytes.readInt();
	}
	
	public function readU32LE(position: Int): Int {
		le();
		bytes.position = position;
		return bytes.readUnsignedInt();
	}
	
	public function readU32BE(position: Int): Int {
		be();
		bytes.position = position;
		return bytes.readUnsignedInt();
	}
	
	public function readF32LE(position: Int): Float {
		le();
		bytes.position = position;
		return bytes.readFloat();
	}
	
	public function readF32BE(position: Int): Float {
		be();
		bytes.position = position;
		return bytes.readFloat();
	}
	
	public function readF64LE(position: Int): Float {
		le();
		bytes.position = position;
		return bytes.readDouble();
	}
	
	public function readF64BE(position: Int): Float {
		be();
		bytes.position = position;
		return bytes.readDouble();
	}
	
	public function toString(): String {
		bytes.position = 0;
		return bytes.toString();
	}
		
	public function unload(): Void {
		bytes = null;
	}
}

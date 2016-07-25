package kha;

import flash.utils.Endian;
import haxe.io.Bytes;
import haxe.io.BytesData;

class Blob implements Resource {
	var bytesData: BytesData;
	
	public var bytes(get, never):Bytes;
	function get_bytes() {
		return Bytes.ofData(bytesData);
	}
	
	@:allow(kha.LoaderImpl)
	private function new(bytes: BytesData) {
		this.bytesData = bytes;
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
		bytesData.position = start;
		bytesData.readBytes(b, 0, length);
		return new Blob(b);
	}
	
	public var length(get, null): Int;
	
	public function get_length(): Int {
		return bytesData.length;
	}
	
	public function writeU8(position: Int, value: Int): Void {
		bytesData[position] = value;
	}
	
	private function le(): Void {
		bytesData.endian = Endian.LITTLE_ENDIAN;
	}
	
	private function be(): Void {
		bytesData.endian = Endian.BIG_ENDIAN;
	}
	
	public function readS8(position: Int): Int {
		bytesData.position = position;
		return bytesData.readByte();
	}
	
	public function readU8(position: Int): Int {
		bytesData.position = position;
		var value = bytesData.readUnsignedByte();
		return value;
	}
		
	public function readS16LE(position: Int): Int {
		le();
		bytesData.position = position;
		return bytesData.readShort();
	}
	
	public function readS16BE(position: Int): Int {
		be();
		bytesData.position = position;
		return bytesData.readShort();
	}
	
	public function readU16LE(position: Int): Int {
		le();
		bytesData.position = position;
		return bytesData.readUnsignedShort();
	}
	
	public function readU16BE(position: Int): Int {
		be();
		bytesData.position = position;
		return bytesData.readUnsignedShort();
	}

	public function readS32LE(position: Int): Int {
		le();
		bytesData.position = position;
		return bytesData.readInt();
	}
	
	public function readS32BE(position: Int): Int {
		be();
		bytesData.position = position;
		return bytesData.readInt();
	}
	
	public function readU32LE(position: Int): Int {
		le();
		bytesData.position = position;
		return bytesData.readUnsignedInt();
	}
	
	public function readU32BE(position: Int): Int {
		be();
		bytesData.position = position;
		return bytesData.readUnsignedInt();
	}
	
	public function readF32LE(position: Int): Float {
		le();
		bytesData.position = position;
		return bytesData.readFloat();
	}
	
	public function readF32BE(position: Int): Float {
		be();
		bytesData.position = position;
		return bytesData.readFloat();
	}
	
	public function readF64LE(position: Int): Float {
		le();
		bytesData.position = position;
		return bytesData.readDouble();
	}
	
	public function readF64BE(position: Int): Float {
		be();
		bytesData.position = position;
		return bytesData.readDouble();
	}
	
	public function toString(): String {
		bytesData.position = 0;
		return bytesData.toString();
	}
		
	public function unload(): Void {
		bytesData = null;
	}
}

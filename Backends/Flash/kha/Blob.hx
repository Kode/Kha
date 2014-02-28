package kha;

import flash.utils.Endian;
import haxe.io.Bytes;
import haxe.io.BytesData;

class Blob implements Resource {
	public var bytes: BytesData;
	
	public function new(bytes: Bytes) {
		this.bytes = bytes.getData();
	}
	
	public var position(get, null): Int;
	
	public function get_position(): Int {
		return bytes.position;
	}
	
	public function seek(pos: Int): Void {
		bytes.position = pos;
	}
	
	private function le(): Void {
		bytes.endian = Endian.LITTLE_ENDIAN;
	}
	
	private function be(): Void {
		bytes.endian = Endian.BIG_ENDIAN;
	}
	
	public function length() {
		return bytes.length;
	}
	
	public function reset() {
		bytes.position = 0;
	}
	
	public function readS8(): Int {
		return bytes.readByte();
	}
	
	public function readU8(): UInt {
		return bytes.readUnsignedByte();
	}
		
	public function readS16LE(): Int {
		le();
		return bytes.readShort();
	}
	
	public function readS16BE(): Int {
		be();
		return bytes.readShort();
	}
	
	public function readU16LE(): UInt {
		le();
		return bytes.readUnsignedShort();
	}
	
	public function readU16BE(): UInt {
		be();
		return bytes.readUnsignedShort();
	}

	public function readS32LE(): Int {
		le();
		return bytes.readInt();
	}
	
	public function readS32BE(): Int {
		be();
		return bytes.readInt();
	}
	
	public function readU32LE(): UInt {
		le();
		return bytes.readUnsignedInt();
	}
	
	public function readU32BE(): UInt {
		be();
		return bytes.readUnsignedInt();
	}
	
	public function readF32LE(): Float {
		le();
		return bytes.readFloat();
	}
	
	public function readF32BE(): Float {
		be();
		return bytes.readFloat();
	}
	
	public function readF64LE(): Float {
		le();
		return bytes.readDouble();
	}
	
	public function readF64BE(): Float {
		be();
		return bytes.readDouble();
	}
	
	public function toString(): String {
		return bytes.toString();
	}
		
	public function unload(): Void {
		bytes = null;
	}
}

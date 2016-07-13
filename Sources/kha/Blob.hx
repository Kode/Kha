package kha;

extern class Blob implements Resource {
	public static function fromBytes(bytes: Bytes): Blob;
	
	public static function alloc(size: Int): Blob;
	
	public function sub(start: Int, length: Int): Blob;
	
	public var length(get, null): Int;
	
	public function writeU8(position: Int, value: Int): Void;
	
	public function readU8(position: Int): Int;
	
	public function readS8(position: Int): Int;
	
	public function readU16BE(position: Int): Int;
	
	public function readU16LE(position: Int): Int;
	
	public function readU32LE(position: Int): Int;

	public function readU32BE(position: Int): Int;
	
	public function readS16BE(position: Int): Int;
	
	public function readS16LE(position: Int): Int;
	
	public function readS32LE(position: Int): Int;

	public function readS32BE(position: Int): Int;
	
	public function readF32LE(position: Int): Float;
	
	public function readF32BE(position: Int): Float;
	
	private static function readF32(i: Int): Float;
	
	public function toString(): String;
	
	public function readUtf8String(): String;
	
	public function toBytes(): Bytes;
	
	public function unload(): Void;
}

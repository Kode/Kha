package kha;

import haxe.io.Bytes;

@:headerCode('
#include <Kore/pch.h>
')

class Blob {
	private var bytes: Bytes;
	
	@:allow(kha.LoaderImpl)
	private function new(bytes: Bytes) {
		this.bytes = bytes;
	}
	
	public static function fromBytes(bytes: Bytes): Blob {
		return new Blob(bytes);
	}
	
	public static function alloc(size: Int): Blob {
		return new Blob(Bytes.alloc(size));
	}
	
	public function sub(start: Int, length: Int): Blob {
		return new Blob(bytes.sub(start, length));
	}
	
	public var length(get, null): Int;
	
	public function get_length(): Int {
		return bytes.length;
	}
	
	public function writeU8(position: Int, value: Int): Void {
		bytes.set(position, value);
	}
	
	@:functionCode('
		Kore::s8 i = *(Kore::s8*)&bytes->b->Pointer()[position];
		position += 1;
		return i;
	')
	public function readS8(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8 i = *(Kore::u8*)&bytes->b->Pointer()[position];
		position += 1;
		return i;
	')
	public function readU8(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::s16 i = (data[0] << 0) | (data[1] << 8);
		position += 2;
		return i;
	')
	public function readS16LE(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::s16 i = (data[1] << 0) | (data[0] << 8);
		position += 2;
		return i;
	')
	public function readS16BE(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::u16 i = (data[0] << 0) | (data[1] << 8);
		position += 2;
		return i;
	')
	public function readU16LE(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::u16 i = (data[1] << 0) | (data[0] << 8);
		position += 2;
		return i;
	')
	public function readU16BE(position: Int): Int {
		return 0;
	}

	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[0] << 0) | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
		position += 4;
		return i;
	')
	public function readS32LE(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[3] << 0) | (data[2] << 8) | (data[1] << 16) | (data[0] << 24);
		position += 4;
		return i;
	')
	public function readS32BE(position: Int): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::u32 i = (data[0] << 0) | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
		position += 4;
		return i;
	')
	public function readU32LE(position: Int): UInt {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::u32 i = (data[3] << 0) | (data[2] << 8) | (data[1] << 16) | (data[0] << 24);
		position += 4;
		return i;
	')
	public function readU32BE(position: Int): UInt {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[0] << 0) | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
		position += 4;
		return *(float*)&i;
	')
	public function readF32LE(position: Int): Float {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[3] << 0) | (data[2] << 8) | (data[1] << 16) | (data[0] << 24);
		position += 4;
		return *(float*)&i;
	')
	public function readF32BE(position: Int): Float {
		return 0;
	}
	
	public function readF64LE(position: Int): Float {
		return 0;
	}
	
	public function readF64BE(position: Int): Float {
		return 0;
	}
	
	public function toString(): String {
		if (bytes.get(0) == 239 && bytes.get(1) == 187 && bytes.get(2) == 191) return bytes.sub(3, bytes.length - 3).toString();
		else return bytes.toString();
	}

	public function toBytes(): Bytes {
		return bytes;
	}
		
	public function unload(): Void {
		bytes = null;
	}
}

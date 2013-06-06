package kha;

import haxe.io.Bytes;

@:headerCode('
#include <Kore/pch.h>
')

class Blob {
	private var bytes: Bytes;
	private var position: Int;
	
	public function new(bytes: Bytes) {
		this.bytes = bytes;
		position = 0;
	}
	
	public function toBytes(): Bytes {
		return bytes;
	}
	
	public function length() {
		return bytes.length;
	}
	
	public function reset() {
		position = 0;
	}
	
	@:functionCode('
		Kore::s8 i = *(Kore::s8*)&bytes->b->Pointer()[position];
		position += 1;
		return i;
	')
	public function readS8(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8 i = *(Kore::u8*)&bytes->b->Pointer()[position];
		position += 1;
		return i;
	')
	public function readU8(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::s16 i = (data[0] << 0) | (data[1] << 8);
		position += 2;
		return i;
	')
	public function readS16LE(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::s16 i = (data[1] << 0) | (data[0] << 8);
		position += 2;
		return i;
	')
	public function readS16BE(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::u16 i = (data[0] << 0) | (data[1] << 8);
		position += 2;
		return i;
	')
	public function readU16LE(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		Kore::u16 i = (data[1] << 0) | (data[0] << 8);
		position += 2;
		return i;
	')
	public function readU16BE(): Int {
		return 0;
	}

	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[0] << 0) | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
		position += 4;
		return i;
	')
	public function readS32LE(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[3] << 0) | (data[2] << 8) | (data[1] << 16) | (data[0] << 24);
		position += 4;
		return i;
	')
	public function readS32BE(): Int {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[0] << 0) | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
		position += 4;
		return *(float*)&i;
	')
	public function readF32LE(): Float {
		return 0;
	}
	
	@:functionCode('
		Kore::u8* data = (Kore::u8*)&bytes->b->Pointer()[position];
		int i = (data[3] << 0) | (data[2] << 8) | (data[1] << 16) | (data[0] << 24);
		position += 4;
		return *(float*)&i;
	')
	public function readF32BE(): Float {
		return 0;
	}
	
	public function readF64LE(): Float {
		return 0;
	}
	
	public function readF64BE(): Float {
		return 0;
	}
	
	public function toString(): String {
		return bytes.toString();
	}
		
	public function unload(): Void {
		bytes = null;
	}
}

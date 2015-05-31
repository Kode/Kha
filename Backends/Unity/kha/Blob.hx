package kha;

import haxe.io.Bytes;

class Blob implements Resource {
	private var bytes: Bytes;
	
	public var position: Int;
	
	public function new(bytes: Bytes) {
		this.bytes = bytes;
		position = 0;
	}
	
	public function length(): Int {
		return bytes.length;
	}
	
	public function reset(): Void {
		position = 0;
	}
	
	public function seek(pos: Int): Void {
		position = pos;
	}
	
	public function readU8(): Int {
		var byte = bytes.get(position);
		++position;
		return byte;
	}
	
	public function readS8(): Int {
		var byte = bytes.get(position);
		++position;
		var sign = (byte & 0x80) == 0 ? 1 : -1;
		byte = byte & 0x7F;
		return sign * byte;
	}
	
	public function readU16BE(): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		position += 2;
		return first * 256 + second;
	}
	
	public function readU16LE(): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		position += 2;
		return second * 256 + first;
	}
	
	public function readS16BE(): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		position += 2;
		var sign = (first & 0x80) == 0 ? 1 : -1;
		first = first & 0x7F;
		if (sign == -1) return -0x7fff + first * 256 + second;
		else return first * 256 + second;
	}
	
	public function readS16LE(): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		var sign = (second & 0x80) == 0 ? 1 : -1;
		second = second & 0x7F;
		position += 2;
		if (sign == -1) return -0x7fff + second * 256 + first;
		else return second * 256 + first;
	}
	
	public function readS32LE(): Int {
		var fourth = bytes.get(position + 0);
		var third  = bytes.get(position + 1);
		var second = bytes.get(position + 2);
		var first  = bytes.get(position + 3);
		var sign = (first & 0x80) == 0 ? 1 : -1;
		first = first & 0x7F;
		position += 4;
		if (sign == -1) return -0x7fffffff + fourth + third * 256 + second * 256 * 256 + first * 256 * 256 * 256;
		else return fourth + third * 256 + second * 256 * 256 + first * 256 * 256 * 256;
	}

	public function readS32BE(): Int {
		var fourth = bytes.get(position + 0);
		var third  = bytes.get(position + 1);
		var second = bytes.get(position + 2);
		var first  = bytes.get(position + 3);
		var sign = (fourth & 0x80) == 0 ? 1 : -1;
		fourth = fourth & 0x7F;
		position += 4;
		if (sign == -1) return -0x7fffffff + first + second * 256 + third * 256 * 256 + fourth * 256 * 256 * 256;
		return first + second * 256 + third * 256 * 256 + fourth * 256 * 256 * 256;
	}
	
	public function readF32LE(): Float {
		return readF32(readS32LE());		
	}
	
	public function readF32BE(): Float {
		return readF32(readS32BE());		
	}
	
	private function readF32(i: Int): Float {
		var sign: Float = ((i & 0x80000000) == 0) ? 1 : -1;
		var exp: Int = ((i >> 23) & 0xFF);
		var man: Int = (i & 0x7FFFFF);
		switch (exp) {
			case 0:
				//zero, do nothing, ignore negative zero and subnormals
				return 0.0;
			case 0xFF:
				if (man != 0) return Math.NaN;
				else if (sign > 0) return Math.POSITIVE_INFINITY;
				else return Math.NEGATIVE_INFINITY;
			default:
				return sign * ((man + 0x800000) / 8388608.0) * Math.pow(2, exp - 127);
		}
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

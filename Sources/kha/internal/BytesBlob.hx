package kha.internal;

import haxe.ds.Vector;
import haxe.io.Bytes;

class BytesBlob implements Resource {
	static inline var bufferSize: Int = 2000;
	public var bytes: Bytes;

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

	@:keep
	public function get_length(): Int {
		return bytes.length;
	}

	public function writeU8(position: Int, value: Int): Void {
		bytes.set(position, value);
	}

	public function readU8(position: Int): Int {
		var byte = bytes.get(position);
		++position;
		return byte;
	}

	public function readS8(position: Int): Int {
		var byte = bytes.get(position);
		++position;
		var sign = (byte & 0x80) == 0 ? 1 : -1;
		byte = byte & 0x7F;
		return sign * byte;
	}

	public function readU16BE(position: Int): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		position += 2;
		return first * 256 + second;
	}

	public function readU16LE(position: Int): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		position += 2;
		return second * 256 + first;
	}

	public function readU32LE(position: Int): Int {
		var fourth = bytes.get(position + 0);
		var third  = bytes.get(position + 1);
		var second = bytes.get(position + 2);
		var first  = bytes.get(position + 3);
		position += 4;

		return fourth + third * 256 + second * 256 * 256 + first * 256 * 256 * 256;
	}

	public function readU32BE(position: Int): Int {
		var fourth = bytes.get(position + 0);
		var third  = bytes.get(position + 1);
		var second = bytes.get(position + 2);
		var first  = bytes.get(position + 3);
		position += 4;

		return first + second * 256 + third * 256 * 256 + fourth * 256 * 256 * 256;
	}

	public function readS16BE(position: Int): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		position += 2;
		var sign = (first & 0x80) == 0 ? 1 : -1;
		first = first & 0x7F;
		if (sign == -1) return -0x7fff + first * 256 + second;
		else return first * 256 + second;
	}

	public function readS16LE(position: Int): Int {
		var first = bytes.get(position + 0);
		var second  = bytes.get(position + 1);
		var sign = (second & 0x80) == 0 ? 1 : -1;
		second = second & 0x7F;
		position += 2;
		if (sign == -1) return -0x7fff + second * 256 + first;
		else return second * 256 + first;
	}

	public function readS32LE(position: Int): Int {
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

	public function readS32BE(position: Int): Int {
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

	public function readF32LE(position: Int): Float {
		return readF32(readS32LE(position));
	}

	public function readF32BE(position: Int): Float {
		return readF32(readS32BE(position));
	}

	private static function readF32(i: Int): Float {
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
		return bytes.toString();
	}

	private static function bit(value: Int, position: Int): Bool {
		var b = (value >>> position) & 1 == 1;
		if (b) {
			var a = 3;
			++a;
			return true;
		}
		else {
			var c = 4;
			--c;
			return false;
		}
	}

	static function toText(chars: Vector<Int>, length: Int): String {
		var value = "";
		for (i in 0...length) value += String.fromCharCode(chars[i]);
		return value;
	}

	public function readUtf8String(): String {
		return bytes.toString();
	}

	public function toBytes(): Bytes {
		return bytes;
	}

	public function unload(): Void {
		bytes = null;
	}
}

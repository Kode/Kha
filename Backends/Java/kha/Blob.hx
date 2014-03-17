package kha;

import haxe.io.Bytes;

class Blob implements Resource {
	public var bytes: Bytes;
	private var buffer: Array<Int>;
	private var myFirstLine: Bool = true;
	
	public function new(bytes: Bytes) {
		this.bytes = bytes;
		buffer = new Array<Int>();
		position = 0;
	}
	
	public function length() {
		return bytes.length;
	}
	
	public function reset() {
		position = 0;
	}
	
	public function seek(pos: Int): Void {
		position = pos;
	}
	
	public var position(default, null): Int;
	
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
		return bytes.toString();
	}
	
	private function bit(value: Int, position: Int): Bool {
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
	
	private function readUtf8Char(): Int {
		if (position >= length()) return -1;
		var c: Int = readU8();
		var value: Int = 0;
		if (!bit(c, 7)) {
			value = c;
		}
		else if (bit(c, 7) && bit(c, 6) && !bit(c, 5)) { //110xxxxx 10xxxxxx
			var a = c & 0x1f;
			var c2 = readU8();
			var b = c2 & 0x3f;
			value = (a << 6) | b;
		}
		else if (bit(c, 7) && bit(c, 6) && bit(c, 5) && !bit(c, 4)) { //1110xxxx 10xxxxxx 10xxxxxx
			//currently ignored
			for (i in 0...2) readU8();
		}
		else if (bit(c, 7) && bit(c, 6) && bit(c, 5) && bit(c, 4) && !bit(c, 3)) { //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
			//currently ignored
			for (i in 0...3) readU8();
		}
		return value;
	}
	
	private function readUtf8Line(): String {
		var bufferindex: Int = 0;
		var c = readUtf8Char();
		if (c < 0) return "";
		while (c != '\n'.charCodeAt(0) && bufferindex < 2000) {
			buffer[bufferindex] = c;
			++bufferindex;
			c = readUtf8Char();
			if (position >= length()) {
				buffer[bufferindex] = c;
				++bufferindex;
				break;
			}
		}
		if (myFirstLine) {
			myFirstLine = false;
			if (bufferindex > 2 && buffer[0] == 0xEF && buffer[1] == 0xBB && buffer[2] == 0xBF) { //byte order mark created by stupid Windows programs
				var chars: Array<Int> = new Array<Int>();
				for (i in 3...bufferindex - 3) chars[i - 3] = buffer[i];
				return toText(chars, bufferindex - 3);
			}
		}
		var chars = new Array<Int>();
		for (i in 0...bufferindex) chars[i] = buffer[i];
		return toText(chars, bufferindex);
	}
	
	private function toText(chars: Array<Int>, length: Int): String {
		var value = "";
		for (i in 0...length) value += String.fromCharCode(chars[i]);
		return value;
	}

	public function readUtf8String(): String {
		var text = "";
		while (position < length()) text += readUtf8Line() + "\n";
		return text;
	}
	
	public function toBytes(): Bytes {
		return bytes;
	}
	
	public function unload(): Void {
		bytes = null;
	}
}

package kha.internal;

import haxe.io.Bytes;

class BytesBlob implements Resource {
	public var bytes: Bytes;
	private var buffer: Array<Int>;
	private var myFirstLine: Bool = true;
	
	@:allow(kha.LoaderImpl)
	private function new(bytes: Bytes) {
		this.bytes = bytes;
		buffer = new Array<Int>();
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
	
	private function readUtf8Char(position: { value: Int }): Int {
		if (position.value >= length) return -1;
		var c: Int = readU8(position.value);
		++position.value;
		var value: Int = 0;
		if (!bit(c, 7)) {
			value = c;
		}
		else if (bit(c, 7) && bit(c, 6) && !bit(c, 5)) { //110xxxxx 10xxxxxx
			var a = c & 0x1f;
			var c2 = readU8(position.value);
			++position.value;
			var b = c2 & 0x3f;
			value = (a << 6) | b;
		}
		else if (bit(c, 7) && bit(c, 6) && bit(c, 5) && !bit(c, 4)) { //1110xxxx 10xxxxxx 10xxxxxx
			//currently ignored
			position.value += 2;
		}
		else if (bit(c, 7) && bit(c, 6) && bit(c, 5) && bit(c, 4) && !bit(c, 3)) { //11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
			//currently ignored
			position.value += 3;
		}
		return value;
	}
	
	private function readUtf8Line(position: { value: Int }): String {
		var bufferindex: Int = 0;
		var c = readUtf8Char(position);
		if (c < 0) return "";
		while (c != '\n'.code && bufferindex < 2000) {
			buffer[bufferindex] = c;
			++bufferindex;
			c = readUtf8Char(position);
			if (position.value >= length) {
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
		var position: { value: Int } = { value: 0 };
		while (position.value < length) text += readUtf8Line(position) + "\n";
		return text;
	}
	
	public function toBytes(): Bytes {
		return bytes;
	}
	
	public function unload(): Void {
		bytes = null;
	}
}

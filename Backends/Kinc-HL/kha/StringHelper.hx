package kha;

@:access(String)
class StringHelper {
	public static inline function convert(s: String): hl.Bytes {
		var size = 0;
		return s.bytes.utf16ToUtf8(0, size);
	}

	public static inline function fromBytes(bytes: hl.Bytes): String {
		var s = "";
		var size = 0;
		s.bytes = bytes.utf8ToUtf16(0, size);
		s.length = Std.int(size / 2);
		return s;
	}
}

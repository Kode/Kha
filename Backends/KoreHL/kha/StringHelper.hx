package kha;

@:access(String)
class StringHelper {
	public static inline function convert(s: String) {
		var size = 0;
		return s.bytes.utf16ToUtf8(0, size);
	}
}

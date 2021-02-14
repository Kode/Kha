package kha.arrays;

/**
 * Holds unformatted binary data into a byte buffer. Use ByteArray for access.
 */
extern class ByteBuffer {
	var byteLength(get, null): Int;
	function new(length: Int): Void;

	/**
	 * Returns a shallow copy of a range of bytes from this buffer.
	 * @param begin start of the range, inclusive
	 * @param end end of the range, exclusive ; defaults to whole buffer
	 * @return ByteBuffer
	 */
	function slice(begin: Int, ?end: Int): ByteBuffer;
}

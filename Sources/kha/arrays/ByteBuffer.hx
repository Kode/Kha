package kha.arrays;

/**
 * Holds unformatted binary data into a byte buffer. Use ByteArray for access.
 */
extern class ByteBuffer {
	public static function create(length: Int): ByteBuffer;

	public var byteLength(get, null): Int;

	/**
	 * Returns a shallow copy of a range of bytes from this buffer.
	 * @param begin start of the range, inclusive
	 * @param end end of the range, exclusive
	 * @return ByteBuffer
	 */
	public function slice(begin: Int, end: Int): ByteBuffer;
}

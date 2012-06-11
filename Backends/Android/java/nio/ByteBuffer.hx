package java.nio;

extern class ByteBuffer extends Buffer {
	public static function allocateDirect(size : Int) : Buffer;
}
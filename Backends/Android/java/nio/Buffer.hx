package java.nio;

extern class Buffer {
	public function order(o : Int) : Buffer;
	public function asFloatBuffer() : FloatBuffer;
	public function asIntBuffer() : IntBuffer;
	public function capacity() : Int;
}
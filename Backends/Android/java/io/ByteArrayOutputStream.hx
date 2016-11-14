package java.io;
import java.NativeArray;
import java.types.Int8;

extern class ByteArrayOutputStream extends InputStream {
	@:overload(function(b: Int): Void {})
	function write(b: NativeArray <Int8>, off: Int, lenf: Int): Void;
	
	public function toByteArray(): NativeArray <Int8>;
	public function size(): Int;
}

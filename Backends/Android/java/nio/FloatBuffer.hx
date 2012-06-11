package java.nio;

extern class FloatBuffer extends Buffer {
	@:overload(function(index : Int, value : Single) : Void {})
	public function put(value : Single) : Void;
	public function position(pos : Int) : Void;
}
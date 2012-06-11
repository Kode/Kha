package java.util;

extern interface List<A> {
	public function add(a : A) : Void;
	public function size() : Int;
	public function get(index : Int) : A;
}
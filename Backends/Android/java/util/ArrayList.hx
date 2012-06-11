package java.util;

extern class ArrayList<A> implements java.util.List<A> {
	public function new() : Void;
	public function add(a : A) : Void;
	public function size() : Int;
	public function get(index : Int) : A;
}
package java.lang.ref;

extern class WeakReference<A> {
	public function new(a : A) : Void;
	public function get() : A;
}
package kha;

class Display {
	public static var count(get, never): Int;

	public static inline function width(index: Int): Int {
		return DisplayImpl.width(index);
	}

	public static inline function height(index: Int): Int {
		return DisplayImpl.height(index);
	}

	public static inline function x(index: Int): Int {
		return DisplayImpl.x(index);
	}

	public static inline function y(index: Int): Int {
		return DisplayImpl.y(index);
	}

	public static inline function isPrimary(index: Int): Bool {
		return DisplayImpl.isPrimary(index);
	}

	static inline function get_count(): Int {
		return DisplayImpl.count();
	}
}

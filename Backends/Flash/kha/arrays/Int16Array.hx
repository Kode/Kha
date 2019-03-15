package kha.arrays;

import flash.Vector;

@:forward(length)
abstract Int16Array(Vector<Int>) to Vector<Int> {
	public inline function new(elements: Int) {
		this = new Vector(elements);
	}

	@:arrayAccess
	public inline function set(index: Int, value: Int): Int {
		return this[index] = value;
	}

	@:arrayAccess
	public inline function get(index: Int): Int {
		return this[index];
	}
}

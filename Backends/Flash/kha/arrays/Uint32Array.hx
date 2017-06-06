package kha.arrays;

import flash.Vector;

@:forward(length)
abstract Uint32Array(Vector<UInt>) to Vector<UInt> {
	public inline function new(elements: Int) {
		this = new Vector(elements);
	}

	@:arrayAccess
	public inline function set(index: Int, value: UInt): UInt {
		return this[index] = value;
	}

	@:arrayAccess
	public inline function get(index: UInt): UInt {
		return this[index];
	}
}

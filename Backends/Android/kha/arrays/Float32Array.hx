package kha.arrays;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

abstract Float32Array(FloatBuffer) {
	private static inline var elementSize = 4;

	public inline function new(elements: Int) {
		this = FloatBuffer.allocate(elements * elementSize);
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.remaining();
	}

	public inline function set(index: Int, value: FastFloat): FastFloat {
		this.put(index, value);
		return value;
	}

	public inline function get(index: Int): FastFloat {
		return this.get(index);
	}

	public inline function data(): FloatBuffer {
		return this;
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): FastFloat {
		return this.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: FastFloat): FastFloat {
		this.put(index, value);
		return value;
	}

	//public inline function subarray(start: Int, ?end: Int): Float32Array {
	//	return cast this.subarray(start, end);
	//}
}

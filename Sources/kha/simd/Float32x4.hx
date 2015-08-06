package kha.simd;

import kha.FastFloat;

#if cpp
@:unreflective
@:structAccess
@:include("Kore/Simd/float32x4.h")
@:native("Kore::float32x4")
extern class Float32x4 {
	@:native("Kore::float32x4")
	public static function create(): Float32x4;
	
	@:native("Kore::loadAll")
	public static function loadAllFast(t: FastFloat): Float32x4;
	
	@:native("Kore::load")
	public static function load(a: Float, b: Float, c: Float, d: Float): Float32x4;
	
	@:native("Kore::load")
	public static function loadFast(a: FastFloat, b: FastFloat, c: FastFloat, d: FastFloat): Float32x4;
	
	@:native("Kore::get")
	public static function get(t: Float32x4, index: Int): Float;
	
	@:native("Kore::get")
	public static function getFast(t: Float32x4, index: Int): FastFloat;
	
	@:native("Kore::abs")
	public static function abs(t: Float32x4): Float32x4;
	
	@:native("Kore::add")
	public static function add(a: Float32x4, b: Float32x4): Float32x4;
	
	@:native("Kore::div")
	public static function div(a: Float32x4, b: Float32x4): Float32x4;
	
	@:native("Kore::mul")
	public static function mul(a: Float32x4, b: Float32x4): Float32x4;

	@:native("Kore::neg")
	public static function neg(t: Float32x4): Float32x4;
	
	@:native("Kore::reciprocalApproximation")
	public static function reciprocalApproximation(t: Float32x4): Float32x4;

	@:native("Kore::reciprocalSqrtApproximation")
	public static function reciprocalSqrtApproximation(t: Float32x4): Float32x4;

	@:native("Kore::sub")
	public static function sub(a: Float32x4, b: Float32x4): Float32x4;

	@:native("Kore::sqrt")
	public static function sqrt(t: Float32x4): Float32x4;
}
#else
class Float32x4 {
	private var _0: FastFloat;
	private var _1: FastFloat;
	private var _2: FastFloat;
	private var _3: FastFloat;
	
	private inline function new(_0: FastFloat, _1: FastFloat, _2: FastFloat, _3: FastFloat) {
		this._0 = _0;
		this._1 = _1;
		this._2 = _2;
		this._3 = _3;
	}
	
	public static inline function create(): Float32x4 {
		return new Float32x4(0, 0, 0, 0);
	}
	
	public static inline function loadAllFast(t: FastFloat): Float32x4 {
		return new Float32x4(t, t, t, t);
	}
	
	public static inline function load(a: Float, b: Float, c: Float, d: Float): Float32x4 {
		return new Float32x4(a, b, c, d);
	}
	
	public static inline function loadFast(a: FastFloat, b: FastFloat, c: FastFloat, d: FastFloat): Float32x4 {
		return new Float32x4(a, b, c, d);
	}
	
	public static inline function get(t: Float32x4, index: Int): Float {
		var value: Float = 0;
		switch (index) {
		case 0:
			value = t._0;
		case 1:
			value = t._1;
		case 2:
			value = t._2;
		case 3:
			value = t._3;
		}
		return value;
	}
	
	public static inline function getFast(t: Float32x4, index: Int): FastFloat {
		switch (index) {
		case 0:
			return t._0;
		case 1:
			return t._1;
		case 2:
			return t._2;
		case 3:
			return t._3;
		}
		return 0;
	}
	
	public static inline function abs(t: Float32x4): Float32x4 {
		return new Float32x4(Math.abs(t._0), Math.abs(t._1), Math.abs(t._2), Math.abs(t._3));
	}
	
	public static inline function add(a: Float32x4, b: Float32x4): Float32x4 {
		return new Float32x4(a._0 + b._0, a._1 + b._1, a._2 + b._2, a._3 + b._3);
	}
	
	public static inline function div(a: Float32x4, b: Float32x4): Float32x4 {
		return new Float32x4(a._0 / b._0, a._1 / b._1, a._2 / b._2, a._3 / b._3);
	}
	
	public static inline function mul(a: Float32x4, b: Float32x4): Float32x4 {
		return new Float32x4(a._0 * b._0, a._1 * b._1, a._2 * b._2, a._3 * b._3);
	}

	public static inline function neg(t: Float32x4): Float32x4 {
		return new Float32x4(-t._0, -t._1, -t._2, -t._3);
	}
	
	public static inline function reciprocalApproximation(t: Float32x4): Float32x4 {
		return new Float32x4(0, 0, 0, 0);
	}

	public static inline function reciprocalSqrtApproximation(t: Float32x4): Float32x4 {
		return new Float32x4(0, 0, 0, 0);
	}

	public static inline function sub(a: Float32x4, b: Float32x4): Float32x4 {
		return new Float32x4(a._0 - b._0, a._1 - b._1, a._2 - b._2, a._3 - b._3);
	}

	public static inline function sqrt(t: Float32x4): Float32x4 {
		return new Float32x4(Math.sqrt(t._0), Math.sqrt(t._1), Math.sqrt(t._2), Math.sqrt(t._3));
	}
}
#end
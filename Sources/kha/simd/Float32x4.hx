package kha.simd;

import kha.FastFloat;

@:unreflective
@:structAccess
@:include("Kore/Simd/float32x4.h")
@:native("Kore::float32x4")
extern class Float32x4 {
	@:native("Kore::float32x4")
	public static function create(): Float32x4;
	
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

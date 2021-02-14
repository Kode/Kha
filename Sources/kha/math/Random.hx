package kha.math;

// Small Fast Counter 32 (sfc32) PRNG implementation
// sfc32 is public domain: http://pracrand.sourceforge.net/license.txt
// Implementation derived from: https://github.com/bryc/code/blob/master/jshash/PRNGs.md
// which is also public domain

/**
	Random number generator

	Please use this one instead of the native Haxe one to
	keep consistency between different platforms.
**/
class Random {
	var a: Int;
	var b: Int;
	var c: Int;
	var d: Int;

	public function new(seed: Int): Void {
		d = seed;
		a = 0x36aef51a;
		b = 0x21d4b3eb;
		c = 0xf2517abf;
		// Immediately skip a few possibly poor results the easy way
		for (i in 0...15) {
			this.Get();
		}
	}

	public function Get(): Int {
		var t = (a + b | 0) + d | 0;
		d = d + 1 | 0;
		a = b ^ b >>> 9;
		b = c + (c << 3) | 0;
		c = c << 21 | c >>> 11;
		c = c + t | 0;
		return t & 0x7fffffff;
	}

	public function GetFloat(): Float {
		return Get() / 0x7fffffff;
	}

	public function GetUpTo(max: Int): Int {
		return Get() % (max + 1);
	}

	public function GetIn(min: Int, max: Int): Int {
		return Get() % (max + 1 - min) + min;
	}

	public function GetFloatIn(min: Float, max: Float): Float {
		return min + GetFloat() * (max - min);
	}

	public static var Default: Random;

	public static function init(seed: Int): Void {
		Default = new Random(seed);
	}

	public static function get(): Int {
		return Default.Get();
	}

	public static function getFloat(): Float {
		return Default.GetFloat();
	}

	public static function getUpTo(max: Int): Int {
		return Default.GetUpTo(max);
	}

	public static function getIn(min: Int, max: Int): Int {
		return Default.GetIn(min, max);
	}

	public static function getFloatIn(min: Float, max: Float): Float {
		return min + Default.GetFloat() * (max - min);
	}
}

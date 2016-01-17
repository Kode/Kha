package kha.math;

//
// Random number generator
//
// Please use this one instead of the native Haxe one to
// keep consistency between different platforms.
//

// Mersenne twister
class Random {
	public function new(seed: Int): Void {
		MT = new Array<Int>();
		MT[624 - 1] = 0;
		MT[0] = seed;
		for (i in 1...624) MT[i] = 0x6c078965 * (MT[i - 1] ^ (MT[i - 1] >> 30)) + i;
	}
	
	public function Get(): Int {
		if (index == 0) GenerateNumbers();

		var y: Int = MT[index];
		y = y ^ (y >> 11);
		y = y ^ ((y << 7) & (0x9d2c5680));
		y = y ^ ((y << 15) & (0xefc60000));
		y = y ^ (y >> 18);

		index = (index + 1) % 624;
		return y;
	}
	
	public function GetFloat(): Float {
		return Get() / 0x7ffffffe;
	}
	
	public function GetUpTo(max: Int): Int {
		return Get() % (max + 1);
	}
	
	public function GetIn(min: Int, max: Int): Int {
		return Get() % (max + 1 - min) + min;
	}
	
	private var MT: Array<Int>;
	private var index: Int = 0;
	
	private function GenerateNumbers(): Void {
		for (i in 0...624) {
			var y: Int = (MT[i] & 1) + (MT[(i + 1) % 624]) & 0x7fffffff;
			MT[i] = MT[(i + 397) % 624] ^ (y >> 1);
			if ((y % 2) != 0) MT[i] = MT[i] ^ 0x9908b0df;
		}
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
}

package kha;

class Color {
	/**
		Creates a new Color object from a packed 32 bit ARGB value.
	**/
	public static function fromValue(value: Int): Color {
		return new Color(value);
	}
	
	/**
		Creates a new Color object from components in the range 0 - 255.
	**/
	public static function fromBytes(r: Int, g: Int, b: Int, a: Int = 255): Color {
		return new Color((a << 24) | (r << 16) | (g << 8) | b);
	}
	
	/**
		Creates a new Color object from components in the range 0 - 1.
	**/
	public static function fromFloats(r: Float, g: Float, b: Float, a: Float = 1): Color {
		return new Color((Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255));
	}
	
	/**
		Contains a byte representing the red color component.
	**/
	public var Rb(get, never): Int;
	
	/**
		Contains a byte representing the green color component.
	**/
	public var Gb(get, never): Int;
	
	/**
		Contains a byte representing the blue color component.
	**/
	public var Bb(get, never): Int;
	
	/**
		Contains a byte representing the alpha color component (more exactly the opacity component - a value of 0 is fully transparent).
	**/
	public var Ab(get, never): Int;
	
	public var R(get, null): Float;
	public var G(get, null): Float;
	public var B(get, null): Float;
	public var A(get, null): Float;
	
	public var value(default, null): Int;
	
	private function new(value: Int) {
		this.value = value;
	}
	
	private function get_Rb(): Int {
		return (value & 0x00ff0000) >>> 16;
	}
	
	private function get_Gb(): Int {
		return (value & 0x0000ff00) >>> 8;
	}
	
	private function get_Bb(): Int {
		return value & 0x000000ff;
	}
	
	private function get_Ab(): Int {
		return value >>> 24;
	}
	
	private function get_R(): Float {
		return get_Rb() / 255;
	}
	
	private function get_G(): Float {
		return get_Gb() / 255;
	}
	
	private function get_B(): Float {
		return get_Bb() / 255;
	}
	
	private function get_A(): Float {
		return get_Ab() / 255;
	}
}
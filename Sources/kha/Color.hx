package kha;

class Color {
	/**
		Creates a new Color object from a packed 32 bit ARGB value.
	**/
	public static function fromValue(value: Int): Color {
		var color = new Color();
		color.value = value;
		return color;
	}
	
	/**
		Creates a new Color object from components in the range 0 - 255.
	**/
	public static function fromBytes(r: Int, g: Int, b: Int, a: Int = 255): Color {
		var color = new Color();
		color.value = (a << 24) | (r << 16) | (g << 8) | b;
		return color;
	}
	
	/**
		Creates a new Color object from components in the range 0 - 1.
	**/
	public static function fromFloats(r: Float, g: Float, b: Float, a: Float = 1): Color {
		var color = new Color();
		color.value = (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);
		return color;
	}
	
	/**
		Contains a byte representing the red color component.
	**/
	public var Rb(get,   null): Int;
	
	/**
		Contains a byte representing the green color component.
	**/
	public var Gb(get, null): Int;
	
	/**
		Contains a byte representing the blue color component.
	**/
	public var Bb(get,  null): Int;
	
	/**
		Contains a byte representing the alpha color component (more exactly the opacity component - a value of 0 is fully transparent).
	**/
	public var Ab(get, null): Int;
	
	public var R(get, null): Float;
	public var G(get, null): Float;
	public var B(get, null): Float;
	public var A(get, null): Float;
	
	public var value(default, null): Int;
	
	private function new() {
		
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
		return (value & 0xff000000) >>> 24;
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
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
	public var Rb(getRedByte,   null): Int;
	
	/**
		Contains a byte representing the green color component.
	**/
	public var Gb(getGreenByte, null): Int;
	
	/**
		Contains a byte representing the blue color component.
	**/
	public var Bb(getBlueByte,  null): Int;
	
	/**
		Contains a byte representing the alpha color component (more exactly the opacity component - a value of 0 is fully transparent).
	**/
	public var Ab(getAlphaByte, null): Int;
	
	public var R(getRed,   null): Float;
	public var G(getGreen, null): Float;
	public var B(getBlue,  null): Float;
	public var A(getAlpha, null): Float;
	
	public var value(default, null): Int;
	
	private function new() {
		
	}
	
	private function getRedByte(): Int {
		return (value & 0x00ff0000) >>> 16;
	}
	
	private function getGreenByte(): Int {
		return (value & 0x0000ff00) >>> 8;
	}
	
	private function getBlueByte(): Int {
		return value & 0x000000ff;
	}
	
	private function getAlphaByte(): Int {
		return (value & 0xff000000) >>> 24;
	}
	
	private function getRed(): Float {
		return getRedByte() / 255;
	}
	
	private function getGreen(): Float {
		return getGreenByte() / 255;
	}
	
	private function getBlue(): Float {
		return getBlueByte() / 255;
	}
	
	private function getAlpha(): Float {
		return getAlphaByte() / 255;
	}
}
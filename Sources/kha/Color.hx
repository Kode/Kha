package kha;

/**
 * Class representing a color, based on Int.
 * Provides a variety of methods for creating and converting colors.
 * 
 * Color's can be written as Ints. This means you can pass a hex value such as
 * 0xff123456 to a function expecting a Color, and it will automatically become a Color object.
 * Similarly, Colors may be treated as Ints.
 */
@:expose
abstract Color(Int) from Int from UInt to Int to UInt {
	public static var Black: Color = fromValue(0xff000000);
	public static var White: Color = fromValue(0xffffffff);
	public static var Red: Color = fromValue(0xffff0000);
	public static var Blue: Color = fromValue(0xff0000ff);
	public static var Green: Color = fromValue(0xff00ff00);
	public static var Magenta: Color = fromValue(0xffff00ff);
	public static var Yellow: Color = fromValue(0xffffff00);
	public static var Cyan: Color = fromValue(0xff00ffff);
	public static var Purple: Color = fromValue(0xff800080);
	public static var Pink: Color = fromValue(0xffffc0cb);
	public static var Orange: Color = fromValue(0xffffa500);
	
	private static inline var invMaxChannelValue: FastFloat = 1 / 255;
	
	/**
	 * Creates a new Color object from a packed 32 bit ARGB value.
	 */
	public static inline function fromValue(value: Int): Color {
		return new Color(value);
	}
	
	/**
	 * Creates a new Color object from components in the range 0 - 255.
	 */
	public static function fromBytes(r: Int, g: Int, b: Int, a: Int = 255): Color {
		return new Color((a << 24) | (r << 16) | (g << 8) | b);
	}
	
	/**
	 * Creates a new Color object from components in the range 0 - 1.
	 */
	public static function fromFloats(r: FastFloat, g: FastFloat, b: FastFloat, a: FastFloat = 1): Color {
		return new Color((Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255));
	}
	
	/**
	 * Creates a new Color object from #AARRGGBB string.
	 */
	public static function fromString(value: String) {
		if ((value.length == 7 || value.length == 9) && StringTools.fastCodeAt(value, 0) == "#".code) {
			var colorValue = Std.parseInt("0x" + value.substr(1));
			if (value.length == 7) {
				colorValue += 0xFF000000;
			}
			return fromValue(colorValue);
		}
		else {
			throw "Invalid Color string: '" + value + "'";
		}
	}
	
	/**
	 * Contains a byte representing the red color component.
	 */
	public var Rb(get, set): Int;
	/**
	 * Contains a byte representing the green color component.
	 */
	public var Gb(get, set): Int;
	/**
	 * Contains a byte representing the blue color component.
	 */
	public var Bb(get, set): Int;
	/**
	 * Contains a byte representing the alpha color component (more exactly the opacity component - a value of 0 is fully transparent).
	 */
	public var Ab(get, set): Int;
	/**
	 * Contains a float representing the red color component.
	 */
	public var R(get, set): FastFloat;
	/**
	 * Contains a float representing the green color component.
	 */
	public var G(get, set): FastFloat;
	/**
	 * Contains a float representing the blue color component.
	 */
	public var B(get, set): FastFloat;
	/**
	 * Contains a float representing the alpha color component (more exactly the opacity component - a value of 0 is fully transparent).
	 */
	public var A(get, set): FastFloat;
	
	private function new(value: Int) {
		this = value;
	}
	
	/**
	 * Return this Color instance as Int.
	 */
	public var value(get, set): Int;
	
	private inline function get_value(): Int {
		return this;
	}
	
	private inline function set_value(value: Int): Int {
		this = value;
		return this;
	}

	private function get_Rb(): Int {
		return (this & 0x00ff0000) >>> 16;
	}
	
	private function get_Gb(): Int {
		return (this & 0x0000ff00) >>> 8;
	}
	
	private function get_Bb(): Int {
		return this & 0x000000ff;
	}
	
	private function get_Ab(): Int {
		return this >>> 24;
	}

	private inline function set_Rb(i: Int): Int {
		this = (Ab << 24) | (i << 16) | (Gb << 8) | Bb;
		return i;
	}
	
	private inline function set_Gb(i: Int): Int {
		this = (Ab << 24) | (Rb << 16) | (i << 8) | Bb;
		return i;
	}
	
	private inline function set_Bb(i: Int): Int {
		this = (Ab << 24) | (Rb << 16) | (Gb << 8) | i;
		return i;
	}
	
	private inline function set_Ab(i: Int): Int {
		this = (i << 24) | (Rb << 16) | (Gb << 8) | Bb;
		return i;
	}

	private inline function get_R(): FastFloat {
		return get_Rb() * invMaxChannelValue;
	}
	
	private inline function get_G(): FastFloat {
		return get_Gb() * invMaxChannelValue;
	}
	
	private inline function get_B(): FastFloat {
		return get_Bb() * invMaxChannelValue;
	}
	
	private inline function get_A(): FastFloat {
		return get_Ab() * invMaxChannelValue;
	}

	private inline function set_R(f: FastFloat): FastFloat {
		this = (Std.int(A * 255) << 24) | (Std.int(f * 255) << 16) | (Std.int(G * 255) << 8) | Std.int(B * 255);
		return f;
	}

	private inline function set_G(f: FastFloat): FastFloat {
		this = (Std.int(A * 255) << 24) | (Std.int(R * 255) << 16) | (Std.int(f * 255) << 8) | Std.int(B * 255);
		return f;
	}

	private inline function set_B(f: FastFloat): FastFloat {
		this = (Std.int(A * 255) << 24) | (Std.int(R * 255) << 16) | (Std.int(G * 255) << 8) | Std.int(f * 255);
		return f;
	}

	private inline function set_A(f: FastFloat): FastFloat {
		this = (Std.int(f * 255) << 24) | (Std.int(R * 255) << 16) | (Std.int(G * 255) << 8) | Std.int(B * 255);
		return f;
	}
}

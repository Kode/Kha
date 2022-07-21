package kha;

class Display {
	static var displays: Array<Display> = null;

	var num: Int;
	var isPrimary: Bool;

	function new(num: Int, isPrimary: Bool) {
		this.num = num;
		this.isPrimary = isPrimary;
	}

	public static function init(): Void {
		if (displays == null) {
			kinc_display_init();
			displays = [];
			for (i in 0...kinc_display_count()) {
				displays.push(new Display(i, kinc_display_is_primary(i)));
			}
		}
	}

	public static var primary(get, never): Display;

	static function get_primary(): Display {
		init();
		for (display in displays) {
			if (display.isPrimary) {
				return display;
			}
		}
		return null;
	}

	public static var all(get, never): Array<Display>;

	static function get_all(): Array<Display> {
		init();
		return displays;
	}

	public var available(get, never): Bool;

	function get_available(): Bool {
		return true;
	}

	public var name(get, never): String;

	function get_name(): String {
		return "Display";
	}

	public var x(get, never): Int;

	function get_x(): Int {
		return kinc_display_x(num);
	}

	public var y(get, never): Int;

	function get_y(): Int {
		return kinc_display_y(num);
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return kinc_display_width(num);
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return kinc_display_height(num);
	}

	public var frequency(get, never): Int;

	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	function get_pixelsPerInch(): Int {
		return kinc_display_ppi();
	}

	public var modes(get, never): Array<DisplayMode>;

	function get_modes(): Array<DisplayMode> {
		return [];
	}

	@:hlNative("std", "kinc_display_init") static function kinc_display_init(): Int {
		return 0;
	}

	@:hlNative("std", "kinc_display_count") static function kinc_display_count(): Int {
		return 0;
	}

	@:hlNative("std", "kinc_display_width") static function kinc_display_width(index: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_display_height") static function kinc_display_height(index: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_display_x") static function kinc_display_x(index: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_display_y") static function kinc_display_y(index: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_display_is_primary") static function kinc_display_is_primary(index: Int): Bool {
		return false;
	}

	@:hlNative("std", "kinc_display_ppi") static function kinc_display_ppi(): Int {
		return 0;
	}
}

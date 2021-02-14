package kha;

class Display {
	static var displays: Array<Display> = [];

	var num: Int;
	var isPrimary: Bool;

	function new(num: Int, isPrimary: Bool) {
		this.num = num;
		this.isPrimary = isPrimary;
		displays.push(this);
	}

	static function init(): Void {
		if (displays == null) {
			displays = [];
			for (i in 0...DisplayImpl.count()) {
				new Display(i, false);
			}
			displays[0].isPrimary = true;
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
		return DisplayImpl.get_x(num);
	}

	public var y(get, never): Int;

	function get_y(): Int {
		return DisplayImpl.get_y(num);
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return DisplayImpl.width(num);
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return DisplayImpl.height(num);
	}

	public var frequency(get, never): Int;

	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	function get_pixelsPerInch(): Int {
		return DisplayImpl.pixelsPerInch(num);
	}

	public var modes(get, never): Array<DisplayMode>;

	function get_modes(): Array<DisplayMode> {
		return [];
	}
}

package kha;

class Display {
	static var displays: Array<Display> = [];
	var num: Int;
	var isPrimary: Bool;
	
	function new(num: Int, isPrimary: Bool) {
		this.num = num;
		this.isPrimary = isPrimary;
	}
	
	static function init(): Void {
		for (i in 0...Krom.displayCount()) {
			displays.push(new Display(i, Krom.displayIsPrimary(i)));
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
		return Krom.displayX(num);
	}

	public var y(get, never): Int;

	function get_y(): Int {
		return Krom.displayY(num);
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return Krom.displayWidth(num);
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return Krom.displayHeight(num);
	}

	public var frequency(get, never): Int;

	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	function get_pixelsPerInch(): Int {
		return Krom.screenDpi();
	}

	public var modes(get, never): Array<DisplayMode>;

	function get_modes(): Array<DisplayMode> {
		return [];
	}
}

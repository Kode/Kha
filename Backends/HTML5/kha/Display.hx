package kha;

class Display {
	static var instance: Display = new Display();

	function new() {

	}

	public static var primary(get, never): Display;

	static function get_primary(): Display {
		return instance;
	}

	public static var all(get, never): Array<Display>;

	static function get_all(): Array<Display> {
		return [primary];
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
		return js.Browser.window.screen.left;
	}

	public var y(get, never): Int;

	function get_y(): Int {
		return js.Browser.window.screen.top;
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return js.Browser.window.screen.width;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return js.Browser.window.screen.height;
	}

	public var frequency(get, never): Int;

	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	function get_pixelsPerInch(): Int {
		return 72;
	}

	public var modes(get, never): Array<DisplayMode>;

	function get_modes(): Array<DisplayMode> {
		return [];
	}
}

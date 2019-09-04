package kha;

extern class Display {
	public static var primary(get, never): Display;
	public static var all(get, never): Array<Display>;
	public var available(get, never): Bool;
	public var name(get, never): String;
	public var x(get, never): Int;
	public var y(get, never): Int;
	public var width(get, never): Int;
	public var height(get, never): Int;
	public var frequency(get, never): Int;
	public var pixelsPerInch(get, never): Int;
	public var modes(get, never): Array<DisplayMode>;

	public static function get_primary(): Display;
	public static function get_all(): Array<Display>;
	public function get_available(): Bool;
	public function get_name(): String;
	public function get_x(): Int;
	public function get_y(): Int;
	public function get_width(): Int;
	public function get_height(): Int;
	public function get_frequency(): Int;
	public function get_pixelsPerInch(): Int;
	public function get_modes(): Array<DisplayMode>;
}

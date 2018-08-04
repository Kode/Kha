package kha;

import flash.system.Capabilities;

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
		return 0;
	}

	public var y(get, never): Int;

	function get_y(): Int {
		return 0;
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return flash.Lib.current.stage.fullScreenWidth;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return flash.Lib.current.stage.fullScreenHeight;
	}

	public var frequency(get, never): Int;

	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	function get_pixelsPerInch(): Int {
		return Std.int(Capabilities.screenDPI);
	}

	public var modes(get, never): Array<DisplayMode>;

	function get_modes(): Array<DisplayMode> {
		return [];
	}
}

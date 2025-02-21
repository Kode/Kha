package kha;

@:headerCode("
#include <kinc/display.h>
")
class Display {
	var num: Int;

	static var displays: Array<Display> = null;

	function new(num: Int) {
		this.num = num;
	}

	@:functionCode("return kinc_count_displays();")
	static function count(): Int {
		return 0;
	}

	@:functionCode("kinc_display_init();")
	static function initKoreDisplay(): Void {}

	public static function init() {
		if (displays == null) {
			initKoreDisplay();
			displays = [];
			for (i in 0...count()) {
				displays.push(new Display(i));
			}
		}
	}

	@:functionCode("return kinc_primary_display();")
	static function primaryId() {
		return 0;
	}

	public static var primary(get, never): Display;

	static function get_primary(): Display {
		init();
		return displays[primaryId()];
	}

	public static var all(get, never): Array<Display>;

	static function get_all(): Array<Display> {
		init();
		return displays;
	}

	public var available(get, never): Bool;

	@:functionCode("return kinc_display_available(num);")
	function get_available(): Bool {
		return true;
	}

	public var name(get, never): String;

	@:functionCode("return ::String(kinc_display_name(num));")
	function get_name(): String {
		return "Display";
	}

	public var x(get, never): Int;

	@:functionCode("return kinc_display_current_mode(num).x;")
	function get_x(): Int {
		return 0;
	}

	public var y(get, never): Int;

	@:functionCode("return kinc_display_current_mode(num).y;")
	function get_y(): Int {
		return 0;
	}

	public var width(get, never): Int;

	@:functionCode("return kinc_display_current_mode(num).width;")
	function get_width(): Int {
		return 800;
	}

	public var height(get, never): Int;

	@:functionCode("return kinc_display_current_mode(num).height;")
	function get_height(): Int {
		return 600;
	}

	public var frequency(get, never): Int;

	@:functionCode("return kinc_display_current_mode(num).frequency;")
	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	@:functionCode("return kinc_display_current_mode(num).pixels_per_inch;")
	function get_pixelsPerInch(): Int {
		return 72;
	}

	public var modes(get, never): Array<DisplayMode>;

	var allModes: Array<DisplayMode> = null;

	@:functionCode("return kinc_display_count_available_modes(num);")
	function modeCount(): Int {
		return 0;
	}

	@:functionCode("return kinc_display_available_mode(num, modeIndex).width;")
	function getModeWidth(modeIndex: Int) {
		return 800;
	}

	@:functionCode("return kinc_display_available_mode(num, modeIndex).height;")
	function getModeHeight(modeIndex: Int) {
		return 600;
	}

	@:functionCode("return kinc_display_available_mode(num, modeIndex).frequency;")
	function getModeFrequency(modeIndex: Int) {
		return 60;
	}

	@:functionCode("return kinc_display_available_mode(num, modeIndex).bits_per_pixel;")
	function getModeBitsPerPixel(modeIndex: Int) {
		return 32;
	}

	function initModes() {
		if (allModes == null) {
			allModes = [];
			for (i in 0...modeCount()) {
				allModes.push(new DisplayMode(getModeWidth(i), getModeHeight(i), getModeFrequency(i), getModeBitsPerPixel(i)));
			}
		}
	}

	function get_modes(): Array<DisplayMode> {
		initModes();
		return allModes;
	}
}

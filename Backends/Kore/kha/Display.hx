package kha;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Display.h>
')

class Display {
	var num: Int;
	static var displays: Array<Display> = null;

	function new(num: Int) {
		this.num = num;
	}

	@:functionCode('return Kore::Display::count();')
	static function count(): Int {
		return 0;
	}

	static function init() {
		if (displays == null) {
			displays = [];
			for (i in 0...count()) {
				displays.push(new Display(i));
			}
		}
	}

	@:functionCode('
		for (int i = 0; i < Kore::Display::count(); ++i) {
			if (Kore::Display::get(i) == Kore::Display::primary()) return i;
		}
		return 0;
	')
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

	@:functionCode('return Kore::Display::get(num)->available();')
	function get_available(): Bool {
		return true;
	}

	public var name(get, never): String;

	@:functionCode('return ::String(Kore::Display::get(num)->name());')
	function get_name(): String {
		return "Display";
	}

	public var x(get, never): Int;

	@:functionCode('return Kore::Display::get(num)->x();')
	function get_x(): Int {
		return 0;
	}

	public var y(get, never): Int;

	@:functionCode('return Kore::Display::get(num)->y();')
	function get_y(): Int {
		return 0;
	}

	public var width(get, never): Int;

	@:functionCode('return Kore::Display::get(num)->width();')
	function get_width(): Int {
		return 800;
	}

	public var height(get, never): Int;

	@:functionCode('return Kore::Display::get(num)->height();')
	function get_height(): Int {
		return 600;
	}

	public var frequency(get, never): Int;

	@:functionCode('return Kore::Display::get(num)->frequency();')
	function get_frequency(): Int {
		return 60;
	}

	public var pixelsPerInch(get, never): Int;

	@:functionCode('return Kore::Display::get(num)->pixelsPerInch();')
	function get_pixelsPerInch(): Int {
		return 72;
	}

	public var modes(get, never): Array<DisplayMode>;

	var allModes: Array<DisplayMode> = null;

	@:functionCode('return Kore::Display::get(num)->countAvailableModes();')
	function modeCount(): Int {
		return 0;
	}

	@:functionCode('return Kore::Display::get(num)->availableMode(num).width;')
	function getModeWidth(num: Int) {
		return 800;
	}

	@:functionCode('return Kore::Display::get(num)->availableMode(num).height;')
	function getModeHeight(num: Int) {
		return 600;
	}

	@:functionCode('return Kore::Display::get(num)->availableMode(num).frequency;')
	function getModeFrequency(num: Int) {
		return 60;
	}

	@:functionCode('return Kore::Display::get(num)->availableMode(num).bitsPerPixel;')
	function getModeBitsPerPixel(num: Int) {
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

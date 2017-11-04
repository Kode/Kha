package kha;

class DisplayImpl {
	public static function count() : Int {
		return 1;
	}

	public static function width(index: Int): Int {
		return js.Browser.window.screen.width;
	}

	public static function height(index: Int): Int {
		return js.Browser.window.screen.height;
	}

	public static function x(index: Int): Int {
		return js.Browser.window.screen.left;
	}

	public static function y(index: Int): Int {
		return js.Browser.window.screen.top;
	}

	public static function isPrimary(index: Int): Bool {
		return true;
	}
}

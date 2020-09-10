package kha;

class Window {
	public static function get(index: Int): Window { return instance; }
	public static var all = [];
	public final width = 0;
	public final height = 0;
	public var mode = WindowMode.Windowed;
	public final vSynced = false;

	static final instance = new Window();

	function new() {
	}
}

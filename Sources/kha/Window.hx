package kha;

extern class Window {
	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window;
	public static function destroy(window: Window): Void;
	public static function get(index: Int): Window;
	public static var all(get, never): Array<Window>;
	public function resize(width: Int, height: Int): Void;
	public function move(x: Int, y: Int): Void;
	public function changeWindowFeatures(features: WindowOptions.WindowFeatures): Void;
	public function changeFramebuffer(frame: FramebufferOptions): Void;
	public var x(get, set): Int;
	public var y(get, set): Int;
	public var width(get, set): Int;
	public var height(get, set): Int;
	public var mode(get, set): WindowMode;
	public var visible(get, set): Bool;
	public var title(get, set): String;
	public function notifyOnResize(callback: Int->Int->Void): Void;
	public function notifyOnPpiChange(callback: Int->Void): Void;
	public var vSynced(get, never): Bool;
}

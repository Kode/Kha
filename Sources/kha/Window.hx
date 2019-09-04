package kha;

extern class Window {
	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window;
	public static function destroy(window: Window): Void;
	public static function get(index: Int): Window;
	public static var all(get, never): Array<Window>;
	public static function get_all(): Array<Window>;
	public function resize(width: Int, height: Int): Void;
	public function move(x: Int, y: Int): Void;
	public function changeWindowFeatures(features: WindowOptions.WindowFeatures): Void;
	public function changeFramebuffer(frame: FramebufferOptions): Void;
	public var x(get, set): Int;
	public function get_x(): Int;
	public function set_x(x:Int): Int;
	public var y(get, set): Int;
	public function get_y(): Int;
	public function set_y(y:Int): Int;
	public var width(get, set): Int;
	public function get_width(): Int;
	public function set_width(width:Int): Int;
	public var height(get, set): Int;
	public function get_height(): Int;
	public function set_height(height:Int): Int;
	public var mode(get, set): WindowMode;
	public function get_mode(): WindowMode;
	public function set_mode(mode:WindowMode): WindowMode;
	public var visible(get, set): Bool;
	public function get_visible(): Bool;
	public function set_visible(visible:Bool): Bool;
	public var title(get, set): String;
	public function get_title(): String;
	public function set_title(title:String): String;
	public function notifyOnResize(callback: Int->Int->Void): Void;
	public function notifyOnPpiChange(callback: Int->Void): Void;
	public var vSynced(get, never): Bool;
	public function get_vSynced(): Bool;
}

package kha;

class Window {
	static var instance: Window;
	
	@:allow(kha.SystemImpl)
	function new() {
		instance = this;
	}
		
	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window {
		return null;
	}
	
	public static function destroy(window: Window): Void {
		
	}
	
	public static function get(index: Int): Window {
		if (index == 0) {
			return instance;
		}
		else {
			return null;
		}
	}
	
	public static var all(get, never): Array<Window>;
	
	static function get_all(): Array<Window> {
		return [instance];
	}
	
	public function resize(width: Int, height: Int): Void {
		
	}
	
	public function move(x: Int, y: Int): Void {
		
	}
	
	public function changeWindowFeatures(features: Int): Void {
		
	}
	
	public function changeFramebuffer(frame: FramebufferOptions): Void {
		
	}
	
	public var x(get, set): Int;
	
	function get_x(): Int {
		return 0;
	}

	function set_x(value: Int): Int {
		return 0;
	}
	
	public var y(get, set): Int;
	
	function get_y(): Int {
		return 0;
	}
	
	function set_y(value: Int): Int {
		return 0;
	}
	
	public var width(get, set): Int;
	
	function get_width(): Int {
		return SystemImpl.width;
	}
	
	function set_width(value: Int): Int {
		return SystemImpl.width;
	}
	
	public var height(get, set): Int;
	
	function get_height(): Int {
		return SystemImpl.height;
	}
	
	function set_height(value: Int): Int {
		return SystemImpl.height;
	}
	
	public var mode(get, set): WindowMode;
	
	function get_mode(): WindowMode {
		return Windowed;
	}
	
	function set_mode(value: WindowMode): WindowMode {
		return Windowed;
	}
	
	public var visible(get, set): Bool;
	
	function get_visible(): Bool {
		return true;
	}
	
	function set_visible(value: Bool): Bool {
		return true;
	}
	
	public var title(get, set): String;
	
	function get_title(): String {
		return "Kha";
	}
	
	function set_title(value: String): String {
		return "Kha";
	}
	
	public function notifyOnResize(callback: Int->Int->Void): Void {
		
	}
	
	public function notifyOnPpiChange(callback: Int->Void): Void {
		
	}
	
	public var vSynced(get, never): Bool;
	
	function get_vSynced(): Bool {
		return true;
	}
}

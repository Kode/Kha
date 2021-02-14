package kha;

class Window {
	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window {
		return instance;
	}

	public static function destroy(window: Window) {}

	public static function get(index: Int): Window {
		return instance;
	}

	public static var all = [];

	public var x = 0;
	public var y = 0;
	public var width = 0;
	public var height = 0;
	public var mode = WindowMode.Windowed;
	public var visible = false;
	public var title = "";
	public final vSynced = false;

	static final instance = new Window();

	function new() {}

	public function notifyOnResize(callback: Int->Int->Void) {}

	public function notifyOnPpiChange(callback: Int->Void) {}

	public function changeWindowFeatures(features: WindowOptions.WindowFeatures) {}

	public function changeFramebuffer(frame: FramebufferOptions) {}

	public function resize(width: Int, height: Int) {}

	public function move(x: Int, y: Int) {}
}

package kha;

class Window {
	static var windows: Array<Window> = [];
	var canvas: js.html.CanvasElement;
	var defaultWidth: Int;
	var defaultHeight: Int;

	@:noCompletion
	@:noDoc
	public function new(defaultWidth: Int, defaultHeight: Int, canvas: js.html.CanvasElement) {
		this.canvas = canvas;
		this.defaultWidth = defaultWidth;
		this.defaultHeight = defaultHeight;
		windows.push(this);
	}

	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window {
		return null;
	}

	public static function destroy(window: Window): Void {}

	public static function get(index: Int): Window {
		return windows[index];
	}

	public static var all(get, never): Array<Window>;
	
	static function get_all(): Array<Window> {
		return windows;
	}

	public function resize(width: Int, height: Int): Void {}

	public function move(x: Int, y: Int): Void {}

	public function changeWindowFeatures(features: Int): Void {}

	public function changeFramebuffer(frame: FramebufferOptions): Void {}

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
		return canvas.clientWidth == 0 ? defaultWidth : canvas.clientWidth;
	}

	function set_width(value: Int): Int {
		return 800;
	}

	public var height(get, set): Int;

	function get_height(): Int {
		return canvas.clientHeight == 0 ? defaultHeight : canvas.clientHeight;
	}

	function set_height(value: Int): Int {
		return 600;
	}

	public var mode(get, set): WindowMode;

	function get_mode(): WindowMode {
		return Windowed;
	}

	function set_mode(mode: WindowMode): WindowMode {
		if (mode == Fullscreen || mode == ExclusiveFullscreen) {
			if (!isFullscreen()) {
				requestFullscreen();
			}
		}
		else {
			if (isFullscreen()) {
				exitFullscreen();
			}
		}
		return mode;
	}

	function isFullscreen(): Bool {
		return untyped __js__("document.fullscreenElement === this.canvas ||
			document.mozFullScreenElement === this.canvas ||
			document.webkitFullscreenElement === this.canvas ||
			document.msFullscreenElement === this.canvas ");
	}

	function requestFullscreen(): Void {
		untyped if (canvas.requestFullscreen) {
			var c: Dynamic = canvas;
			c.requestFullscreen({navigationUI: "hide"});
		}
		else if (canvas.msRequestFullscreen) {
			canvas.msRequestFullscreen();
		}
		else if (canvas.mozRequestFullScreen) {
			canvas.mozRequestFullScreen();
		}
		else if (canvas.webkitRequestFullscreen){
			canvas.webkitRequestFullscreen();
		}
	}

	function exitFullscreen(): Void {
		untyped if (document.exitFullscreen) {
			document.exitFullscreen();
		}
		else if (document.msExitFullscreen) {
			document.msExitFullscreen();
		}
		else if (document.mozCancelFullScreen) {
			document.mozCancelFullScreen();
		}
		else if (document.webkitExitFullscreen) {
			document.webkitExitFullscreen();
		}
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

	public function notifyOnResize(callback: Int->Int->Void): Void {}

	public var vSynced(get, never): Bool;

	function get_vSynced(): Bool {
		return true;
	}
}

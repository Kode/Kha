package kha;

import js.Syntax;
import js.html.MutationObserver;

class Window {
	static var windows: Array<Window> = [];
	static var resizeCallbacks: Array<Array<Int->Int->Void>> = [];

	var num: Int;
	var canvas: js.html.CanvasElement;
	var defaultWidth: Int;
	var defaultHeight: Int;

	@:noCompletion
	@:noDoc
	public function new(num: Int, defaultWidth: Int, defaultHeight: Int, canvas: js.html.CanvasElement) {
		this.num = num;
		this.canvas = canvas;
		this.defaultWidth = defaultWidth;
		this.defaultHeight = defaultHeight;
		windows.push(this);
		resizeCallbacks[num] = [];
		windows.push(this);
		final observer: MutationObserver = new MutationObserver(function(mutations: Array<js.html.MutationRecord>, observer: MutationObserver) {
			var isResize = false;
			for (mutation in mutations) {
				if (mutation.attributeName == "width" || mutation.attributeName == "height") {
					isResize = true;
					break;
				}
			}
			if (isResize) {
				this.resize(canvas.clientWidth, canvas.clientHeight);
			}
		});
		observer.observe(canvas, {attributes: true});
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

	public function resize(width: Int, height: Int): Void {
		for (callback in resizeCallbacks[num]) {
			callback(width, height);
		}
	}

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
		return canvas.width == 0 ? defaultWidth : canvas.width;
	}

	function set_width(value: Int): Int {
		return 800;
	}

	public var height(get, set): Int;

	function get_height(): Int {
		return canvas.height == 0 ? defaultHeight : canvas.height;
	}

	function set_height(value: Int): Int {
		return 600;
	}

	public var mode(get, set): WindowMode;

	function get_mode(): WindowMode {
		return isFullscreen() ? Fullscreen : Windowed;
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
		return Syntax.code("document.fullscreenElement === this.canvas ||
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
		else if (canvas.webkitRequestFullscreen) {
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

	public function notifyOnResize(callback: Int->Int->Void): Void {
		resizeCallbacks[num].push(callback);
	}

	public var vSynced(get, never): Bool;

	function get_vSynced(): Bool {
		return true;
	}
}

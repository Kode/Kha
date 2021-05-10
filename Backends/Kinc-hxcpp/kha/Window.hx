package kha;

@:headerCode("
#include <kinc/window.h>
")
@:cppFileCode("
namespace {
	char windowTitles[10][256];
	int titleIndex = 0;
	
	void resizeCallback(int width, int height, void* data) {
		::kha::Window_obj::callResizeCallbacks(*((int*)&data), width, height);
	}
	
	void ppiCallback(int ppi, void* data) {
		::kha::Window_obj::callPpiCallbacks(*((int*)&data), ppi);
	}
}

kinc_window_options_t convertWindowOptions(::kha::WindowOptions win) {
	kinc_window_options_t window;
	strcpy(windowTitles[titleIndex], win->title.c_str());
	window.title = windowTitles[titleIndex];
	++titleIndex;
	window.x = win->x;
	window.y = win->y;
	window.width = win->width;
	window.height = win->height;
	window.display_index = win->display;
	window.visible = win->visible;
	window.window_features = win->windowFeatures;
	window.mode = (kinc_window_mode_t)win->mode;
	return window;
}

kinc_framebuffer_options_t convertFramebufferOptions(::kha::FramebufferOptions frame) {
	kinc_framebuffer_options_t framebuffer;
	framebuffer.frequency = frame->frequency;
	framebuffer.vertical_sync = frame->verticalSync;
	framebuffer.color_bits = frame->colorBufferBits;
	framebuffer.depth_bits = frame->depthBufferBits;
	framebuffer.stencil_bits = frame->stencilBufferBits;
	framebuffer.samples_per_pixel = frame->samplesPerPixel;
	return framebuffer;
}
")
class Window {
	static var windows: Array<Window> = [];
	static var resizeCallbacks: Array<Array<Int->Int->Void>> = [];
	static var ppiCallbacks: Array<Array<Int->Void>> = [];

	var num: Int;
	var visibility: Bool;
	var windowTitle: String;

	@:noCompletion
	@:noDoc
	public function new(num: Int, win: WindowOptions) {
		this.num = num;
		visibility = win != null && win.visible;
		windowTitle = win == null ? "Kha" : (win.title == null ? "Kha" : win.title);
		resizeCallbacks[num] = [];
		ppiCallbacks[num] = [];
	}

	@:noCompletion
	@:noDoc
	@:keep
	static function unused(): Void {
		Display.primary.x;
	}

	@:noCompletion
	@:noDoc
	public static function _init(win: WindowOptions = null, frame: FramebufferOptions = null): Void {
		var window = new Window(windows.length, win);
		windows.push(window);
	}

	@:access(kha.SystemImpl)
	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window {
		koreCreate(win == null ? {} : win, frame == null ? {} : frame);
		var window = new Window(windows.length, win);
		var index = windows.push(window) - 1;
		kha.SystemImpl.onWindowCreated(index);
		return window;
	}

	@:functionCode("
		kinc_window_options_t window = convertWindowOptions(win);
		kinc_framebuffer_options_t framebuffer = convertFramebufferOptions(frame);
		kinc_window_create(&window, &framebuffer);
	")
	static function koreCreate(win: WindowOptions, frame: FramebufferOptions) {}

	public static function destroy(window: Window): Void {
		koreDestroy(window.num);
		windows.remove(window);
	}

	@:functionCode("kinc_window_destroy(num);")
	static function koreDestroy(num: Int) {}

	public static function get(index: Int): Window {
		return windows[index];
	}

	public static var all(get, never): Array<Window>;

	static function get_all(): Array<Window> {
		return windows;
	}

	@:functionCode("kinc_window_resize(num, width, height);")
	public function resize(width: Int, height: Int): Void {}

	@:functionCode("kinc_window_move(num, x, y);")
	public function move(x: Int, y: Int): Void {}

	@:functionCode("kinc_window_change_features(num, features);")
	public function changeWindowFeatures(features: Int): Void {}

	@:functionCode("
		kinc_framebuffer_options_t framebuffer = convertFramebufferOptions(frame);
		kinc_window_change_framebuffer(num, &framebuffer);
	")
	public function changeFramebuffer(frame: FramebufferOptions): Void {}

	public var x(get, set): Int;

	@:functionCode("return kinc_window_x(num);")
	function get_x(): Int {
		return 0;
	}

	@:functionCode("int y = kinc_window_y(num); kinc_window_move(num, value, y);")
	function set_x(value: Int): Int {
		return 0;
	}

	public var y(get, set): Int;

	@:functionCode("return kinc_window_y(num);")
	function get_y(): Int {
		return 0;
	}

	@:functionCode("int x = kinc_window_x(num); kinc_window_move(num, x, value);")
	function set_y(value: Int): Int {
		return 0;
	}

	public var width(get, set): Int;

	@:functionCode("return kinc_window_width(num);")
	function get_width(): Int {
		return 800;
	}

	@:functionCode("int height = kinc_window_height(num); kinc_window_resize(num, value, height);")
	function set_width(value: Int): Int {
		return 800;
	}

	public var height(get, set): Int;

	@:functionCode("return kinc_window_height(num);")
	function get_height(): Int {
		return 600;
	}

	@:functionCode("int width = kinc_window_width(num); kinc_window_move(num, width, value);")
	function set_height(value: Int): Int {
		return 600;
	}

	public var mode(get, set): WindowMode;

	function get_mode(): WindowMode {
		return cast getKincMode();
	}

	@:functionCode("return kinc_window_get_mode(num);")
	function getKincMode(): Int {
		return 0;
	}

	@:functionCode("kinc_window_change_mode(num, (kinc_window_mode_t)mode); return mode;")
	function set_mode(mode: WindowMode): WindowMode {
		return mode;
	}

	public var visible(get, set): Bool;

	function get_visible(): Bool {
		return visibility;
	}

	@:functionCode("if (value) kinc_window_show(num); else kinc_window_hide(num);")
	function set_visible(value: Bool): Bool {
		visibility = value;
		return value;
	}

	public var title(get, set): String;

	function get_title(): String {
		return windowTitle;
	}

	@:functionCode("kinc_window_set_title(num, value.c_str());")
	function set_title(value: String): String {
		windowTitle = value;
		return windowTitle;
	}

	@:functionCode("kinc_window_set_resize_callback(num, resizeCallback, (void*)this->num);")
	public function notifyOnResize(callback: Int->Int->Void): Void {
		resizeCallbacks[num].push(callback);
	}

	@:noCompletion
	@:noDoc
	@:keep
	public static function callResizeCallbacks(num: Int, width: Int, height: Int) {
		for (callback in resizeCallbacks[num]) {
			callback(width, height);
		}
	}

	@:functionCode("kinc_window_set_ppi_changed_callback(num, ppiCallback, (void*)this->num);")
	public function notifyOnPpiChange(callback: Int->Void): Void {
		ppiCallbacks[num].push(callback);
	}

	@:noCompletion
	@:noDoc
	@:keep
	public static function callPpiCallbacks(num: Int, ppi: Int) {
		for (callback in ppiCallbacks[num]) {
			callback(ppi);
		}
	}

	public var vSynced(get, never): Bool;

	@:functionCode("return kinc_window_vsynced(num);")
	function get_vSynced(): Bool {
		return true;
	}
}

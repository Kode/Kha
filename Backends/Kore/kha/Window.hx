package kha;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Window.h>
')

@:cppFileCode('
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

Kore::WindowOptions convertWindowOptions(::kha::WindowOptions win) {
	Kore::WindowOptions window;
	strcpy(windowTitles[titleIndex], win->title.c_str());
	window.title = windowTitles[titleIndex];
	++titleIndex;
	window.x = win->x;
	window.y = win->y;
	window.width = win->width;
	window.height = win->height;
	window.display = win->display < 0 ? Kore::Display::primary() : Kore::Display::get(win->display);
	window.visible = win->visible;
	window.windowFeatures = win->windowFeatures;
	window.mode = (Kore::WindowMode)win->mode;
	return window;
}

Kore::FramebufferOptions convertFramebufferOptions(::kha::FramebufferOptions frame) {
	Kore::FramebufferOptions framebuffer;
	framebuffer.frequency = frame->frequency;
	framebuffer.verticalSync = frame->verticalSync;
	framebuffer.colorBufferBits = frame->colorBufferBits;
	framebuffer.depthBufferBits = frame->depthBufferBits;
	framebuffer.stencilBufferBits = frame->stencilBufferBits;
	framebuffer.samplesPerPixel = frame->samplesPerPixel;
	return framebuffer;
}
')

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

	@:functionCode('
		Kore::WindowOptions window = convertWindowOptions(win);
		Kore::FramebufferOptions framebuffer = convertFramebufferOptions(frame);
		Kore::Window::create(&window, &framebuffer);
	')
	static function koreCreate(win: WindowOptions, frame: FramebufferOptions) {

	}

	public static function destroy(window: Window): Void {
		koreDestroy(window.num);
		windows.remove(window);
	}

	@:functionCode('Kore::Window::destroy(Kore::Window::get(num));')
	static function koreDestroy(num: Int) {}

	public static function get(index: Int): Window {
		return windows[index];
	}

	public static var all(get, never): Array<Window>;
	
	static function get_all(): Array<Window> {
		return windows;
	}

	@:functionCode('Kore::Window::get(this->num)->resize(width, height);')
	public function resize(width: Int, height: Int): Void {}

	@:functionCode('Kore::Window::get(this->num)->move(x, y);')
	public function move(x: Int, y: Int): Void {}

	@:functionCode('Kore::Window::get(this->num)->changeWindowFeatures(features);')
	public function changeWindowFeatures(features: Int): Void {}

	@:functionCode('
		Kore::FramebufferOptions framebuffer = convertFramebufferOptions(frame);
		Kore::Window::get(this->num)->changeFramebuffer(&framebuffer);
	')
	public function changeFramebuffer(frame: FramebufferOptions): Void {}

	public var x(get, set): Int;

	@:functionCode('return Kore::Window::get(this->num)->x();')
	function get_x(): Int {
		return 0;
	}

	@:functionCode('int y = Kore::Window::get(this->num)->y(); Kore::Window::get(this->num)->move(value, y);')
	function set_x(value: Int): Int {
		return 0;
	}

	public var y(get, set): Int;

	@:functionCode('return Kore::Window::get(this->num)->y();')
	function get_y(): Int {
		return 0;
	}

	@:functionCode('int x = Kore::Window::get(this->num)->x(); Kore::Window::get(this->num)->move(x, value);')
	function set_y(value: Int): Int {
		return 0;
	}

	public var width(get, set): Int;

	@:functionCode('return Kore::Window::get(this->num)->width();')
	function get_width(): Int {
		return 800;
	}

	@:functionCode('int height = Kore::Window::get(this->num)->height(); Kore::Window::get(this->num)->resize(value, height);')
	function set_width(value: Int): Int {
		return 800;
	}

	public var height(get, set): Int;

	@:functionCode('return Kore::Window::get(this->num)->height();')
	function get_height(): Int {
		return 600;
	}

	@:functionCode('int width = Kore::Window::get(this->num)->width(); Kore::Window::get(this->num)->move(width, value);')
	function set_height(value: Int): Int {
		return 600;
	}

	public var mode(get, set): WindowMode;

	
	function get_mode(): WindowMode {
		return cast getKoreMode();
	}
	
	@:functionCode('return Kore::Window::get(this->num)->mode();')
	function getKoreMode(): Int {
		return 0;
	}

	@:functionCode('Kore::Window::get(this->num)->changeWindowMode((Kore::WindowMode)mode); return mode;')
	function set_mode(mode: WindowMode): WindowMode {
		return mode;
	}

	public var visible(get, set): Bool;

	function get_visible(): Bool {
		return visibility;
	}

	@:functionCode('if (value) Kore::Window::get(this->num)->show(); else Kore::Window::get(this->num)->hide();')
	function set_visible(value: Bool): Bool {
		visibility = value;
		return value;
	}

	public var title(get, set): String;

	function get_title(): String {
		return windowTitle;
	}

	@:functionCode('Kore::Window::get(this->num)->setTitle(value.c_str());')
	function set_title(value: String): String {
		windowTitle = value;
		return windowTitle;
	}

	@:functionCode('Kore::Window::get(this->num)->setResizeCallback(resizeCallback, (void*)this->num);')
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
	
	@:functionCode('Kore::Window::get(this->num)->setPpiChangedCallback(ppiCallback, (void*)this->num);')
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

	@:functionCode('return Kore::Window::get(this->num)->vSynced();')
	function get_vSynced(): Bool {
		return true;
	}
}

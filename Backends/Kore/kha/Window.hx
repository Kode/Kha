package kha;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Window.h>
')

class Window {
	static var windows: Array<Window> = [];
	var num: Int;

	@:noCompletion
	@:noDoc
	public function new(num: Int) {
		this.num = num;
	}
	
	@:noCompletion
	@:noDoc
	public static function _init(win: WindowOptions = null, frame: FramebufferOptions = null): Void {
		var window = new Window(windows.length);
		windows.push(window);
	}

	public static function create(win: WindowOptions = null, frame: FramebufferOptions = null): Window {
		koreCreate();
		var window = new Window(windows.length);
		windows.push(window);
		return window;
	}

	@:functionCode('Kore::Window::create();')
	static function koreCreate() {

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

	@:functionCode('')
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
		return true;
	}

	function set_visible(value: Bool): Bool {
		return true;
	}

	public var title(get, set): String;

	//@:functionCode('return ::String(Kore::Window::get(this->num)->title());')
	function get_title(): String {
		return "Kha";
	}

	@:functionCode('Kore::Window::get(this->num)->setTitle(value.c_str());')
	function set_title(value: String): String {
		return "Kha";
	}

	public function notifyOnResize(callback: Int->Int->Void): Void {}

	public var vSynced(get, never): Bool;

	@:functionCode('return Kore::Window::get(this->num)->vSynced();')
	function get_vSynced(): Bool {
		return true;
	}
}

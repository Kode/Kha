package kha.input;

import kha.Key;

@:expose
extern class Keyboard {
	public static function get(num: Int = 0): Keyboard;
	public function notify(downListener: Key->String->Void, upListener: Key->String->Void): Void;
	public function remove(downListener: Key->String->Void, upListener: Key->String->Void): Void;
}

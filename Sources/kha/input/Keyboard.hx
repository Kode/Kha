package kha.input;

import kha.Key;
import kha.networking.Controller;

@:allow(kha.Starter)
@:expose
class Keyboard implements Controller {
	public static function get(num: Int = 0): Keyboard {
		if (num != 0) return null;
		return instance;
	}
	
	public function notify(downListener: Key->String->Void, upListener: Key->String->Void): Void {
		if (downListener != null) downListeners.push(downListener);
		if (upListener != null) upListeners.push(upListener);
	}
	
	public function remove(downListener: Key->String->Void, upListener: Key->String->Void): Void {
		if (downListener != null) downListeners.remove(downListener);
		if (upListener != null) upListeners.remove(upListener);
	}
	
	private static var instance: Keyboard;
	private var downListeners: Array<Key->String->Void>;
	private var upListeners: Array<Key->String->Void>;
	
	private function new() {
		downListeners = new Array<Key->String->Void>();
		upListeners = new Array<Key->String->Void>();
		instance = this;
	}
	
	@input
	private function sendDownEvent(key: Key, char: String): Void {
		for (listener in downListeners) {
			listener(key, char);
		}
	}
	
	@input
	private function sendUpEvent(key: Key, char: String): Void {
		for (listener in upListeners) {
			listener(key, char);
		}
	}
}

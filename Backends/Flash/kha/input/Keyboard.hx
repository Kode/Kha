package kha.input;

import kha.Key;

class Keyboard {
	private static var instance: Keyboard;
	private var downListeners: Array<Key->String->Void>;
	private var upListeners: Array<Key->String->Void>;
	
	public function new() {
		downListeners = new Array<Key->String->Void>();
		upListeners = new Array<Key->String->Void>();
		instance = this;
	}
	
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
	
	public function _sendDownEvent(key: Key, char: String): Void {
		for (listener in downListeners) {
			listener(key, char);
		}
	}
	
	public function _sendUpEvent(key: Key, char: String): Void {
		for (listener in upListeners) {
			listener(key, char);
		}
	}
}

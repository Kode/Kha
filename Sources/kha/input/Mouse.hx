package kha.input;

@:allow(kha.Starter)
@:expose
class Mouse {
	public static function get(num: Int = 0): Mouse {
		if (num != 0) return null;
		return instance;
	}
	
	public function notify(downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Void, wheelListener: Int->Void): Void {
		if (downListener != null) downListeners.push(downListener);
		if (upListener != null) upListeners.push(upListener);
		if (moveListener != null) moveListeners.push(moveListener);
		if (wheelListener != null) wheelListeners.push(wheelListener);
	}
	
	public function remove(downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Void, wheelListener: Int->Void): Void {
		if (downListener != null) downListeners.remove(downListener);
		if (upListener != null) upListeners.remove(upListener);
		if (moveListener != null) moveListeners.remove(moveListener);
		if (wheelListener != null) wheelListeners.remove(wheelListener);
	}
	
	private static var instance: Mouse;
	private var downListeners: Array<Int->Int->Int->Void>;
	private var upListeners: Array<Int->Int->Int->Void>;
	private var moveListeners: Array<Int->Int->Void>;
	private var wheelListeners: Array<Int->Void>;
	
	private function new() {
		downListeners = new Array<Int->Int->Int->Void>();
		upListeners = new Array<Int->Int->Int->Void>();
		moveListeners = new Array<Int->Int->Void>();
		wheelListeners = new Array<Int->Void>();
		instance = this;
	}
	
	private function sendDownEvent(button: Int, x: Int, y: Int): Void {
		for (listener in downListeners) {
			listener(button, x, y);
		}
	}
	
	private function sendUpEvent(button: Int, x: Int, y: Int): Void {
		for (listener in upListeners) {
			listener(button, x, y);
		}
	}
	
	private function sendMoveEvent(x: Int, y: Int): Void {
		for (listener in moveListeners) {
			listener(x, y);
		}
	}
	
	private function sendWheelEvent(delta: Int): Void {
		for (listener in wheelListeners) {
			listener(delta);
		}
	}
}

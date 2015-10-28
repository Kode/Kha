package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Surface {
	public static function get(num: Int = 0): Surface {
		if (num != 0) return null;
		return instance;
	}
	
	public function notify(touchStartListener: Int->Int->Int->Void, touchEndListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Void): Void {
		if (touchStartListener != null) touchStartListeners.push(touchStartListener);
		if (touchEndListener != null) touchEndListeners.push(touchEndListener);
		if (moveListener != null) moveListeners.push(moveListener);
	}
	
	public function remove(touchStartListener: Int->Int->Int->Void, touchEndListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Void): Void {
		if (touchStartListener != null) touchStartListeners.remove(touchStartListener);
		if (touchEndListener != null) touchEndListeners.remove(touchEndListener);
		if (moveListener != null) moveListeners.push(moveListener);
	}
	
	private static var instance: Surface;
	private var touchStartListeners: Array<Int->Int->Int->Void>;
	private var touchEndListeners: Array<Int->Int->Int->Void>;
	private var moveListeners: Array<Int->Int->Int->Void>;
	
	private function new() {
		touchStartListeners = new Array<Int->Int->Int->Void>();
		touchEndListeners = new Array<Int->Int->Int->Void>();
		moveListeners = new Array<Int->Int->Int->Void>();
		instance = this;
	}
	
	private function sendTouchStartEvent(index: Int, x: Int, y: Int): Void {
		for (listener in touchStartListeners) {
			listener(index, x, y);
		}
	}
	
	private function sendTouchEndEvent(index: Int, x: Int, y: Int): Void {
		for (listener in touchEndListeners) {
			listener(index, x, y);
		}
	}
	
	private function sendMoveEvent(index: Int, x: Int, y: Int): Void {
		for (listener in moveListeners) {
			listener(index, x, y);
		}
	}
}

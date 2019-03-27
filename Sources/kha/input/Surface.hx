package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Surface {
	/**
	 * Get current Surface.
	 * @param num (optional) surface id (0 by default).
	 */
	public static function get(num: Int = 0): Surface {
		if (num != 0) return null;
		return instance;
	}
	
	/**
	 * Creates event handlers from passed functions.
	 * @param touchStartListener function with `id:Int`,`x:Int`,`y:Int` arguments, fired when a surface is pressed down. The finger `id` goes from 0 increasing by one. When the finger releases the screen, the old `id` is freed up and will be occupied with pressing the next finger (when releasing a finger, the shift of ids does not occur).
	 * @param touchEndListener function with `id:Int`,`x:Int`,`y:Int` arguments, fired when a surface is released.
	 * @param moveListener function with `id:Int`,`x:Int`,`y:Int` arguments, fired when a surface is moved.
	 */
	public function notify(touchStartListener: Int->Int->Int->Void, touchEndListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Void): Void {
		if (touchStartListener != null) touchStartListeners.push(touchStartListener);
		if (touchEndListener != null) touchEndListeners.push(touchEndListener);
		if (moveListener != null) moveListeners.push(moveListener);
	}
	
	/**
	 * Removes event handlers from the passed functions that were passed to `notify` function.
	 */
	public function remove(touchStartListener: Int->Int->Int->Void, touchEndListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Void): Void {
		if (touchStartListener != null) touchStartListeners.remove(touchStartListener);
		if (touchEndListener != null) touchEndListeners.remove(touchEndListener);
		if (moveListener != null) moveListeners.remove(moveListener);
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

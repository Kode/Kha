package kha.input;

/** See `Surface.setTouchDownEventBlockBehavior` */
enum TouchDownEventBlockBehavior {
	Full;
	None;
	Custom(func: (event: Dynamic) -> Bool);
}

@:allow(kha.SystemImpl)
@:expose
class Surface {
	static var touchDownEventBlockBehavior = TouchDownEventBlockBehavior.Full;

	/**
	 * Get current Surface.
	 * @param num (optional) surface id (0 by default).
	 */
	public static function get(num: Int = 0): Surface {
		if (num != 0)
			return null;
		return instance;
	}

	/**
	 * Allows fine grained control of touch down browser default actions (html5 only).
	 * @param behavior can be:
	 *   Full - block touch down events.
	 *   None - do not block touch down events.
	 *   Custom(func:(event:TouchEvent)->Bool) - set custom handler for touch down event (should return true if touch down event blocked).
	 */
	public static function setTouchDownEventBlockBehavior(behavior: TouchDownEventBlockBehavior): Void {
		touchDownEventBlockBehavior = behavior;
	}

	/**
	 * Creates event handlers from passed functions.
	 * @param touchStartListener (optional) function with `id:Int`,`x:Int`,`y:Int` arguments, fired when a surface is pressed down. The finger `id` goes from 0 increasing by one. When the finger releases the screen, the old `id` is freed up and will be occupied with pressing the next finger (when releasing a finger, the shift of ids does not occur).
	 * @param touchEndListener (optional) function with `id:Int`,`x:Int`,`y:Int` arguments, fired when a surface is released.
	 * @param moveListener (optional) function with `id:Int`,`x:Int`,`y:Int` arguments, fired when a surface is moved.
	 */
	public function notify(?touchStartListener: (id: Int, x: Int, y: Int) -> Void, ?touchEndListener: (id: Int, x: Int, y: Int) -> Void,
			?moveListener: (id: Int, x: Int, y: Int) -> Void): Void {
		if (touchStartListener != null)
			touchStartListeners.push(touchStartListener);
		if (touchEndListener != null)
			touchEndListeners.push(touchEndListener);
		if (moveListener != null)
			moveListeners.push(moveListener);
	}

	/**
	 * Removes event handlers from the passed functions that were passed to `notify` function.
	 */
	public function remove(?touchStartListener: (id: Int, x: Int, y: Int) -> Void, ?touchEndListener: (id: Int, x: Int, y: Int) -> Void,
			?moveListener: (id: Int, x: Int, y: Int) -> Void): Void {
		if (touchStartListener != null)
			touchStartListeners.remove(touchStartListener);
		if (touchEndListener != null)
			touchEndListeners.remove(touchEndListener);
		if (moveListener != null)
			moveListeners.remove(moveListener);
	}

	static var instance: Surface;

	var touchStartListeners: Array<Int->Int->Int->Void>;
	var touchEndListeners: Array<Int->Int->Int->Void>;
	var moveListeners: Array<Int->Int->Int->Void>;

	function new() {
		touchStartListeners = new Array<Int->Int->Int->Void>();
		touchEndListeners = new Array<Int->Int->Int->Void>();
		moveListeners = new Array<Int->Int->Int->Void>();
		instance = this;
	}

	function sendTouchStartEvent(index: Int, x: Int, y: Int): Void {
		for (listener in touchStartListeners) {
			listener(index, x, y);
		}
	}

	function sendTouchEndEvent(index: Int, x: Int, y: Int): Void {
		for (listener in touchEndListeners) {
			listener(index, x, y);
		}
	}

	function sendMoveEvent(index: Int, x: Int, y: Int): Void {
		for (listener in moveListeners) {
			listener(index, x, y);
		}
	}
}

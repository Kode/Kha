package kha.input;

@:allow(kha.SystemImpl)
class Pen {
	/**
	 * Get current Pen.
	 * @param num (optional) pen id (0 by default).
	 */
	public static function get(num: Int = 0): Pen {
		return SystemImpl.getPen(num);
	}

	/**
	 * Creates event handlers from passed functions.
	 * @param downListener function with `x:Int`,`y:Int`,`pressure:Float` arguments, fired when a pen is pressed down. `pressure` is force of pressure on the screen in the range from `0` to `1`.
	 * @param upListener function with `x:Int`,`y:Int`,`pressure:Float` arguments, fired when a pen is released.
	 * @param moveListener function with `x:Int`,`y:Int`,`pressure:Float` arguments, fired when a pen is moved.
	 */
	public function notify(downListener: Int->Int->Float->Void, upListener: Int->Int->Float->Void, moveListener: Int->Int->Float->Void): Void {
		notifyWindowed(0, downListener, upListener, moveListener);
	}

	/**
	 * Removes event handlers from the passed functions that were passed to `notify` function.
	 */
	public function remove(downListener: Int->Int->Float->Void, upListener: Int->Int->Float->Void, moveListener: Int->Int->Float->Void): Void {
		removeWindowed(0, downListener, upListener, moveListener);
	}

	/**
	 * Creates event handlers from passed functions like `notify` function, but only for window with `windowId:Int` id argument. The windows are not supported by all the targets.
	 */
	public function notifyWindowed(windowId: Int, downListener: Int->Int->Float->Void, upListener: Int->Int->Float->Void, moveListener: Int->Int->Float->Void): Void {
		if (downListener != null) {
			if (windowDownListeners == null) {
				windowDownListeners = [];
			}
			while (windowDownListeners.length <= windowId) {
				windowDownListeners.push([]);
			}
			windowDownListeners[windowId].push(downListener);
		}

		if (upListener != null) {
			if (windowUpListeners == null) {
				windowUpListeners = [];
			}
			while (windowUpListeners.length <= windowId) {
				windowUpListeners.push([]);
			}
			windowUpListeners[windowId].push(upListener);
		}

		if (moveListener != null) {
			if (windowMoveListeners == null) {
				windowMoveListeners = [];
			}
			while (windowMoveListeners.length <= windowId) {
				windowMoveListeners.push([]);
			}
			windowMoveListeners[windowId].push(moveListener);
		}
	}

	/**
	 * Removes event handlers for `windowId:Int` from the passed functions that were passed to `notifyWindowed` function.
	 */
	public function removeWindowed(windowId: Int, downListener: Int->Int->Float->Void, upListener: Int->Int->Float->Void, moveListener: Int->Int->Float->Void): Void {
		if (downListener != null && windowDownListeners != null) {
			if (windowId < windowDownListeners.length) {
				windowDownListeners[windowId].remove(downListener);
			}
		}

		if (upListener != null && windowUpListeners != null) {
			if (windowId < windowUpListeners.length) {
				windowUpListeners[windowId].remove(upListener);
			}
		}

		if (moveListener != null && windowMoveListeners != null) {
			if (windowId < windowMoveListeners.length) {
				windowMoveListeners[windowId].remove(moveListener);
			}
		}
	}

	private static var instance: Pen;
	var windowDownListeners: Array<Array<Int->Int->Float->Void>>;
	var windowUpListeners: Array<Array<Int->Int->Float->Void>>;
	var windowMoveListeners: Array<Array<Int->Int->Float->Void>>;

	private function new() {
		instance = this;
	}
	
	private function sendDownEvent(windowId: Int, x: Int, y: Int, pressure: Float): Void {
		if (windowDownListeners != null) {
			for (listener in windowDownListeners[windowId]) {
				listener(x, y, pressure);
			}
		}
	}

	private function sendUpEvent(windowId: Int, x: Int, y: Int, pressure: Float): Void {
		if (windowUpListeners != null) {
			for (listener in windowUpListeners[windowId]) {
				listener(x, y, pressure);
			}
		}
	}

	private function sendMoveEvent(windowId: Int, x: Int, y: Int, pressure: Float): Void {
		if (windowMoveListeners != null) {
			for (listener in windowMoveListeners[windowId]) {
				listener(x, y, pressure);
			}
		}
	}
}

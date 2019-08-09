package kha.input;

import kha.netsync.Controller;

@:allow(kha.SystemImpl)
@:expose
class Mouse extends Controller {
	/**
	 * Get current Mouse.
	 * @param num (optional) mouse id (0 by default).
	 */
	public static function get(num: Int = 0): Mouse {
		return SystemImpl.getMouse(num);
	}

	/**
	 * Creates event handlers from passed functions.
	 * @param downListener function with `button:Int`,`x:Int`,`y:Int` arguments, fired when a mouse is pressed down. `button:Int` is `0` for left button, `1` for right and `2` for middle.
	 * @param upListener function with `button:Int`,`x:Int`,`y:Int` arguments, fired when a mouse is released.
	 * @param moveListener function with `x:Int`,`y:Int`,`moveX:Int`,`moveY:Int` arguments, fired when a mouse is moved. `moveX`/`moveY` is the difference between the current coordinates and the last position of the mouse.
	 * @param wheelListener function with `delta:Int` argument, fired when the wheel rotates. It can have a value of `1` or `-1` depending on the rotation.
	 * @param leaveListener (optional) function without` arguments, when fired mouse leave canvas.
	 */
	public function notify(downListener: (button:Int, x:Int, y:Int)->Void, upListener: (button:Int, x:Int, y:Int)->Void, moveListener: (x:Int, y:Int, moveX:Int, moveY:Int)->Void, wheelListener: (delta:Int)->Void, leaveListener:()->Void = null): Void {
		notifyWindowed(0, downListener, upListener, moveListener, wheelListener, leaveListener);
	}

	/**
	 * Removes event handlers from the passed functions that were passed to `notify` function.
	 */
	public function remove(downListener: (button:Int, x:Int, y:Int)->Void, upListener: (button:Int, x:Int, y:Int)->Void, moveListener: (x:Int, y:Int, moveX:Int, moveY:Int)->Void, wheelListener: (delta:Int)->Void, leaveListener:()->Void = null): Void {
		removeWindowed(0, downListener, upListener, moveListener, wheelListener, leaveListener);
	}

	/**
	 * Creates event handlers from passed functions like `notify` function, but only for window with `windowId:Int` id argument. The windows are not supported by all the targets.
	 */
	public function notifyWindowed(windowId: Int, downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void, leaveListener:Void->Void = null): Void {
		if (downListener != null) {
			if (windowDownListeners == null) {
				windowDownListeners = new Array();
			}

			while (windowDownListeners.length <= windowId) {
				windowDownListeners.push(new Array());
			}

			windowDownListeners[windowId].push(downListener);
		}

		if (upListener != null) {
			if (windowUpListeners == null) {
				windowUpListeners = new Array();
			}

			while (windowUpListeners.length <= windowId) {
				windowUpListeners.push(new Array());
			}

			windowUpListeners[windowId].push(upListener);
		}

		if (moveListener != null) {
			if (windowMoveListeners == null) {
				windowMoveListeners = new Array();
			}

			while (windowMoveListeners.length <= windowId) {
				windowMoveListeners.push(new Array());
			}

			windowMoveListeners[windowId].push(moveListener);
		}

		if (wheelListener != null) {
			if (windowWheelListeners == null) {
				windowWheelListeners = new Array();
			}

			while (windowWheelListeners.length <= windowId) {
				windowWheelListeners.push(new Array());
			}

			windowWheelListeners[windowId].push(wheelListener);
		}
		
		if (leaveListener != null) {
			if (windowLeaveListeners == null) {
				windowLeaveListeners = new Array();
			}
			
			while (windowLeaveListeners.length <= windowId) {
				windowLeaveListeners.push(new Array());
			}
			
			windowLeaveListeners[windowId].push(leaveListener);
		}
	}

	/**
	 * Removes event handlers for `windowId:Int` from the passed functions that were passed to `notifyWindowed` function.
	 */
	public function removeWindowed(windowId: Int, downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void, leaveListener:Void->Void = null): Void {
		if (downListener != null) {
			if (windowDownListeners != null) {
				if (windowId < windowDownListeners.length) {
					windowDownListeners[windowId].remove(downListener);
				}
				else {
					trace('no downListeners for window "${windowId}" are registered');
				}
			}
			else {
				trace('no downListeners were ever registered');
			}
		}

		if (upListener != null) {
			if (windowUpListeners != null) {
				if (windowId < windowUpListeners.length) {
					windowUpListeners[windowId].remove(upListener);
				}
				else {
					trace('no upListeners for window "${windowId}" are registered');
				}
			}
			else {
				trace('no upListeners were ever registered');
			}
		}

		if (moveListener != null) {
			if (windowMoveListeners != null) {
				if (windowId < windowMoveListeners.length) {
					windowMoveListeners[windowId].remove(moveListener);
				}
				else {
					trace('no moveListeners for window "${windowId}" are registered');
				}
			}
			else {
				trace('no moveListeners were ever registered');
			}
		}

		if (wheelListener != null) {
			if (windowWheelListeners != null) {
				if (windowId < windowWheelListeners.length) {
					windowWheelListeners[windowId].remove(wheelListener);
				}
				else {
					trace('no wheelListeners for window "${windowId}" are registered');
				}
			}
			else {
				trace('no wheelListeners were ever registered');
			}
		}
		
		if (leaveListener != null) {
			if (windowLeaveListeners != null) {
				if (windowId < windowLeaveListeners.length) {
					windowLeaveListeners[windowId].remove(leaveListener);
				}
				else {
					trace('no leaveListeners for window "${windowId}" are registered');
				}
			}
			else {
				trace('no leaveListeners were ever registered');
			}
		}
	}

	/**
	 * Locks the cursor position and hides it. For catching movements, use the `moveX`/`moveY` arguments of your `moveListener` handler.
	 */
	public function lock(): Void {

	}

	/**
	 * Unlock the cursor position and hides it. For catching movements, use the `moveX`/`moveY` arguments of your `moveListener` handler.
	 */
	public function unlock(): Void {

	}

	/**
	 * Unlocks the cursor position and displays it.
	 */
	public function canLock(): Bool {
		return false;
	}

	/**
	 * Returns the status of the cursor lock
	 */
	public function isLocked(): Bool {
		return false;
	}

	/**
	 * Creates event handlers from passed functions.
	 * @param change function fired when the lock is turned on / off.
	 * @param error function fired when a toggle error occurs.
	 */
	public function notifyOnLockChange(change: Void -> Void, error: Void -> Void): Void {

	}

	/**
	 * Removes event handlers from the passed functions that were passed to `notifyOnLockChange` function.
	 */
	public function removeFromLockChange(change: Void -> Void, error: Void -> Void): Void{

	}

	/**
	 * Hides the system cursor (without locking)
	 */
	public function hideSystemCursor(): Void {

	}

	/**
	 * Show the system cursor
	 */
	public function showSystemCursor(): Void {

	}

	private static var instance: Mouse;
	var windowDownListeners: Array<Array<Int->Int->Int->Void>>;
	var windowUpListeners: Array<Array<Int->Int->Int->Void>>;
	var windowMoveListeners: Array<Array<Int->Int->Int->Int->Void>>;
	var windowWheelListeners: Array<Array<Int->Void>>;
	var windowLeaveListeners: Array<Array<Void->Void>>;

	private function new() {
		super();
		instance = this;
	}

	@input
	private function sendLeaveEvent(windowId:Int): Void {
		if (windowLeaveListeners != null) {
			for (listener in windowLeaveListeners[windowId]) {
				listener();
			}
		}
	}
	
	@input
	private function sendDownEvent(windowId: Int, button: Int, x: Int, y: Int): Void {
		if (windowDownListeners != null) {
			for (listener in windowDownListeners[windowId]) {
				listener(button, x, y);
			}
		}
	}

	@input
	private function sendUpEvent(windowId: Int, button: Int, x: Int, y: Int): Void {
		if (windowUpListeners != null) {
			for (listener in windowUpListeners[windowId]) {
				listener(button, x, y);
			}
		}
	}

	@input
	private function sendMoveEvent(windowId: Int, x: Int, y: Int, movementX: Int, movementY: Int): Void {
		if (windowMoveListeners != null) {
			for (listener in windowMoveListeners[windowId]) {
				listener(x, y, movementX, movementY);
			}
		}
	}

	@input
	private function sendWheelEvent(windowId: Int, delta: Int): Void {
		if (windowWheelListeners != null) {
			for (listener in windowWheelListeners[windowId]) {
				listener(delta);
			}
		}
	}
}

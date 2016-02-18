package kha.input;

import kha.network.Controller;

@:allow(kha.SystemImpl)
@:expose
class Mouse extends Controller {
	public static function get(num: Int = 0): Mouse {
		return SystemImpl.getMouse(num);
	}

	public function notify(downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void): Void {
		notifyWindowed(0, downListener, upListener, moveListener, wheelListener);
	}

	public function remove(downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void): Void {
		removeWindowed(0, downListener, upListener, moveListener, wheelListener);
	}

	public function notifyWindowed(windowId: Int, downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void): Void {
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
	}

	public function removeWindowed(windowId: Int, downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void): Void {
		if (downListener != null) {
			if (windowDownListeners != null) {
				if (windowId < windowDownListeners.length) {
					windowDownListeners[windowId].remove(downListener);
				} else {
					trace('no downListeners for window "${windowId}" are registered');
				}
			} else {
				trace('no downListeners were ever registered');
			}
		}

		if (upListener != null) {
			if (windowUpListeners != null) {
				if (windowId < windowUpListeners.length) {
					windowUpListeners[windowId].remove(upListener);
				} else {
					trace('no upListeners for window "${windowId}" are registered');
				}
			} else {
				trace('no upListeners were ever registered');
			}
		}

		if (moveListener != null) {
			if (windowMoveListeners != null) {
				if (windowId < windowMoveListeners.length) {
					windowMoveListeners[windowId].remove(moveListener);
				} else {
					trace('no moveListeners for window "${windowId}" are registered');
				}
			} else {
				trace('no moveListeners were ever registered');
			}
		}

		if (wheelListener != null) {
			if (windowWheelListeners != null) {
				if (windowId < windowWheelListeners.length) {
					windowWheelListeners[windowId].remove(wheelListener);
				} else {
					trace('no wheelListeners for window "${windowId}" are registered');
				}
			} else {
				trace('no wheelListeners were ever registered');
			}
		}
	}

	public function lock(): Void {

	}

	public function unlock(): Void {

	}

	public function canLock(): Bool {
		return false;
	}

	public function isLocked(): Bool {
		return false;
	}

	public function notifyOnLockChange(func: Void -> Void, error: Void -> Void): Void {

	}

	public function removeFromLockChange(func: Void -> Void, error: Void -> Void): Void{

	}

	public function hideSystemCursor(): Void {

	}

	public function showSystemCursor(): Void {

	}

	private static var instance: Mouse;
	var windowDownListeners: Array<Array<Int->Int->Int->Void>>;
	var windowUpListeners: Array<Array<Int->Int->Int->Void>>;
	var windowMoveListeners: Array<Array<Int->Int->Int->Int->Void>>;
	var windowWheelListeners: Array<Array<Int->Void>>;

	private function new() {
		super();
		instance = this;
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

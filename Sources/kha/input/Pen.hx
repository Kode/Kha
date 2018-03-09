package kha.input;

@:allow(kha.SystemImpl)
class Pen {
	public static function get(num: Int = 0): Pen {
		return SystemImpl.getPen(num);
	}

	public function notify(downListener: Int->Int->Float->Void, upListener: Int->Int->Float->Void, moveListener: Int->Int->Float->Void): Void {
		notifyWindowed(0, downListener, upListener, moveListener);
	}

	public function remove(downListener: Int->Int->Float->Void, upListener: Int->Int->Float->Void, moveListener: Int->Int->Float->Void): Void {
		removeWindowed(0, downListener, upListener, moveListener);
	}

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

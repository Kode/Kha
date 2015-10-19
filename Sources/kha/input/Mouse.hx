package kha.input;

import kha.network.Controller;
import kha.Starter;

@:allow(kha.Starter)
@:expose
class Mouse implements Controller {
	public static function get(num: Int = 0): Mouse {
		if (num != 0) return null;
		return instance;
	}
	
	public function notify(downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void): Void {
		if (downListener != null) downListeners.push(downListener);
		if (upListener != null) upListeners.push(upListener);
		if (moveListener != null) moveListeners.push(moveListener);
		if (wheelListener != null) wheelListeners.push(wheelListener);
	}
	
	public function remove(downListener: Int->Int->Int->Void, upListener: Int->Int->Int->Void, moveListener: Int->Int->Int->Int->Void, wheelListener: Int->Void): Void {
		if (downListener != null) downListeners.remove(downListener);
		if (upListener != null) upListeners.remove(upListener);
		if (moveListener != null) moveListeners.remove(moveListener);
		if (wheelListener != null) wheelListeners.remove(wheelListener);
	}
	
	public function lock(): Void {
		Starter.lockMouse();
	}

	public function unlock(): Void {
		Starter.unlockMouse();
	}

	public function canLock(): Bool {
		return Starter.canLockMouse();
	}

	public function isLocked(): Bool {
		return Starter.isMouseLocked();
	}

	public function notifyOfLockChange(func: Void -> Void, error: Void -> Void): Void {
		Starter.notifyOfMouseLockChange(func, error);
	}

	public function removeFromLockChange(func: Void -> Void, error: Void -> Void): Void{
		Starter.removeFromMouseLockChange(func, error);
	}

	private static var instance: Mouse;
	private var downListeners: Array<Int->Int->Int->Void>;
	private var upListeners: Array<Int->Int->Int->Void>;
	private var moveListeners: Array<Int->Int->Int->Int->Void>;
	private var wheelListeners: Array<Int->Void>;
	
	private function new() {
		downListeners = new Array<Int->Int->Int->Void>();
		upListeners = new Array<Int->Int->Int->Void>();
		moveListeners = new Array<Int->Int->Int->Int->Void>();
		wheelListeners = new Array<Int->Void>();
		instance = this;
	}
	
	@input
	private function sendDownEvent(button: Int, x: Int, y: Int): Void {
		for (listener in downListeners) {
			listener(button, x, y);
		}
	}
	
	@input
	private function sendUpEvent(button: Int, x: Int, y: Int): Void {
		for (listener in upListeners) {
			listener(button, x, y);
		}
	}
	
	@input
	private function sendMoveEvent(x: Int, y: Int, movementX: Int, movementY: Int): Void {
		for (listener in moveListeners) {
			listener(x, y, movementX, movementY);
		}
	}
	
	@input
	private function sendWheelEvent(delta: Int): Void {
		for (listener in wheelListeners) {
			listener(delta);
		}
	}
}

package kha.input;

import kha.network.Controller;

@:allow(kha.SystemImpl)
@:expose
class Mouse extends Controller {
	public static function get(num: Int = 0): Mouse {
		return SystemImpl.getMouse(num);
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
	private var downListeners: Array<Int->Int->Int->Void>;
	private var upListeners: Array<Int->Int->Int->Void>;
	private var moveListeners: Array<Int->Int->Int->Int->Void>;
	private var wheelListeners: Array<Int->Void>;
	
	private function new() {
		super();
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

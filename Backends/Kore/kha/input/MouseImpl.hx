package kha.input;

import kha.SystemImpl;

class MouseImpl extends kha.input.Mouse {
	public function new() {
		super();
	}

	override public function lock(): Void {
		SystemImpl.lockMouse();
	}

	override public function unlock(): Void {
		SystemImpl.unlockMouse();
	}

	override public function canLock(): Bool {
		return SystemImpl.canLockMouse();
	}

	override public function isLocked(): Bool {
		return SystemImpl.isMouseLocked();
	}

	override public function notifyOnLockChange(func: Void -> Void, error: Void -> Void): Void {
		SystemImpl.notifyOfMouseLockChange(func, error);
	}

	override public function removeFromLockChange(func: Void -> Void, error: Void -> Void): Void {
		SystemImpl.removeFromMouseLockChange(func, error);
	}

	override public function hideSystemCursor(): Void {
		
	}

	override public function showSystemCursor(): Void {
		
	}
}

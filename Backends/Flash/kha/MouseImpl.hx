package kha;

class MouseImpl {
	public function new() {
		
	}
	
	public static function hideSystemCursor(): Void {
		flash.ui.Mouse.hide();
	}
	
	public static function showSystemCursor(): Void {
		flash.ui.Mouse.show();
	}
	
	public static function lockMouse(): Void {
		
	}
	
	public static function unlockMouse(): Void {
		
	}

	public static function canLockMouse(): Bool {
		return false;
	}

	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}
}

package android.view;

extern class MotionEvent {
	public static var ACTION_DOWN: Int;
	public static var ACTION_MOVE: Int;
	public static var ACTION_UP: Int;
	public static var ACTION_POINTER_DOWN: Int;
	public static var ACTION_POINTER_UP: Int;
	public static var ACTION_CANCEL: Int;
	public function getAction(): Int;
	public function getX(pointerIndex: Int): Single;
	public function getY(pointerIndex: Int): Single;
	public function getPointerCount(): Int;
	public function getPointerId(pointerIndex: Int): Int;
	public function getActionIndex(): Int;
	public function getActionMasked(): Int;
}

package android.view;

extern class MotionEvent {
	public static var ACTION_DOWN : Int;
	public static var ACTION_MOVE : Int;
	public static var ACTION_UP : Int;
	public function getAction() : Int;
	public function getX() : Int;
	public function getY() : Int;
}
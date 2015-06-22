package android.view;

extern class KeyEvent {
	public static var KEYCODE_BACK: Int;
	public static var KEYCODE_DPAD_RIGHT: Int;
	public static var KEYCODE_DPAD_LEFT: Int;
	public static var KEYCODE_DPAD_CENTER: Int;
	public static var KEYCODE_DPAD_DOWN: Int;
	public static var KEYCODE_VOLUME_DOWN: Int;
	public static var KEYCODE_VOLUME_MUTE: Int;
	public static var KEYCODE_VOLUME_UP: Int;
	public function isAltPressed(): Bool;
	public function getKeyCode(): Int;
}

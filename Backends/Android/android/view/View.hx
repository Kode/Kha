package android.view;

import android.os.IBinder;

extern class View {
	public static var SYSTEM_UI_FLAG_LAYOUT_STABLE: Int;
	public static var SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION: Int;
	public static var SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN: Int;
	public static var SYSTEM_UI_FLAG_HIDE_NAVIGATION: Int;
	public static var SYSTEM_UI_FLAG_FULLSCREEN: Int;
	public static var SYSTEM_UI_FLAG_IMMERSIVE_STICKY: Int;
	public static var SYSTEM_UI_FLAG_IMMERSIVE: Int;

	public function setFocusable(focusable: Bool): Void;
	public function setFocusableInTouchMode(focusableInTouchMode: Bool): Void;
	public function setOnTouchListener(l: ViewOnTouchListener): Void;
	public function getApplicationWindowToken(): IBinder;
	public function setSystemUiVisibility(visibility: Int): Void;
}

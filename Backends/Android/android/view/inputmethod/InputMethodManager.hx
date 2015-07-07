package android.view.inputmethod;

import android.os.IBinder;

extern class InputMethodManager {
	public static var SHOW_IMPLICIT: Int;
	public static var HIDE_NOT_ALWAYS: Int;
	public function toggleSoftInputFromWindow(windowToken: IBinder, showFlags: Int, hideFlags: Int): Void;
	public function hideSoftInputFromWindow(windowToken: IBinder, flags: Int): Bool;
}

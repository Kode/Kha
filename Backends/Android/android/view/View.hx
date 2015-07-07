package android.view;

import android.os.IBinder;

extern class View {
	public function setFocusable(focusable: Bool): Void;
	public function setFocusableInTouchMode(focusableInTouchMode: Bool): Void;
	public function setOnTouchListener(l: ViewOnTouchListener): Void;
	public function getApplicationWindowToken(): IBinder;
}

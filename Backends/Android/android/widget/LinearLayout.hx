package android.widget;

import android.app.Activity;
import android.view.View;

extern class LinearLayout extends View {
	public function new(activity : Activity) : Void;
	public function addView(view : View) : Void;
}
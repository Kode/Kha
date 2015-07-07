package android.view;

import android.content.Context;

extern class SurfaceView extends View {
	public function new(context: Context): Void;
	public function getHolder(): SurfaceHolder;
	public function getWidth(): Int;
	public function getHeight(): Int;
}

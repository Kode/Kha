package android.view;

import android.graphics.Canvas;

extern class SurfaceHolder {
	//public class Callback { }
	public function lockCanvas(canvas : Canvas) : Canvas;
	public function unlockCanvasAndPost(canvas : Canvas) : Void;
}
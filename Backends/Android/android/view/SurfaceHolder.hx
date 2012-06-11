package android.view;

import android.graphics.Canvas;

extern class SurfaceHolder {
	public function lockCanvas(canvas : Canvas) : Canvas;
	public function unlockCanvasAndPost(canvas : Canvas) : Void;
	public function addCallback(callb : SurfaceHolderCallback) : Void;
}
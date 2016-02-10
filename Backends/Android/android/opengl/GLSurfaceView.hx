package android.opengl;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import java.lang.Runnable;

extern class GLSurfaceView extends View {
	//@:overload public function new(context: Context);
	public function new(activity: Activity);
	public function queueEvent(r: Runnable): Void;
	public function onPause(): Void;
	public function onResume(): Void;
	public function setPreserveEGLContextOnPause(preserveOnPause: Bool): Void;
	public function setEGLContextClientVersion(version: Int): Void;
	public function setEGLConfigChooser(redSize: Int, greenSize: Int, blueSize: Int, alphaSize: Int, depthSize: Int, stencilSize: Int): Void;
	public function setRenderer(renderer: GLSurfaceViewRenderer): Void;
}

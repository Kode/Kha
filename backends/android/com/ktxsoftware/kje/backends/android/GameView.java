package com.ktxsoftware.kje.backends.android;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.KeyEvent;
import android.view.MotionEvent;

public class GameView extends GLSurfaceView {
	private OpenGLES20Renderer renderer;
	
	public GameView(Context context) {
		super(context);
		setEGLContextClientVersion(2);
		renderer = new OpenGLES20Renderer(context);
        setRenderer(renderer);
        setFocusable(true);
		requestFocus();
	}

	public boolean onTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			renderer.mouseDown((int)event.getX(), (int)event.getY());
			break;
		case MotionEvent.ACTION_MOVE:
			renderer.mouseMove((int)event.getX(), (int)event.getY());
			break;
		case MotionEvent.ACTION_UP:
			renderer.mouseUp((int)event.getX(), (int)event.getY());
			break;
		}
		return true;
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent msg) {
		if (keyCode == KeyEvent.KEYCODE_BACK && msg.isAltPressed()) return true; //Circle button on Xperia Play
		return renderer.keyDown(keyCode);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent msg) {
		return renderer.keyUp(keyCode);
	}
}
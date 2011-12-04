package com.ktxsoftware.kje.backends.android;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.SurfaceHolder;

public class GameView extends GLSurfaceView /*implements SurfaceHolder.Callback*/ {
	//private GameThread thread;
	//private int lastTouch;

	public GameView(Context context) {
		super(context);
		//SurfaceHolder holder = getHolder();
		//holder.addCallback(this);
		//thread = new GameThread(holder, context, getWidth(), getHeight());
		//setFocusable(true);
		setEGLContextClientVersion(2);
        setRenderer(new OpenGLES20Renderer(context, getWidth(), getHeight()));
	}
/*
	public boolean onTouchEvent(MotionEvent event) {
		//if (gestureDetector == null) setupGestureDetector();
		//gestureDetector.onTouchEvent(event);

		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			thread.mouseDown((int)event.getX(), (int)event.getY());
			break;
		case MotionEvent.ACTION_MOVE:
			thread.mouseMove((int)event.getX(), (int)event.getY());
			break;
		case MotionEvent.ACTION_UP:
			thread.mouseUp((int)event.getX(), (int)event.getY());
			break;
		}
		return true;
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent msg) {
		if (keyCode == KeyEvent.KEYCODE_BACK && msg.isAltPressed()) return true; //Circle button on Xperia Play
		return thread.keyDown(keyCode);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent msg) {
		return thread.keyUp(keyCode);
	}

	@Override
	public void onWindowFocusChanged(boolean hasWindowFocus) {

	}

	public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
		thread.setSurfaceSize(width, height);
	}

	public void surfaceCreated(SurfaceHolder holder) {
		thread.setRunning(true);
		thread.start();
	}

	public void surfaceDestroyed(SurfaceHolder holder) {
		boolean retry = true;
		thread.setRunning(false);
		while (retry) {
			try {
				thread.join();
				retry = false;
			}
			catch (InterruptedException e) {

			}
		}
	}*/
}
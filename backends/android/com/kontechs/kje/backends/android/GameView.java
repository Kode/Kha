package com.kontechs.kje.backends.android;

import android.content.Context;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

class GameView extends SurfaceView implements SurfaceHolder.Callback {
	private GameThread thread;
	private int lastTouch;

	public GameView(Context context) {
		super(context);
		SurfaceHolder holder = getHolder();
		holder.addCallback(this);
		thread = new GameThread(holder, context);
		setFocusable(true);
	}
	
	public boolean onTouchEvent(MotionEvent event) {
		if (event.getAction() == MotionEvent.ACTION_DOWN) {
			if (event.getRawY() < getHeight() / 2) {
				lastTouch = 0;
				thread.keyDown(KeyEvent.KEYCODE_DPAD_UP);
			}
			else if (event.getRawX() < getWidth() / 2) {
				lastTouch = 1;
				thread.keyDown(KeyEvent.KEYCODE_DPAD_LEFT);
			}
			else {
				lastTouch = 2;
				thread.keyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
			}
		}
		else if (event.getAction() == MotionEvent.ACTION_UP) {
			switch (lastTouch) {
			case 0:
				thread.keyUp(KeyEvent.KEYCODE_DPAD_UP);
				break;
			case 1:
				thread.keyUp(KeyEvent.KEYCODE_DPAD_LEFT);
				break;
			case 2:
				thread.keyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
				break;
			}
		}
		return true;
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent msg) {
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
	}
}
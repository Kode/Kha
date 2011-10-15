package com.ktxsoftware.kje.backends.android;

import android.content.Context;
import android.graphics.Canvas;
import android.view.KeyEvent;
import android.view.SurfaceHolder;

import com.ktxsoftware.kje.GameInfo;
import com.ktxsoftware.kje.Key;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Painter;

public class GameThread extends Thread {
	private boolean running = false;
	private SurfaceHolder surface;
	private Context context;
	private com.ktxsoftware.kje.Game game;
	private int width, height;

	public GameThread(SurfaceHolder surface, Context context, int width, int height) {
		this.surface = surface;
		this.context = context;
		this.width = width;
		this.height = height;
	}

	@Override
	public void run() {
		Loader.init(new ResourceLoader(context));
		game = GameInfo.createGame("level1", "tiles");
		Loader.getInstance().load();
		game.postInit();
		
		while (running) {
			Canvas c = null;
			try {
				c = surface.lockCanvas(null);
				Painter p = new CanvasPainter(c, width, height);
				synchronized (surface) {
					updateGame();
					doDraw(p);
				}
			}
			finally {
				if (c != null) surface.unlockCanvasAndPost(c);
			}
		}
	}

	public void setRunning(boolean b) {
		running = b;
	}

	public void setSurfaceSize(int width, int height) {
		synchronized (surface) {
			this.width = width;
			this.height = height;
		}
	}

	boolean keyDown(int keyCode) {
		synchronized (surface) {
			switch (keyCode) {
			case KeyEvent.KEYCODE_DPAD_RIGHT:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.RIGHT, true));
				break;
			case KeyEvent.KEYCODE_DPAD_LEFT:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.LEFT, true));
				break;
			case KeyEvent.KEYCODE_DPAD_CENTER:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.UP, true));
				break;
			case KeyEvent.KEYCODE_DPAD_DOWN:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.DOWN, true));
				break;
			case 99:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.BUTTON_1, true));
				break;
			case 100:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.BUTTON_2, true));
				break;
			default:
				return false;	
			}
			return true;
		}
	}

	boolean keyUp(int keyCode) {
		synchronized (surface) {
			switch (keyCode) {
			case KeyEvent.KEYCODE_DPAD_RIGHT:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.RIGHT, false));
				break;
			case KeyEvent.KEYCODE_DPAD_LEFT:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.LEFT, false));
				break;
			case KeyEvent.KEYCODE_DPAD_CENTER:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.UP, false));
				break;
			case KeyEvent.KEYCODE_DPAD_DOWN:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.DOWN, false));
				break;
			case 99:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.BUTTON_1, false));
				break;
			case 100:
				game.key(new com.ktxsoftware.kje.KeyEvent(Key.BUTTON_2, false));
				break;
			default:
				return false;
			}
			return true;
		}
	}

	private void updateGame() {
		game.update();
	}

	private void doDraw(Painter painter) {
		game.render(painter);
	}
}
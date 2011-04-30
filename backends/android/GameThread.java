package de.hsharz.game;

import android.content.Context;
import android.graphics.Canvas;
import android.view.KeyEvent;
import android.view.SurfaceHolder;
import de.hsharz.game.engine.Key;
import de.hsharz.game.engine.Loader;
import de.hsharz.game.engine.Painter;
import de.hsharz.game.engine.example.ExampleGame;
import de.hsharz.game.engine.zool.ZoolGame;

public class GameThread extends Thread {
	private boolean running = false;
	private SurfaceHolder surface;
	private Context context;
	private de.hsharz.game.engine.Game game;

	public GameThread(SurfaceHolder surface, Context context) {
		this.surface = surface;
		this.context = context;
	}

	@Override
	public void run() {
		de.hsharz.game.engine.System.init(new AndroidSystem());
		Loader.init(new ResourceLoader(context));
		game = new ExampleGame();
		//game = new ZoolGame();
		while (running) {
			Canvas c = null;
			try {
				c = surface.lockCanvas(null);
				Painter p = new CanvasPainter(c);
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

		}
	}

	boolean keyDown(int keyCode) {
		synchronized (surface) {
			switch (keyCode) {
			case KeyEvent.KEYCODE_DPAD_RIGHT:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.RIGHT, true));
				break;
			case KeyEvent.KEYCODE_DPAD_LEFT:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.LEFT, true));
				break;
			case KeyEvent.KEYCODE_DPAD_UP:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.UP, true));
				break;
			case KeyEvent.KEYCODE_DPAD_DOWN:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.DOWN, true));
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
				game.key(new de.hsharz.game.engine.KeyEvent(Key.RIGHT, false));
				break;
			case KeyEvent.KEYCODE_DPAD_LEFT:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.LEFT, false));
				break;
			case KeyEvent.KEYCODE_DPAD_UP:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.UP, false));
				break;
			case KeyEvent.KEYCODE_DPAD_DOWN:
				game.key(new de.hsharz.game.engine.KeyEvent(Key.DOWN, false));
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
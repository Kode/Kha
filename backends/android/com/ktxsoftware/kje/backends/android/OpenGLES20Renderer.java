package com.ktxsoftware.kje.backends.android;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.KeyEvent;

import com.ktxsoftware.kje.GameInfo;
import com.ktxsoftware.kje.Key;
import com.ktxsoftware.kje.Loader;

class OpenGLES20Renderer implements GLSurfaceView.Renderer {
	private com.ktxsoftware.kje.Game game;
	private OpenGLPainter painter;
	
	public OpenGLES20Renderer(Context context) {
		Loader.init(new ResourceLoader(context));
		game = GameInfo.createGame();
		Loader.getInstance().load();
		game.init();
	}

	public void onDrawFrame(GL10 glUnused) {
		synchronized (game) {
			game.update();
			painter.begin();
			game.render(painter);
			painter.end();
		}
	}

	public void onSurfaceChanged(GL10 glUnused, int width, int height) {
		painter = new OpenGLPainter(width, height);
	}

	public void onSurfaceCreated(GL10 glUnused, EGLConfig config) {

	}

	boolean keyDown(int keyCode) {
		synchronized (game) {
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
		synchronized (game) {
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
	
	boolean mouseDown(int x, int y) {
	    synchronized (game) {
	    	game.mouseDown((int)painter.adjustXPosInv(x), (int)painter.adjustYPosInv(y));
	    }
	    return true;
	}
	
	boolean mouseUp(int x, int y) {
	    synchronized (game) {
	    	game.mouseUp((int)painter.adjustXPosInv(x), (int)painter.adjustYPosInv(y));
	    }
	    return true;
	}
	
	boolean mouseMove(int x, int y) {
	    synchronized (game) {
	    	game.mouseMove((int)painter.adjustXPosInv(x), (int)painter.adjustYPosInv(y));
	    }
	    return true;
	}
}
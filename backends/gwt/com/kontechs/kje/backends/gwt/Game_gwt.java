package com.kontechs.kje.backends.gwt;

import com.google.gwt.core.client.Duration;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyDownHandler;
import com.google.gwt.event.dom.client.KeyPressEvent;
import com.google.gwt.event.dom.client.KeyPressHandler;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.kontechs.kje.Game;
import com.kontechs.kje.GameInfo;
import com.kontechs.kje.Key;
import com.kontechs.kje.KeyEvent;
import com.kontechs.kje.Loader;
import com.kontechs.kje.Painter;

public class Game_gwt implements EntryPoint {
	public void onModuleLoad() {
		try {
			Loader.init(new WebLoader());
			GameInfo.createGame("level1", "tiles");
			Loader.getInstance().load();
		}
		catch (Exception ex) {
			AnimationTimer.alert(ex.getMessage());
		}
	}
}

class AnimationTimer extends Timer implements KeyDownHandler, KeyUpHandler, KeyPressHandler {
	private Painter painter;
	private static final int WIDTH = 640;
	private static final int HEIGHT = 550;
	private boolean[] keyreleased;
	public boolean webgl = false;
	
	AnimationTimer() {
		try {
			keyreleased = new boolean[256];
			for (int i = 0; i < 256; ++i) keyreleased[i] = true;
			
			FocusPanel panel = new FocusPanel(); //Canvas can not receive key events in IE9
			RootPanel.get().add(panel);
			try {
				painter = new WebGLPainter(panel, WIDTH, HEIGHT);
				webgl = true;
			}
			catch (Exception ex) {
				painter = new CanvasPainter(panel, WIDTH, HEIGHT);
			}
			panel.addKeyDownHandler(this);
			panel.addKeyUpHandler(this);
			panel.addKeyPressHandler(this);
			panel.setFocus(true);
			
			com.kontechs.kje.System.init(new WebSystem(WIDTH, HEIGHT));
			
			Game.getInstance().postInit();
		}
		catch (Exception ex) {
			alert(ex.getMessage());
		}
		//requestAnimationFrame(this);
		if (webgl) scheduleRepeating(1000 / 60);
		else scheduleRepeating(1000 / 30);
	}
	
	//private native void requestAnimationFrame(AnimationTimer callback) /*-{
	//    var fn = function() { callback.@com.kontechs.kje.backends.gwt.AnimationTimer::run()(); };
	//    if ($wnd.requestAnimationFrame) {
	//      $wnd.requestAnimationFrame(fn);
	//    } else if ($wnd.mozRequestAnimationFrame) {
	//      $wnd.mozRequestAnimationFrame(fn);
	//    } else if ($wnd.webkitRequestAnimationFrame) {
	//      $wnd.webkitRequestAnimationFrame(fn);
	//    } else {
	//      $wnd.setTimeout(fn, 1000 / 60);
	//    }
	//}-*/;
	
	public static native void alert(String msg) /*-{
	  $wnd.alert(msg);
	}-*/;
	
	private void pressKey(int keycode, Key key) {
		if (keyreleased[keycode]) { //avoid auto-repeat
			keyreleased[keycode] = false;
			Game.getInstance().key(new KeyEvent(key, true));
		}
	}
	
	private void releaseKey(int keycode, Key key) {
		keyreleased[keycode] = true;
		Game.getInstance().key(new KeyEvent(key, false));
	}
	
	@Override
	public void onKeyDown(KeyDownEvent event) {
		if (event.isRightArrow()) {
			pressKey(0, Key.RIGHT);
		}
		else if (event.isLeftArrow()) {
			pressKey(1, Key.LEFT);
		}
		else if (event.isUpArrow()) {
			pressKey(2, Key.UP);
		}
		else if (event.isDownArrow()) {
			pressKey(3, Key.DOWN);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_CTRL) {
			pressKey(4, Key.BUTTON_1);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_SHIFT) {
			pressKey(5, Key.BUTTON_2);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_ENTER) {
			pressKey(6, Key.ENTER);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_BACKSPACE) {
			pressKey(7, Key.BACKSPACE);
		}
	}
	
	@Override
	public void onKeyUp(KeyUpEvent event) {
		if (event.isRightArrow()) {
			releaseKey(0, Key.RIGHT);
		}
		else if (event.isLeftArrow()) {
			releaseKey(1, Key.LEFT);
		}
		else if (event.isUpArrow()) {
			releaseKey(2, Key.UP);
		}
		else if (event.isDownArrow()) {
			releaseKey(3, Key.DOWN);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_CTRL) {
			releaseKey(4, Key.BUTTON_1);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_SHIFT) {
			releaseKey(5, Key.BUTTON_2);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_ENTER) {
			releaseKey(6, Key.ENTER);
		}
		else if (event.getNativeKeyCode() == KeyCodes.KEY_BACKSPACE) {
			releaseKey(7, Key.BACKSPACE);
		}
	}
	
	public double time() {
		return Duration.currentTimeMillis();
	}
	
	final double updateRate = 1000 / 60;
	private double accum = 0;
    private double lastTime;
    private final double MAX_DELTA = 1000.0;

	public void run() {
		//requestAnimationFrame(this);
		try {
			double now = time();
			double delta = now - lastTime;
			if (delta > MAX_DELTA) delta = MAX_DELTA;
			lastTime = now;
			accum += delta;
			while (accum > updateRate) {
				Game.getInstance().update();
				accum -= updateRate;
			}
			painter.begin();
			Game.getInstance().render(painter);
			painter.end();
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	@Override
	public void onKeyPress(KeyPressEvent event) {
		Game.getInstance().charKey(event.getCharCode());
	}
}
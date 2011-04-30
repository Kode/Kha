package de.hsharz.game.client;

import com.google.gwt.canvas.client.Canvas;
import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyDownHandler;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.RootPanel;

import de.hsharz.game.engine.Game;
import de.hsharz.game.engine.Key;
import de.hsharz.game.engine.KeyEvent;
import de.hsharz.game.engine.Loader;
import de.hsharz.game.engine.example.ExampleGame;
//import de.hsharz.game.engine.zool.ZoolGame;

public class Game_gwt implements EntryPoint {
	public void onModuleLoad() {
		WebLoader.load();
	}
}

class AnimationTimer extends Timer implements KeyDownHandler, KeyUpHandler {
	private Canvas canvas;
	private Context2d context;
	private CanvasPainter painter;
	private Game game;
	private static final int WIDTH = 640;
	private static final int HEIGHT = 550;
	private boolean[] keyreleased;
	
	AnimationTimer() {
		keyreleased = new boolean[256];
		for (int i = 0; i < 256; ++i) keyreleased[i] = true;
		
		canvas = Canvas.createIfSupported();
		canvas.setWidth(WIDTH + "px");
		canvas.setHeight(HEIGHT + "px");
		canvas.setCoordinateSpaceWidth(WIDTH);
		canvas.setCoordinateSpaceHeight(HEIGHT);
		context = canvas.getContext2d();
		painter = new CanvasPainter(context);

		FocusPanel panel = new FocusPanel(); //Canvas can not receive key events in IE9
		RootPanel.get().add(panel);
		panel.add(canvas);
		panel.addKeyDownHandler(this);
		panel.addKeyUpHandler(this);
		panel.setFocus(true);
		
		de.hsharz.game.engine.System.init(new WebSystem(WIDTH, HEIGHT));
		Loader.init(new WebLoader());
		game = new ExampleGame();
		//game = new ZoolGame();
	}
	
	private void pressKey(int keycode, Key key) {
		if (keyreleased[keycode]) { //avoid auto-repeat
			keyreleased[keycode] = false;
			game.key(new KeyEvent(key, true));
		}
	}
	
	private void releaseKey(int keycode, Key key) {
		keyreleased[keycode] = true;
		game.key(new KeyEvent(key, false));
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
	}

	public void run() {
		try {
			game.update();
			game.update();
			game.render(painter);
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
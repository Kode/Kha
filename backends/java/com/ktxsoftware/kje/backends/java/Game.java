package com.ktxsoftware.kje.backends.java;

import java.awt.BufferCapabilities;
import java.awt.Canvas;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.image.BufferStrategy;
import java.lang.reflect.Constructor;

import javax.swing.JFrame;

import com.ktxsoftware.kje.GameInfo;
import com.ktxsoftware.kje.Key;
import com.ktxsoftware.kje.Loader;

public class Game extends JFrame implements KeyListener, MouseListener, MouseMotionListener {
	private static final long serialVersionUID = 1L;
	public static Game instance;
	private static int WIDTH;
	private static int HEIGHT;
	private static int syncrate = 60;
	
	private Canvas canvas;
	private boolean vsynced = false;
	private com.ktxsoftware.kje.Game game;
	private boolean[] keyreleased;
	private boolean reset = false;
	
	public static Game getInstance() {
		return instance;
	}
	
	public Game() {
		instance = this;
		keyreleased = new boolean[256];
		for (int i = 0; i < 256; ++i) keyreleased[i] = true;
		
		Loader.init(new JavaLoader());
		createGame();
		setupWindow();
		createVSyncedDoubleBuffer();
		mainLoop();
	}
	
	private void setupWindow() {
		setIgnoreRepaint(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		canvas = new Canvas();
		canvas.setIgnoreRepaint(true);
		canvas.setSize(WIDTH, HEIGHT);
		canvas.setFocusable(false);
		add(canvas);
		setResizable(false);
		pack();

		Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();
		setLocation((screen.width - WIDTH) / 2, (screen.height - HEIGHT) / 2);
		
		setTitle("Game");
		
		setVisible(true);
		
		addKeyListener(this);
		canvas.addMouseListener(this);
		canvas.addMouseMotionListener(this);
	}
	
	private void createVSyncedDoubleBuffer() {
		vsynced = true;
		canvas.createBufferStrategy(2);
		BufferStrategy bufferStrategy = canvas.getBufferStrategy();
		if (bufferStrategy != null) {
			BufferCapabilities caps = bufferStrategy.getCapabilities();
			try {
				Class<?> ebcClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities");
				Class<?> vstClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities$VSyncType");

				Constructor<?> ebcConstructor = ebcClass.getConstructor(new Class[] { BufferCapabilities.class, vstClass });
				Object vSyncType = vstClass.getField("VSYNC_ON").get(null);

				BufferCapabilities newCaps = (BufferCapabilities)ebcConstructor.newInstance(new Object[] { caps, vSyncType });

				canvas.createBufferStrategy(2, newCaps);

				//vsynced = true;
				
				//setCanChangeRefreshRate(false);
				//setRefreshRate(60);
			}
			catch (Throwable t) {
				vsynced = false;
				t.printStackTrace();
				canvas.createBufferStrategy(2);
			}
		}
		
		if (vsynced) checkVSync();
	}
	
	private void checkVSync() {
		long starttime = System.nanoTime();
		for (int i = 0; i < 3; ++i) {
			canvas.getBufferStrategy().show();
			Toolkit.getDefaultToolkit().sync();
		}
		long endtime = System.nanoTime();
		if (endtime - starttime > 1000 * 1000 * 1000 / 60) {
			vsynced = true;
			System.out.println("VSync enabled.");
		}
		else System.out.println("VSync not enabled, sorry.");
	}
 
	private void mainLoop() {
		Loader.getInstance().load();
		game.postInit();
		long lasttime = System.nanoTime();
		for (;;) {
			if (vsynced) update();
			else {
				long time = System.nanoTime();
				while (time >= lasttime + 1000 * 1000 * 1000 / syncrate) {
					lasttime += 1000 * 1000 * 1000 / syncrate;
					update();
				}
			}
			render();
			
			if (reset) resetGame();
		}
	}
	
	private void createGame() {
		game = GameInfo.createGame();
		WIDTH = game.getWidth();
		HEIGHT = game.getHeight();
	}
	
	private void resetGame() {
		reset = false;
		createGame();
	}
	
	void update() {
		//System.gc();
		game.update();
	}
 
	private void render() {
		BufferStrategy bf = canvas.getBufferStrategy();
		Graphics2D g = null;
	 
		try {
			g = (Graphics2D)bf.getDrawGraphics();
			JavaPainter painter = new JavaPainter(g);
			game.render(painter);
		}
		finally {
			g.dispose();
		}
	 
		bf.show();
		Toolkit.getDefaultToolkit().sync();
	}
	
	private void pressKey(int keycode, Key key) {
		if (keyreleased[keycode]) { //avoid auto-repeat
			keyreleased[keycode] = false;
			game.key(new com.ktxsoftware.kje.KeyEvent(key, true));
		}
	}
	
	private void releaseKey(int keycode, Key key) {
		keyreleased[keycode] = true;
		game.key(new com.ktxsoftware.kje.KeyEvent(key, false));
	}
	
	@Override
	public void keyPressed(KeyEvent e) {
		int keyCode = e.getKeyCode();
		switch (keyCode) {
		case KeyEvent.VK_RIGHT:
			pressKey(keyCode, Key.RIGHT);
			break;
		case KeyEvent.VK_LEFT:
			pressKey(keyCode, Key.LEFT);
			break;
		case KeyEvent.VK_UP:
			pressKey(keyCode, Key.UP);
			break;
		case KeyEvent.VK_DOWN:
			pressKey(keyCode, Key.DOWN);
			break;
		case KeyEvent.VK_SPACE:
			pressKey(keyCode, Key.BUTTON_1);
			break;
		case KeyEvent.VK_CONTROL:
			pressKey(keyCode, Key.BUTTON_2);
			break;
		case KeyEvent.VK_ENTER:
			pressKey(keyCode, Key.ENTER);
			break;
		case KeyEvent.VK_BACK_SPACE:
			pressKey(keyCode, Key.BACKSPACE);
			break;
		}
	}
	
	
	@Override
	public void keyReleased(KeyEvent e) {
		int keyCode = e.getKeyCode();
		switch (keyCode) {
		case KeyEvent.VK_RIGHT:
			releaseKey(keyCode, Key.RIGHT);
			break;
		case KeyEvent.VK_LEFT:
			releaseKey(keyCode, Key.LEFT);
			break;
		case KeyEvent.VK_UP:
			releaseKey(keyCode, Key.UP);
			break;
		case KeyEvent.VK_DOWN:
			releaseKey(keyCode, Key.DOWN);
			break;
		case KeyEvent.VK_SPACE:
			releaseKey(keyCode, Key.BUTTON_1);
			break;
		case KeyEvent.VK_CONTROL:
			releaseKey(keyCode, Key.BUTTON_2);
			break;
		case KeyEvent.VK_ENTER:
			releaseKey(keyCode, Key.ENTER);
			break;
		case KeyEvent.VK_BACK_SPACE:
			releaseKey(keyCode, Key.BACKSPACE);
			break;
		}
	}
 
	@Override
	public void keyTyped(KeyEvent e) {
		game.charKey(e.getKeyChar());
	}
	
	public static int getSyncrate() {
		return syncrate;
	}
	
	public static void main(String[] args) {
		new Game();
	}

	@Override
	public void mouseClicked(MouseEvent arg0) {
		
	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		
	}

	@Override
	public void mousePressed(MouseEvent arg0) {
		game.mouseDown(arg0.getPoint().x, arg0.getPoint().y);
	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		game.mouseUp(arg0.getPoint().x, arg0.getPoint().y);
	}

	@Override
	public void mouseDragged(MouseEvent arg0) {
		game.mouseMove(arg0.getPoint().x, arg0.getPoint().y);
	}

	@Override
	public void mouseMoved(MouseEvent arg0) {
		if (game != null) game.mouseMove(arg0.getPoint().x, arg0.getPoint().y);
	}
}
package com.kontechs.kje.backends.java;

import java.awt.BufferCapabilities;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.image.BufferStrategy;
import java.lang.reflect.Constructor;

import javax.swing.JFrame;

import com.kontechs.kje.Key;
import com.kontechs.kje.Loader;

public class Game extends JFrame implements KeyListener {
	private static final long serialVersionUID = 1L;
	private static final int WIDTH = 640;
	private static final int HEIGHT = 540;
	private boolean vsynced = false;
	private com.kontechs.kje.Game game;
	private boolean[] keyreleased;
	
	public Game() {
		keyreleased = new boolean[256];
		for (int i = 0; i < 256; ++i) keyreleased[i] = true;
		setupWindow();
		createVSyncedDoubleBuffer();
		mainLoop();
	}
	
	private void setupWindow() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		setSize(WIDTH, HEIGHT);
		Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();
		setLocation((screen.width - WIDTH) / 2, (screen.height - HEIGHT) / 2);
		setResizable(false);
		this.setTitle("Game");
		
		setVisible(true);
		
		setFocusable(true);
		requestFocus();
		addKeyListener(this);
	}
	
	private void createVSyncedDoubleBuffer() {
		createBufferStrategy(2);
		BufferStrategy bufferStrategy = getBufferStrategy();
		if (bufferStrategy != null) {
			BufferCapabilities caps = bufferStrategy.getCapabilities();
			try {
				Class<?> ebcClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities");
				Class<?> vstClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities$VSyncType");

				Constructor<?> ebcConstructor = ebcClass.getConstructor(new Class[] { BufferCapabilities.class, vstClass });
				Object vSyncType = vstClass.getField("VSYNC_ON").get(null);

				BufferCapabilities newCaps = (BufferCapabilities)ebcConstructor.newInstance(new Object[] { caps, vSyncType });

				createBufferStrategy(2, newCaps);

				//vsynced = true;
				
				//setCanChangeRefreshRate(false);
				//setRefreshRate(60);
			}
			catch (Throwable t) {
				t.printStackTrace();
				createBufferStrategy(2);
			}
		}
		
		checkVSync();
	}
	
	private void checkVSync() {
		long starttime = System.nanoTime();
		for (int i = 0; i < 3; ++i) {
			getBufferStrategy().show();
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
		com.kontechs.kje.System.init(new JavaSystem(WIDTH, HEIGHT));
		Loader.init(new JavaLoader());
		game = new com.kontechs.sml.SuperMarioLand();
		//game = new ZoolGame();
		long lasttime = System.nanoTime();
		for (;;) {
			if (vsynced) update();
			else {
				long time = System.nanoTime();
				while (time >= lasttime + 1000 * 1000 * 1000 / 60) {
					lasttime += 1000 * 1000 * 1000 / 60;
					update();
				}
			}
			render();
		}
	}
	
	void update() {
		//System.gc();
		game.update();
	}
 
	private void render() {
		BufferStrategy bf = getBufferStrategy();
		Graphics2D g = null;
	 
		try {
			g = (Graphics2D)bf.getDrawGraphics();
			GraphicsPainter painter = new GraphicsPainter(g);
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
			game.key(new com.kontechs.kje.KeyEvent(key, true));
		}
	}
	
	private void releaseKey(int keycode, Key key) {
		keyreleased[keycode] = true;
		game.key(new com.kontechs.kje.KeyEvent(key, false));
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
		}
	}
 
	@Override
	public void keyTyped(KeyEvent e) {
		
	}
	
	public static void main(String[] args) {
		new Game();
	}
}
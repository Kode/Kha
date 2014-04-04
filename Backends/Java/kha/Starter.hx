package kha;

import kha.Game;
import kha.Key;

@:classCode('
	class Window extends javax.swing.JFrame implements java.awt.event.KeyListener, java.awt.event.MouseListener, java.awt.event.MouseMotionListener, java.awt.event.MouseWheelListener {
		private static final long serialVersionUID = 1L;
		public Window instance;
		private int WIDTH;
		private int HEIGHT;
		private int syncrate = 60;
		private java.awt.Canvas canvas;
		private boolean vsynced = false;
		public kha.Game game;
		private boolean[] keyreleased;
		private boolean reset = false;

		public Window() {
			instance = this;
			keyreleased = new boolean[256];
			for (int i = 0; i < 256; ++i) keyreleased[i] = true;
		}

		public void start() {
			createGame();
			setupWindow();
			createVSyncedDoubleBuffer();
			mainLoop();
		}

		private void setupWindow() {
			setIgnoreRepaint(true);
			setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE);
			canvas = new java.awt.Canvas();
			canvas.setIgnoreRepaint(true);
			canvas.setSize(WIDTH, HEIGHT);
			canvas.setFocusable(false);
			add(canvas);
			setResizable(false);
			pack();
			java.awt.Dimension screen = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
			setLocation((screen.width - WIDTH) / 2, (screen.height - HEIGHT) / 2);
			setTitle("Game");
			setVisible(true);
			addKeyListener(this);
			canvas.addMouseListener(this);
			canvas.addMouseMotionListener(this);
			canvas.addMouseWheelListener(this);
		}

		private void createVSyncedDoubleBuffer() {
			vsynced = true;
			canvas.createBufferStrategy(2);
			java.awt.image.BufferStrategy bufferStrategy = canvas.getBufferStrategy();
			if (bufferStrategy != null) {
				java.awt.BufferCapabilities caps = bufferStrategy.getCapabilities();
				try {
					Class<?> ebcClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities");
					Class<?> vstClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities$VSyncType");
					java.lang.reflect.Constructor<?> ebcConstructor = ebcClass.getConstructor(new Class[] { java.awt.BufferCapabilities.class, vstClass });
					Object vSyncType = vstClass.getField("VSYNC_ON").get(null);
					java.awt.BufferCapabilities newCaps = (java.awt.BufferCapabilities)ebcConstructor.newInstance(new Object[] { caps, vSyncType });
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
				java.awt.Toolkit.getDefaultToolkit().sync();
			}
			long endtime = System.nanoTime();
			if (endtime - starttime > 1000 * 1000 * 1000 / 60) {
				vsynced = true;
				System.out.println("VSync enabled.");
			}
			else System.out.println("VSync not enabled, sorry.");
		}

		private void mainLoop() {
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
			WIDTH = game.width;
			HEIGHT = game.height;
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
			java.awt.image.BufferStrategy bf = canvas.getBufferStrategy();
			java.awt.Graphics2D g = null;
			try {
				g = (java.awt.Graphics2D)bf.getDrawGraphics();
				kha.java.Painter painter = new kha.java.Painter();
				painter.graphics = g;
				painter.setRenderHint();
				game.render(painter);
			}
			finally {
				g.dispose();
			}
			bf.show();
			java.awt.Toolkit.getDefaultToolkit().sync();
		}

		private void pressKey(int keycode, Button button) {
			if (keyreleased[keycode]) { //avoid auto-repeat
				keyreleased[keycode] = false;
				game.buttonDown(button);
			}
		}

		private void releaseKey(int keycode, Button button) {
			keyreleased[keycode] = true;
			game.buttonUp(button);
		}

		@Override
		public void keyPressed(java.awt.event.KeyEvent e) {
			int keyCode = e.getKeyCode();
			switch (keyCode) {
			case java.awt.event.KeyEvent.VK_RIGHT:
				pressKey(keyCode, Button.RIGHT);
				break;
			case java.awt.event.KeyEvent.VK_LEFT:
				pressKey(keyCode, Button.LEFT);
				break;
			case java.awt.event.KeyEvent.VK_UP:
				pressKey(keyCode, Button.UP);
				break;
			case java.awt.event.KeyEvent.VK_DOWN:
				pressKey(keyCode, Button.DOWN);
				break;
			case java.awt.event.KeyEvent.VK_SPACE:
				pressKey(keyCode, Button.BUTTON_1);
				break;
			case java.awt.event.KeyEvent.VK_CONTROL:
				pressKey(keyCode, Button.BUTTON_2);
				break;
			case java.awt.event.KeyEvent.VK_ENTER:
				//pressKey(keyCode, Key.ENTER);
				break;
			case java.awt.event.KeyEvent.VK_BACK_SPACE:
				//pressKey(keyCode, Key.BACKSPACE);
				break;
			}
		}

		@Override
		public void keyReleased(java.awt.event.KeyEvent e) {
			int keyCode = e.getKeyCode();
			switch (keyCode) {
			case java.awt.event.KeyEvent.VK_RIGHT:
				releaseKey(keyCode, Button.RIGHT);
				break;
			case java.awt.event.KeyEvent.VK_LEFT:
				releaseKey(keyCode, Button.LEFT);
				break;
			case java.awt.event.KeyEvent.VK_UP:
				releaseKey(keyCode, Button.UP);
				break;
			case java.awt.event.KeyEvent.VK_DOWN:
				releaseKey(keyCode, Button.DOWN);
				break;
			case java.awt.event.KeyEvent.VK_SPACE:
				releaseKey(keyCode, Button.BUTTON_1);
				break;
			case java.awt.event.KeyEvent.VK_CONTROL:
				releaseKey(keyCode, Button.BUTTON_2);
				break;
			case java.awt.event.KeyEvent.VK_ENTER:
				//releaseKey(keyCode, Key.ENTER);
				break;
			case java.awt.event.KeyEvent.VK_BACK_SPACE:
				//releaseKey(keyCode, Key.BACKSPACE);
				break;
			}
		}
		
		@Override
		public void keyTyped(java.awt.event.KeyEvent e) {
			//game.charKey(e.getKeyChar());
		}

		public int getSyncrate() {
			return syncrate;
		}

		@Override
		public void mouseClicked(java.awt.event.MouseEvent arg0) {

		}

		@Override
		public void mouseEntered(java.awt.event.MouseEvent arg0) {

		}

		@Override
		public void mouseExited(java.awt.event.MouseEvent arg0) {

		}

		@Override
		public void mousePressed(java.awt.event.MouseEvent arg0) {
			mouseX = arg0.getX();
			mouseY = arg0.getY();
			
			if (javax.swing.SwingUtilities.isLeftMouseButton(arg0))
				game.mouseDown(arg0.getX(), arg0.getY());
			else if (javax.swing.SwingUtilities.isRightMouseButton(arg0))
				game.rightMouseDown(arg0.getX(), arg0.getY());
		}

		@Override
		public void mouseReleased(java.awt.event.MouseEvent arg0) {
			mouseX = arg0.getX();
			mouseY = arg0.getY();
			
			if (javax.swing.SwingUtilities.isLeftMouseButton(arg0))
				game.mouseUp(arg0.getX(), arg0.getY());
			else if (javax.swing.SwingUtilities.isRightMouseButton(arg0))
				game.rightMouseUp(arg0.getX(), arg0.getY());
		}

		@Override
		public void mouseDragged(java.awt.event.MouseEvent arg0) {
			mouseX = arg0.getX();
			mouseY = arg0.getY();
			game.mouseMove(arg0.getPoint().x, arg0.getPoint().y);
		}

		@Override
		public void mouseMoved(java.awt.event.MouseEvent arg0) {
			mouseX = arg0.getX();
			mouseY = arg0.getY();
			if (game != null) game.mouseMove(arg0.getPoint().x, arg0.getPoint().y);
		}
		
		@Override
		public void mouseWheelMoved(java.awt.event.MouseWheelEvent arg0) {
			mouseX = arg0.getX();
			mouseY = arg0.getY();
			
			game.mouseWheel(-arg0.getWheelRotation()); //invert
		}
	}

	private Window window;
')
class Starter {
	static var instance: Starter;
	static var game: Game;
	static var painter: kha.java.Painter;
	
	public static var mouseX: Int;
	public static var mouseY: Int;
	
	public function new() {
		instance = this;
		kha.Loader.init(new kha.java.Loader());
		Sys.init();
		Scheduler.init();
	}
	
	public function start(game: Game): Void {
		Starter.game = game;
		Configuration.setScreen(new EmptyScreen(Color.fromBytes(0, 0, 0)));
		Loader.the.loadProject(loadFinished);
	}
	
	public function loadFinished(): Void {
		Loader.the.initProject();
		Sys.pixelWidth = game.width = Loader.the.width;
		Sys.pixelHeight = game.height = Loader.the.height;
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
		startMainLoop();
	}
	
	@:functionCode('
		Window window = instance.new Window();
		window.game = game;
		window.start();
	')
	private static function startMainLoop(): Void {
		
	}
}
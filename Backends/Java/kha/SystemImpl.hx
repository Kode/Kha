package kha;

import kha.System.SystemOptions;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Mouse;
import kha.java.Graphics;
import kha.System;
import kha.Window;
import java.javax.swing.JFrame;
import java.lang.Class;
import java.lang.System in Sys;
import java.lang.Object;
import java.lang.Throwable;
import java.NativeArray;

@:access(kha.System)
class JWindow extends JFrame
implements java.awt.event.KeyListener
implements java.awt.event.MouseListener
implements java.awt.event.MouseMotionListener
implements java.awt.event.MouseWheelListener {
	public var instance: JWindow;
	private var WIDTH: Int;
	private var HEIGHT: Int;
	private var syncrate = 60;
	private var canvas: java.awt.Canvas;
	private var vsynced = false;
	private var reset = false;
	private var framebuffer: kha.Framebuffer;
	private var painter: kha.java.Painter;

	public static var mouseX: Int;
	public static var mouseY: Int;

	public function new() {
		super();
		instance = this;
		painter = new kha.java.Painter();
		framebuffer = new kha.Framebuffer(0, null, painter, null);
		var g1 = new kha.graphics2.Graphics1(framebuffer);
		framebuffer.init(g1, painter, null);
	}

	public function start(): Void {
		createGame();
		setupWindow();
		createVSyncedDoubleBuffer();
		mainLoop();
	}

	private function setupWindow(): Void {
		setIgnoreRepaint(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		canvas = new java.awt.Canvas();
		canvas.setIgnoreRepaint(true);
		canvas.setSize(WIDTH, HEIGHT);
		canvas.setFocusable(false);
		add(canvas);
		setResizable(false);
		pack();
		var screen: java.awt.Dimension = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
		var x = Std.int((screen.width - WIDTH) / 2);
		var y = Std.int((screen.height - HEIGHT) / 2);
		setLocation(x, y);
		setTitle("Game");
		setVisible(true);
		addKeyListener(this);
		canvas.addMouseListener(this);
		canvas.addMouseMotionListener(this);
		canvas.addMouseWheelListener(this);
	}

	private function createVSyncedDoubleBuffer(): Void {
		vsynced = true;
		canvas.createBufferStrategy(2);
		var bufferStrategy: java.awt.image.BufferStrategy = canvas.getBufferStrategy();
		if (bufferStrategy != null) {
			var caps: java.awt.BufferCapabilities = bufferStrategy.getCapabilities();
			try {
				// Class<?>
				var ebcClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities");
				var vstClass = Class.forName("sun.java2d.pipe.hw.ExtendedBufferCapabilities$VSyncType");
				// java.lang.reflect.Constructor<?>
				// new Class[] { java.awt.BufferCapabilities.class, vstClass }
				untyped var _class = untyped __java__("java.awt.BufferCapabilities.class");
				var classes:NativeArray<Class<Dynamic>> = NativeArray.make(_class, vstClass);
				var ebcConstructor = ebcClass.getConstructor(classes);
				var vSyncType: Object = vstClass.getField("VSYNC_ON").get(null);
				// (java.awt.BufferCapabilities)
				// new Object[]
				var objs:NativeArray<Object> = NativeArray.make(cast (caps, Object), vSyncType);
				var newCaps: java.awt.BufferCapabilities = ebcConstructor.newInstance(objs);
				canvas.createBufferStrategy(2, newCaps);
				//setCanChangeRefreshRate(false);
				//setRefreshRate(60);
			}
			catch (t:Throwable) {
				vsynced = false;
				t.printStackTrace();
				canvas.createBufferStrategy(2);
			}
		}
		if (vsynced) checkVSync();
	}

	private function checkVSync(): Void {
		var starttime = Sys.nanoTime();
		for (i in 0...3) {
			canvas.getBufferStrategy().show();
			java.awt.Toolkit.getDefaultToolkit().sync();
		}
		var endtime = Sys.nanoTime();
		if (endtime - starttime > 1000 * 1000 * 1000 / 60) {
			vsynced = true;
			Sys.out.println("VSync enabled.");
		}
		else Sys.out.println("VSync not enabled, sorry.");
	}

	private function mainLoop(): Void {
		var lasttime = Sys.nanoTime();
		while (true) {
			if (vsynced) update();
			else {
				var time = Sys.nanoTime();
				while (time >= lasttime + 1000 * 1000 * 1000 / syncrate) {
					lasttime += 1000 * 1000 * 1000 / syncrate;
					update();
				}
			}
			render();
			if (reset) resetGame();
		}
	}

	private function createGame(): Void {
		WIDTH = System.windowWidth();
		HEIGHT = System.windowHeight();
	}

	private function resetGame(): Void {
		reset = false;
		createGame();
	}

	@:overload
	function update(): Void {
		Scheduler.executeFrame();
	}

	private function render(): Void {
		var bf: java.awt.image.BufferStrategy = canvas.getBufferStrategy();
		var g: java.awt.Graphics2D = null;
		try {
			g = cast bf.getDrawGraphics();
			painter.graphics = g;
			painter.setRenderHint();
			System.render([framebuffer]);
		}
		catch(e: Any) {trace(e);}
		g.dispose();
		bf.show();
		java.awt.Toolkit.getDefaultToolkit().sync();
	}

	@Override
	public function keyPressed(e: java.awt.event.KeyEvent): Void {
		var keyCode: Int = e.getKeyCode();
		// switch (keyCode) {
		// case java.awt.event.KeyEvent.VK_RIGHT:
		// 	pressKey(keyCode, KeyCode.RIGHT);
		// case java.awt.event.KeyEvent.VK_LEFT:
		// 	pressKey(keyCode, KeyCode.LEFT);
		// case java.awt.event.KeyEvent.VK_UP:
		// 	pressKey(keyCode, KeyCode.UP);
		// case java.awt.event.KeyEvent.VK_DOWN:
		// 	pressKey(keyCode, KeyCode.DOWN);
		// case java.awt.event.KeyEvent.VK_SPACE:
		// 	pressKey(keyCode, KeyCode.BUTTON_1);
		// case java.awt.event.KeyEvent.VK_CONTROL:
		// 	pressKey(keyCode, KeyCode.BUTTON_2);
		// case java.awt.event.KeyEvent.VK_ENTER:
		// 	//pressKey(keyCode, Key.ENTER);
		// case java.awt.event.KeyEvent.VK_BACK_SPACE:
		// 	//pressKey(keyCode, Key.BACKSPACE);
		// default:
		// }
	}

	@Override
	public function keyReleased(e: java.awt.event.KeyEvent): Void {
		var keyCode: Int = e.getKeyCode();
		// switch (keyCode) {
		// case java.awt.event.KeyEvent.VK_RIGHT:
		// 	releaseKey(keyCode, KeyCode.RIGHT);
		// case java.awt.event.KeyEvent.VK_LEFT:
		// 	releaseKey(keyCode, KeyCode.LEFT);
		// case java.awt.event.KeyEvent.VK_UP:
		// 	releaseKey(keyCode, KeyCode.UP);
		// case java.awt.event.KeyEvent.VK_DOWN:
		// 	releaseKey(keyCode, KeyCode.DOWN);
		// case java.awt.event.KeyEvent.VK_SPACE:
		// 	releaseKey(keyCode, KeyCode.BUTTON_1);
		// case java.awt.event.KeyEvent.VK_CONTROL:
		// 	releaseKey(keyCode, KeyCode.BUTTON_2);
		// case java.awt.event.KeyEvent.VK_ENTER:
		// 	//releaseKey(keyCode, Key.ENTER);
		// case java.awt.event.KeyEvent.VK_BACK_SPACE:
		// 	//releaseKey(keyCode, Key.BACKSPACE);
		// default:
		// }
	}

	@Override
	public function keyTyped(e: java.awt.event.KeyEvent): Void {
		//game.charKey(e.getKeyChar());
	}

	public function getSyncrate(): Int {
		return syncrate;
	}

	@Override
	public function mouseClicked(arg0: java.awt.event.MouseEvent): Void {

	}

	@Override
	public function mouseEntered(arg0: java.awt.event.MouseEvent): Void {

	}

	@Override
	public function mouseExited(arg0: java.awt.event.MouseEvent): Void {

	}

	@Override
	public function mousePressed(arg0: java.awt.event.MouseEvent): Void {
		mouseX = arg0.getX();
		mouseY = arg0.getY();

		// if (javax.swing.SwingUtilities.isLeftMouseButton(arg0))
		// 	game.mouseDown(arg0.getX(), arg0.getY());
		// else if (javax.swing.SwingUtilities.isRightMouseButton(arg0))
		// 	game.rightMouseDown(arg0.getX(), arg0.getY());
	}

	@Override
	public function mouseReleased(arg0: java.awt.event.MouseEvent): Void {
		mouseX = arg0.getX();
		mouseY = arg0.getY();

		// if (javax.swing.SwingUtilities.isLeftMouseButton(arg0))
		// 	game.mouseUp(arg0.getX(), arg0.getY());
		// else if (javax.swing.SwingUtilities.isRightMouseButton(arg0))
		// 	game.rightMouseUp(arg0.getX(), arg0.getY());
	}

	@Override
	public function mouseDragged(arg0: java.awt.event.MouseEvent): Void {
		mouseX = arg0.getX();
		mouseY = arg0.getY();
		// game.mouseMove(arg0.getPoint().x, arg0.getPoint().y);
	}

	@Override
	public function mouseMoved(arg0: java.awt.event.MouseEvent): Void {
		mouseX = arg0.getX();
		mouseY = arg0.getY();
		// if (game != null) game.mouseMove(arg0.getPoint().x, arg0.getPoint().y);
	}

	@Override
	public function mouseWheelMoved(arg0: java.awt.event.MouseWheelEvent): Void {
		mouseX = arg0.getX();
		mouseY = arg0.getY();

		// game.mouseWheel(-arg0.getWheelRotation()); //invert
	}
}

@:allow(kha.SystemImpl.JWindow)
class SystemImpl {
	public static var graphics(default, null): Graphics;
	private static var keyboard: Keyboard;
	private static var mouse: Mouse;
	private static var keyreleased: Array<Bool>;

	public static function init(options: SystemOptions, callback: Window -> Void) {
		init2();
		Scheduler.init();
		if (options.width != -1) myPixelWidth = options.width;
		if (options.height != -1) myPixelHeight = options.height;

		var window = new Window(options.width, options.height);
		Scheduler.start();
		callback(window);
		var jWindow = new JWindow();
		jWindow.start();
	}

	public static function initEx(title: String, options: Array<WindowOptions>, windowCallback: Int -> Void, callback: Window -> Void) {
		init({title: title, width: options[0].width, height: options[0].height}, callback);
	}

	private static var startTime: Float;

	public static function init2(): Void {
		graphics = new Graphics();
		startTime = getTimestamp();
		mouse = new Mouse();
		keyboard = new Keyboard();
		keyreleased = [for (i in 0...256) true];
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num == 0) return keyboard;
		else return null;
	}

	public static function getMouse(num: Int): Mouse {
		if (num == 0) return mouse;
		else return null;
	}

	private function pressKey(keyCode: Int, button: KeyCode): Void {
		if (keyreleased[keyCode]) { //avoid auto-repeat
			keyreleased[keyCode] = false;
			keyboard.sendDownEvent(button);
		}
	}

	private function releaseKey(keyCode: Int, button: KeyCode): Void {
		keyreleased[keyCode] = true;
		keyboard.sendUpEvent(button);
	}

	public static function getFrequency(): Int {
		return 1000;
	}

	public static function getTimestamp(): Float {
		return cast java.lang.System.currentTimeMillis();
	}

	public static function getTime(): Float {
		return (getTimestamp() - startTime) / getFrequency();
	}

	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}

	public static function getVsync(): Bool {
		return true;
	}

	public static function getRefreshRate(): Int {
		return 60;
	}

	public static function getSystemId(): String {
		return "java";
	}

	public static function vibrate(ms:Int): Void {

	}

	public static function getLanguage(): String {
		return java.util.Locale.getDefault().getLanguage();
	}

	private static var myPixelWidth = 640;
	private static var myPixelHeight = 480;

	public static function windowWidth(id: Int): Int {
		return myPixelWidth;
	}

	public static function windowHeight(id: Int): Int {
		return myPixelHeight;
	}

	public static function screenDpi(): Int {
		return 96;
	}

	public static function changeResolution(width: Int, height: Int): Void {

	}

	public static function requestShutdown(): Bool {
		return false;
	}

	public static function canSwitchFullscreen(): Bool {
		return false;
	}

	public static function isFullscreen(): Bool{
		return false;
	}

	public static function requestFullscreen(): Void {

	}

	public static function exitFullscreen(): Void {

	}

	public static function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void{

	}


	public static function removeFromFullscreenChange(func: Void -> Void, error : Void -> Void): Void{

	}

	public function lockMouse(): Void {

	}

	public function unlockMouse(): Void {

	}

	public function canLockMouse(): Bool {
		return false;
	}

	public function isMouseLocked(): Bool {
		return false;
	}

	public function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {

	}


	public function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void): Void {

	}

	public static function setKeepScreenOn(on: Bool): Void {

	}

	public static function loadUrl(url: String): Void {

	}

	public static function safeZone(): Float {
		return 1.0;
	}
}

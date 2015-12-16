package kha;

import kha.input.Mouse;
import kha.wpf.Graphics;
import system.diagnostics.Stopwatch;
import kha.input.Keyboard;
import kha.Key;
import system.windows.controls.Canvas;
import system.windows.FrameworkElement;

@:classCode('
		protected override void OnRender(global::System.Windows.Media.DrawingContext drawingContext) {
			base.OnRender(drawingContext);
			
			if (kha.SystemImpl.painter != null) {
				kha.SystemImpl.painter.context = drawingContext;
				//Starter.painter.begin();
				System.render(SystemImpl.framebuffer);
				//if (drawMousePos) {
				//	Starter.painter.setColor(unchecked((int)0xFFFFFFFF));
				//	Starter.painter.fillRect(mousePosX - 5, mousePosY - 5, 10, 10);
				//	Starter.painter.setColor(unchecked((int)0xFF000000));
				//	Starter.painter.drawRect(mousePosX - 5, mousePosY - 5, 10, 10, default(global::haxe.lang.Null<double>));
				//}
				//Starter.painter.end();
			}
			//global::System.GC.Collect();
		}
')
class StoryPublishCanvas extends system.windows.controls.Canvas {
	private var mousePosX: Int;
	private var mousePosY: Int;
	public var drawMousePos: Bool;
	
	public function setMousePos(posX: Int, posY: Int): Void {
		mousePosX = posX;
		mousePosY = posY;
	}
}

@:classCode('
	private global::System.Collections.Generic.HashSet<global::System.Windows.Input.Key> pressedKeys = new global::System.Collections.Generic.HashSet<global::System.Windows.Input.Key>();

	void CompositionTarget_Rendering(object sender, global::System.EventArgs e) {
		double widthTransform = canvas.ActualWidth / kha.System.get_pixelWidth();
		double heightTransform = canvas.ActualHeight / kha.System.get_pixelHeight();
		double transform = global::System.Math.Min(widthTransform, heightTransform);
		canvas.RenderTransform = new global::System.Windows.Media.ScaleTransform(transform, transform);
		Scheduler.executeFrame(); // Main loop
		canvas.InvalidateVisual();
		InvalidateVisual();
	}
	
	protected override void OnTextInput(global::System.Windows.Input.TextCompositionEventArgs e) {
		base.OnTextInput(e);
		kha.SystemImpl.OnTextInput(e);
	}
	
	protected override void OnKeyDown(global::System.Windows.Input.KeyEventArgs e) {
		base.OnKeyDown(e);
		kha.SystemImpl.OnKeyDown(e);
	}

	protected override void OnKeyUp(global::System.Windows.Input.KeyEventArgs e) {
		base.OnKeyUp(e);
		kha.SystemImpl.OnKeyUp(e);
	}
	
	protected override void OnClosed(global::System.EventArgs e) {
		base.OnClosed(e);
		
		//Game.the.onPause();
		//Game.the.onBackground();
		//Game.the.onShutdown();
	}

	protected override void OnMouseDown(global::System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseDown(e);
		kha.SystemImpl.OnMouseDown(e);
	}

	protected override void OnMouseUp(global::System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseUp(e);
		kha.SystemImpl.OnMouseUp(e);
	}

	protected override void OnMouseMove(global::System.Windows.Input.MouseEventArgs e) {
		base.OnMouseMove(e);
		kha.SystemImpl.OnMouseMove(e);
	}
	
	protected override void OnMouseWheel(global::System.Windows.Input.MouseWheelEventArgs e) {
		base.OnMouseWheel(e);
		kha.SystemImpl.OnMouseWheel(e);
	}
')
class MainWindow extends system.windows.Window {
	public var canvas: StoryPublishCanvas;
	
	@:functionCode('
		canvas = new StoryPublishCanvas();
		AddChild(canvas);
		
		Title = title;
		resize(width, height);
		
		// Go fullscreen
		//WindowStyle = global::System.Windows.WindowStyle.None;
		//WindowState = global::System.Windows.WindowState.Maximized;
		
		Background = new global::System.Windows.Media.SolidColorBrush(global::System.Windows.Media.Color.FromArgb(0, 0, 0, 0));
		global::System.Windows.Media.CompositionTarget.Rendering += new global::System.EventHandler(CompositionTarget_Rendering);
	')
	public function new(title: String, width: Int, height: Int) {
		
	}
	
	@:functionCode('
		Width = width + (global::System.Windows.SystemParameters.ResizeFrameVerticalBorderWidth * 2);
		Height = height + global::System.Windows.SystemParameters.WindowCaptionHeight + (global::System.Windows.SystemParameters.ResizeFrameHorizontalBorderHeight * 2);
	')
	public function resize(width: Int, height: Int): Void {
		
	}
}

@:classCode('
	private static global::System.Collections.Generic.HashSet<global::System.Windows.Input.Key> pressedKeys = new global::System.Collections.Generic.HashSet<global::System.Windows.Input.Key>();

	public static void OnTextInput(global::System.Windows.Input.TextCompositionEventArgs e) {
		if (!global::System.String.IsNullOrEmpty(e.Text)) {
			// Used for text input since KeyEventArgs does not provide a string representation
			// Printable characters only
			if (e.Text != "") {
				char[] chararray = e.Text.ToCharArray();
				int c = global::System.Convert.ToInt32((char)chararray[0]);
				if (c >= 32) {
					keyboard.sendDownEvent(Key.CHAR, e.Text);
				}
			}
		}
	}
	
	public static void OnKeyDown(global::System.Windows.Input.KeyEventArgs e) {
		if (pressedKeys.Contains(e.Key)) return;
		pressedKeys.Add(e.Key);

		switch (e.Key) {
			case global::System.Windows.Input.Key.Back:
				keyboard.sendDownEvent(Key.BACKSPACE, null);
				break;
			case global::System.Windows.Input.Key.Enter:
				keyboard.sendDownEvent(Key.ENTER, null);
				break;
			case global::System.Windows.Input.Key.Escape:
				keyboard.sendDownEvent(Key.ESC, null);
				break;
			case global::System.Windows.Input.Key.Delete:
				keyboard.sendDownEvent(Key.DEL, null);
				break;
			case global::System.Windows.Input.Key.Up:
				keyboard.sendDownEvent(Key.UP, null);
				break;
			case global::System.Windows.Input.Key.Down:
				keyboard.sendDownEvent(Key.DOWN, null);
				break;
			case global::System.Windows.Input.Key.Left:
				keyboard.sendDownEvent(Key.LEFT, null);
				break;
			case global::System.Windows.Input.Key.Right:
				keyboard.sendDownEvent(Key.RIGHT, null);
				break;
		}
	}
	
	public static void OnKeyDown(Key key, string c) {
		//Game.the.keyDown(key, c);
	}

	public static void OnKeyUp(global::System.Windows.Input.KeyEventArgs e) {
		pressedKeys.Remove(e.Key);

		switch (e.Key) {
			case global::System.Windows.Input.Key.Back:
				keyboard.sendUpEvent(Key.BACKSPACE, null);
				break;
			case global::System.Windows.Input.Key.Enter:
				keyboard.sendUpEvent(Key.ENTER, null);
				break;
			case global::System.Windows.Input.Key.Escape:
				keyboard.sendUpEvent(Key.ESC, null);
				break;
			case global::System.Windows.Input.Key.Delete:
				keyboard.sendUpEvent(Key.DEL, null);
				break;
			case global::System.Windows.Input.Key.Up:
				keyboard.sendUpEvent(Key.UP, null);
				break;
			case global::System.Windows.Input.Key.Down:
				keyboard.sendUpEvent(Key.DOWN, null);
				break;
			case global::System.Windows.Input.Key.Left:
				keyboard.sendUpEvent(Key.LEFT, null);
				break;
			case global::System.Windows.Input.Key.Right:
				keyboard.sendUpEvent(Key.RIGHT, null);
				break;
		}
	}

	public static void OnMouseDown(global::System.Windows.Input.MouseButtonEventArgs e) {
		if (e.ChangedButton == global::System.Windows.Input.MouseButton.Left) {
			kha.SystemImpl.mouseDown((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
		else if (e.ChangedButton == global::System.Windows.Input.MouseButton.Right) {
			kha.SystemImpl.rightMouseDown((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
		
	}

	public static void OnMouseUp(global::System.Windows.Input.MouseButtonEventArgs e) {
		if (e.ChangedButton == global::System.Windows.Input.MouseButton.Left) {
			kha.SystemImpl.mouseUp((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
		else if (e.ChangedButton == global::System.Windows.Input.MouseButton.Right) {
			kha.SystemImpl.rightMouseUp((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
	}

	public static void OnMouseMove(global::System.Windows.Input.MouseEventArgs e) {
		kha.SystemImpl.mouseMove((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
	}
	
	public static void OnMouseWheel(global::System.Windows.Input.MouseWheelEventArgs e) {
		kha.SystemImpl.mouseWheel((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y, e.Delta / 120);
	}
')
class SystemImpl {
	private static var watch: Stopwatch;
	
	public static var graphics(default, null): kha.wpf.Graphics;
	
	public static var screenRotation: ScreenRotation = ScreenRotation.RotationNone;
	
	public static function init2(): Void {
		graphics = new Graphics();
		watch = new Stopwatch();
		watch.Start();
	}
	
	public static function getMouse(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}

	public static function getKeyboard(num: Int): Keyboard {
		if (num != 0) return null;
		return keyboard;
	}
	
	private static var mainWindow: MainWindow;
	private static var openWindow: Bool = true;
	private static var autostartGame: Bool = true;
	private static var showMousePos: Bool = false;
	private static var painter: kha.wpf.Painter;
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private static var title: String;
	public static var frameworkElement: StoryPublishCanvas;
	
	public static function init(title: String, width: Int, height: Int, callback: Void -> Void) {
		SystemImpl.title = title;
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		init2();
		Scheduler.init();
		
		//Sys.pixelWidth = gameToStart.width = Loader.the.width;
		//Sys.pixelHeight = gameToStart.height = Loader.the.height;
		// TODO: Clean exit with error message if width and heiht is invalid (e.g. error: width and height must be set in project.kha)
		if (openWindow) {
			mainWindow = new MainWindow(title, width, height);
			frameworkElement = mainWindow.canvas;
		}
		painter = new kha.wpf.Painter(width, height);
		framebuffer = new Framebuffer(null, painter, null);
		Scheduler.start();
		//if (autostartGame) gameToStart.loadFinished();
		
		callback();
		
		if (openWindow) {
			startWindow();
		}
		else if (frameworkElement != null) {
			frameworkElement.drawMousePos = SystemImpl.showMousePos;
		}
	}
	
	public static function configure(path: String, openWindow: Bool, autostartGame: Bool, showMousePos: Bool, forceBusyCursor: Bool) {
		SystemImpl.openWindow = openWindow;
		SystemImpl.autostartGame = autostartGame;
		SystemImpl.showMousePos = showMousePos;
		LoaderImpl.path = path;
		LoaderImpl.forceBusyCursor = forceBusyCursor;
	}
	
	@:functionCode('global::System.Windows.MessageBox.Show(msg, "Exeption", global::System.Windows.MessageBoxButton.OK, global::System.Windows.MessageBoxImage.Error);')
	private static function displayErrorMessage(msg: String) {
		
	}
	
	public static function lockMouse(): Void {
		
	}
	
	public static function unlockMouse(): Void {
		
	}

	public static function canLockMouse(): Bool {
		return false;
	}

	public static function isMouseLocked(): Bool {
		return false;
	}

	public static function notifyOfMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public static function removeFromMouseLockChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	@:functionCode('
		if (global::System.Windows.Application.Current == null) {
			new global::System.Windows.Application().Run(mainWindow);
		}
	')
	static function startWindow(): Void {
		
	}
	
	public static var mouseX: Int;
	public static var mouseY: Int;
	
	public static function mouseDown(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendDownEvent(0, x, y);
		frameworkElement.setMousePos(x, y);
	}

	public static function mouseUp(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendUpEvent(0, x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function rightMouseDown(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendDownEvent(1, x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function rightMouseUp(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendUpEvent(1, x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function mouseMove(x: Int, y: Int): Void {
		var movementX = x - mouseX;
		var movementY = y - mouseY;
		mouseX = x;
		mouseY = y;
		mouse.sendMoveEvent(x, y, movementX, movementY);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function mouseWheel(x: Int, y: Int, delta: Int): Void {
		mouseX = x;
		mouseY = y;
		mouse.sendWheelEvent(delta);
		frameworkElement.setMousePos(x, y);
	}
	
	@:functionCode('
		return watch.ElapsedMilliseconds / 1000.0;
	')
	public static function getTime(): Float {
		return 0;
	}
	
	public static function getVsync(): Bool {
		return true;
	}
	
	public static function getRefreshRate(): Int {
		return 60;
	}
	
	public static function getScreenRotation(): ScreenRotation {
		return ScreenRotation.RotationNone;
	}
	
	@:functionCode('return (int)mainWindow.canvas.ActualWidth;')
	public static function getPixelWidth(): Int {
		return 0;
	}
	
	@:functionCode('return (int)mainWindow.canvas.ActualHeight;')
	public static function getPixelHeight(): Int {
		return 0;
	}
	
	public static function getSystemId(): String {
		return "WPF";
	}
	
	@:functionCode('global::System.Windows.Application.Current.Shutdown();')
	public static function requestShutdown(): Void {
		
	}

	public static function canSwitchFullscreen(): Bool {
		return false;
	}

	public static function isFullscreen(): Bool {
		return false;
	}

	public static function requestFullscreen(): Void {
		
	}

	public static function exitFullscreen(): Void {
		
  	}

	public function notifyOfFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}

	public function removeFromFullscreenChange(func: Void -> Void, error: Void -> Void): Void {
		
	}
	
	//@:functionCode('mainWindow.resize(width, height);')
	public static function changeResolution(width: Int, height: Int): Void {
		painter.width = width;
		painter.height = height;
	}
}

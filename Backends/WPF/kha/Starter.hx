package kha;

import kha.Game;
import kha.input.Keyboard;
import kha.Key;
import system.windows.controls.Canvas;
import system.windows.FrameworkElement;

@:classCode('
		protected override void OnRender(System.Windows.Media.DrawingContext drawingContext) {
			base.OnRender(drawingContext);
			
			if (kha.Starter.painter != null && Configuration.screen() != null) {
				Starter.painter.context = drawingContext;
				//Starter.painter.begin();
				Configuration.screen().render(Starter.framebuffer);
				//if (drawMousePos) {
				//	Starter.painter.setColor(unchecked((int)0xFFFFFFFF));
				//	Starter.painter.fillRect(mousePosX - 5, mousePosY - 5, 10, 10);
				//	Starter.painter.setColor(unchecked((int)0xFF000000));
				//	Starter.painter.drawRect(mousePosX - 5, mousePosY - 5, 10, 10, default(global::haxe.lang.Null<double>));
				//}
				//Starter.painter.end();
			}
			System.GC.Collect();
		}
')
class StoryPublishCanvas extends system.windows.controls.Canvas {
	var mousePosX : Int;
	var mousePosY : Int;
	public var drawMousePos : Bool;
	
	public function setMousePos(posX : Int, posY : Int) : Void {
		mousePosX = posX;
		mousePosY = posY;
	}
}

@:classCode('
	private System.Collections.Generic.HashSet<System.Windows.Input.Key> pressedKeys = new System.Collections.Generic.HashSet<System.Windows.Input.Key>();

	void CompositionTarget_Rendering(object sender, System.EventArgs e) {
		double widthTransform = canvas.ActualWidth/Game.the.width;
		double heightTransform = canvas.ActualHeight/Game.the.height;
		double transform = System.Math.Min(widthTransform, heightTransform);
		canvas.RenderTransform = new System.Windows.Media.ScaleTransform(transform, transform);
		Scheduler.executeFrame(); // Main loop
		canvas.InvalidateVisual();
		InvalidateVisual();
	}
	
	protected override void OnTextInput(System.Windows.Input.TextCompositionEventArgs e) {
		base.OnTextInput(e);
		
		Starter.OnTextInput(e);
	}
	
	protected override void OnKeyDown(System.Windows.Input.KeyEventArgs e) {
		base.OnKeyDown(e);

		Starter.OnKeyDown(e);
	}

	protected override void OnKeyUp(System.Windows.Input.KeyEventArgs e) {
		base.OnKeyUp(e);

		Starter.OnKeyUp(e);
	}
	
	protected override void OnClosed(System.EventArgs e) {
		base.OnClosed(e);
		
		Game.the.onPause();
		Game.the.onBackground();
		Game.the.onShutdown();
	}

	protected override void OnMouseDown(System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseDown(e);
		
		Starter.OnMouseDown(e);
	}

	protected override void OnMouseUp(System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseUp(e);
		
		Starter.OnMouseUp(e);
	}

	protected override void OnMouseMove(System.Windows.Input.MouseEventArgs e) {
		base.OnMouseMove(e);
		
		Starter.OnMouseMove(e);
	}
	
	protected override void OnMouseWheel(System.Windows.Input.MouseWheelEventArgs e) {
		base.OnMouseWheel(e);

		Starter.OnMouseWheel(e);
	}
')
class MainWindow extends system.windows.Window {
	public var canvas : StoryPublishCanvas;
	
	@:functionCode('
		canvas = new StoryPublishCanvas();
		AddChild(canvas);
		
		Width = kha.Game.the.width + (System.Windows.SystemParameters.ResizeFrameVerticalBorderWidth * 2);
		Height = kha.Game.the.height + System.Windows.SystemParameters.WindowCaptionHeight + (System.Windows.SystemParameters.ResizeFrameHorizontalBorderHeight * 2);
		
		// Go fullscreen
		//WindowStyle = System.Windows.WindowStyle.None;
		//WindowState = System.Windows.WindowState.Maximized;
		
		Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(0, 0, 0, 0));
		System.Windows.Media.CompositionTarget.Rendering += new System.EventHandler(CompositionTarget_Rendering);
	')
	public function new() {
		
	}
}

@:classCode('
	private static System.Collections.Generic.HashSet<System.Windows.Input.Key> pressedKeys = new System.Collections.Generic.HashSet<System.Windows.Input.Key>();

	public static void OnTextInput(System.Windows.Input.TextCompositionEventArgs e) {
		if (!System.String.IsNullOrEmpty(e.Text)) {
			// Used for text input since KeyEventArgs does not provide a string representation
			// Printable characters only
			if (e.Text != "") {
				char[] chararray = e.Text.ToCharArray();
				int c = System.Convert.ToInt32((char)chararray[0]);
				if (c > 32) {
					Game.the.keyDown(Key.CHAR, e.Text);
					keyboard.sendDownEvent(Key.CHAR, e.Text);
				}
			}
		}
	}
	
	public static void OnKeyDown(System.Windows.Input.KeyEventArgs e) {
		if (pressedKeys.Contains(e.Key)) return;
		pressedKeys.Add(e.Key);

		switch (e.Key) {
			case System.Windows.Input.Key.Back:
				Game.the.keyDown(Key.BACKSPACE, null);
				keyboard.sendDownEvent(Key.BACKSPACE, null);
				break;
			case System.Windows.Input.Key.Enter:
				Game.the.keyDown(Key.ENTER, "");
				keyboard.sendDownEvent(Key.ENTER, null);
				break;
			case System.Windows.Input.Key.Escape:
				Game.the.keyDown(Key.ESC, "");
				keyboard.sendDownEvent(Key.ESC, null);
				break;
			case System.Windows.Input.Key.Delete:
				Game.the.keyDown(Key.DEL, "");
				keyboard.sendDownEvent(Key.DEL, null);
				break;
			case System.Windows.Input.Key.Up:
				Game.the.buttonDown(Button.UP);
				Game.the.keyDown(Key.UP, null);
				keyboard.sendDownEvent(Key.UP, null);
				break;
			case System.Windows.Input.Key.Down:
				Game.the.buttonDown(Button.DOWN);
				Game.the.keyDown(Key.DOWN, null);
				keyboard.sendDownEvent(Key.DOWN, null);
				break;
			case System.Windows.Input.Key.Left:
				Game.the.buttonDown(Button.LEFT);
				Game.the.keyDown(Key.LEFT, null);
				keyboard.sendDownEvent(Key.LEFT, null);
				break;
			case System.Windows.Input.Key.Right:
				Game.the.buttonDown(Button.RIGHT);
				Game.the.keyDown(Key.RIGHT, null);
				keyboard.sendDownEvent(Key.RIGHT, null);
				break;
		}
	}
	
	public static void OnKeyDown(Key key, string c) {
		Game.the.keyDown(key, c);
	}

	public static void OnKeyUp(System.Windows.Input.KeyEventArgs e) {
		pressedKeys.Remove(e.Key);

		switch (e.Key) {
			case System.Windows.Input.Key.Back:
				Game.the.keyUp(Key.BACKSPACE, null);
				keyboard.sendUpEvent(Key.BACKSPACE, null);
				break;
			case System.Windows.Input.Key.Enter:
				Game.the.keyUp(Key.ENTER, null);
				keyboard.sendUpEvent(Key.ENTER, null);
				break;
			case System.Windows.Input.Key.Escape:
				Game.the.keyUp(Key.ESC, null);
				keyboard.sendUpEvent(Key.ESC, null);
				break;
			case System.Windows.Input.Key.Delete:
				Game.the.keyUp(Key.DEL, null);
				keyboard.sendUpEvent(Key.DEL, null);
				break;
			case System.Windows.Input.Key.Up:
				Game.the.buttonUp(Button.UP);
				Game.the.keyUp(Key.UP, null);
				keyboard.sendUpEvent(Key.UP, null);
				break;
			case System.Windows.Input.Key.Down:
				Game.the.buttonUp(Button.DOWN);
				Game.the.keyUp(Key.DOWN, null);
				keyboard.sendUpEvent(Key.DOWN, null);
				break;
			case System.Windows.Input.Key.Left:
				Game.the.buttonUp(Button.LEFT);
				Game.the.keyUp(Key.LEFT, null);
				keyboard.sendUpEvent(Key.LEFT, null);
				break;
			case System.Windows.Input.Key.Right:
				Game.the.buttonUp(Button.RIGHT);
				Game.the.keyUp(Key.RIGHT, null);
				keyboard.sendUpEvent(Key.RIGHT, null);
				break;
		}
	}

	public static void OnMouseDown(System.Windows.Input.MouseButtonEventArgs e) {
		if (e.ChangedButton == System.Windows.Input.MouseButton.Left) {
			Starter.mouseDown((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
		else if (e.ChangedButton == System.Windows.Input.MouseButton.Right) {
			Starter.rightMouseDown((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
		
	}

	public static void OnMouseUp(System.Windows.Input.MouseButtonEventArgs e) {
		if (e.ChangedButton == System.Windows.Input.MouseButton.Left) {
			Starter.mouseUp((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
		else if (e.ChangedButton == System.Windows.Input.MouseButton.Right) {
			Starter.rightMouseUp((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
		}
	}

	public static void OnMouseMove(System.Windows.Input.MouseEventArgs e) {
		Starter.mouseMove((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
	}
	
	public static void OnMouseWheel(System.Windows.Input.MouseWheelEventArgs e) {
		Starter.mouseWheel((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y, e.Delta / 120);
	}
')
class Starter {
	private static var mainWindow: MainWindow;
	private static var openWindow: Bool = true;
	private static var autostartGame: Bool = true;
	private static var showMousePos: Bool = false;
	private static var painter: kha.wpf.Painter;
	private static var framebuffer: Framebuffer;
	private static var keyboard: Keyboard;
	private static var mouse: kha.input.Mouse;
	private var gameToStart: Game;
	public static var frameworkElement: StoryPublishCanvas;
	
	public function new() {
		keyboard = new Keyboard();
		mouse = new kha.input.Mouse();
		kha.Loader.init(new kha.wpf.Loader());
		Sys.init();
		Scheduler.init();
	}
	
	public static function configure(path : String, openWindow : Bool, autostartGame : Bool, showMousePos : Bool, forceBusyCursor : Bool) {
		Starter.openWindow = openWindow;
		Starter.autostartGame = autostartGame;
		Starter.showMousePos = showMousePos;
		kha.wpf.Loader.path = path;
		kha.wpf.Loader.forceBusyCursor = forceBusyCursor;
	}
	
	public function start(game: Game) {
		#if !debug
		try {
		#end
			gameToStart = game;
			Loader.the.loadProject(loadFinished);
		#if !debug
		}
		catch (unknown: Dynamic) {
			if (openWindow)
				displayErrorMessage("Unknown exception : " + Std.string(unknown));
			else
				cs.Lib.rethrow(unknown);
		}
		#end
	}
	
	@:functionCode('
	System.Windows.MessageBox.Show(msg, "Exeption", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
	')
	private static function displayErrorMessage(msg : String) {
		
	}
	
	public function loadFinished() {
		Loader.the.initProject();
		Sys.pixelWidth = gameToStart.width = Loader.the.width;
		Sys.pixelHeight = gameToStart.height = Loader.the.height;
		// TODO: Clean exit with error message if width and heiht is invalid (e.g. error: width and height must be set in project.kha)
		if (openWindow) {
			mainWindow = new MainWindow();
			Starter.frameworkElement = mainWindow.canvas;
		}
		Configuration.setScreen(gameToStart);
		painter = new kha.wpf.Painter(Sys.pixelWidth, Sys.pixelHeight);
		framebuffer = new Framebuffer(painter, null);
		Scheduler.start();
		if (autostartGame)
			gameToStart.loadFinished();
		if (openWindow) {
			startWindow();
		} else if (frameworkElement != null) {
			frameworkElement.drawMousePos = Starter.showMousePos;
		}
	}

	@:functionCode('
		new System.Windows.Application().Run(mainWindow);
	')
	static function startWindow() : Void {
		
	}
	
	public static var mouseX: Int;
	public static var mouseY: Int;
	
	public static function mouseDown(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseDown(x, y);
		mouse.sendDownEvent(0, x, y);
		frameworkElement.setMousePos(x, y);
	}

	public static function mouseUp(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseUp(x, y);
		mouse.sendUpEvent(0, x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function rightMouseDown(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.rightMouseDown(x, y);
		mouse.sendDownEvent(1, x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function rightMouseUp(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.rightMouseUp(x, y);
		mouse.sendUpEvent(1, x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function mouseMove(x: Int, y: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseMove(x, y);
		mouse.sendMoveEvent(x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function mouseWheel(x: Int, y: Int, delta: Int): Void {
		mouseX = x;
		mouseY = y;
		Game.the.mouseWheel(delta);
		mouse.sendWheelEvent(delta);
		frameworkElement.setMousePos(x, y);
	}
}

package kha;

import kha.Game;
import kha.Key;
import system.windows.controls.Canvas;
import system.windows.FrameworkElement;

@:classCode('
	protected override void OnRender(System.Windows.Media.DrawingContext drawingContext) {
		base.OnRender(drawingContext);

		if (kha.Starter.painter != null && kha.Starter.game != null && Configuration.screen() != null) {
			Starter.painter.context = drawingContext;
			Starter.painter.begin();
			Configuration.screen().render(Starter.painter);
			if (drawMousePos) {
				Starter.painter.setColor(kha.Color.fromBytes(255, 255, 255, default(global::haxe.lang.Null<int>)));
				Starter.painter.fillRect(mousePosX - 5, mousePosY - 5, 10, 10);
				Starter.painter.setColor(kha.Color.fromBytes(0, 0, 0, default(global::haxe.lang.Null<int>)));
				Starter.painter.drawRect(mousePosX - 5, mousePosY - 5, 10, 10, default(global::haxe.lang.Null<double>));
			}
			Starter.painter.end();
		}
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
		double widthTransform = canvas.ActualWidth/Starter.game.width;
		double heightTransform = canvas.ActualHeight/Starter.game.height;
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
		
		Starter.game.onClose();
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
')
class MainWindow extends system.windows.Window {
	public var canvas : StoryPublishCanvas;
	
	@:functionCode('
		canvas = new StoryPublishCanvas();
        canvas.Width = Game.the.width;
        canvas.Height = Game.the.height;
        AddChild(canvas);
        
		System.Windows.Data.Binding widthBinding = new System.Windows.Data.Binding {
			RelativeSource = new System.Windows.Data.RelativeSource(System.Windows.Data.RelativeSourceMode.FindAncestor, typeof(System.Windows.Controls.UserControl), 1),
			Path = new System.Windows.PropertyPath("ActualWidth"),
		};
		canvas.SetBinding(System.Windows.Controls.Canvas.WidthProperty, widthBinding);
		
		System.Windows.Data.Binding heightBinding = new System.Windows.Data.Binding {
			RelativeSource = new System.Windows.Data.RelativeSource(System.Windows.Data.RelativeSourceMode.FindAncestor, typeof(System.Windows.Controls.UserControl), 1),
			Path = new System.Windows.PropertyPath("ActualHeight"),
		};

		canvas.SetBinding(System.Windows.Controls.Canvas.HeightProperty, heightBinding);
		
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
				if (c > 32)
					game.keyDown(Key.CHAR, e.Text);
			}
		}
	}
	
	public static void OnKeyDown(System.Windows.Input.KeyEventArgs e) {
		if (pressedKeys.Contains(e.Key))
			return;
		pressedKeys.Add(e.Key);

		switch (e.Key)
		{
			case System.Windows.Input.Key.Back:
				game.keyDown(Key.BACKSPACE, "");
				break;
			case System.Windows.Input.Key.Enter:
				game.keyDown(Key.ENTER, "");
				break;
			case System.Windows.Input.Key.Escape:
				game.keyDown(Key.ESC, "");
				break;
			case System.Windows.Input.Key.Delete:
				game.keyDown(Key.DEL, "");
				break;
			case System.Windows.Input.Key.Up:
				game.buttonDown(Button.UP);
				break;
			case System.Windows.Input.Key.Down:
				game.buttonDown(Button.DOWN);
				break;
			case System.Windows.Input.Key.Left:
				game.buttonDown(Button.LEFT);
				break;
			case System.Windows.Input.Key.Right:
				game.buttonDown(Button.RIGHT);
				break;
			case System.Windows.Input.Key.A:
				game.buttonDown(Button.BUTTON_1);
				break;
		}
	}
	
	public static void OnKeyDown(Key key, string c) {
		game.keyDown(key, c);
	}

	public static void OnKeyUp(System.Windows.Input.KeyEventArgs e) {
		pressedKeys.Remove(e.Key);

		switch (e.Key) {
			case System.Windows.Input.Key.Back:
				game.keyUp(Key.BACKSPACE, "");
				break;
			case System.Windows.Input.Key.Enter:
				game.keyUp(Key.ENTER, "");
				break;
			case System.Windows.Input.Key.Escape:
				game.keyUp(Key.ESC, "");
				break;
			case System.Windows.Input.Key.Delete:
				game.keyUp(Key.DEL, "");
				break;
			case System.Windows.Input.Key.Up:
				game.buttonUp(Button.UP);
				break;
			case System.Windows.Input.Key.Down:
				game.buttonUp(Button.DOWN);
				break;
			case System.Windows.Input.Key.Left:
				game.buttonUp(Button.LEFT);
				break;
			case System.Windows.Input.Key.Right:
				game.buttonUp(Button.RIGHT);
				break;
			case System.Windows.Input.Key.A:
				game.buttonUp(Button.BUTTON_1);
				break;
		}
	}

	public static void OnMouseDown(System.Windows.Input.MouseButtonEventArgs e) {
		Starter.mouseDown((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
	}

	public static void OnMouseUp(System.Windows.Input.MouseButtonEventArgs e) {
		Starter.mouseUp((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
	}

	public static void OnMouseMove(System.Windows.Input.MouseEventArgs e) {
		Starter.mouseMove((int)e.GetPosition(frameworkElement).X, (int)e.GetPosition(frameworkElement).Y);
	}
	
	public static void OnClosed(System.EventArgs e) {
		game.onClose();
	}
')
class Starter {
	static var mainWindow : MainWindow;
	static var openWindow : Bool = true;
	static var autostartGame : Bool = true;
	static var showMousePos : Bool = false;
	static var painter : kha.wpf.Painter;
	public static var game : Game;
	public static var frameworkElement : StoryPublishCanvas;
	
	public function new() {
		kha.Storage.init(new kha.wpf.Storage());
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
		try {
			Starter.game = game;
			Loader.the.loadProject(loadFinished);
		}
		catch (unknown: Dynamic) {
			if (openWindow)
				displayErrorMessage("Unknown exception : " + Std.string(unknown));
			else
				throw unknown;
		}
	}
	
	@:functionCode('
	System.Windows.MessageBox.Show(msg, "Exeption", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
	')
	private static function displayErrorMessage(msg : String) {
		
	}
	
	public static function loadFinished() {
		Loader.the.initProject();
		game.width = Loader.the.width;
		game.height = Loader.the.height;
		// TODO: Clean exit with error message if width and heiht is invalid (e.g. error: width and height must be set in project.kha)
		if (openWindow) {
			mainWindow = new MainWindow();
			Starter.frameworkElement = mainWindow.canvas;
		}
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		painter = new kha.wpf.Painter();
		Scheduler.start();
		if (autostartGame)
			game.loadFinished();
		if (openWindow)
			startWindow();
		Starter.frameworkElement.drawMousePos = Starter.showMousePos;
	}

	@:functionCode('
		new System.Windows.Application().Run(mainWindow);
	')
	static function startWindow() : Void {
		
	}
	
	public static function pushUp() : Void {
		game.buttonDown(Button.UP);
	}
	
	public static function pushDown() : Void {
		game.buttonDown(Button.DOWN);
	}

	public static function pushLeft() : Void {
		game.buttonDown(Button.LEFT);
	}

	public static function pushRight() : Void {
		game.buttonDown(Button.RIGHT);
	}
	
	public static function pushButton1() : Void {
		game.buttonDown(Button.BUTTON_1);
	}

	public static function releaseUp() : Void {
		game.buttonUp(Button.UP);
	}

	public static function releaseDown() : Void {
		game.buttonUp(Button.DOWN);
	}

	public static function releaseLeft() : Void {
		game.buttonUp(Button.LEFT);
	}
	
	public static function releaseRight() : Void {
		game.buttonUp(Button.RIGHT);
	}
	
	public static function releaseButton1() : Void {
		game.buttonUp(Button.BUTTON_1);
	}	
	
	public static function mouseDown(x : Int, y : Int) : Void {
		game.mouseDown(x, y);
		frameworkElement.setMousePos(x, y);
	}

	public static function mouseUp(x : Int, y : Int) : Void {
		game.mouseUp(x, y);
		frameworkElement.setMousePos(x, y);
	}
	
	public static function mouseMove(x : Int, y : Int) : Void {
		game.mouseMove(x, y);
		frameworkElement.setMousePos(x, y);
	}
}
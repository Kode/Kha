package kha;

import kha.Game;
import kha.Key;
import system.windows.controls.Canvas;
import system.windows.FrameworkElement;

@:classContents('
	protected override void OnRender(System.Windows.Media.DrawingContext drawingContext) {
		base.OnRender(drawingContext);

		if (kha.Starter.painter != null && kha.Starter.game != null) {
			Starter.painter.context = drawingContext;
			Starter.painter.begin();
			Configuration.screen().render(Starter.painter);
			if (drawMousePos) {
				Starter.painter.setColor(255, 255, 255);
				Starter.painter.fillRect(mousePosX - 5, mousePosY - 5, 10, 10);
				Starter.painter.setColor(0, 0, 0);
				Starter.painter.drawRect(mousePosX - 5, mousePosY - 5, 10, 10);
			}
			Starter.painter.end();
		}
	}
')
class StoryPublishCanvas extends system.windows.controls.Canvas {
	var mousePosX : Int;
	var mousePosY : Int;
	var drawMousePos : Bool;
	
	public function setMousePos(posX : Int, posY : Int) : Void {
		mousePosX = posX;
		mousePosY = posY;
	}
}

@:classContents('
	private System.Collections.Generic.HashSet<System.Windows.Input.Key> pressedKeys = new System.Collections.Generic.HashSet<System.Windows.Input.Key>();

	void CompositionTarget_Rendering(object sender, System.EventArgs e) {
		double widthTransform = canvas.ActualWidth/Starter.game.getWidth();
		double heightTransform = canvas.ActualHeight/Starter.game.getHeight();
		double transform = System.Math.Min(widthTransform, heightTransform);
		canvas.RenderTransform = new System.Windows.Media.ScaleTransform(transform, transform);
		Configuration.screen().update();
		canvas.InvalidateVisual();
		InvalidateVisual();
	}

	protected override void OnMouseDown(System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseDown(e);
		Starter.mouseDown((int)e.GetPosition(canvas).X, (int)e.GetPosition(canvas).Y);
	}

	protected override void OnMouseUp(System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseUp(e);
		Starter.mouseUp((int)e.GetPosition(canvas).X, (int)e.GetPosition(canvas).Y);
	}

	protected override void OnMouseMove(System.Windows.Input.MouseEventArgs e) {
		base.OnMouseMove(e);
		Starter.mouseMove((int)e.GetPosition(canvas).X, (int)e.GetPosition(canvas).Y);
	}

	
	protected override void OnTextInput(System.Windows.Input.TextCompositionEventArgs e) {
		// Used for text input since KeyEventArgs does not provide a string representation
		base.OnTextInput(e);
		
		// Printable characters only
		char[] chararray = e.Text.ToCharArray();
		int c = System.Convert.ToInt32((char)chararray[0]);
		if (c > 32)
			kha.Starter.game.keyDown(Key.CHAR, e.Text);
	}
	
	protected override void OnKeyDown(System.Windows.Input.KeyEventArgs e) {
		base.OnKeyDown(e);

		if (pressedKeys.Contains(e.Key))
			return;
		pressedKeys.Add(e.Key);

		switch (e.Key)
		{
			case System.Windows.Input.Key.Back:
				kha.Starter.game.keyDown(Key.BACKSPACE, "");
				break;
			case System.Windows.Input.Key.Enter:
				kha.Starter.game.keyDown(Key.ENTER, "");
				break;
			case System.Windows.Input.Key.Up:
				kha.Starter.game.buttonDown(Button.UP);
				break;
			case System.Windows.Input.Key.Down:
				kha.Starter.game.buttonDown(Button.DOWN);
				break;
			case System.Windows.Input.Key.Left:
				kha.Starter.game.buttonDown(Button.LEFT);
				break;
			case System.Windows.Input.Key.Right:
				kha.Starter.game.buttonDown(Button.RIGHT);
				break;
			case System.Windows.Input.Key.A:
				kha.Starter.game.buttonDown(Button.BUTTON_1);
				break;
		}
	}

	protected override void OnKeyUp(System.Windows.Input.KeyEventArgs e) {
		base.OnKeyUp(e);

		pressedKeys.Remove(e.Key);

		switch (e.Key) {
			case System.Windows.Input.Key.Back:
				kha.Starter.game.keyUp(Key.BACKSPACE, "");
				break;
			case System.Windows.Input.Key.Enter:
				kha.Starter.game.keyUp(Key.ENTER, "");
				break;
			case System.Windows.Input.Key.Up:
				kha.Starter.game.buttonUp(Button.UP);
				break;
			case System.Windows.Input.Key.Down:
				kha.Starter.game.buttonUp(Button.DOWN);
				break;
			case System.Windows.Input.Key.Left:
				kha.Starter.game.buttonUp(Button.LEFT);
				break;
			case System.Windows.Input.Key.Right:
				kha.Starter.game.buttonUp(Button.RIGHT);
				break;
			case System.Windows.Input.Key.A:
				kha.Starter.game.buttonUp(Button.BUTTON_1);
				break;
		}
	}
')
class MainWindow extends system.windows.Window {
	public var canvas : StoryPublishCanvas;
	
	@:functionBody('
		canvas = new StoryPublishCanvas();
        canvas.Width = Game.getInstance().getWidth();
        canvas.Height = Game.getInstance().getHeight();
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
		
		Width = kha.Game.getInstance().getWidth() + (System.Windows.SystemParameters.ResizeFrameVerticalBorderWidth * 2);
        Height = kha.Game.getInstance().getHeight() + System.Windows.SystemParameters.WindowCaptionHeight + (System.Windows.SystemParameters.ResizeFrameHorizontalBorderHeight * 2);
		
		Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(0, 0, 0, 0));
		System.Windows.Media.CompositionTarget.Rendering += new System.EventHandler(CompositionTarget_Rendering);
	')
	public function new() {
		
	}
}

class Starter {
	static var game: Game;
	static var mainWindow : MainWindow;
	static var openWindow : Bool = true;
	public static var painter : kha.wpf.Painter;
	public static var frameworkElement: StoryPublishCanvas;
	
	public function new() {
		kha.Storage.init(new kha.wpf.Storage());
		kha.Loader.init(new kha.wpf.Loader());
	}
	
	public static function configure(path : String, openWindow : Bool, forceBusyCursor : Bool, suppressLogging : Bool, suppressRandomSeed : Bool) {
		Starter.openWindow = openWindow;
		kha.wpf.Loader.path = path;
		kha.wpf.Loader.forceBusyCursor = forceBusyCursor;
        //Player.suppressLogging = suppressLogging;
		//Player.suppressRandomSeed = suppressRandomSeed;
	}
	
	public function start(game: Game) {
		try {
			if (openWindow) {
				mainWindow = new MainWindow();
				Starter.frameworkElement = mainWindow.canvas;
			}
			Starter.game = game;
			Configuration.setScreen(new EmptyScreen(game.getWidth(), game.getHeight(), new Color(0, 0, 0)));
			Loader.the().loadProject(loadFinished);
		}
		catch (unknown: Dynamic) {
			if (openWindow)
				displayErrorMessage("Unknown exception : " + Std.string(unknown));
			else
				throw unknown;
		}
	}
	
	@:functionBody('
	System.Windows.MessageBox.Show(msg, "Exeption", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
	')
	private function displayErrorMessage(msg : String) {
		
	}
	
	public static function loadFinished() {
		if (Loader.getInstance().getWidth() > 0 && Loader.getInstance().getHeight() > 0) {
			game.setWidth(Loader.getInstance().getWidth());
			game.setHeight(Loader.getInstance().getHeight());
		}
		Loader.the().initProject();
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		painter = new kha.wpf.Painter();
		game.loadFinished();
		if (openWindow)
			startWindow();
	}

	@:functionBody('
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
	
	public static function keyDown(key : Key, c : String) : Void {
		game.keyDown(key, c);
	}
}
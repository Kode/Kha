package kha;

import kha.Game;
import kha.Key;
import system.windows.FrameworkElement;

@:classContents('
	private System.Collections.Generic.HashSet<System.Windows.Input.Key> pressedKeys = new System.Collections.Generic.HashSet<System.Windows.Input.Key>();

	void CompositionTarget_Rendering(object sender, System.EventArgs e) {
		Starter.game.update();
		InvalidateVisual();
	}

	protected override void OnRender(System.Windows.Media.DrawingContext drawingContext) {
		base.OnRender(drawingContext);
		Starter.painter.context = drawingContext;
		Starter.painter.begin();
		Starter.game.render(Starter.painter);
		Starter.painter.end();
	}

	protected override void OnMouseDown(System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseDown(e);
		Starter.mouseDown((int)e.GetPosition(this).X, (int)e.GetPosition(this).Y);
	}

	protected override void OnMouseUp(System.Windows.Input.MouseButtonEventArgs e) {
		base.OnMouseUp(e);
		Starter.mouseUp((int)e.GetPosition(this).X, (int)e.GetPosition(this).Y);
	}

	protected override void OnMouseMove(System.Windows.Input.MouseEventArgs e) {
		base.OnMouseMove(e);
		Starter.mouseMove((int)e.GetPosition(this).X, (int)e.GetPosition(this).Y);
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
	@:functionBody('
		Width = 1000;
		Height = 600;
		Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(0, 0, 0, 0));
		System.Windows.Media.CompositionTarget.Rendering += new System.EventHandler(CompositionTarget_Rendering);
	')
	public function new() {
		
	}
}

class Starter {
	static var game : Game;
	static var mainWindow : MainWindow;
	static var openWindow : Bool = true;
	public static var painter : kha.wpf.Painter;
	public static var frameworkElement: FrameworkElement;
	
	public function new() {
		kha.Storage.init(new kha.wpf.Storage());
		kha.Loader.init(new kha.wpf.Loader());
	}
	
	public static function configure(openWindow : Bool, path : String) {
		Starter.openWindow = openWindow;
		kha.wpf.Loader.path = path;
	}
	
	public function start(game : Game) {
		if (openWindow) {
			mainWindow = new MainWindow();
			Starter.frameworkElement = mainWindow;
		}
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		game.loadFinished();
		painter = new kha.wpf.Painter();
		
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
	}

	public static function mouseUp(x : Int, y : Int) : Void {
		game.mouseUp(x, y);
	}
	
	public static function mouseMove(x : Int, y : Int) : Void {
		game.mouseMove(x, y);
	}
}
package kha;

import kha.Game;
import kha.Key;

@:classContents('
	class MainWindow : System.Windows.Window {
		public MainWindow() {
			Width = 1000;
			Height = 600;
			Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromArgb(0, 0, 0, 0));
			System.Windows.Media.CompositionTarget.Rendering += new System.EventHandler(CompositionTarget_Rendering);
		}

		void CompositionTarget_Rendering(object sender, System.EventArgs e) {
			Starter.game.update();
			InvalidateVisual();
		}

		protected override void OnRender(System.Windows.Media.DrawingContext drawingContext) {
			base.OnRender(drawingContext);
			Starter.painter.context = drawingContext;
			Starter.painter.begin();
			Starter.game.render(painter);
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
	}
')
class Starter {
	static var game : Game;
	static var painter : kha.wpf.Painter;
	static var openWindow : Bool = true;
	
	public function new() {
		kha.Loader.init(new kha.wpf.Loader());
	}
	
	public function start(game : Game) {
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
		new System.Windows.Application().Run(new MainWindow());
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
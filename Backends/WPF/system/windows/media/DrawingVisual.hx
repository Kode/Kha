package system.windows.media;

@:native("System.Windows.Media.DrawingVisual")
extern class DrawingVisual {
	public function new();
	public function RenderOpen(): DrawingContext;
}

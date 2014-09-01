package system.windows.media;

@:native("System.Windows.Media.DrawingContext")
extern class DrawingContext {
	public function PushTransform(transform: MatrixTransform): Void;
	public function Pop(): Void;
}

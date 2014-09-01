package system.windows.media;

@:native("System.Windows.Media.MatrixTransform")
extern class MatrixTransform {
	public function new(m11: Float, m12: Float, m21: Float, m22: Float, offsetX: Float, offsetY: Float);
}

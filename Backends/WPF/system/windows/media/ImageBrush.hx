package system.windows.media;

@:native("System.Windows.Media.ImageBrush")
extern class ImageBrush {
	//public function new();
	public function new(source: ImageSource);
	public var ImageSource(get, set): ImageSource;
	private function get_ImageSource(): ImageSource;
	private function set_ImageSource(source: ImageSource): ImageSource;
}

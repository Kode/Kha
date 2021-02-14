package system.windows.media;

@:native("System.Windows.Media.ImageBrush")
extern class ImageBrush {
	// public function new();
	public function new(source: ImageSource);
	public var ImageSource(get, set): ImageSource;
	function get_ImageSource(): ImageSource;
	function set_ImageSource(source: ImageSource): ImageSource;
}

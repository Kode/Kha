package kha.wpf;

import system.windows.media.imaging.BitmapImage;

class Image implements kha.Image {
	public var image : BitmapImage;
	
	@:functionCode('
		image = new System.Windows.Media.Imaging.BitmapImage(new System.Uri(filename, System.UriKind.Relative));
	')
	public function new(filename : String) {
		
	}

	@:functionCode('
		return image.PixelWidth;
	')
	public function getWidth() : Int {
		return 0;
	}
	
	@:functionCode('
		return image.PixelHeight;
	')
	public function getHeight() : Int {
		return 0;
	}
	
	@:functionCode('
		if (x < 0 || y < 0 || x >= image.PixelWidth || y >= image.PixelHeight)
            return false;
		
		byte[] pixels = new byte[8];
		image.CopyPixels(new System.Windows.Int32Rect(x, y, 1, 1), pixels, image.PixelWidth * 4, 0);
		return pixels[0] > 0;
	')
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
	
	public function unload(): Void {
		image = null;
	}
}
package kha.wpf;

import kha.graphics.Texture;
import system.windows.media.imaging.BitmapImage;

class Image implements kha.Image {
	public var image: BitmapImage;
	
	@:functionBody('
		image = new System.Windows.Media.Imaging.BitmapImage(new System.Uri(filename, System.UriKind.Relative));
	')
	public function new(filename: String) {
		
	}

	@:functionBody('
		return image.PixelWidth;
	')
	public function getWidth(): Int {
		return 0;
	}
	
	@:functionBody('
		return image.PixelHeight;
	')
	public function getHeight(): Int {
		return 0;
	}
	
	@:functionBody('
		if (x < 0 || y < 0 || x >= image.PixelWidth || y >= image.PixelHeight)
            return false;
		
		byte[] pixels = new byte[8];
		image.CopyPixels(new System.Windows.Int32Rect(x, y, 1, 1), pixels, image.PixelWidth * 4, 0);
		return pixels[0] > 0;
	')
	public function isOpaque(x: Int, y: Int) : Bool {
		return true;
	}
	
	public function unload(): Void {
		image = null;
	}
	
	public function getTexture(): Texture {
		return null;
	}

	public function setTexture(texture: Texture): Void {
		
	}
}
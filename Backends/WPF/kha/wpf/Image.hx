package kha.wpf;

import haxe.io.Bytes;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;
import system.windows.media.imaging.BitmapSource;

class Image implements Texture {
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	
	public var image: BitmapSource;
	
	public function new(width: Int, height: Int, format: TextureFormat) {
		myWidth = width;
		myHeight = height;
		this.format = format;
	}
	
	@:functionCode('
		System.Windows.Media.Imaging.BitmapImage image = new System.Windows.Media.Imaging.BitmapImage(new System.Uri(filename, System.UriKind.Relative));
		return fromImage(image, image.PixelWidth, image.PixelHeight);
	')
	public static function fromFilename(filename: String): Image {
		return null;
	}
	
	public static function fromImage(image: Dynamic, width: Int, height: Int): Image {
		var img = new Image(width, height, TextureFormat.RGBA32);
		img.image = image;
		return img;
	}
	
	public var width(get, null): Int;
	
	public function get_width(): Int {
		return myWidth;
	}

	public var height(get, null): Int;
	
	public function get_height(): Int {
		return myHeight;
	}
	
	public var realWidth(get, null): Int;
	
	public function get_realWidth(): Int {
		return width;
	}
	
	public var realHeight(get, null): Int;
	
	public function get_realHeight(): Int {
		return height;
	}
	
	@:functionCode('
		if (x < 0 || y < 0 || x >= image.PixelWidth || y >= image.PixelHeight)
            return false;
		
		byte[] pixels = new byte[8];
		image.CopyPixels(new System.Windows.Int32Rect(x, y, 1, 1), pixels, image.PixelWidth * 4, 0);
		return pixels[3] > 0;
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
	
	public var bytes: Bytes;
	
	public function lock(): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}
	
	@:functionCode('
		System.Windows.Media.PixelFormat pf = System.Windows.Media.PixelFormats.Bgra32;
		int rawStride = (myWidth * pf.BitsPerPixel + 7) / 8;
		var bgra = new byte[myWidth * myHeight * 4];
		for (int y = 0; y < myHeight; ++y) {
			for (int x = 0; x < myWidth; ++x) {
				bgra[y * myWidth * 4 + x * 4 + 0] = 0;
				bgra[y * myWidth * 4 + x * 4 + 1] = 0;
				bgra[y * myWidth * 4 + x * 4 + 2] = 0;
				bgra[y * myWidth * 4 + x * 4 + 3] = bytes.b[y * myWidth + x];
			}
		}
		image = System.Windows.Media.Imaging.BitmapSource.Create(myWidth, myHeight, 96, 96, pf, null, bgra, rawStride);
	')
	public function unlock(): Void {
		
	}
}

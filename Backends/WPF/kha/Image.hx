package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.hxsl.Globals;
import kha.wpf.Painter;
import system.windows.media.DrawingVisual;
import system.windows.media.ImageBrush;
import system.windows.media.imaging.BitmapSource;

class Image implements Resource {
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	private var painter: Painter;
	public var image: BitmapSource;
	public var brush: ImageBrush;
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format);
	}
	
	@:functionCode('
		global::System.Windows.Media.Imaging.RenderTargetBitmap image = new global::System.Windows.Media.Imaging.RenderTargetBitmap(width, height, 96, 96, global::System.Windows.Media.PixelFormats.Pbgra32);
		return fromImage(image, image.PixelWidth, image.PixelHeight);
	')
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		return null;
	}
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}
	
	public function new(width: Int, height: Int, format: TextureFormat) {
		myWidth = width;
		myHeight = height;
		this.format = format;
	}
	
	@:functionCode('
		global::System.Windows.Media.Imaging.BitmapImage image = new global::System.Windows.Media.Imaging.BitmapImage(new global::System.Uri(filename, global::System.UriKind.Relative));
		return fromImage(image, image.PixelWidth, image.PixelHeight);
	')
	public static function fromFilename(filename: String): Image {
		return null;
	}
	
	public static function fromImage(image: Dynamic, width: Int, height: Int): Image {
		var img = new Image(width, height, TextureFormat.RGBA32);
		img.image = image;
		img.brush = new ImageBrush(image);
		return img;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		if (painter == null) {
			painter = new Painter(width, height);
			painter.image = image;
			painter.visual = new DrawingVisual();
		}
		return painter;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics { return null; }
	
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
		image.CopyPixels(new global::System.Windows.Int32Rect(x, y, 1, 1), pixels, image.PixelWidth * 4, 0);
		return pixels[3] > 0;
	')
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	public function at(x: Int, y: Int): Int {
		return 0;
	}
	
	public function unload(): Void {
		image = null;
	}
	
	//public function getTexture(): Texture {
	//	return null;
	//}

	//public function setTexture(texture: Texture): Void {
	//	
	//}
	
	public var bytes: Bytes;
	
	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}
	
	@:functionCode('
		global::System.Windows.Media.PixelFormat pf = global::System.Windows.Media.PixelFormats.Bgra32;
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
		image = global::System.Windows.Media.Imaging.BitmapSource.Create(myWidth, myHeight, 96, 96, pf, null, bgra, rawStride);
		brush = new global::System.Windows.Media.ImageBrush(image);
	')
	public function unlock(): Void {
		
	}

	public function generateMipmaps(levels: Int): Void {
		
	}

	public function setMipmaps(mipmaps: Array<Image>): Void {
		
	}

	public function setDepthStencilFrom(image: Image): Void {
		
	}
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 4096;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return true;
	}
}

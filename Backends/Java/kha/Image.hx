package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.java.Painter;

@:classCode('
	public java.awt.image.BufferedImage image;
')
class Image implements Canvas implements Resource {
	var painter: Painter;
	var graphics1: kha.graphics1.Graphics;

	public function new(filename: String) {}

	@:functionCode('
		image.image = new java.awt.image.BufferedImage(width, height, format == 0 ? 10 : 6);
	')
	static function create2(image: Image, width: Int, height: Int, format: Int): Void {}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var img = new Image(null);
		create2(img, width, height, format == TextureFormat.L8 ? 0 : 1);
		return img;
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false,
			antiAliasingSamples: Int = 1): Image {
		var img = new Image(null);
		create2(img, width, height, format == TextureFormat.L8 ? 0 : 1);
		return img;
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	public var g2(get, never): kha.graphics2.Graphics;

	@:functionCode('
		painter.graphics = image.createGraphics();
	')
	function initPainter(painter: Painter): Void {}

	function get_g2(): kha.graphics2.Graphics {
		if (painter == null) {
			painter = new Painter();
			initPainter(painter);
		}
		return painter;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		return null;
	}

	public var width(get, never): Int;

	@:functionCode('
		return image.getWidth(null);
	')
	function get_width(): Int {
		return 0;
	}

	public var height(get, never): Int;

	@:functionCode('
		return image.getHeight(null);
	')
	function get_height(): Int {
		return 0;
	}

	public var depth(get, never): Int;

	function get_depth(): Int {
		return 1;
	}

	public var format(get, never): TextureFormat;

	@:functionCode('
		return image.getType();
	')
	function get_format(): TextureFormat {
		return TextureFormat.RGBA32;
	}

	public var realWidth(get, never): Int;

	function get_realWidth(): Int {
		return width;
	}

	public var realHeight(get, never): Int;

	function get_realHeight(): Int {
		return height;
	}

	public var stride(get, never): Int;

	function get_stride(): Int {
		return realWidth * 4;
	}

	@:functionCode('
		if (x >= 0 && x < get_width() && y >= 0 && y < get_height()) {
			int argb = image.getRGB(x, y);
			return argb >> 24 != 0;
		}
		else return false;
	')
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}

	public function at(x: Int, y: Int): Int {
		return 0;
	}

	public function unload(): Void {}

	public function lock(level: Int = 0): Bytes {
		return null;
	}

	public function unlock(): Void {}

	public function getPixels(): Bytes {
		return null;
	}

	public function generateMipmaps(levels: Int): Void {}

	public function setMipmaps(mipmaps: Array<Image>): Void {}

	public function setDepthStencilFrom(image: Image): Void {}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {}
}

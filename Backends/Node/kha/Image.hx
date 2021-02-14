package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;
import kha.js.EmptyGraphics1;
import kha.js.EmptyGraphics2;
import kha.js.EmptyGraphics4;

class Image implements Canvas implements Resource {
	var w: Int;
	var h: Int;
	var graphics1: EmptyGraphics1;
	var graphics2: EmptyGraphics2;
	var graphics4: EmptyGraphics4;
	var bytes: Bytes;
	var myFormat: TextureFormat;

	public function new(width: Int, height: Int, format: TextureFormat) {
		w = width;
		h = height;
		var bytesPerPixel = 4;
		if (format != null && format == TextureFormat.L8)
			bytesPerPixel = 1;
		myFormat = format;
		bytes = Bytes.alloc(width * height * bytesPerPixel);
		graphics1 = new EmptyGraphics1(w, h);
		graphics2 = new EmptyGraphics2(w, h);
		graphics4 = new EmptyGraphics4(w, h);
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return new Image(width, height, format);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null,
			depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return new Image(width, height, format);
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static var maxSize(get, never): Int;

	static function get_maxSize(): Int {
		return 1024 * 4;
	}

	public static var nonPow2Supported(get, never): Bool;

	static function get_nonPow2Supported(): Bool {
		return false;
	}

	public static function renderTargetsInvertedY(): Bool {
		return false;
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return false;
	}

	public function at(x: Int, y: Int): Color {
		return 0;
	}

	public function unload(): Void {}

	public function lock(level: Int = 0): Bytes {
		return bytes;
	}

	public function unlock(): Void {}

	public function getPixels(): Bytes {
		return null;
	}

	public function generateMipmaps(levels: Int): Void {}

	public function setMipmaps(mipmaps: Array<Image>): Void {}

	public function setDepthStencilFrom(image: Image): Void {}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {}

	public var width(get, never): Int;

	function get_width(): Int {
		return w;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return h;
	}

	public var depth(get, never): Int;

	function get_depth(): Int {
		return 1;
	}

	public var format(get, never): TextureFormat;

	function get_format(): TextureFormat {
		return myFormat;
	}

	public var realWidth(get, never): Int;

	function get_realWidth(): Int {
		return w;
	}

	public var realHeight(get, never): Int;

	function get_realHeight(): Int {
		return h;
	}

	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		return graphics1;
	}

	public var g2(get, never): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		return graphics2;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		return graphics4;
	}
}

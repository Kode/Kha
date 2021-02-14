package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;
import unityEngine.RenderTexture;
import unityEngine.Texture;
import unityEngine.Texture2D;

class Image implements Canvas implements Resource {
	var myWidth: Int;
	var myHeight: Int;
	var myFormat: TextureFormat;

	public var texture: Texture;

	var graphics1: kha.graphics1.Graphics;
	var graphics2: kha.graphics2.Graphics;
	var graphics4: kha.graphics4.Graphics;

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, false);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null,
			depthStencilFormat: DepthStencilFormat = NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, true);
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}

	public function new(width: Int, height: Int, format: TextureFormat, renderTexture: Bool) {
		myWidth = width;
		myHeight = height;
		myFormat = format;
		if (renderTexture)
			texture = new RenderTexture(upperPowerOfTwo(width), upperPowerOfTwo(height), 0);
		else
			texture = new Texture2D(width, height);
	}

	public static function fromFilename(filename: String, width: Int, height: Int): Image {
		var tex = UnityBackend.loadImage(filename);
		var image = new Image(width, height, TextureFormat.RGBA32, false);
		image.texture = tex;
		return image;
	}

	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	public var g2(get, never): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		if (graphics2 == null) {
			graphics2 = new kha.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.unity.Graphics(this);
		}
		return graphics4;
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return myWidth;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return myHeight;
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
		return texture.width;
	}

	public var realHeight(get, never): Int;

	function get_realHeight(): Int {
		return texture.height;
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}

	public function unload(): Void {
		// image = null;
	}

	public var bytes: Bytes;

	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(myFormat == TextureFormat.RGBA32 ? 4 * width * height : width * height);
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

	public static var maxSize(get, never): Int;

	static function get_maxSize(): Int {
		return 4096;
	}

	public static var nonPow2Supported(get, never): Bool;

	static function get_nonPow2Supported(): Bool {
		return false;
	}

	public static function renderTargetsInvertedY(): Bool {
		return !UnityBackend.uvStartsAtTop();
	}
}

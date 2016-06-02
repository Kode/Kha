package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;
import unityEngine.RenderTexture;
import unityEngine.Texture;
import unityEngine.Texture2D;

class Image implements Canvas implements Resource {
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	public var texture: Texture;

	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, false);
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencilFormat: DepthStencilFormat = NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, true);
	}
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	private static function upperPowerOfTwo(v: Int): Int {
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
		this.format = format;
		if (renderTexture) texture = new RenderTexture(upperPowerOfTwo(width), upperPowerOfTwo(height), 0);
		else texture = new Texture2D(width, height);
	}

	public static function fromFilename(filename: String, width: Int, height: Int): Image {
		var tex = UnityBackend.loadImage(filename);
		var image = new Image(width, height, TextureFormat.RGBA32, false);
		image.texture = tex;
		return image;
	}

	public var g1(get, null): kha.graphics1.Graphics;

	private function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	public var g2(get, null): kha.graphics2.Graphics;

	private function get_g2(): kha.graphics2.Graphics {
		if (graphics2 == null) {
			graphics2 = new kha.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, null): kha.graphics4.Graphics;

	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.unity.Graphics(this);
		}
		return graphics4;
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
		return texture.width;
	}

	public var realHeight(get, null): Int;

	public function get_realHeight(): Int {
		return texture.height;
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}

	public function unload(): Void {
		//image = null;
	}

	public var bytes: Bytes;

	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}

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
		return false;
	}
}

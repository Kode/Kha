package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import unityEngine.Texture2D;

class Image implements Canvas implements Resource {
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	public var texture: Texture2D;
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format);
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		return null;
	}
	
	public function new(width: Int, height: Int, format: TextureFormat) {
		myWidth = width;
		myHeight = height;
		this.format = format;
		texture = new Texture2D(width, height);
	}
	
	public static function fromFilename(filename: String): Image {
		var tex = UnityBackend.loadImage(filename);
		var image = new Image(tex.width, tex.height, TextureFormat.RGBA32);
		image.texture = tex;
		var size = UnityBackend.getImageSize(tex);
		image.myWidth = size.x;
		image.myHeight = size.y;
		return image;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return null;
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
	
	public function isOpaque(x: Int, y: Int) : Bool {
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
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 4096;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return true;
	}
}

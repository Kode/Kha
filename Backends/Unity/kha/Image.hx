package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
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
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, false);
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, true);
	}
	
	public function new(width: Int, height: Int, format: TextureFormat, renderTexture: Bool) {
		myWidth = width;
		myHeight = height;
		this.format = format;
		if (renderTexture) texture = new RenderTexture(width, height, 0);
		else texture = new Texture2D(width, height);
	}
	
	public static function fromFilename(filename: String): Image {
		var tex = UnityBackend.loadImage(filename);
		var image = new Image(tex.width, tex.height, TextureFormat.RGBA32, false);
		image.texture = tex;
		var size = UnityBackend.getImageSize(tex);
		image.myWidth = size.x;
		image.myHeight = size.y;
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

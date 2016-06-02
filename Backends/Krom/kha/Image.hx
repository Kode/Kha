package kha;

import haxe.io.Bytes;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public var texture_: Dynamic;
	public var renderTarget_: Dynamic;
	
	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;
	
	private function new(texture: Dynamic) {
		texture_ = texture;
	}
	
	public static function _fromTexture(texture: Dynamic): Image {
		return new Image(texture);
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1): Image {
		var image = new Image(null);
		image.renderTarget_ = Krom.createRenderTarget(width, height);
		return image;
	}

	public static var maxSize(get, null): Int;

	public static function get_maxSize(): Int {
		return 4096;
	}

	public static var nonPow2Supported(get, null): Bool;

	public static function get_nonPow2Supported(): Bool {
		return true;
	}

	public function isOpaque(x: Int, y: Int): Bool { return false; }
	public function at(x: Int, y: Int): Color { return Color.Black; }
	public function unload(): Void { }
	public function lock(level: Int = 0): Bytes { return null; }
	public function unlock(): Void { }
	public function generateMipmaps(levels: Int): Void { }
	public function setMipmaps(mipmaps: Array<Image>): Void { }
	public function setDepthStencilFrom(image: Image): Void { }
	public var width(get, null): Int;
	private function get_width(): Int { return texture_ == null ? renderTarget_.width : texture_.width; }
	public var height(get, null): Int;
	private function get_height(): Int { return texture_ == null ? renderTarget_.height : texture_.height; }
	public var realWidth(get, null): Int;
	private function get_realWidth(): Int { return texture_ == null ? renderTarget_.width : texture_.realWidth; }
	public var realHeight(get, null): Int;
	private function get_realHeight(): Int { return texture_ == null ? renderTarget_.height : texture_.realHeight; }
	
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
			graphics4 = new kha.krom.Graphics(this);
		}
		return graphics4;
	}
}

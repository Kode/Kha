package kha;

import haxe.io.Bytes;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1): Image {
		return null;
	}
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static var maxSize(get, null): Int;

	public static function get_maxSize(): Int {
		return 0;
	}

	public static var nonPow2Supported(get, null): Bool;

	public static function get_nonPow2Supported(): Bool {
		return false;
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
	private function get_width(): Int { return 0; }
	public var height(get, null): Int;
	private function get_height(): Int { return 0; }
	public var realWidth(get, null): Int;
	private function get_realWidth(): Int { return 0; }
	public var realHeight(get, null): Int;
	private function get_realHeight(): Int { return 0; }
	public var g1(get, null): kha.graphics1.Graphics;
	private function get_g1(): kha.graphics1.Graphics { return null; }
	public var g2(get, null): kha.graphics2.Graphics;
	private function get_g2(): kha.graphics2.Graphics { return null; }
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics { return null; }
}

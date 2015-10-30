package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.js.EmptyGraphics1;
import kha.js.EmptyGraphics2;
import kha.js.EmptyGraphics4;

class Image implements Canvas implements Resource {
	private var w: Int;
	private var h: Int;
	private var graphics1: EmptyGraphics1;
	private var graphics2: EmptyGraphics2;
	private var graphics4: EmptyGraphics4;
	private var bytes: Bytes;
	
	public function new(width: Int, height: Int, format: TextureFormat) {
		w = width;
		h = height;
		var bytesPerPixel = 4;
		if (format != null && format == TextureFormat.L8) bytesPerPixel = 1;
		bytes = Bytes.alloc(width * height * bytesPerPixel);
		graphics1 = new EmptyGraphics1(w, h);
		graphics2 = new EmptyGraphics2(w, h);
		graphics4 = new EmptyGraphics4(w, h);
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		return new Image(width, height, format);
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		return new Image(width, height, format);
	}
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 1024 * 4;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return false;
	}
	
	public function isOpaque(x: Int, y: Int): Bool { return false; }
	public function at(x: Int, y: Int): Color { return 0; }
	public function unload(): Void { }
	public function lock(level: Int = 0): Bytes { return bytes; }
	public function unlock(): Void { }
	public var width(get, null): Int;
	private function get_width(): Int { return w; }
	public var height(get, null): Int;
	private function get_height(): Int { return h; }
	public var realWidth(get, null): Int;
	private function get_realWidth(): Int { return w; }
	public var realHeight(get, null): Int;
	private function get_realHeight(): Int { return h; }
	
	public var g1(get, null): kha.graphics1.Graphics;
	private function get_g1(): kha.graphics1.Graphics { return graphics1; }
	
	public var g2(get, null): kha.graphics2.Graphics;
	private function get_g2(): kha.graphics2.Graphics { return graphics2; }
	
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics { return graphics4; }
}

package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public var id: Int;
	private var w: Int;
	private var h: Int;
	private var rw: Int;
	private var rh: Int;
	
	public function new(id: Int, width: Int, height: Int, realWidth: Int, realHeight: Int) {
		this.id = id;
		w = width;
		h = height;
		rw = realWidth;
		rh = realHeight;
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (usage == null) usage = Usage.StaticUsage;
		return null;
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		if (format == null) format = TextureFormat.RGBA32;
		return null;
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
	public function unload(): Void { }
	public function lock(level: Int = 0): Bytes { return null; }
	public function unlock(): Void { }
	public var width(get, null): Int;
	private function get_width(): Int { return w; }
	public var height(get, null): Int;
	private function get_height(): Int { return h; }
	public var realWidth(get, null): Int;
	private function get_realWidth(): Int { return rw; }
	public var realHeight(get, null): Int;
	private function get_realHeight(): Int { return rh; }
	public var g2(get, null): kha.graphics2.Graphics;
	private function get_g2(): kha.graphics2.Graphics { return null; }
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics { return null; }
}

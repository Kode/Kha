package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

extern class Image implements Canvas implements Resource {
	public static function create(width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, usage: Usage = Usage.StaticUsage, levels: Int = 1): Image;
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image;
	public static var maxSize(get, null): Int;
	public static var nonPow2Supported(get, null): Bool;
	
	public function isOpaque(x: Int, y: Int): Bool;
	public function unload(): Void;
	public function lock(level: Int = 0): Bytes;
	public function unlock(): Void;
	public var width(get, null): Int;
	public var height(get, null): Int;
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	public var g2(get, null): kha.graphics2.Graphics;
	public var g4(get, null): kha.graphics4.Graphics;
}

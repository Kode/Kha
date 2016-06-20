package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

extern class Image implements Canvas implements Resource {

	public static function create(width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, usage: Usage = Usage.StaticUsage): Image;

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, usage: Usage = Usage.StaticUsage): Image;

	// Create a new image instance and set things up so you can render to the image.
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, depthStencil: DepthStencilFormat = NoDepthAndStencil, antiAliasingSamples: Int = 1): Image;
	
	public static var maxSize(get, null): Int;
	
	public static var nonPow2Supported(get, null): Bool;
	
	public function isOpaque(x: Int, y: Int): Bool;
	
	public function unload(): Void;
	
	// Allocate a bytes for the texture size.
	public function lock(level: Int = 0): Bytes;
	
	public function unlock(): Void;
	
	public function generateMipmaps(levels: Int): Void;
	
	// Set custom texture mipmaps, starting at level 1.
	public function setMipmaps(mipmaps: Array<Image>): Void;
	
	// Use depth buffer attached to different image.
	public function setDepthStencilFrom(image: Image): Void;
	
	public var width(get, null): Int;
	
	public var height(get, null): Int;
	
	// The width of the image in pixels and been power of two.
	public var realWidth(get, null): Int;
	
	// The height of the image in pixels and been power of two.
	public var realHeight(get, null): Int;
	
	// Use this for 2D operations.
	public var g2(get, null): kha.graphics2.Graphics;
	
	// Use this for 3D operations.
	public var g4(get, null): kha.graphics4.Graphics;
}

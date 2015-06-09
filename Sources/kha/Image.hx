package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

/**
 * Image represents a texture that can be rendered.
 */
extern class Image implements Canvas implements Resource {
	/**
	 * Create a new image instance.
	 * 
	 * @param width		The image width.
 	 * @param height	The image height.
 	 * @param format	The image format, from TextureFormat, default = RGBA32.
 	 * @param usage		If you plan to change the vertex after or not, from Usage, default = StaticUsage.
	 * @param levels	TODO, default = 1.
	 */
	public static function create(width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, usage: Usage = Usage.StaticUsage, levels: Int = 1): Image;
	/**
	 * Create a new image instance and sets things up so you can render to the image.
	 * 
	 * @param width					The image width.
 	 * @param height				The image height.
 	 * @param format				The image format, from TextureFormat, default = RGBA32.
 	 * @param depthStencil			default = false
	 * @param antiAliasingSamples	The number of antialiasing samples, default = 1.
	 */
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = TextureFormat.RGBA32, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image;
	/**
	 * The max image size.
	 */
	public static var maxSize(get, null): Int;
	/**
	 * If the non pow of two sizes are supported or no.
	 */
	public static var nonPow2Supported(get, null): Bool;
	/**
	 * Returns true if the alpha value of pixel in the given position is 0.
	 *
	 * @param x		The X position in the image.
	 * @param y		The Y position in the image.
	 */
	public function isOpaque(x: Int, y: Int): Bool;
	/**
	 * Unload the image from memory.
	 */
	public function unload(): Void;
	/**
	 * Allocate a bytes for the texture size.
	 *
	 * @param level		TODO, default = 0.
	 */
	public function lock(level: Int = 0): Bytes;
	/**
	 * Release the bytes and upload them to the GPU.
	 */
	public function unlock(): Void;
	/**
	 * The width of the image in pixels.
	 */
	public var width(get, null): Int;
	/**
	 * The height of the image in pixels.
	 */
	public var height(get, null): Int;
	/**
	 * The width of the image in pixels and been power of two.
	 */
	public var realWidth(get, null): Int;
	/**
	 * The height of the image in pixels and been power of two.
	 */
	public var realHeight(get, null): Int;
	/**
	 * The Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	public var g2(get, null): kha.graphics2.Graphics;
	/**
	 * The Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */
	public var g4(get, null): kha.graphics4.Graphics;
}

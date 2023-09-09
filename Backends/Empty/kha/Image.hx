package kha;

import haxe.io.Bytes;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null,
			depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1): Image {
		return null;
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static var maxSize(get, never): Int;

	static function get_maxSize(): Int {
		return 0;
	}

	public static var nonPow2Supported(get, never): Bool;

	static function get_nonPow2Supported(): Bool {
		return false;
	}

	public static function renderTargetsInvertedY(): Bool {
		return false;
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return false;
	}

	/**
	 * Returns the color of a pixel identified by its x/y-coordinates. This only works for images for which
	 * the readable flag is set to true because by default images only exist in video-memory. To load images
	 * which are readable use a line ala project.addAssets('Assets/image.png', { readable: true }); in
	 * your khafile.
	 * For reading the content of render-targets use getPixels() instead.
	 */
	public function at(x: Int, y: Int): Color {
		return Color.Black;
	}

	public function unload(): Void {}

	/**
	 * Returns a writable Bytes object. Once unlock() is called the content of the Bytes object
	 * is written into the image.
	 * This can not be used to read the current content of an image - for this use at() or getPixels() instead.
	 */
	public function lock(level: Int = 0): Bytes {
		return null;
	}

	public function unlock(): Void {}

	/**
	 * Returns the content of an image. This only works if the image is a render-target and it is very slow
	 * because data will be copied from video-memory to main-memory. This is useful for making screenshots
	 * but please avoid using it for regular rendering.
	 * For reading the content of images which are not render-targets use at() instead.
	 */
	public function getPixels(): Bytes {
		return null;
	}

	public function generateMipmaps(levels: Int): Void {}

	public function setMipmaps(mipmaps: Array<Image>): Void {}

	public function setDepthStencilFrom(image: Image): Void {}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {}

	/**
	 * Returns the original width of the image.
	 */
	public var width(get, never): Int;

	function get_width(): Int {
		return 0;
	}

	/**
	 * Returns the original height of the image.
	 */
	public var height(get, never): Int;

	function get_height(): Int {
		return 0;
	}

	public var depth(get, never): Int;

	function get_depth(): Int {
		return 1;
	}

	public var format(get, never): TextureFormat;

	function get_format(): TextureFormat {
		return TextureFormat.RGBA32;
	}

	/**
	 * Very old GPUs only supported power of two texture-widths.
	 * When an Image is created on such a GPU, Kha automatically increases
	 * its size to a power of two and realWidth returns this new, internal
	 * size. Knowing the real size is important for calculating
	 * texture-coordinates correctly but all of this is irrelevant unless
	 * you really want to support very very old GPUs.
	 */
	public var realWidth(get, never): Int;

	function get_realWidth(): Int {
		return 0;
	}

	/**
	 * Very old GPUs only supported power of two texture-heights.
	 * When an Image is created on such a GPU, Kha automatically increases
	 * its size to a power of two and realHeight returns this new, internal
	 * size. Knowing the real size is important for calculating
	 * texture-coordinates correctly but all of this is irrelevant unless
	 * you really want to support very very old GPUs.
	 */
	public var realHeight(get, never): Int;

	function get_realHeight(): Int {
		return 0;
	}

	public var stride(get, never): Int;

	function get_stride(): Int {
		return 0;
	}

	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		return null;
	}

	public var g2(get, never): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		return null;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		return null;
	}
}

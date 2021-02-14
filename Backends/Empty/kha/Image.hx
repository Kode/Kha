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

	public function at(x: Int, y: Int): Color {
		return Color.Black;
	}

	public function unload(): Void {}

	public function lock(level: Int = 0): Bytes {
		return null;
	}

	public function unlock(): Void {}

	public function getPixels(): Bytes {
		return null;
	}

	public function generateMipmaps(levels: Int): Void {}

	public function setMipmaps(mipmaps: Array<Image>): Void {}

	public function setDepthStencilFrom(image: Image): Void {}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {}

	public var width(get, never): Int;

	function get_width(): Int {
		return 0;
	}

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

	public var realWidth(get, never): Int;

	function get_realWidth(): Int {
		return 0;
	}

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

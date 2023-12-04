package kha;

import haxe.io.Bytes;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public var texture_: Dynamic;
	public var renderTarget_: Dynamic;

	var myFormat: TextureFormat;
	var readable: Bool;

	var graphics1: kha.graphics1.Graphics;
	var graphics2: kha.graphics2.Graphics;
	var graphics4: kha.graphics4.Graphics;

	function new(texture: Dynamic) {
		texture_ = texture;
	}

	static function getRenderTargetFormat(format: TextureFormat): Int {
		switch (format) {
			case RGBA32: // Target32Bit
				return 0;
			case RGBA64: // Target64BitFloat
				return 1;
			case A32: // Target32BitRedFloat
				return 2;
			case RGBA128: // Target128BitFloat
				return 3;
			case DEPTH16: // Target16BitDepth
				return 4;
			case L8:
				return 5; // Target8BitRed
			case A16:
				return 6; // Target16BitRedFloat
			default:
				return 0;
		}
	}

	static function getDepthBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: 24;
			case DepthAutoStencilAuto: 24;
			case Depth24Stencil8: 24;
			case Depth32Stencil8: 32;
			case Depth16: 16;
		}
	}

	static function getStencilBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: -1;
			case DepthAutoStencilAuto: 8;
			case Depth24Stencil8: 8;
			case Depth32Stencil8: 8;
			case Depth16: 0;
		}
	}

	static function getTextureFormat(format: TextureFormat): Int {
		switch (format) {
			case RGBA32:
				return 0;
			case RGBA128:
				return 3;
			case RGBA64:
				return 4;
			case A32:
				return 5;
			case A16:
				return 7;
			default:
				return 1; // Grey8
		}
	}

	public static function _fromTexture(texture: Dynamic): Image {
		return new Image(texture);
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, readable: Bool = false): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		var image = new Image(null);
		image.myFormat = format;
		image.texture_ = Krom.createTextureFromBytes(bytes.getData(), width, height, getTextureFormat(format), readable);
		return image;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null,
			readable: Bool = false): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		var image = new Image(null);
		image.myFormat = format;
		image.texture_ = Krom.createTextureFromBytes3D(bytes.getData(), width, height, depth, getTextureFormat(format), readable);
		return image;
	}

	public static function fromEncodedBytes(bytes: Bytes, format: String, doneCallback: Image->Void, errorCallback: String->Void,
			readable: Bool = false): Void {
		var image = new Image(null);
		image.texture_ = Krom.createTextureFromEncodedBytes(bytes.getData(), format, readable);
		doneCallback(image);
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, readable: Bool = false): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		var image = new Image(null);
		image.myFormat = format;
		image.texture_ = Krom.createTexture(width, height, getTextureFormat(format));
		return image;
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null, readable: Bool = false): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		var image = new Image(null);
		image.myFormat = format;
		image.texture_ = Krom.createTexture3D(width, height, depth, getTextureFormat(format));
		return image;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null,
			depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		var image = new Image(null);
		image.myFormat = format;
		image.renderTarget_ = Krom.createRenderTarget(width, height, getRenderTargetFormat(format), getDepthBufferBits(depthStencil),
			getStencilBufferBits(depthStencil));
		return image;
	}

	public static var maxSize(get, never): Int;

	static function get_maxSize(): Int {
		return 4096;
	}

	public static var nonPow2Supported(get, never): Bool;

	static function get_nonPow2Supported(): Bool {
		return true;
	}

	public static function renderTargetsInvertedY(): Bool {
		return Krom.renderTargetsInvertedY();
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return false;
	}

	public function at(x: Int, y: Int): Color {
		return Color.Black;
	}

	public function unload(): Void {
		Krom.unloadImage(this);
		texture_ = null;
		renderTarget_ = null;
	}

	public function lock(level: Int = 0): Bytes {
		return Bytes.ofData(Krom.lockTexture(texture_, level));
	}

	public function unlock(): Void {
		Krom.unlockTexture(texture_);
	}

	var pixels: Bytes = null;

	public function getPixels(): Bytes {
		if (renderTarget_ != null) {
			if (pixels == null)
				pixels = Bytes.alloc(formatByteSize(myFormat) * width * height);
			Krom.getRenderTargetPixels(renderTarget_, pixels.getData());
			return pixels;
		}
		else {
			return Bytes.ofData(Krom.getTexturePixels(texture_));
		}
	}

	static function formatByteSize(format: TextureFormat): Int {
		return switch (format) {
			case RGBA32: 4;
			case L8: 1;
			case RGBA128: 16;
			case DEPTH16: 2;
			case RGBA64: 8;
			case A32: 4;
			case A16: 2;
			default: 4;
		}
	}

	public function generateMipmaps(levels: Int): Void {
		texture_ == null ? Krom.generateRenderTargetMipmaps(renderTarget_, levels) : Krom.generateTextureMipmaps(texture_, levels);
	}

	public function setMipmaps(mipmaps: Array<Image>): Void {
		Krom.setMipmaps(texture_, mipmaps);
	}

	public function setDepthStencilFrom(image: Image): Void {
		Krom.setDepthStencilFrom(renderTarget_, image.renderTarget_);
	}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {
		Krom.clearTexture(texture_, x, y, z, width, height, depth, color);
	}

	public var width(get, never): Int;

	function get_width(): Int {
		return texture_ == null ? renderTarget_.width : texture_.width;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return texture_ == null ? renderTarget_.height : texture_.height;
	}

	public var depth(get, never): Int;

	function get_depth(): Int {
		return texture_ != null ? texture_.depth : 1;
	}

	public var format(get, never): TextureFormat;

	function get_format(): TextureFormat {
		return myFormat;
	}

	public var realWidth(get, never): Int;

	function get_realWidth(): Int {
		return texture_ == null ? renderTarget_.width : texture_.realWidth;
	}

	public var realHeight(get, never): Int;

	function get_realHeight(): Int {
		return texture_ == null ? renderTarget_.height : texture_.realHeight;
	}

	public var stride(get, never): Int;

	function get_stride(): Int {
		return texture_.stride;
	}

	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	public var g2(get, never): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		if (graphics2 == null) {
			graphics2 = new kha.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.krom.Graphics(this);
		}
		return graphics4;
	}
}

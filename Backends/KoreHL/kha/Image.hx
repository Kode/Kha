package kha;

import haxe.io.Bytes;
import kha.korehl.graphics4.TextureUnit;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public var _texture: Pointer;
	public var _renderTarget: Pointer;
	
	private var format: TextureFormat;
	private var readable: Bool;

	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;

	public static function createFromVideo(video: Video): Image {
		var image = new Image(false);
		image.format = TextureFormat.RGBA32;
		//image.initVideo(cast(video, kha.kore.Video));
		return image;
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, NoDepthAndStencil, 0);
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, true, depthStencil, contextId);
	}
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	private function new(readable: Bool) {
		this.readable = readable;
	}

	private static function getRenderTargetFormat(format: TextureFormat): Int {
		switch (format) {
		case RGBA32:	// Target32Bit
			return 0;
		case RGBA64:	// Target64BitFloat
			return 1;
		case RGBA128:	// Target128BitFloat
			return 3;
		case DEPTH16:	// Target16BitDepth
			return 4;
		default:
			return 0;
		}
	}

	private static function getDepthBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: 24;
			case DepthAutoStencilAuto: 24;
			case Depth24Stencil8: 24;
			case Depth32Stencil8: 32;
		}
	}

	private static function getStencilBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: -1;
			case DepthAutoStencilAuto: 8;
			case Depth24Stencil8: 8;
			case Depth32Stencil8: 8;
		}
	}

	public static function create2(width: Int, height: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthStencil: DepthStencilFormat, contextId: Int): Image {
		var image = new Image(readable);
		image.format = format;
		if (renderTarget) image.initRenderTarget(width, height, getDepthBufferBits(depthStencil), getRenderTargetFormat(format), getStencilBufferBits(depthStencil), contextId);
		else image.init(width, height, format == TextureFormat.RGBA32 ? 0 : 1);
		return image;
	}

	//@:functionCode('renderTarget = new Kore::RenderTarget(width, height, depthBufferBits, false, (Kore::RenderTargetFormat)format, stencilBufferBits, contextId); texture = nullptr;')
	private function initRenderTarget(width: Int, height: Int, depthBufferBits: Int, format: Int, stencilBufferBits: Int, contextId: Int): Void {

	}

	private function init(width: Int, height: Int, format: Int): Void {
		_texture = kore_texture_create(width, height, format, readable);
		_renderTarget = null;
	}

	//@:functionCode('texture = video->video->currentImage(); renderTarget = nullptr;')
	//private function initVideo(video: kha.kore.Video): Void {
	//
	//}

	public static function fromFile(filename: String, readable: Bool): Image {
		var image = new Image(readable);
		var isFloat = StringTools.endsWith(filename, ".hdr");
		image.format = isFloat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
		image.initFromFile(filename);
		return image;
	}

	private function initFromFile(filename: String): Void {
		_texture = kore_texture_create_from_file(StringHelper.convert(filename), readable);
		_renderTarget = null;
	}

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
			graphics2 = new kha.korehl.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, null): kha.graphics4.Graphics;

	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.korehl.graphics4.Graphics(this);
		}
		return graphics4;
	}

	public static var maxSize(get, null): Int;

	public static function get_maxSize(): Int {
		return 4096;
	}

	public static var nonPow2Supported(get, null): Bool;

	public static function get_nonPow2Supported(): Bool {
		return kore_non_pow2_textures_supported();
	}

	public var width(get, null): Int;
	public var height(get, null): Int;

	//@:functionCode("if (texture != nullptr) return texture->width; else return renderTarget->width;")
	public function get_width(): Int {
		return kore_texture_get_width(_texture);
	}

	//@:functionCode("if (texture != nullptr) return texture->height; else return renderTarget->height;")
	public function get_height(): Int {
		return kore_texture_get_height(_texture);
	}

	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;

	//@:functionCode("if (texture != nullptr) return texture->texWidth; else return renderTarget->texWidth;")
	public function get_realWidth(): Int {
		return kore_texture_get_real_width(_texture);
	}

	//@:functionCode("if (texture != nullptr) return texture->texHeight; else return renderTarget->texHeight;")
	public function get_realHeight(): Int {
		return kore_texture_get_real_height(_texture);
	}

	//@:functionCode("return (texture->at(x, y) & 0xff) != 0;")
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}

	//@:functionCode('return texture->at(x, y);')
	private function atInternal(x: Int, y: Int): Int {
		return 0;
	}

	public inline function at(x: Int, y: Int): Color {
		return Color.fromValue(atInternal(x, y));
	}

	//@:functionCode("delete texture; texture = nullptr; delete renderTarget; renderTarget = nullptr;")
	public function unload(): Void {

	}

	private var bytes: Bytes = null;

	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}

	/*@:functionCode('
		Kore::u8* b = bytes->b->Pointer();
		Kore::u8* tex = texture->lock();
		for (int i = 0; i < ((texture->format == Kore::Image::RGBA32) ? (4 * texture->width * texture->height) : (texture->width * texture->height)); ++i) tex[i] = b[i];
		texture->unlock();
	')*/
	public function unlock(): Void {
		bytes = null;
	}

	public function generateMipmaps(levels: Int): Void {
		//untyped __cpp__("texture->generateMipmaps(levels)");
	}

	public function setMipmaps(mipmaps: Array<Image>): Void {
		/*for (i in 0...mipmaps.length) {
			var image = mipmaps[i];
			var level = i + 1;
			untyped __cpp__("texture->setMipmap(image->texture, level)");
		}*/
	}

	public function setDepthStencilFrom(image: Image): Void {
		
	}
	
	@:hlNative("std", "kore_texture_create") static function kore_texture_create(width: Int, height: Int, format: Int, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_texture_create_from_file") static function kore_texture_create_from_file(filename: hl.types.Bytes, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_non_pow2_textures_supported") static function kore_non_pow2_textures_supported(): Bool { return false; }
	@:hlNative("std", "kore_texture_get_width") static function kore_texture_get_width(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_get_height") static function kore_texture_get_height(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_get_real_width") static function kore_texture_get_real_width(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_get_real_height") static function kore_texture_get_real_height(texture: Pointer): Int { return 0; }
}

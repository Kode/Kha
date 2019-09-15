package kha;

import haxe.io.Bytes;
import haxe.io.BytesData;
import kha.korehl.graphics4.TextureUnit;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public var _texture: Pointer;
	public var _renderTarget: Pointer;
	public var _textureArray: Pointer;
	public var _textureArrayTextures: Pointer;
	
	private var format: TextureFormat;
	private var readable: Bool;

	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;

	public static function createFromVideo(video: Video): Image {
		var image = new Image(false);
		image.format = TextureFormat.RGBA32;
		image.initVideo(cast(video, kha.korehl.Video));
		return image;
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, NoDepthAndStencil, 0);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return create3(width, height, depth, format == null ? TextureFormat.RGBA32 : format, false, 0);
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, true, depthStencil, contextId);
	}

	// public static function createArray(images: Array<Image>, format: TextureFormat = null): Image {
		// var image = new Image(false);
		// image.format = (format == null) ? TextureFormat.RGBA32 : format;
		// initArrayTexture(image, images);
		// return image;
	// }
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var readable = true;
		var image = new Image(readable);
		image.format = format;
		image.initFromBytes(bytes.getData(), width, height, getTextureFormat(format));
		return image;
	}

	private function initFromBytes(bytes: BytesData, width: Int, height: Int, format: Int): Void {
		_texture = kore_texture_from_bytes(bytes.bytes, width, height, format, readable);
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var readable = true;
		var image = new Image(readable);
		image.format = format;
		image.initFromBytes3D(bytes.getData(), width, height, depth, getTextureFormat(format));
		return image;
	}

	private function initFromBytes3D(bytes: BytesData, width: Int, height: Int, depth: Int, format: Int): Void {
		_texture = kore_texture_from_bytes3d(bytes.bytes, width, height, depth, format, readable);
	}

	public static function fromEncodedBytes(bytes: Bytes, format: String, doneCallback: Image -> Void, errorCallback: String->Void, readable: Bool = false): Void {
		var image = new Image(readable);
		var isFloat = format == "hdr" || format == "HDR";
		image.format = isFloat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
		image.initFromEncodedBytes(bytes.getData(), format);
		doneCallback(image);
	}

	private function initFromEncodedBytes(bytes: BytesData, format: String): Void {
		_texture = kore_texture_from_encoded_bytes(bytes.bytes, bytes.length, StringHelper.convert(format), readable);
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
			case Depth16: 16;
		}
	}

	private static function getStencilBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: -1;
			case DepthAutoStencilAuto: 8;
			case Depth24Stencil8: 8;
			case Depth32Stencil8: 8;
			case Depth16: 0;
		}
	}

	private static function getTextureFormat(format: TextureFormat): Int {
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

	public static function create2(width: Int, height: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthStencil: DepthStencilFormat, contextId: Int): Image {
		var image = new Image(readable);
		image.format = format;
		if (renderTarget) image.initRenderTarget(width, height, getDepthBufferBits(depthStencil), getRenderTargetFormat(format), getStencilBufferBits(depthStencil), contextId);
		else image.init(width, height, format == TextureFormat.RGBA32 ? 0 : 1);
		return image;
	}

	public static function create3(width: Int, height: Int, depth: Int, format: TextureFormat, readable: Bool, contextId: Int): Image {
		var image = new Image(readable);
		image.format = format;
		image.init3D(width, height, depth, getTextureFormat(format));
		return image;
	}

	private function initRenderTarget(width: Int, height: Int, depthBufferBits: Int, format: Int, stencilBufferBits: Int, contextId: Int): Void {
		_renderTarget = kore_render_target_create(width, height, depthBufferBits, format, stencilBufferBits, contextId);
		_texture = null;
	}

	private function init(width: Int, height: Int, format: Int): Void {
		_texture = kore_texture_create(width, height, format, readable);
		_renderTarget = null;
	}

	private function init3D(width: Int, height: Int, depth:Int, format: Int): Void {
		_texture = kore_texture_create3d(width, height, depth, format, readable);
		_renderTarget = null;
	}

	private function initVideo(video: kha.korehl.Video): Void {
		_texture = kore_video_get_current_image(video._video);
		_renderTarget = null;
	}

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
	
	public static function renderTargetsInvertedY(): Bool {
		return kore_graphics_render_targets_inverted_y();
	}

	public var width(get, null): Int;
	public var height(get, null): Int;
	public var depth(get, null): Int;

	public function get_width(): Int {
		return _texture != null ? kore_texture_get_width(_texture) : kore_render_target_get_width(_renderTarget);
	}

	public function get_height(): Int {
		return _texture != null ? kore_texture_get_height(_texture) : kore_render_target_get_height(_renderTarget);
	}

	public function get_depth(): Int {
		return 1;
	}

	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;

	public function get_realWidth(): Int {
		return _texture != null ? kore_texture_get_real_width(_texture) : kore_render_target_get_real_width(_renderTarget);
	}

	public function get_realHeight(): Int {
		return _texture != null ? kore_texture_get_real_height(_texture) : kore_render_target_get_real_height(_renderTarget);
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return atInternal(x, y) & 0xff != 0;
	}

	private function atInternal(x: Int, y: Int): Int {
		return kore_texture_at(_texture, x, y);
	}

	public inline function at(x: Int, y: Int): Color {
		return Color.fromValue(atInternal(x, y));
	}

	public function unload(): Void {
		_texture != null ? kore_texture_unload(_texture) : kore_render_target_unload(_renderTarget);
	}

	private var bytes: Bytes = null;

	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(formatByteSize(format) * width * height);
		return bytes;
	}

	public function unlock(): Void {
		kore_texture_unlock(_texture, bytes.getData().bytes);
		bytes = null;
	}

	private var pixels: Bytes = null;
	public function getPixels(): Bytes {
		if (_renderTarget == null) return null;
		if (pixels == null) {
			var size = formatByteSize(format) * width * height;
			pixels = Bytes.alloc(size);
		}
		kore_render_target_get_pixels(_renderTarget, pixels.getData().bytes);
		return pixels;
	}

	private static function formatByteSize(format: TextureFormat): Int {
		return switch(format) {
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
		_texture != null ? kore_generate_mipmaps_texture(_texture, levels) : kore_generate_mipmaps_target(_renderTarget, levels);
	}

	public function setMipmaps(mipmaps: Array<Image>): Void {
		for (i in 0...mipmaps.length) {
			var image = mipmaps[i];
			var level = i + 1;
			kore_set_mipmap_texture(_texture, image._texture, level);
		}
	}

	public function setDepthStencilFrom(image: Image): Void {
		kore_render_target_set_depth_stencil_from(_renderTarget, image._renderTarget);
	}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {
		kore_texture_clear(_texture, x, y, z, width, height, depth, color);
	}
	
	@:hlNative("std", "kore_texture_create") static function kore_texture_create(width: Int, height: Int, format: Int, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_texture_create_from_file") static function kore_texture_create_from_file(filename: hl.Bytes, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_texture_create3d") static function kore_texture_create3d(width: Int, height: Int, depth: Int, format: Int, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_video_get_current_image") static function kore_video_get_current_image(video: Pointer): Pointer { return null; }
	@:hlNative("std", "kore_texture_from_bytes") static function kore_texture_from_bytes(bytes: Pointer, width: Int, height: Int, format: Int, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_texture_from_bytes3d") static function kore_texture_from_bytes3d(bytes: Pointer, width: Int, height: Int, depth: Int, format: Int, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_texture_from_encoded_bytes") static function kore_texture_from_encoded_bytes(bytes: Pointer, length: Int, format: hl.Bytes, readable: Bool): Pointer { return null; }
	@:hlNative("std", "kore_non_pow2_textures_supported") static function kore_non_pow2_textures_supported(): Bool { return false; }
	@:hlNative("std", "kore_graphics_render_targets_inverted_y") static function kore_graphics_render_targets_inverted_y(): Bool { return false; }
	@:hlNative("std", "kore_texture_get_width") static function kore_texture_get_width(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_get_height") static function kore_texture_get_height(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_get_real_width") static function kore_texture_get_real_width(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_get_real_height") static function kore_texture_get_real_height(texture: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_at") static function kore_texture_at(texture: Pointer, x: Int, y: Int): Int { return 0; }
	@:hlNative("std", "kore_texture_unload") static function kore_texture_unload(texture: Pointer): Void { }
	@:hlNative("std", "kore_render_target_unload") static function kore_render_target_unload(renderTarget: Pointer): Void { }
	@:hlNative("std", "kore_render_target_create") static function kore_render_target_create(width: Int, height: Int, depthBufferBits: Int, format: Int, stencilBufferBits: Int, contextId: Int): Pointer { return null; }
	@:hlNative("std", "kore_render_target_get_width") static function kore_render_target_get_width(renderTarget: Pointer): Int { return 0; }
	@:hlNative("std", "kore_render_target_get_height") static function kore_render_target_get_height(renderTarget: Pointer): Int { return 0; }
	@:hlNative("std", "kore_render_target_get_real_width") static function kore_render_target_get_real_width(renderTarget: Pointer): Int { return 0; }
	@:hlNative("std", "kore_render_target_get_real_height") static function kore_render_target_get_real_height(renderTarget: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_unlock") static function kore_texture_unlock(texture: Pointer, bytes: Pointer): Void { }
	@:hlNative("std", "kore_render_target_get_pixels") static function kore_render_target_get_pixels(renderTarget: Pointer, pixels: Pointer): Void { }
	@:hlNative("std", "kore_generate_mipmaps_texture") static function kore_generate_mipmaps_texture(texture: Pointer, levels: Int): Void { }
	@:hlNative("std", "kore_generate_mipmaps_target") static function kore_generate_mipmaps_target(renderTarget: Pointer, levels: Int): Void { }
	@:hlNative("std", "kore_set_mipmap_texture") static function kore_set_mipmap_texture(texture: Pointer, mipmap: Pointer, level: Int): Void { }
	@:hlNative("std", "kore_render_target_set_depth_stencil_from") static function kore_render_target_set_depth_stencil_from(renderTarget: Pointer, from: Pointer): Int { return 0; }
	@:hlNative("std", "kore_texture_clear") static function kore_texture_clear(texture: Pointer, x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void { }
}

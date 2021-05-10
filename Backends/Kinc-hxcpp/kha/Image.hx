package kha;

import haxe.io.Bytes;
import haxe.io.BytesData;
import kha.kore.graphics4.TextureUnit;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

@:headerCode("
#include <kinc/graphics4/rendertarget.h>
#include <kinc/graphics4/texture.h>
#include <kinc/graphics4/texturearray.h>

#include <assert.h>

enum KhaImageType {
	KhaImageTypeNone,
	KhaImageTypeTexture,
	KhaImageTypeRenderTarget,
	KhaImageTypeTextureArray
};
")
@:headerClassCode("
	KhaImageType imageType;
	int originalWidth;
	int originalHeight;
	uint8_t *imageData;
	bool ownsImageData;
	kinc_g4_texture_t texture;
	kinc_g4_render_target_t renderTarget;
	kinc_g4_texture_array_t textureArray;
")
class Image implements Canvas implements Resource {
	var myFormat: TextureFormat;
	var readable: Bool;

	var graphics1: kha.graphics1.Graphics;
	var graphics2: kha.graphics2.Graphics;
	var graphics4: kha.graphics4.Graphics;

	public static function createFromVideo(video: Video): Image {
		var image = new Image(false);
		image.myFormat = TextureFormat.RGBA32;
		image.initVideo(cast(video, kha.kore.Video));
		return image;
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return _create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, NoDepthAndStencil, false, 0);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return _create3(width, height, depth, format == null ? TextureFormat.RGBA32 : format, false, 0);
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = NoDepthAndStencil,
			antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return _create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, true, depthStencil, antiAliasingSamples > 1, contextId);
	}

	/**
	 * The provided images need to be readable.
	 */
	public static function createArray(images: Array<Image>, format: TextureFormat = null): Image {
		var image = new Image(false);
		image.myFormat = (format == null) ? TextureFormat.RGBA32 : format;
		initArrayTexture(image, images);
		return image;
	}

	@:functionCode("
		kinc_image_t *kincImages = (kinc_image_t*)malloc(sizeof(kinc_image_t) * images->length);
		for (unsigned i = 0; i < images->length; ++i) {
			kinc_image_init(&kincImages[i], images->__get(i).StaticCast<::kha::Image>()->imageData, images->__get(i).StaticCast<::kha::Image>()->originalWidth, images->__get(i).StaticCast<::kha::Image>()->originalHeight, (kinc_image_format_t)getTextureFormat(images->__get(i).StaticCast<::kha::Image>()->myFormat));
		}
		kinc_g4_texture_array_init(&source->textureArray, kincImages, images->length);
		for (unsigned i = 0; i < images->length; ++i) {
			kinc_image_destroy(&kincImages[i]);
		}
		free(kincImages);
	")
	static function initArrayTexture(source: Image, images: Array<Image>): Void {}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var readable = true;
		var image = new Image(readable);
		image.myFormat = format;
		image.initFromBytes(bytes.getData(), width, height, getTextureFormat(format));
		return image;
	}

	@:functionCode("
		kinc_image_t image;
		kinc_image_init(&image, bytes.GetPtr()->GetBase(), width, height, (kinc_image_format_t)format);
		kinc_g4_texture_init_from_image(&texture, &image);
		if (readable) {
			imageData = (uint8_t*)image.data;
		}
		kinc_image_destroy(&image);
		imageType = KhaImageTypeTexture;
		originalWidth = width;
		originalHeight = height;
	")
	function initFromBytes(bytes: BytesData, width: Int, height: Int, format: Int): Void {}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var readable = true;
		var image = new Image(readable);
		image.myFormat = format;
		image.initFromBytes3D(bytes.getData(), width, height, depth, getTextureFormat(format));
		return image;
	}

	@:functionCode("
		kinc_image_t image;
		kinc_image_init3d(&image, bytes.GetPtr()->GetBase(), width, height, depth, (kinc_image_format_t)format);
		kinc_g4_texture_init_from_image3d(&texture, &image);
		if (readable) {
			imageData = (uint8_t*)image.data;
		}
		kinc_image_destroy(&image);
		imageType = KhaImageTypeTexture;
		originalWidth = width;
		originalHeight = height;
	")
	function initFromBytes3D(bytes: BytesData, width: Int, height: Int, depth: Int, format: Int): Void {}

	public static function fromEncodedBytes(bytes: Bytes, format: String, doneCallback: Image->Void, errorCallback: String->Void,
			readable: Bool = false): Void {
		var image = new Image(readable);
		var isFloat = format == "hdr" || format == "HDR";
		image.myFormat = isFloat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
		image.initFromEncodedBytes(bytes.getData(), format);
		doneCallback(image);
	}

	@:functionCode("
		size_t size = kinc_image_size_from_encoded_bytes(bytes.GetPtr()->GetBase(), bytes.GetPtr()->length, format.c_str());
		void* data = malloc(size);
		kinc_image_t image;
		kinc_image_init_from_encoded_bytes(&image, data, bytes.GetPtr()->GetBase(), bytes.GetPtr()->length, format.c_str());
		originalWidth = image.width;
		originalHeight = image.height;
		kinc_g4_texture_init_from_image(&texture, &image);
		if (readable) {
			imageData = (uint8_t*)image.data;
		}
		kinc_image_destroy(&image);
		if (!readable) {
			free(data);
		}
		imageType = KhaImageTypeTexture;
	")
	function initFromEncodedBytes(bytes: BytesData, format: String): Void {}

	function new(readable: Bool) {
		this.readable = readable;
		nullify();
		cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:functionCode("
		imageType = KhaImageTypeNone;
		originalWidth = 0;
		originalHeight = 0;
		imageData = NULL;
		ownsImageData = false;
	")
	function nullify() {}

	@:functionCode("
		if (image->imageType != KhaImageTypeNone) {
			image->unload();
		}
	")
	@:void static function finalize(image: Image): Void {}

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

	@:noCompletion
	public static function _create2(width: Int, height: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthStencil: DepthStencilFormat,
			antiAliasing: Bool, contextId: Int): Image {
		var image = new Image(readable);
		image.myFormat = format;
		if (renderTarget)
			image.initRenderTarget(width, height, getDepthBufferBits(depthStencil), antiAliasing, getRenderTargetFormat(format),
				getStencilBufferBits(depthStencil), contextId);
		else
			image.init(width, height, getTextureFormat(format));
		return image;
	}

	@:noCompletion
	public static function _create3(width: Int, height: Int, depth: Int, format: TextureFormat, readable: Bool, contextId: Int): Image {
		var image = new Image(readable);
		image.myFormat = format;
		image.init3D(width, height, depth, getTextureFormat(format));
		return image;
	}

	@:functionCode("
		kinc_g4_render_target_init(&renderTarget, width, height, depthBufferBits, antiAliasing, (kinc_g4_render_target_format_t)format, stencilBufferBits, contextId);
		imageType = KhaImageTypeRenderTarget;
		originalWidth = width;
		originalHeight = height;
	")
	function initRenderTarget(width: Int, height: Int, depthBufferBits: Int, antiAliasing: Bool, format: Int, stencilBufferBits: Int, contextId: Int): Void {}

	@:functionCode("
		kinc_g4_texture_init(&texture, width, height, (kinc_image_format_t)format);
		imageType = KhaImageTypeTexture;
		originalWidth = width;
		originalHeight = height;
	")
	function init(width: Int, height: Int, format: Int): Void {}

	@:functionCode("
		kinc_g4_texture_init3d(&texture, width, height, depth, (kinc_image_format_t)format);
		imageType = KhaImageTypeTexture;
		originalWidth = width;
		originalHeight = height;
	")
	function init3D(width: Int, height: Int, depth: Int, format: Int): Void {}

	// TODO
	// @:functionCode('texture = new Kore::Graphics4::Texture(*video->video->currentImage()); renderTarget = nullptr;')
	function initVideo(video: kha.kore.Video): Void {}

	public static function createEmpty(readable: Bool, floatFormat: Bool): Image {
		var image = new Image(readable);
		image.myFormat = floatFormat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
		return image;
	}

	/*public static function fromFile(filename: String, readable: Bool): Image {
			var image = new Image(readable);
			var isFloat = StringTools.endsWith(filename, ".hdr");
			image.format = isFloat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
			image.initFromFile(filename);
			return image;
		}

		@:functionCode('texture = new Kore::Graphics4::Texture(filename.c_str(), readable);')
		private function initFromFile(filename: String): Void {

	}*/
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
			graphics2 = new kha.kore.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.kore.graphics4.Graphics(this);
		}
		return graphics4;
	}

	public static var maxSize(get, never): Int;

	static function get_maxSize(): Int {
		return 4096;
	}

	public static var nonPow2Supported(get, never): Bool;

	@:functionCode("return kinc_g4_non_pow2_textures_supported();")
	static function get_nonPow2Supported(): Bool {
		return false;
	}

	@:functionCode("return kinc_g4_render_targets_inverted_y();")
	public static function renderTargetsInvertedY(): Bool {
		return false;
	}

	public var width(get, never): Int;

	@:functionCode("return originalWidth;")
	function get_width(): Int {
		return 0;
	}

	public var height(get, never): Int;

	@:functionCode("return originalHeight;")
	function get_height(): Int {
		return 0;
	}

	public var depth(get, never): Int;

	@:functionCode("if (imageType == KhaImageTypeTexture) return texture.tex_depth; else return 0;")
	function get_depth(): Int {
		return 0;
	}

	public var format(get, never): TextureFormat;

	@:functionCode("if (imageType == KhaImageTypeTexture) return texture.format; else return 0;")
	function get_format(): TextureFormat {
		return TextureFormat.RGBA32;
	}

	public var realWidth(get, never): Int;

	@:functionCode("if (imageType == KhaImageTypeTexture) return texture.tex_width; else if (imageType == KhaImageTypeRenderTarget) return renderTarget.width; else return 0;")
	function get_realWidth(): Int {
		return 0;
	}

	public var realHeight(get, never): Int;

	@:functionCode("if (imageType == KhaImageTypeTexture) return texture.tex_height; else if (imageType == KhaImageTypeRenderTarget) return renderTarget.height; else return 0;")
	function get_realHeight(): Int {
		return 0;
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return isOpaqueInternal(x, y, getTextureFormat(myFormat));
	}

	@:functionCode("
		kinc_image_t image;
		kinc_image_init(&image, imageData, originalWidth, originalHeight, (kinc_image_format_t)format);
		bool opaque = (kinc_image_at(&image, x, y) & 0xff) != 0;
		kinc_image_destroy(&image);
		return opaque;
	")
	function isOpaqueInternal(x: Int, y: Int, format: Int): Bool {
		return true;
	}

	public inline function at(x: Int, y: Int): Color {
		return Color.fromValue(atInternal(x, y, getTextureFormat(myFormat)));
	}

	@:functionCode("
		kinc_image_t image;
		kinc_image_init(&image, imageData, originalWidth, originalHeight, (kinc_image_format_t)format);
		int value = kinc_image_at(&image, x, y);
		kinc_image_destroy(&image);
		return value;
	")
	function atInternal(x: Int, y: Int, format: Int): Int {
		return 0;
	}

	@:functionCode("
		if (imageType == KhaImageTypeTexture) {
			kinc_g4_texture_destroy(&texture);
		}
		else if (imageType == KhaImageTypeRenderTarget) {
			kinc_g4_render_target_destroy(&renderTarget);
		}
		else if (imageType == KhaImageTypeTextureArray) {
			kinc_g4_texture_array_destroy(&textureArray);
		}
		else {
			assert(false);
		}
		if (ownsImageData) {
			free(imageData);
		}
		imageData = NULL;
		imageType = KhaImageTypeNone;
	")
	public function unload(): Void {}

	var bytes: Bytes = null;

	@:functionCode("
		int size = kinc_image_format_sizeof(texture.format) * originalWidth * originalHeight;
		this->bytes = ::haxe::io::Bytes_obj::alloc(size);
		return this->bytes;
	")
	public function lock(level: Int = 0): Bytes {
		return null;
	}

	@:functionCode("
		uint8_t *b = bytes->b->Pointer();
		uint8_t *tex = kinc_g4_texture_lock(&texture);
		int size = kinc_image_format_sizeof(texture.format);
		int stride = kinc_g4_texture_stride(&texture);
		for (int y = 0; y < texture.tex_height; ++y) {
			for (int x = 0; x < texture.tex_width; ++x) {
#ifdef KORE_DIRECT3D
				if (texture.format == KINC_IMAGE_FORMAT_RGBA32) {
					//RBGA->BGRA
					tex[y * stride + x * size + 0] = b[(y * originalWidth + x) * size + 2];
					tex[y * stride + x * size + 1] = b[(y * originalWidth + x) * size + 1];
					tex[y * stride + x * size + 2] = b[(y * originalWidth + x) * size + 0];
					tex[y * stride + x * size + 3] = b[(y * originalWidth + x) * size + 3];
				}
				else
#endif
				{
					for (int i = 0; i < size; ++i) {
						tex[y * stride + x * size + i] = b[(y * originalWidth + x) * size + i];
					}
				}
			}
		}
		kinc_g4_texture_unlock(&texture);
	")
	public function unlock(): Void {
		bytes = null;
	}

	@:ifFeature("kha.Image.getPixelsInternal")
	var pixels: Bytes = null;
	@:ifFeature("kha.Image.getPixelsInternal")
	var pixelsAllocated: Bool = false;

	@:functionCode("
		if (imageType != KhaImageTypeRenderTarget) return NULL;
		if (!this->pixelsAllocated) {
			int size = formatSize * renderTarget.width * renderTarget.height;
			this->pixels = ::haxe::io::Bytes_obj::alloc(size);
			this->pixelsAllocated = true;
		}
		uint8_t *b = this->pixels->b->Pointer();
		kinc_g4_render_target_get_pixels(&renderTarget, b);
		return this->pixels;
	")
	function getPixelsInternal(formatSize: Int): Bytes {
		return null;
	}

	public function getPixels(): Bytes {
		return getPixelsInternal(formatByteSize(myFormat));
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
		untyped __cpp__("if (imageType == KhaImageTypeTexture) kinc_g4_texture_generate_mipmaps(&texture, levels); else if (imageType == KhaImageTypeRenderTarget) kinc_g4_render_target_generate_mipmaps(&renderTarget, levels)");
	}

	public function setMipmaps(mipmaps: Array<Image>): Void {
		for (i in 0...mipmaps.length) {
			var khaImage = mipmaps[i];
			var level = i + 1;
			var format = getTextureFormat(this.format);
			untyped __cpp__("
				kinc_image_t image;
				kinc_image_init(&image, {0}->imageData, {0}->originalWidth, {0}->originalHeight, (kinc_image_format_t){2});
				kinc_g4_texture_set_mipmap(&texture, &image, {1});
				kinc_image_destroy(&image);
			", khaImage, level, format);
		}
	}

	public function setDepthStencilFrom(image: Image): Void {
		untyped __cpp__("kinc_g4_render_target_set_depth_stencil_from(&renderTarget, &image->renderTarget)");
	}

	@:functionCode("if (imageType == KhaImageTypeTexture) kinc_g4_texture_clear(&texture, x, y, z, width, height, depth, color);")
	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {}

	public var stride(get, never): Int;

	@:functionCode("return kinc_g4_texture_stride(&texture);")
	function get_stride(): Int {
		return 0;
	}
}

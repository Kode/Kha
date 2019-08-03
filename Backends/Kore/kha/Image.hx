package kha;

import haxe.io.Bytes;
import haxe.io.BytesData;
import kha.kore.graphics4.TextureUnit;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <Kore/Graphics4/TextureArray.h>
')

@:headerClassCode("Kore::Graphics4::Texture* texture; Kore::Graphics4::RenderTarget* renderTarget; Kore::Graphics4::TextureArray* textureArray; Kore::Graphics4::Image** textureArrayTextures;")
class Image implements Canvas implements Resource {
	private var format: TextureFormat;
	private var readable: Bool;

	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;

	public static function createFromVideo(video: Video): Image {
		var image = new Image(false);
		image.format = TextureFormat.RGBA32;
		image.initVideo(cast(video, kha.kore.Video));
		return image;
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return _create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, NoDepthAndStencil, false, 0);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return _create3(width, height, depth, format == null ? TextureFormat.RGBA32 : format, false, 0);
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		return _create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, true, depthStencil, antiAliasingSamples > 1, contextId);
	}
	
	/**
	 * Textures in array mast be readable!
	 */
	public static function createArray(images:Array<Image>, format: TextureFormat = null):Image {
		var image = new Image(false);
		image.format = (format == null) ? TextureFormat.RGBA32 : format;
		initArrayTexture(image, images);
		return image;
	}
	
	@:functionCode('
		source->textureArrayTextures = new Kore::Graphics4::Image*[images->length];
		for (unsigned i = 0; i < images->length; ++i) {
			source->textureArrayTextures[i] = images->__get(i).StaticCast<  ::kha::Image >()->texture;
		}
		source->textureArray = new Kore::Graphics4::TextureArray(source->textureArrayTextures, images->length);
	')
	private static function initArrayTexture(source:Image, images:Array<Image>):Void {
		
	}
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var readable = true;
		var image = new Image(readable);
		image.format = format;
		image.initFromBytes(bytes.getData(), width, height, getTextureFormat(format));
		return image;
	}

	@:functionCode('texture = new Kore::Graphics4::Texture(bytes.GetPtr()->GetBase(), width, height, (Kore::Graphics1::Image::Format)format, readable);')
	private function initFromBytes(bytes: BytesData, width: Int, height: Int, format: Int): Void {
		
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		var readable = true;
		var image = new Image(readable);
		image.format = format;
		image.initFromBytes3D(bytes.getData(), width, height, depth, getTextureFormat(format));
		return image;
	}

	@:functionCode('texture = new Kore::Graphics4::Texture(bytes.GetPtr()->GetBase(), width, height, depth, (Kore::Graphics1::Image::Format)format, readable);')
	private function initFromBytes3D(bytes: BytesData, width: Int, height: Int, depth: Int, format: Int): Void {
		
	}
	
	public static function fromEncodedBytes(bytes: Bytes, format: String, doneCallback: Image -> Void, errorCallback: String->Void, readable: Bool = false): Void {
		var image = new Image(readable);
		var isFloat = format == "hdr" || format == "HDR";
		image.format = isFloat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
		image.initFromEncodedBytes(bytes.getData(), format);
		doneCallback(image);
	}

	@:functionCode('texture = new Kore::Graphics4::Texture(bytes.GetPtr()->GetBase(), bytes.GetPtr()->length, format.c_str(), readable);')
	private function initFromEncodedBytes(bytes: BytesData, format: String): Void {
		
	}

	private function new(readable: Bool) {
		this.readable = readable;
		nullify();
		cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:functionCode("texture = nullptr; renderTarget = nullptr; textureArray = nullptr; textureArrayTextures = nullptr;")
	function nullify() {

	}

	@:void static function finalize(image: Image): Void {
		image.unload();
	}

	private static function getRenderTargetFormat(format: TextureFormat): Int {
		switch (format) {
		case RGBA32:	// Target32Bit
			return 0;
		case RGBA64:	// Target64BitFloat
			return 1;
		case A32:		// Target32BitRedFloat
			return 2;
		case RGBA128:	// Target128BitFloat
			return 3;
		case DEPTH16:	// Target16BitDepth
			return 4;
		case L8:
			return 5;	// Target8BitRed
		case A16:
			return 6;	// Target16BitRedFloat
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

	@:noCompletion
	public static function _create2(width: Int, height: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthStencil: DepthStencilFormat, antiAliasing: Bool, contextId: Int): Image {
		var image = new Image(readable);
		image.format = format;
		if (renderTarget) image.initRenderTarget(width, height, getDepthBufferBits(depthStencil), antiAliasing, getRenderTargetFormat(format), getStencilBufferBits(depthStencil), contextId);
		else image.init(width, height, getTextureFormat(format));
		return image;
	}

	@:noCompletion
	public static function _create3(width: Int, height: Int, depth: Int, format: TextureFormat, readable: Bool, contextId: Int): Image {
		var image = new Image(readable);
		image.format = format;
		image.init3D(width, height, depth, getTextureFormat(format));
		return image;
	}

	@:functionCode('renderTarget = new Kore::Graphics4::RenderTarget(width, height, depthBufferBits, antiAliasing, (Kore::Graphics4::RenderTargetFormat)format, stencilBufferBits, contextId); texture = nullptr;')
	private function initRenderTarget(width: Int, height: Int, depthBufferBits: Int, antiAliasing: Bool, format: Int, stencilBufferBits: Int, contextId: Int): Void {

	}

	@:functionCode('texture = new Kore::Graphics4::Texture(width, height, (Kore::Graphics4::Image::Format)format, readable); renderTarget = nullptr;')
	private function init(width: Int, height: Int, format: Int): Void {

	}

	@:functionCode('texture = new Kore::Graphics4::Texture(width, height, depth, (Kore::Graphics4::Image::Format)format, readable); renderTarget = nullptr;')
	private function init3D(width: Int, height: Int, depth:Int, format: Int): Void {

	}

	@:functionCode('texture = video->video->currentImage(); renderTarget = nullptr;')
	private function initVideo(video: kha.kore.Video): Void {

	}

	public static function createEmpty(readable: Bool, floatFormat: Bool): Image {
		var image = new Image(readable);
		image.format = floatFormat ? TextureFormat.RGBA128 : TextureFormat.RGBA32;
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
			graphics2 = new kha.kore.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, null): kha.graphics4.Graphics;

	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.kore.graphics4.Graphics(this);
		}
		return graphics4;
	}

	public static var maxSize(get, null): Int;

	public static function get_maxSize(): Int {
		return 4096;
	}

	public static var nonPow2Supported(get, null): Bool;

	@:functionCode('return Kore::Graphics4::nonPow2TexturesSupported();')
	public static function get_nonPow2Supported(): Bool {
		return false;
	}

	public var width(get, null): Int;
	public var height(get, null): Int;
	public var depth(get, null): Int;

	@:functionCode("if (texture != nullptr) return texture->width; else return renderTarget->width;")
	public function get_width(): Int {
		return 0;
	}

	@:functionCode("if (texture != nullptr) return texture->height; else return renderTarget->height;")
	public function get_height(): Int {
		return 0;
	}

	@:functionCode("if (texture != nullptr) return texture->depth; else return 0;")
	public function get_depth(): Int {
		return 0;
	}

	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;

	@:functionCode("if (texture != nullptr) return texture->texWidth; else return renderTarget->texWidth;")
	public function get_realWidth(): Int {
		return 0;
	}

	@:functionCode("if (texture != nullptr) return texture->texHeight; else return renderTarget->texHeight;")
	public function get_realHeight(): Int {
		return 0;
	}

	@:functionCode("return (texture->at(x, y) & 0xff) != 0;")
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}

	@:functionCode('return texture->at(x, y);')
	private function atInternal(x: Int, y: Int): Int {
		return 0;
	}

	public inline function at(x: Int, y: Int): Color {
		return Color.fromValue(atInternal(x, y));
	}

	@:functionCode("delete texture; texture = nullptr; delete renderTarget; renderTarget = nullptr; delete textureArray; textureArray = nullptr; delete[] textureArrayTextures; textureArrayTextures = nullptr;")
	public function unload(): Void {

	}

	private var bytes: Bytes = null;

	@:functionCode('
		int size = texture-> sizeOf(texture->format) * texture->width * texture->height;
		this->bytes = ::haxe::io::Bytes_obj::alloc(size);
		return this->bytes;
	')
	public function lock(level: Int = 0): Bytes {
		return null;
	}

	@:functionCode('
		Kore::u8* b = bytes->b->Pointer();
		Kore::u8* tex = texture->lock();
		int size = texture->sizeOf(texture->format);
		int stride = texture->stride();
		for (int y = 0; y < texture->height; ++y) {
			for (int x = 0; x < texture->width; ++x) {
#ifdef KORE_DIRECT3D
				if (texture->format == Kore::Graphics4::Image::RGBA32) {
					//RBGA->BGRA
					tex[y * stride + x * size + 0] = b[(y * texture->width + x) * size + 2];
					tex[y * stride + x * size + 1] = b[(y * texture->width + x) * size + 1];
					tex[y * stride + x * size + 2] = b[(y * texture->width + x) * size + 0];
					tex[y * stride + x * size + 3] = b[(y * texture->width + x) * size + 3];
				}
				else
#endif
				{
					for (int i = 0; i < size; ++i) {
						tex[y * stride + x * size + i] = b[(y * texture->width + x) * size + i];
					}
				}
			}
		}
		texture->unlock();
	')
	public function unlock(): Void {
		bytes = null;
	}

	@:ifFeature("kha.Image.getPixelsInternal")
	private var pixels: Bytes = null;
	@:ifFeature("kha.Image.getPixelsInternal")
	private var pixelsAllocated: Bool = false;

	@:functionCode('
		if (renderTarget == nullptr) return nullptr;
		if (!this->pixelsAllocated) {
			int size = formatSize * renderTarget->width * renderTarget->height;
			this->pixels = ::haxe::io::Bytes_obj::alloc(size);
			this->pixelsAllocated = true;
		}
		Kore::u8* b = this->pixels->b->Pointer();
		renderTarget->getPixels(b);
		return this->pixels;
	')
	private function getPixelsInternal(formatSize: Int): Bytes {
		return null;
	}

	public function getPixels(): Bytes {
		return getPixelsInternal(formatByteSize(format));
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
		untyped __cpp__("texture != nullptr ? texture->generateMipmaps(levels) : renderTarget->generateMipmaps(levels)");
	}

	public function setMipmaps(mipmaps: Array<Image>): Void {
		for (i in 0...mipmaps.length) {
			var image = mipmaps[i];
			var level = i + 1;
			untyped __cpp__("texture->setMipmap(image->texture, level)");
		}
	}

	public function setDepthStencilFrom(image: Image): Void {
		untyped __cpp__("renderTarget->setDepthStencilFrom(image->renderTarget)");
	}

	@:functionCode("if (texture != nullptr) texture->clear(x, y, z, width, height, depth, color);")
	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {
		
	}
}

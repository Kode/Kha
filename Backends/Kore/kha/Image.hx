package kha;

import haxe.io.Bytes;
import kha.kore.graphics4.TextureUnit;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Texture* texture; Kore::RenderTarget* renderTarget;")
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
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		return create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, false);
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		return create2(width, height, format == null ? TextureFormat.RGBA32 : format, false, true, depthStencil);
	}
	
	private function new(readable: Bool) {
		this.readable = readable;
	}

	private static function getRenderTargetFormat(format: TextureFormat): Int {
		switch (format) {
		case RGBA32:	// Target32Bit
			return 0;
		case RGBA128:	// Target32BitFloat
			return 3;
		default:
			return 0;
		}
	}
	
	public static function create2(width: Int, height: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthBuffer: Bool): Image {
		var image = new Image(readable);
		image.format = format;
		if (renderTarget) image.initRenderTarget(width, height, getRenderTargetFormat(format), depthBuffer);
		else image.init(width, height, format == TextureFormat.RGBA32 ? 0 : 1);
		return image;
	}
	
	@:functionCode('renderTarget = new Kore::RenderTarget(width, height, depthBuffer, false, (Kore::RenderTargetFormat)format); texture = nullptr;')
	private function initRenderTarget(width: Int, height: Int, format: Int, depthBuffer: Bool): Void {
		
	}
	
	@:functionCode('texture = new Kore::Texture(width, height, (Kore::Image::Format)format, readable); renderTarget = nullptr;')
	private function init(width: Int, height: Int, format: Int): Void {
		
	}

	@:functionCode('texture = video->video->currentImage(); renderTarget = nullptr;')
	private function initVideo(video: kha.kore.Video): Void {

	}
	
	public static function fromFile(filename: String, readable: Bool): Image {
		var image = new Image(readable);
		image.format = TextureFormat.RGBA32;
		image.initFromFile(filename);
		return image;
	}
	
	@:functionCode('texture = new Kore::Texture(filename.c_str(), readable);')
	private function initFromFile(filename: String): Void {
		
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
	
	@:functionCode('return Kore::Graphics::nonPow2TexturesSupported();')
	public static function get_nonPow2Supported(): Bool {
		return false;
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	@:functionCode("if (texture != nullptr) return texture->width; else return renderTarget->width;")
	public function get_width(): Int {
		return 0; 
	}
	
	@:functionCode("if (texture != nullptr) return texture->height; else return renderTarget->height;")
	public function get_height(): Int {
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
	
	@:functionCode("delete texture; texture = nullptr; delete renderTarget; renderTarget = nullptr;")
	public function unload(): Void {
		
	}
	
	private var bytes: Bytes = null;
	
	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}
	
	@:functionCode('
		Kore::u8* b = bytes->b->Pointer();
		Kore::u8* tex = texture->lock();
		for (int i = 0; i < ((texture->format == Kore::Image::RGBA32) ? (4 * texture->width * texture->height) : (texture->width * texture->height)); ++i) tex[i] = b[i];
		texture->unlock();
	')
	public function unlock(): Void {	
		bytes = null;
	}
}

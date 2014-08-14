package kha.cpp;

import haxe.io.Bytes;
import kha.cpp.graphics.TextureUnit;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Texture* texture; Kore::RenderTarget* renderTarget;")
class Image implements Texture {
	private var format: TextureFormat;
	private var readable: Bool;
	
	private function new(readable: Bool) {
		this.readable = readable;
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthBuffer: Bool): Image {
		var image = new Image(readable);
		image.format = format;
		if (renderTarget) image.initRenderTarget(width, height, format == TextureFormat.RGBA32 ? 0 : 1, depthBuffer);
		else image.init(width, height, format == TextureFormat.RGBA32 ? 0 : 1);
		return image;
	}
	
	@:functionCode('renderTarget = new Kore::RenderTarget(width, height, depthBuffer, false, Kore::Target32Bit); texture = nullptr;')
	private function initRenderTarget(width: Int, height: Int, format: Int, depthBuffer: Bool): Void {
		
	}
	
	@:functionCode('texture = new Kore::Texture(width, height, (Kore::Image::Format)format, readable); renderTarget = nullptr;')
	private function init(width: Int, height: Int, format: Int): Void {
		
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
	
	@:functionCode("
		if (texture != nullptr) texture-> set(unit->unit);
		else renderTarget->useColorAsTexture(unit->unit);
	")
	public function set(unit: TextureUnit): Void {
		
	}
	
	@:functionCode("return texture->at(x, y) & 0xff != 0;")
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
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

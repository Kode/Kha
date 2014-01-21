package kha.cpp;

import haxe.io.Bytes;
import kha.cpp.graphics.TextureUnit;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Texture* texture;")
class Image implements Texture {
	private var format: TextureFormat;
	
	private function new() { }
	
	public static function create(width: Int, height: Int, format: TextureFormat): Image {
		var image = new Image();
		image.format = format;
		image.init(width, height, format == TextureFormat.RGBA32 ? 0 : 1);
		return image;
	}
	
	@:functionCode('texture = new Kore::Texture(width, height, (Kore::Image::Format)format);')
	private function init(width: Int, height: Int, format: Int): Void {
		
	}
	
	public static function fromFile(filename: String): Image {
		var image = new Image();
		image.format = TextureFormat.L8;
		image.initFromFile(filename);
		return image;
	}
	
	@:functionCode('texture = new Kore::Texture(filename.c_str());')
	private function initFromFile(filename: String): Void {
		
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	@:functionCode("return texture->width;")
	public function get_width(): Int {
		return 0; 
	}
	
	@:functionCode("return texture->height;")
	public function get_height(): Int {
		return 0;
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	@:functionCode("return texture->texWidth;")
	public function get_realWidth(): Int {
		return 0;
	}
	
	@:functionCode("return texture->texHeight;")
	public function get_realHeight(): Int {
		return 0;
	}
	
	@:functionCode("
		texture->set(unit->unit);
	")
	public function set(unit: TextureUnit): Void {
		
	}
	
	//@:functionCode("return image.At(x, y).Ab() > 0;")
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	@:functionCode("delete texture; texture = nullptr;")
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

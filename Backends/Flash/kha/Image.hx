package kha;

import flash.utils.ByteArray;
import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.geom.Matrix;

class Image implements Canvas implements Resource {
	private var tex: Texture;
	private var myWidth: Int;
	private var myHeight: Int;
	private var texWidth: Int;
	private var texHeight: Int;
	private var format: TextureFormat;
	private var depthStencil: Bool;
	
	private var data: BitmapData;
	private var bytes: Bytes;
	private var readable: Bool;
	
	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, usage == Usage.ReadableUsage);
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, true, depthStencil, false);
	}
	
	public function new(width: Int, height: Int, format: TextureFormat, renderTarget: Bool, depthStencil: Bool, readable: Bool) {
		myWidth = width;
		myHeight = height;
		texWidth = upperPowerOfTwo(Std.int(myWidth));
		texHeight = upperPowerOfTwo(Std.int(myHeight));
		this.format = format;
		this.depthStencil = depthStencil;
		this.readable = readable;
		tex = SystemImpl.context.createTexture(texWidth, texHeight, format == TextureFormat.RGBA128 ? Context3DTextureFormat.RGBA_HALF_FLOAT : Context3DTextureFormat.BGRA, renderTarget);
	}
	
	public static function fromBitmap(image: DisplayObject, readable: Bool): Image {
		var bitmap = cast(image, Bitmap);
		return fromBitmapData(bitmap.bitmapData, readable);
	}
	
	public static function fromBitmapData(image: BitmapData, readable: Bool): Image {
		var texture = new Image(Std.int(image.width), Std.int(image.height), TextureFormat.RGBA32, false, false, readable);
		texture.uploadBitmap(image, readable);
		return texture;
	}
	
	public function uploadBitmap(bitmap: BitmapData, readable: Bool): Void {
		if (readable) data = bitmap;
		tex.uploadFromBitmapData(bitmap, 0);
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
			graphics2 = new kha.flash.graphics4.Graphics2(this);
		}
		return graphics2;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.flash.graphics4.Graphics(this);
		}
		return graphics4;
	}
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 2048;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return false;
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	private function get_width(): Int {
		return Std.int(myWidth);
	}
	
	private function get_height(): Int {
		return Std.int(myHeight);
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	private function get_realWidth(): Int {
		return texWidth;
	}
	
	private function get_realHeight(): Int {
		return texHeight;
	}
	
	public function unload(): Void {
		if (tex != null) {
			tex.dispose();
			tex = null;
		}
	}
	
	public function isOpaque(x: Int, y: Int): Bool {
		if (data != null) return (data.getPixel32(x, y) >> 24 & 0xFF) != 0;
		if (bytes != null) return bytes.get(y * texWidth * 4 + x * 4 + 3) != 0;
		return true;
	}
	
	public inline function at(x: Int, y: Int): Color {
		return Color.fromValue(data.getPixel32(x, y));
	}
	
	public function getFlashTexture(): Texture {
		return tex;
	}
	
	public function hasDepthStencil(): Bool {
		return depthStencil;
	}
	
	private static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}
	
	public function lock(level: Int = 0): Bytes {
		if (bytes == null) {
			switch (format) {
				case RGBA32:
					bytes = Bytes.alloc(texWidth * texHeight * 4);
				case L8:
					bytes = Bytes.alloc(texWidth * texHeight);
				case RGBA128:
					bytes = Bytes.alloc(texWidth * texHeight * 16);
			}
		}
		return bytes;
	}
	
	public function unlock(): Void {
		switch (format) {
			case RGBA32:
				tex.uploadFromByteArray(bytes.getData(), 0);
			case L8:
				var rgbaBytes = Bytes.alloc(texWidth * texHeight * 4);
				for (y in 0...texHeight) for (x in 0...texWidth) {
					var value = bytes.get(y * texWidth + x);
					rgbaBytes.set(y * texWidth * 4 + x * 4 + 0, value);
					rgbaBytes.set(y * texWidth * 4 + x * 4 + 1, value);
					rgbaBytes.set(y * texWidth * 4 + x * 4 + 2, value);
					rgbaBytes.set(y * texWidth * 4 + x * 4 + 3, 255);
				}
				tex.uploadFromByteArray(rgbaBytes.getData(), 0);
			case RGBA128:
				var rgbaBytes = Bytes.alloc(texWidth * texHeight * 8);
				for (y in 0...texHeight) for (x in 0...texWidth) {
					var value1 = bytes.getDouble(y * texWidth * 16 + x * 16 +  0);
					var value2 = bytes.getDouble(y * texWidth * 16 + x * 16 +  4);
					var value3 = bytes.getDouble(y * texWidth * 16 + x * 16 +  8);
					var value4 = bytes.getDouble(y * texWidth * 16 + x * 16 + 12);
					rgbaBytes.setFloat(y * texWidth * 8 + x * 8 + 0, value1);
					rgbaBytes.setFloat(y * texWidth * 8 + x * 8 + 2, value2);
					rgbaBytes.setFloat(y * texWidth * 8 + x * 8 + 4, value3);
					rgbaBytes.setFloat(y * texWidth * 8 + x * 8 + 6, value4);
				}
				tex.uploadFromByteArray(rgbaBytes.getData(), 0);
		}
		
		if (!readable) bytes = null;
	}
}

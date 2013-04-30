package kha.flash;

import kha.Starter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.geom.Matrix;

class Image implements kha.graphics.Texture {
	static var maxTextureControll: List<Image> = new List<Image>();
	
	public var image: Bitmap;
	private var tex: Texture;
	private var texWidth: Int;
	private var texHeight: Int;
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	public function get_width(): Int {
		return Std.int(image.width);
	}
	
	public function get_height(): Int {
		return Std.int(image.height);
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	public function get_realWidth(): Int {
		return texWidth;
	}
	
	public function get_realHeight(): Int {
		return texHeight;
	}
	
	public function new(image: DisplayObject)  {
		this.image = cast(image, Bitmap);
	}
	
	public function unload(): Void {
		dispose();
	}
	
	public function dispose(): Void {
		if (tex != null) {
			tex.dispose();
			tex = null;
		}
	}
	
	public function isOpaque(x: Int, y: Int): Bool {
		return (image.bitmapData.getPixel32(x, y) >> 24 & 0xFF) != 0;
	}
	
	public function getFlashTexture(): Texture {
		if (tex == null) uploadTextureWithMipmaps();
		return tex;
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
	
	function uploadTextureWithMipmaps(): Void {		
		texWidth = upperPowerOfTwo(Std.int(image.width));
		texHeight = upperPowerOfTwo(Std.int(image.height));
		while (tex == null) {
			try {
				tex = Starter.context.createTexture(texWidth, texHeight, Context3DTextureFormat.BGRA, false);
				maxTextureControll.add(this);
			}
			catch (e : Dynamic) {
				var toDispose = maxTextureControll.pop();
				toDispose.dispose();
			}
		}
		tex.uploadFromBitmapData(image.bitmapData, 0);
		
		/*var level : Int = 0;
		var transform = new Matrix();
		var tmp = new BitmapData(ws, hs, true, 0x00000000);

		while (ws >= 1 && hs >= 1) {
			tmp.draw(image.bitmapData, transform, null, null, null, true);
			tex.uploadFromBitmapData(tmp, level);
			transform.scale(0.5, 0.5);
			++level;
			ws >>= 1;
			hs >>= 1;
			if (hs != 0 && ws != 0) {
				tmp.dispose();
				tmp = new BitmapData(ws, hs, true, 0x00000000);
			}
		}
		tmp.dispose();*/
	}
	
	public function correctU(u: Float): Float {
		return u * image.width / texWidth;
	}

	public function correctV(v: Float): Float {
		return v * image.height / texHeight;
	}
}

package com.ktxsoftware.kha.backends.flash;

import com.ktxsoftware.kha.Starter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.geom.Matrix;

class Image implements com.ktxsoftware.kha.Image {
	public var image : Bitmap;
	
	public function new(image : DisplayObject)  {
		this.image = cast(image, Bitmap);
	}
	
	public function getWidth() : Int {
		return Std.int(image.width);
	}
	
	public function getHeight() : Int {
		return Std.int(image.height);
	}
	
	public function isAlpha(x : Int, y : Int) : Bool {
		return true;
	}
	
	public function getTexture() : Texture {
		var tex : Texture;
		tex = Starter.context.createTexture(Std.int(image.width), Std.int(image.height), Context3DTextureFormat.BGRA, false);
		uploadTextureWithMipmaps(tex);
		return tex;
	}
	
	function uploadTextureWithMipmaps(dest : Texture) : Void {
		var ws : Int = Std.int(image.width);
		var hs : Int = Std.int(image.height);
		var level : Int = 0;
		var transform = new Matrix();
		var tmp = new BitmapData(ws, hs, true, 0x00000000);

		while (ws >= 1 && hs >= 1) {
			tmp.draw(image.bitmapData, transform, null, null, null, true);
			dest.uploadFromBitmapData(tmp, level);
			transform.scale(0.5, 0.5);
			++level;
			ws >>= 1;
			hs >>= 1;
			if (hs != 0 && ws != 0) {
				tmp.dispose();
				tmp = new BitmapData(ws, hs, true, 0x00000000);
			}
		}
		tmp.dispose();
	}
}
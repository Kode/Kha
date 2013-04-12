package kha.flash;

import kha.Starter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.geom.Matrix;

class Image implements kha.Image {
	static var maxTextureControll: List<Image> = new List<Image>();
	
	public var image: Bitmap;
	private var tex: Texture;
	private var texWidth: Int;
	private var texHeight: Int;
	
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
	
	public function getWidth(): Int {
		return Std.int(image.width);
	}
	
	public function getHeight(): Int {
		return Std.int(image.height);
	}
	
	public function isOpaque(x: Int, y: Int): Bool {
		return (image.bitmapData.getPixel32(x, y) >> 24 & 0xFF) != 0;
	}
	
	public function getFlashTexture(): Texture {
		if (tex == null) uploadTextureWithMipmaps();
		return tex;
	}
	
	private var texture: kha.graphics.Texture = null;
	
	public function getTexture(): kha.graphics.Texture {
		return texture;
	}
	
	public function setTexture(texture: kha.graphics.Texture): Void {
		this.texture = texture;
	}
	
	private function pow(pow: Int): Int {
        var ret : Int = 1;
        for (i in 0...pow) ret *= 2;
        return ret;
    }

    private function toPow2(i: Int): Int {
        var power: Int = 0;
		while (true) {
            if (pow(power) >= i) return pow(power);
			++power;
		}
		return -1;
    }
	
	function uploadTextureWithMipmaps(): Void {		
		texWidth = toPow2(Std.int(image.width));
		texHeight = toPow2(Std.int(image.height));
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
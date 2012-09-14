package kha.android;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import java.lang.ref.WeakReference;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.io.Exceptions;

class BitmapManager {
	static var images : Array<Image> = new Array<Image>();
	
	public static function add(image : Image) {
		images.push(image);
	}
	
	public static function touch(image : Image) {
		images.remove(image);
		images.push(image);
		for (i in 0...images.length - 10) images[i].unload();
	}
}

class Image implements kha.Image {
	public static var assets : AssetManager;
	var name : String;
	var bitmap : WeakReference<Bitmap>;
	var b : Bitmap;
	
	public var tex : Int = -1;
	var buffer : Buffer;
	
	public function new(name : String) {
		this.name = name;
		BitmapManager.add(this);
	}
	
	function load() : Void {
		if (bitmap != null && bitmap.get() != null) return;
		try {
			b = BitmapFactory.decodeStream(assets.open(name));
			bitmap = new WeakReference<Bitmap>(b);
		}
		catch (e : IOException) {
			e.printStackTrace();
		}
		BitmapManager.touch(this);
	}
	
	public function unload() : Void {
		b = null;
	}
	
	public function getBuffer() : Buffer {
		load();
		if (buffer == null) {
			buffer = ByteBuffer.allocateDirect(getBitmap().getWidth() * getBitmap().getHeight() * 4);
			getBitmap().copyPixelsToBuffer(buffer);
		}
		return buffer;
	}
	
	public function getBitmap() : Bitmap {
		load();
		return bitmap.get();
	}
	
	public function getWidth() : Int {
		load();
		return bitmap.get().getWidth();
	}

	public function getHeight() : Int {
		load();
		return bitmap.get().getHeight();
	}

	public function isOpaque(x : Int, y : Int) : Bool {
		load();
		return (bitmap.get().getPixel(x, y) >> 24) != 0;
	}
}
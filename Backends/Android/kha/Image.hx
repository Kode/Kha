package kha;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import haxe.io.Bytes;
import java.lang.ref.WeakReference;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.io.IOException;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

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

class Image {
	public static var assets : AssetManager;
	private var name: String;
	private var bitmap: WeakReference<Bitmap>;
	private var b: Bitmap;
	
	public var tex: Int = -1;
	private var buffer: Buffer;
	
	public function new(name: String) {
		this.name = name;
		BitmapManager.add(this);
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (usage == null) usage = Usage.StaticUsage;
		return null;
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		if (format == null) format = TextureFormat.RGBA32;
		return null;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return null;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		return null;
	}
	
	private function load() : Void {
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
	
	public var width(get, null): Int;
	
	private function get_width() : Int {
		load();
		return bitmap.get().getWidth();
	}
	
	public var height(get, null): Int;

	private function get_height() : Int {
		load();
		return bitmap.get().getHeight();
	}
	
	public var realWidth(get, null): Int;
	
	private function get_realWidth(): Int {
		return width;
	}
	
	public var realHeight(get, null): Int;
	
	private function get_realHeight(): Int {
		return height;
	}

	public function isOpaque(x : Int, y : Int) : Bool {
		load();
		return (bitmap.get().getPixel(x, y) >> 24) != 0;
	}
	
	public function lock(level: Int = 0): Bytes {
		return null;
	}
	
	public function unlock(): Void {
		
	}
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 2048;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return false;
	}
}

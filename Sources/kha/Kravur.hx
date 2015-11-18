package kha;

import haxe.ds.Vector;
import haxe.io.Bytes;
import kha.graphics2.truetype.StbTruetype;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class BakedChar {
	public function new() { }
	
	// coordinates of bbox in bitmap
	public var x0: Int;
	public var y0: Int;
	public var x1: Int;
	public var y1: Int;
   
	public var xoff: Float;
	public var yoff: Float;
	public var xadvance: Float;
}

class AlignedQuad {
	public function new() { }
	
	// top-left
	public var x0: Float;
	public var y0: Float;
	public var s0: Float;
	public var t0: Float;
	
	// bottom-right
	public var x1: Float;
	public var y1: Float;
	public var s1: Float;
	public var t1: Float;
	
	public var xadvance: Float;
}

class Kravur implements Font {
	private var myName: String;
	private var myStyle: FontStyle;
	private var mySize: Float;
	
	private var chars: Vector<Stbtt_bakedchar>;
	private var texture: Image;
	public var width: Int;
	public var height: Int;
	private var baseline: Float;
	
	private static var fontCache: Map<String, Kravur> = new Map();
	
	/**
		Returns the cached Kravur for name, style and size or loads it.
	**/
	public static function load(name: String, style: FontStyle, size: Float, done: Kravur -> Void): Void {
		var key = createKey(name, style, size);
		
		var kravur = fontCache.get(key);
		if (kravur == null) {
			Assets.loadBlobFromPath(key, function (blob: Blob) {
				if (blob != null) {
					var kravur = getFromBlob(name, style, size, blob);
					kravur.myName = name;
					kravur.myStyle = style;
					kravur.mySize = size;
					
					fontCache.set(key, kravur);
					
					done(kravur);
				}
			});
		}
		else {
			done(kravur);
		}
	}
	
	public static function getFromBlob(name: String, style: FontStyle, size: Float, blob: Blob): Kravur {
		var width: Int = 64;
		var height: Int = 32;
		var baked = new Vector<Stbtt_bakedchar>(256 - 32);
		for (i in 0...baked.length) {
			baked[i] = new Stbtt_bakedchar();
		}

		var pixels: Bytes = null;

		var status: Int = -1;
		while (status < 0) {
			if (height < width) height *= 2;
			else width *= 2;
			pixels = Bytes.alloc(width * height);
			status = StbTruetype.stbtt_BakeFontBitmap(blob.bytes, 0, size, pixels, width, height, 32, 256 - 32, baked);
		}
		
		// TODO: Scale pixels down if they exceed the supported texture size
		
		var info = new Stbtt_fontinfo();
		StbTruetype.stbtt_InitFont(info, blob.bytes, 0);

		var metrics = StbTruetype.stbtt_GetFontVMetrics(info);
		var scale = StbTruetype.stbtt_ScaleForPixelHeight(info, size);
		var ascent = Math.round(metrics.ascent * scale); // equals baseline
		var descent = Math.round(metrics.descent * scale);
		var lineGap = Math.round(metrics.lineGap * scale);
		
		var key = createKey(name, style, size);
		
		var kravur = fontCache.get(key);
		if (kravur == null) {
			var kravur = new Kravur(Std.int(size), ascent, descent, lineGap, width, height, baked, pixels);
			kravur.myName = name;
			kravur.myStyle = style;
			kravur.mySize = size;
			
			fontCache.set(key, kravur);
			
			return kravur;		
		}
		else {
			return kravur;
		}
	}
	
	public static function createKey(name: String, style: FontStyle, size: Float): String {
		var key = name;
		if (style.getBold()) {
			key += "#Bold";
		}
		if (style.getItalic()) {
			key += "#Italic";
		}
		key += size + ".kravur";
		return key;
	}
	
	private function new(size: Int, ascent: Int, descent: Int, lineGap: Int, width: Int, height: Int, chars: Vector<Stbtt_bakedchar>, pixels: Bytes) {
		this.width = width;
		this.height = height;
		this.chars = chars;
		baseline = ascent;
		for (char in chars) {
			char.yoff += baseline;
		}
		texture = Image.create(width, height, TextureFormat.L8);
		var bytes = texture.lock();
		var pos: Int = 0;
		for (y in 0...height) for (x in 0...width) {
			bytes.set(pos, pixels.get(pos));
			++pos;
		}
		texture.unlock();
	}
	
	public function getTexture(): Image {
		return texture;
	}
	
	public function getBakedQuad(char_index: Int, xpos: Float, ypos: Float): AlignedQuad {
		if (char_index >= chars.length) return null;
		var ipw: Float = 1.0 / width;
		var iph: Float = 1.0 / height;
		var b = chars[char_index];
		if (b == null) return null;
		var round_x: Int = Math.round(xpos + b.xoff);
		var round_y: Int = Math.round(ypos + b.yoff);

		var q = new AlignedQuad();
		q.x0 = round_x;
		q.y0 = round_y;
		q.x1 = round_x + b.x1 - b.x0;
		q.y1 = round_y + b.y1 - b.y0;

		q.s0 = b.x0 * ipw;
		q.t0 = b.y0 * iph;
		q.s1 = b.x1 * ipw;
		q.t1 = b.y1 * iph;

		q.xadvance = b.xadvance;
		
		return q;
	}
	
	private function getCharWidth(charIndex: Int): Float {
		if (charIndex < 32) return 0;
		if (charIndex - 32 >= chars.length) return 0;
		return chars[charIndex - 32].xadvance;
	}
	
	public var name(get, null): String;
	public var style(get, null): FontStyle;
	public var size(get, null): Float;
	
	public function get_name(): String {
		return myName;
	}
	
	public function get_style(): FontStyle {
		return myStyle;
	}
	
	public function get_size(): Float {
		return mySize;
	}
	
	public function getHeight(): Float {
		return mySize;
	}
	
	public function charWidth(ch: String): Float {
		return getCharWidth(ch.charCodeAt(0));
	}

	public function charsWidth(ch: String, offset: Int, length: Int): Float {
		return stringWidth(ch.substr(offset, length));
	}
	
	public function stringWidth(string: String): Float {
		var str = new SuperString(string);
		var width: Float = 0;
		for (c in 0...str.length) {
			width += getCharWidth(str.charCodeAt(c));
		}
		//trace("width: " + width);
		if (width > 10 && width < 100) {
			var a = 3;
			++a;
		}
		return width;
	}
	
	public function getBaselinePosition(): Float {
		return baseline;
	}
}

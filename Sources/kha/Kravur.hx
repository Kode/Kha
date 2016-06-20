package kha;

import haxe.ds.Vector;
import haxe.io.Bytes;
import kha.graphics2.truetype.StbTruetype;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

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

class KravurImage {
	private var mySize: Float;
	
	private var chars: Vector<Stbtt_bakedchar>;
	private var texture: Image;
	public var width: Int;
	public var height: Int;
	private var baseline: Float;
	
	public function new(size: Int, ascent: Int, descent: Int, lineGap: Int, width: Int, height: Int, chars: Vector<Stbtt_bakedchar>, pixels: Blob) {
		mySize = size;
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
			bytes.set(pos, pixels.readU8(pos));
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
	
	public function getHeight(): Float {
		return mySize;
	}
	
	public function stringWidth(string: String): Float {
		var str = new SuperString(string);
		var width: Float = 0;
		for (c in 0...str.length) {
			width += getCharWidth(str.charCodeAt(c));
		}
		return width;
	}
	
	public function getBaselinePosition(): Float {
		return baseline;
	}
}

class Kravur implements Font {
	private var blob: Blob;
	private var images: Map<Int, KravurImage> = new Map();
	
	public function new(blob: Blob) {
		this.blob = blob;
	}
	
	public function _get(fontSize: Int, glyphs: Array<Int> = null): KravurImage {
		if (!images.exists(fontSize)) {
			if (glyphs == null) {
				glyphs = [];
				for (i in 32...256) {
					glyphs.push(i);
				}
			}
			
			var width: Int = 64;
			var height: Int = 32;
			var baked = new Vector<Stbtt_bakedchar>(glyphs.length);
			for (i in 0...baked.length) {
				baked[i] = new Stbtt_bakedchar();
			}

			var pixels: Blob = null;

			var status: Int = -1;
			while (status < 0) {
				if (height < width) height *= 2;
				else width *= 2;
				pixels = Blob.alloc(width * height);
				status = StbTruetype.stbtt_BakeFontBitmap(blob, 0, fontSize, pixels, width, height, glyphs, baked);
			}
			
			// TODO: Scale pixels down if they exceed the supported texture size
			
			var info = new Stbtt_fontinfo();
			StbTruetype.stbtt_InitFont(info, blob, 0);

			var metrics = StbTruetype.stbtt_GetFontVMetrics(info);
			var scale = StbTruetype.stbtt_ScaleForPixelHeight(info, fontSize);
			var ascent = Math.round(metrics.ascent * scale); // equals baseline
			var descent = Math.round(metrics.descent * scale);
			var lineGap = Math.round(metrics.lineGap * scale);
			
			var image = new KravurImage(Std.int(fontSize), ascent, descent, lineGap, width, height, baked, pixels);
			images[fontSize] = image;
			return image;
		}
		return images[fontSize];
	}

	public function height(fontSize: Int): Float {
		return _get(fontSize).getHeight();
	}

	public function width(fontSize: Int, str: String): Float {
		return _get(fontSize).stringWidth(str);
	}
	
	public function baseline(fontSize: Int): Float {
		return _get(fontSize).getBaselinePosition();
	}
	
	public function unload(): Void {
		blob = null;
		images = null;
	}
}

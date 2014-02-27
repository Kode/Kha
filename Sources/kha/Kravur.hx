package kha;

import kha.graphics.Texture;
import kha.graphics.TextureFormat;
import kha.graphics.Usage;

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
	
	private var chars: Array<BakedChar>;
	private var texture: Texture;
	public var width: Int;
	public var height: Int;
	private var baseline: Float;
	
	private static var fontCache: Map<String, Kravur> = new Map();
	/**
		Returns the cached Kravur for name, style and size or loads it.
	**/
	public static function get(name: String, style: FontStyle, size: Float) : Kravur {
		var key = name;
		if (style.getBold()) {
			key += "#Bold";
		}
		if (style.getItalic()) {
			key += "#Italic";
		}
		key += size + ".kravur";
		
		var kravur = fontCache.get(key);
		if (kravur == null) {
			kravur = new Kravur(key);
			kravur.myName = name;
			kravur.myStyle = style;
			kravur.mySize = size;
			
			fontCache.set(key, kravur);
		}
		return kravur;
	}
	
	private function new(name: String) {
		var blob = Loader.the.getBlob(name);
		var size = blob.readS32LE();
		var ascent = blob.readS32LE();
		var descent = blob.readS32LE();
		var lineGap = blob.readS32LE();
		baseline = ascent;
		chars = new Array<BakedChar>();
		for (i in 0...256 - 32) {
			var char = new BakedChar();
			char.x0 = blob.readS16LE();
			char.y0 = blob.readS16LE();
			char.x1 = blob.readS16LE();
			char.y1 = blob.readS16LE();
			char.xoff = blob.readF32LE();
			char.yoff = blob.readF32LE() + baseline;
			char.xadvance = blob.readF32LE();
			chars.push(char);
		}
		width = blob.readS32LE();
		height = blob.readS32LE();
		var w = width;
		var h = height;
		while (w > Sys.graphics.maxTextureSize() || h > Sys.graphics.maxTextureSize()) {
			blob.seek(blob.position + h * w);
			w = Std.int(w / 2);
			h = Std.int(h / 2);
		}
		texture = Sys.graphics.createTexture(w, h, TextureFormat.L8, Usage.StaticUsage);
		var bytes = texture.lock();
		var pos: Int = 0;
		for (y in 0...h) for (x in 0...w) {
			bytes.set(pos, blob.readU8());
			
			//filter-test
			//if ((x + y) % 2 == 0) bytes.set(pos, 0xff);
			//else bytes.set(pos, 0);
			
			++pos;
		}
		texture.unlock();
		blob.reset();
	}
	
	public function getTexture(): Texture {
		return texture;
	}
	
	public function getBakedQuad(char_index: Int, xpos: Float, ypos: Float): AlignedQuad {
		if (char_index >= chars.length) return null;
		var ipw: Float = 1.0 / width;
		var iph: Float = 1.0 / height;
		var b = chars[char_index];
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
	
	#if cpp
	@:functionCode('
		const wchar_t * w = str.__WCStr();
		float width = 0;
		for (int c = 0; w[c] != 0; ++c) {
			width += this->getCharWidth(w[c]);
		}
		return width;
	')
	public function stringWidth(str: String): Float {
		return 0;
	}
	#else
	public function stringWidth(str: String): Float {
		var width: Float = 0;
		for (c in 0...str.length) {
			width += getCharWidth(str.charCodeAt(c));
		}
		return width;
	}
	#end

	public function getBaselinePosition(): Float {
		return baseline;
	}
}

package kha;

import haxe.ds.Vector;
import haxe.io.Bytes;
import kha.graphics2.truetype.StbTruetype;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class AlignedQuad {
	public function new() {}

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
	var mySize: Float;

	var chars: Vector<Stbtt_bakedchar>;
	var texture: Image;

	public var width: Int;
	public var height: Int;

	var baseline: Float;

	public static var charBlocks: Array<Int>;

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
		for (y in 0...height)
			for (x in 0...width) {
				bytes.set(pos, pixels.readU8(pos));
				++pos;
			}
		texture.unlock();
	}

	public function getTexture(): Image {
		return texture;
	}

	public function getBakedQuad(q: AlignedQuad, char_index: Int, xpos: Float, ypos: Float): AlignedQuad {
		if (char_index >= chars.length)
			return null;
		var ipw: Float = 1.0 / width;
		var iph: Float = 1.0 / height;
		var b = chars[char_index];
		if (b == null)
			return null;
		var round_x: Int = Math.round(xpos + b.xoff);
		var round_y: Int = Math.round(ypos + b.yoff);

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

	function getCharWidth(charIndex: Int): Float {
		if (chars.length == 0)
			return 0;
		var offset = charBlocks[0];
		if (charIndex < offset)
			return chars[0].xadvance;

		for (i in 1...Std.int(charBlocks.length / 2)) {
			var prevEnd = charBlocks[i * 2 - 1];
			var start = charBlocks[i * 2];
			if (charIndex > start - 1)
				offset += start - 1 - prevEnd;
		}

		if (charIndex - offset >= chars.length)
			return chars[0].xadvance;
		return chars[charIndex - offset].xadvance;
	}

	public function getHeight(): Float {
		return mySize;
	}

	public function stringWidth(str: String): Float {
		var width: Float = 0;
		for (c in 0...str.length) {
			width += getCharWidth(str.charCodeAt(c));
		}
		return width;
	}

	public function charactersWidth(characters: Array<Int>, start: Int, length: Int): Float {
		var width: Float = 0;
		for (i in start...start + length) {
			width += getCharWidth(characters[i]);
		}
		return width;
	}

	public function getBaselinePosition(): Float {
		return baseline;
	}
}

class Kravur implements Resource {
	// Do not put static data in Kravur because it is overwritten
	// when <canvas> is used - but it's still used by the overwriting class.
	var oldGlyphs: Array<Int>;
	var blob: Blob;
	var images: Map<Int, KravurImage> = new Map();
	var fontIndex: Int;

	public function new(blob: Blob, fontIndex: Int = 0) {
		this.blob = blob;
		this.fontIndex = fontIndex;
	}

	public static function fromBytes(bytes: Bytes, fontIndex: Int = 0): Kravur {
		return new Kravur(Blob.fromBytes(bytes), fontIndex);
	}

	public function _get(fontSize: Int): KravurImage {
		var glyphs = kha.graphics2.Graphics.fontGlyphs;

		if (glyphs != oldGlyphs) {
			oldGlyphs = glyphs;
			// save first/last chars of sequences
			KravurImage.charBlocks = [glyphs[0]];
			var nextChar = KravurImage.charBlocks[0] + 1;
			for (i in 1...glyphs.length) {
				if (glyphs[i] != nextChar) {
					KravurImage.charBlocks.push(glyphs[i - 1]);
					KravurImage.charBlocks.push(glyphs[i]);
					nextChar = glyphs[i] + 1;
				}
				else
					nextChar++;
			}
			KravurImage.charBlocks.push(glyphs[glyphs.length - 1]);
		}

		var imageIndex = fontIndex * 10000000 + fontSize * 10000 + glyphs.length;
		if (!images.exists(imageIndex)) {
			var width: Int = 64;
			var height: Int = 32;
			var baked = new Vector<Stbtt_bakedchar>(glyphs.length);
			for (i in 0...baked.length) {
				baked[i] = new Stbtt_bakedchar();
			}

			var pixels: Blob = null;

			var offset = StbTruetype.stbtt_GetFontOffsetForIndex(blob, fontIndex);
			if (offset == -1) {
				offset = StbTruetype.stbtt_GetFontOffsetForIndex(blob, 0);
			}
			var status: Int = -1;
			while (status <= 0) {
				if (height < width)
					height *= 2;
				else
					width *= 2;
				pixels = Blob.alloc(width * height);
				status = StbTruetype.stbtt_BakeFontBitmap(blob, offset, fontSize, pixels, width, height, glyphs, baked);
			}

			// TODO: Scale pixels down if they exceed the supported texture size

			var info = new Stbtt_fontinfo();
			StbTruetype.stbtt_InitFont(info, blob, offset);

			var metrics = StbTruetype.stbtt_GetFontVMetrics(info);
			var scale = StbTruetype.stbtt_ScaleForPixelHeight(info, fontSize);
			var ascent = Math.round(metrics.ascent * scale); // equals baseline
			var descent = Math.round(metrics.descent * scale);
			var lineGap = Math.round(metrics.lineGap * scale);

			var image = new KravurImage(Std.int(fontSize), ascent, descent, lineGap, width, height, baked, pixels);
			images[imageIndex] = image;
			return image;
		}
		return images[imageIndex];
	}

	public function height(fontSize: Int): Float {
		return _get(fontSize).getHeight();
	}

	public function width(fontSize: Int, str: String): Float {
		return _get(fontSize).stringWidth(str);
	}

	public function widthOfCharacters(fontSize: Int, characters: Array<Int>, start: Int, length: Int): Float {
		return _get(fontSize).charactersWidth(characters, start, length);
	}

	public function baseline(fontSize: Int): Float {
		return _get(fontSize).getBaselinePosition();
	}

	public function setFontIndex(fontIndex: Int): Void {
		this.fontIndex = fontIndex;
	}

	public function unload(): Void {
		blob = null;
		images = null;
	}
}

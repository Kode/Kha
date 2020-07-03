package kha.graphics2.truetype;

import haxe.ds.Vector;
import kha.Blob;

typedef Stbtt_uint8  = Int;
typedef Stbtt_int8   = Int;
typedef Stbtt_uint16 = Int;
typedef Stbtt_int16  = Int;
typedef Stbtt_uint32 = Int;
typedef Stbtt_int32  = Int;
   
//typedef char stbtt__check_size32[sizeof(stbtt_int32)==4 ? 1 : -1];
//typedef char stbtt__check_size16[sizeof(stbtt_int16)==2 ? 1 : -1];

class VectorOfIntPointer {
	public function new() { }
	public var value: Vector<Int>;
}

class Stbtt_temp_rect {
	public function new() { }
	public var x0: Int;
	public var y0: Int;
	public var x1: Int;
	public var y1: Int;
}

class Stbtt_temp_glyph_h_metrics {
	public function new() { }
	public var advanceWidth: Int;
	public var leftSideBearing: Int;
}

class Stbtt_temp_font_v_metrics {
	public function new() { }
	public var ascent: Int;
	public var descent: Int;
	public var lineGap: Int;
}

class Stbtt_temp_region {
	public function new() { }
	public var width: Int;
	public var height: Int;
	public var xoff: Int;
	public var yoff: Int;
}

class Stbtt__buf {
	public function new() { }
	public var data: Blob;
	public var cursor: Int;
}

class Stbtt_bakedchar {
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

class Stbtt_aligned_quad {
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
}

class Stbtt_packedchar {
	// coordinates of bbox in bitmap
	public var x0: Int;
	public var y0: Int;
	public var x1: Int;
	public var y1: Int;
	
	public var xoff: Float;
	public var yoff: Float;
	public var xadvance: Float;
	
	public var xoff2: Float;
	public var yoff2: Float;
}

class Stbtt_pack_range {
	public var font_size: Float;
	public var first_unicode_codepoint_in_range: Int;    // if non-zero, then the chars are continuous, and this is the first codepoint
	public var array_of_unicode_codepoints: Vector<Int>; // if non-zero, then this is an array of unicode codepoints
	public var num_chars: Int;
	public var chardata_for_range: Stbtt_packedchar;     // output
	
	// don't set these, they're used internally
	public var h_oversample: Int;
	public var v_oversample: Int;
}

class Stbtt_pack_context {
	//**void *user_allocator_context;
	//**void *pack_info;
	public var width: Int;
	public var height: Int;
	public var stride_in_bytes: Int;
	public var padding: Int;
	public var h_oversample: Int;
	public var v_oversample: Int;
	public var pixels: Blob;
	//**void  *nodes;
}

class Stbtt_fontinfo {
	public function new() { }
	public var data: Blob;                        // pointer to .ttf file
	public var fontstart: Int;                     // offset of start of font

	public var numGlyphs: Int;                     // number of glyphs, needed for range checking

	// table locations as offset from start of .ttf
	public var loca: Int;
	public var head: Int;
	public var glyf: Int;
	public var hhea: Int;
	public var hmtx: Int;
	public var kern: Int;
	public var gpos: Int;

	public var index_map: Int;                     // a cmap mapping for our chosen character encoding
	public var indexToLocFormat: Int;              // format needed to map from glyph index to glyph

	public var cff: Stbtt__buf;                    // cff font data
	public var charstrings: Stbtt__buf;            // the charstring index
	public var gsubrs: Stbtt__buf;                 // global charstring subroutines index
	public var subrs: Stbtt__buf;                  // private charstring subroutines index
	public var fontdicts: Stbtt__buf;              // array of font dicts
	public var fdselect: Stbtt__buf;               // map from glyph to fontdict
}

class Stbtt_vertex {
	public function new() { }
	public var x: Stbtt_int16;
	public var y: Stbtt_int16;
	public var cx: Stbtt_int16;
	public var cy: Stbtt_int16;
	public var cx1: Stbtt_int16;
	public var cy1: Stbtt_int16;
	public var type: Int;
	public var padding: Int;
}

class Stbtt__bitmap {
	public function new() { }
	public var w: Int;
	public var h: Int;
	public var stride: Int;
	public var pixels: Blob;
	public var pixels_offset: Int;
}

class Stbtt__edge {
	public function new() { }
	public var x0: Float;
	public var y0: Float;
	public var x1: Float;
	public var y1: Float;
	public var invert: Bool;
}

class Stbtt__active_edge {
	public function new() { }
	public var next: Stbtt__active_edge;
	public var fx: Float;
	public var fdx: Float;
	public var fdy: Float;
	public var direction: Float;
	public var sy: Float;
	public var ey: Float;
}

class Stbtt__point {
	public function new() { }
	public var x: Float;
	public var y: Float;
}

class Stbtt__csctx {
	public function new() { }
	public var bounds: Bool;
	public var started: Bool;
	public var first_x: Float;
	public var first_y: Float;
	public var x: Float;
	public var y: Float;
	public var min_x: Stbtt_int32;
	public var min_y: Stbtt_int32;
	public var max_x: Stbtt_int32;
	public var max_y: Stbtt_int32;

	public var pvertices: Vector<Stbtt_vertex>;
	public var num_vertices: Int;
}

class StbTruetype {
	private static inline function STBTT_assert(value: Bool): Void { if (!value) throw "Error"; }
	private static inline function STBTT_POINT_SIZE(x: Float): Float { return -x; }
	
	public static inline var STBTT_vmove  = 1;
	public static inline var STBTT_vline  = 2;
	public static inline var STBTT_vcurve = 3;
	public static inline var STBTT_vcubic = 4;

	public static inline var STBTT_MACSTYLE_DONTCARE   = 0;
	public static inline var STBTT_MACSTYLE_BOLD       = 1;
	public static inline var STBTT_MACSTYLE_ITALIC     = 2;
	public static inline var STBTT_MACSTYLE_UNDERSCORE = 4;
	public static inline var STBTT_MACSTYLE_NONE       = 8; // <= not same as 0, this makes us check the bitfield is 0

	// platformID
	public static inline var STBTT_PLATFORM_ID_UNICODE   = 0;
	public static inline var STBTT_PLATFORM_ID_MAC       = 1;
	public static inline var STBTT_PLATFORM_ID_ISO       = 2;
	public static inline var STBTT_PLATFORM_ID_MICROSOFT = 3;
   
	// encodingID for STBTT_PLATFORM_ID_UNICODE
	public static inline var STBTT_UNICODE_EID_UNICODE_1_0      = 0;
	public static inline var STBTT_UNICODE_EID_UNICODE_1_1      = 1;
	public static inline var STBTT_UNICODE_EID_ISO_10646        = 2;
	public static inline var STBTT_UNICODE_EID_UNICODE_2_0_BMP  = 3;
	public static inline var STBTT_UNICODE_EID_UNICODE_2_0_FULL = 4;

	// encodingID for STBTT_PLATFORM_ID_MICROSOFT
	public static inline var STBTT_MS_EID_SYMBOL        = 0;
	public static inline var STBTT_MS_EID_UNICODE_BMP   = 1;
	public static inline var STBTT_MS_EID_SHIFTJIS      = 2;
	public static inline var STBTT_MS_EID_UNICODE_FULL  = 10;
   
	// encodingID for STBTT_PLATFORM_ID_MAC; same as Script Manager codes
	public static inline var STBTT_MAC_EID_ROMAN        = 0;
	public static inline var STBTT_MAC_EID_ARABIC       = 4;
	public static inline var STBTT_MAC_EID_JAPANESE     = 1;
	public static inline var STBTT_MAC_EID_HEBREW       = 5;
	public static inline var STBTT_MAC_EID_CHINESE_TRAD = 2;
	public static inline var STBTT_MAC_EID_GREEK        = 6;
	public static inline var STBTT_MAC_EID_KOREAN       = 3;
	public static inline var STBTT_MAC_EID_RUSSIAN      = 7;
	
	// languageID for STBTT_PLATFORM_ID_MICROSOFT; same as LCID...
	// problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
	public static inline var STBTT_MS_LANG_ENGLISH     = 0x0409;
	public static inline var STBTT_MS_LANG_ITALIAN     = 0x0410;
	public static inline var STBTT_MS_LANG_CHINESE     = 0x0804;
	public static inline var STBTT_MS_LANG_JAPANESE    = 0x0411;
	public static inline var STBTT_MS_LANG_DUTCH       = 0x0413;
	public static inline var STBTT_MS_LANG_KOREAN      = 0x0412;
	public static inline var STBTT_MS_LANG_FRENCH      = 0x040c;
	public static inline var STBTT_MS_LANG_RUSSIAN     = 0x0419;
	public static inline var STBTT_MS_LANG_GERMAN      = 0x0407;
	public static inline var STBTT_MS_LANG_SPANISH     = 0x0409;
	public static inline var STBTT_MS_LANG_HEBREW      = 0x040d;
	public static inline var STBTT_MS_LANG_SWEDISH     = 0x041D;
	
	// languageID for STBTT_PLATFORM_ID_MAC
	public static inline var STBTT_MAC_LANG_ENGLISH            =  0;
	public static inline var STBTT_MAC_LANG_JAPANESE           = 11;
	public static inline var STBTT_MAC_LANG_ARABIC             = 12;
	public static inline var STBTT_MAC_LANG_KOREAN             = 23;
	public static inline var STBTT_MAC_LANG_DUTCH              =  4;
	public static inline var STBTT_MAC_LANG_RUSSIAN            = 32;
	public static inline var STBTT_MAC_LANG_FRENCH             =  1;
	public static inline var STBTT_MAC_LANG_SPANISH            =  6;
	public static inline var STBTT_MAC_LANG_GERMAN             =  2;
	public static inline var STBTT_MAC_LANG_SWEDISH            =  5;
	public static inline var STBTT_MAC_LANG_HEBREW             = 10;
	public static inline var STBTT_MAC_LANG_CHINESE_SIMPLIFIED = 33;
	public static inline var STBTT_MAC_LANG_ITALIAN            =  3;
	public static inline var STBTT_MAC_LANG_CHINESE_TRAD       = 19;
	
	public static inline var STBTT_MAX_OVERSAMPLE: Int = 8;
	//**typedef int stbtt__test_oversample_pow2[(STBTT_MAX_OVERSAMPLE & (STBTT_MAX_OVERSAMPLE-1)) == 0 ? 1 : -1];
	public static inline var STBTT_RASTERIZER_VERSION: Int = 2;

//////////////////////////////////////////////////////////////////////////
//
// stbtt__buf helpers to parse data from file
//

	private static inline function stbtt__buf_get8(b: Stbtt__buf): Stbtt_uint8 {
		if (b.cursor >= b.data.length)
			return 0;
		return ttBYTE(b.data, b.cursor++);
	}

	private static inline function stbtt__buf_peek8(b: Stbtt__buf): Stbtt_uint8 {
		if (b.cursor >= b.data.length)
			return 0;
		return ttBYTE(b.data, b.cursor);
	}

	private static inline function stbtt__buf_seek(b: Stbtt__buf, o: Int): Void {
		STBTT_assert(!(o > b.data.length || o < 0));
		b.cursor = (o > b.data.length || o < 0) ? b.data.length : o;
	}

	private static inline function stbtt__buf_skip(b: Stbtt__buf, o: Int): Void {
		stbtt__buf_seek(b, b.cursor + o);
	}

	private static inline function stbtt__buf_get(b: Stbtt__buf, n: Int): Stbtt_uint32 {
		var v: Stbtt_uint32 = 0;
		STBTT_assert(n >= 1 && n <= 4);
		for (i in 0...n)
			v = (v << 8) | stbtt__buf_get8(b);
		return v;
	}

	private static inline function stbtt__new_buf(p: Blob, size: Int): Stbtt__buf {
		var r: Stbtt__buf = new Stbtt__buf();
		STBTT_assert(size < 0x40000000);
		r.data = p;
		r.cursor = 0;
		return r;
	}

	private static inline function stbtt__buf_get16(b: Stbtt__buf): Stbtt_uint32 {
		return stbtt__buf_get(b, 2);
	}

	private static inline function stbtt__buf_get32(b: Stbtt__buf): Stbtt_uint32 {
		return stbtt__buf_get(b, 4);
	}

	private static inline function stbtt__buf_range(b: Stbtt__buf, o: Int, s: Int): Stbtt__buf {
		var r = stbtt__new_buf(null, 0);
		if (o < 0 || s < 0 || o > b.data.length || s > b.data.length - o) return r;
		r.data = b.data.sub(o, s);
		return r;
	}

	private static inline function stbtt__cff_get_index(b: Stbtt__buf): Stbtt__buf {
		var start = b.cursor;
		var count = stbtt__buf_get16(b);
		if (count > 0) {
			var offsize = stbtt__buf_get8(b);
			STBTT_assert(offsize >= 1 && offsize <= 4);
			stbtt__buf_skip(b, offsize * count);
			stbtt__buf_skip(b, stbtt__buf_get(b, offsize) - 1);
			return stbtt__buf_range(b, start, b.cursor - start);
		}
		return b;
	}

	private static inline function stbtt__cff_int(b: Stbtt__buf): Stbtt_uint32 {
		var b0: Stbtt_uint8 = stbtt__buf_get8(b);
		if (b0 >= 32 && b0 <= 246)       return b0 - 139;
		else if (b0 >= 247 && b0 <= 250) return (b0 - 247)*256 + stbtt__buf_get8(b) + 108;
		else if (b0 >= 251 && b0 <= 254) return -(b0 - 251)*256 - stbtt__buf_get8(b) - 108;
		else if (b0 == 28)               return stbtt__buf_get16(b);
		else if (b0 == 29)               return stbtt__buf_get32(b);
		else {
			STBTT_assert(false);
			return 0;
		}
	}

	private static inline function stbtt__cff_skip_operand(b: Stbtt__buf): Void {
		var v: Int, b0: Stbtt_uint8 = stbtt__buf_peek8(b);
		STBTT_assert(b0 >= 28);
		if (b0 == 30) {
			stbtt__buf_skip(b, 1);
			while (b.cursor < b.data.length) {
				v = stbtt__buf_get8(b);
				if ((v & 0xF) == 0xF || (v >> 4) == 0xF)
					break;
			}
		} else {
			stbtt__cff_int(b);
		}
	}

	private static inline function stbtt__dict_get(b: Stbtt__buf, key: Int): Stbtt__buf {
		stbtt__buf_seek(b, 0);
		var ret: Stbtt__buf = null;
		while (b.cursor < b.data.length) {
			var start: Int = b.cursor, end: Int, op: Int;
			while (stbtt__buf_peek8(b) >= 28)
				stbtt__cff_skip_operand(b);
			end = b.cursor;
			op = stbtt__buf_get8(b);
			if (op == 12)  op = stbtt__buf_get8(b) | 0x100;
			if (op == key) {
				ret = stbtt__buf_range(b, start, end - start);
				break;
			}
		}
		return ret != null ? ret : stbtt__buf_range(b, 0, 0);
	}

	private static inline function stbtt__dict_get_ints(b: Stbtt__buf, key: Int, outcount: Int, out: Array<Stbtt_uint32>): Void {
		var i: Int = 0, operands = stbtt__dict_get(b, key);
		while (i < outcount && operands.cursor < operands.data.length) {
			out[i] = stbtt__cff_int(operands);
			i++;
		}
	}

	private static inline function stbtt__cff_index_count(b: Stbtt__buf): Int
	{
		stbtt__buf_seek(b, 0);
		return stbtt__buf_get16(b);
	}

	private static inline function stbtt__cff_index_get(b: Stbtt__buf, i: Int): Stbtt__buf {
		stbtt__buf_seek(b, 0);
		var count: Int = stbtt__buf_get16(b);
		var offsize: Int = stbtt__buf_get8(b);
		STBTT_assert(i >= 0 && i < count);
		STBTT_assert(offsize >= 1 && offsize <= 4);
		stbtt__buf_skip(b, i*offsize);
		var start: Int = stbtt__buf_get(b, offsize);
		var end: Int = stbtt__buf_get(b, offsize);
		return stbtt__buf_range(b, 2+(count+1)*offsize+start, end - start);
	}

	private static inline function ttBYTE(p: Blob, pos: Int = 0): Stbtt_uint8 {
		return p.readU8(pos);
	}
	
	private static inline function ttCHAR(p: Blob, pos: Int = 0): Stbtt_int8 {
		var n = p.readU8(pos);
		if (n >= 128)
			return n - 256;
		return n;
	}
	
	private static inline function ttUSHORT(p: Blob, pos: Int = 0): Stbtt_uint16 {
		var ch1 = p.readU8(pos + 0);
		var ch2 = p.readU8(pos + 1);
		return ch2 | (ch1 << 8);
	}
	
	private static inline function ttSHORT(p: Blob, pos: Int = 0): Stbtt_int16 {
		var ch1 = p.readU8(pos + 0);
		var ch2 = p.readU8(pos + 1);
		var n = ch2 | (ch1 << 8);
		if (n & 0x8000 != 0)
			return n - 0x10000;
		return n;
	}
	
	private static inline function ttULONG(p: Blob, pos: Int = 0): Stbtt_uint32 { return ttLONG(p, pos); }
	
	private static inline function ttLONG(p: Blob, pos: Int = 0): Stbtt_int32 {
		var ch1 = p.readU8(pos + 0);
		var ch2 = p.readU8(pos + 1);
		var ch3 = p.readU8(pos + 2);
		var ch4 = p.readU8(pos + 3);
		return ch4 | (ch3 << 8) | (ch2 << 16) | (ch1 << 24);
	}

	private static inline function to_stbtt_uint16(value: Int) {
		return value & 0xffff;
	}
	
	private static inline function ttFixed(p: Blob, pos: Int = 0): Stbtt_int32 { return ttLONG(p, pos); }
	
	private static inline function stbtt_tag4(p: Blob, pos: Int, c0: Int, c1: Int, c2: Int, c3: Int): Bool { return p.readU8(pos + 0) == c0 && p.readU8(pos + 1) == c1 && p.readU8(pos + 2) == c2 && p.readU8(pos + 3) == c3; }
	private static inline function stbtt_tag(p: Blob, pos: Int, str: String): Bool { return stbtt_tag4(p, pos, str.charCodeAt(0), str.charCodeAt(1), str.charCodeAt(2), str.charCodeAt(3)); }

   private static function stbtt__isfont(font: Blob): Bool {
		// check the version number
		if (stbtt_tag4(font, 0, '1'.charCodeAt(0),0,0,0)) return true; // TrueType 1
		if (stbtt_tag(font, 0, "typ1"))   return true; // TrueType with type 1 font -- we don't support this!
		if (stbtt_tag(font, 0, "OTTO"))   return true; // OpenType with CFF
		if (stbtt_tag4(font, 0, 0,1,0,0)) return true; // OpenType 1.0
		if (stbtt_tag(font, 0, "true"))   return true; // Apple specification for TrueType fonts
		return false;
	}

	// @OPTIMIZE: binary search
	private static function stbtt__find_table(data: Blob, fontstart: Stbtt_uint32, tag: String): Stbtt_uint32 {
		var num_tables: Stbtt_int32 = ttUSHORT(data, fontstart+4);
		var tabledir: Stbtt_uint32 = fontstart + 12;
		for (i in 0...num_tables) {
			var loc: Stbtt_uint32 = tabledir + 16*i;
			if (stbtt_tag(data, loc+0, tag))
				return ttULONG(data, loc+8);
		}
		return 0;
	}

	public static function stbtt_GetFontOffsetForIndex(font_collection: Blob, index: Int): Int {
		// if it's just a font, there's only one valid index
		if (stbtt__isfont(font_collection))
			return index == 0 ? 0 : -1;

		// check if it's a TTC
		if (stbtt_tag(font_collection, 0, "ttcf")) {
			// version 1?
			if (ttULONG(font_collection, 4) == 0x00010000 || ttULONG(font_collection, 4) == 0x00020000) {
				var n: Stbtt_int32 = ttLONG(font_collection, 8);
				if (index >= n)
					return -1;
				return ttULONG(font_collection, 12+index*4);
			}
		}
		return -1;
	}

	public static function stbtt_GetNumberOfFonts(font_collection: Blob): Int {
		// if it's just a font, there's only one valid font
		if (stbtt__isfont(font_collection))
			return 1;

		// check if it's a TTC
		if (stbtt_tag(font_collection, 0, "ttcf")) {
			// version 1?
			if (ttULONG(font_collection, 4) == 0x00010000 || ttULONG(font_collection, 4) == 0x00020000) {
				return ttLONG(font_collection, 8);
			}
		}
		return 0;
	}

	private static inline function stbtt__get_subrs(cff: Stbtt__buf, fontdict: Stbtt__buf): Stbtt__buf {
		var subrsoff: Array<Stbtt_uint32> = [ 0 ];
		var private_loc: Array<Stbtt_uint32> = [ 0, 0 ];
		stbtt__dict_get_ints(fontdict, 18, 2, private_loc);
		if (private_loc[1] == 0 || private_loc[0] == 0) return stbtt__new_buf(null, 0);
		var pdict: Stbtt__buf = stbtt__buf_range(cff, private_loc[1], private_loc[0]);
		stbtt__dict_get_ints(pdict, 19, 1, subrsoff);
		if (subrsoff[0] == 0) return stbtt__new_buf(null, 0);
		stbtt__buf_seek(cff, private_loc[1]+subrsoff[0]);
		return stbtt__cff_get_index(cff);
	}

	public static function stbtt_InitFont(info: Stbtt_fontinfo, data: Blob, fontstart: Int): Bool {
		var cmap, t: Stbtt_uint32;
		var numTables: Stbtt_int32 ;

		info.data = data;
		info.fontstart = fontstart;
		info.cff = stbtt__new_buf(null, 0);

		cmap = stbtt__find_table(data, fontstart, "cmap");       // required
		info.loca = stbtt__find_table(data, fontstart, "loca"); // required
		info.head = stbtt__find_table(data, fontstart, "head"); // required
		info.glyf = stbtt__find_table(data, fontstart, "glyf"); // required
		info.hhea = stbtt__find_table(data, fontstart, "hhea"); // required
		info.hmtx = stbtt__find_table(data, fontstart, "hmtx"); // required
		info.kern = stbtt__find_table(data, fontstart, "kern"); // not required
		info.gpos = stbtt__find_table(data, fontstart, "GPOS"); // not required

		if (cmap == 0 || info.head == 0 || info.hhea == 0 || info.hmtx == 0)
			return false;
		if (info.glyf != 0) {
			if (info.loca == 0) return false;
		} else {
			// initialization for CFF / Type2 fonts (OTF)
			var b: Stbtt__buf, topdict, topdictidx;
			var cstype: Array<Stbtt_uint32> = [ 2 ], charstrings = [ 0 ], fdarrayoff = [ 0 ], fdselectoff = [ 0 ];
			var cff: Stbtt_uint32;

			cff = stbtt__find_table(data, fontstart, "CFF ");
			if (cff == 0) return false;

			info.fontdicts = stbtt__new_buf(null, 0);
			info.fdselect = stbtt__new_buf(null, 0);

			var cff_data = data.sub(cff, data.length - cff);
			info.cff = stbtt__new_buf(cff_data, cff_data.length);
			b = info.cff;

			// read the header
			stbtt__buf_skip(b, 2);
			stbtt__buf_seek(b, stbtt__buf_get8(b)); // hdrsize

			// @TODO the name INDEX could list multiple fonts,
			// but we just use the first one.
			stbtt__cff_get_index(b);  // name INDEX
			topdictidx = stbtt__cff_get_index(b);
			topdict = stbtt__cff_index_get(topdictidx, 0);
			stbtt__cff_get_index(b);  // string INDEX
			info.gsubrs = stbtt__cff_get_index(b);

			stbtt__dict_get_ints(topdict, 17, 1, charstrings);
			stbtt__dict_get_ints(topdict, 0x100 | 6, 1, cstype);
			stbtt__dict_get_ints(topdict, 0x100 | 36, 1, fdarrayoff);
			stbtt__dict_get_ints(topdict, 0x100 | 37, 1, fdselectoff);
			info.subrs = stbtt__get_subrs(b, topdict);

			// we only support Type 2 charstrings
			if (cstype[0] != 2) return false;
			if (charstrings[0] == 0) return false;

			if (fdarrayoff[0] != 0) {
				// looks like a CID font
				if (fdselectoff[0] == 0) return false;
				stbtt__buf_seek(b, fdarrayoff[0]);
				info.fontdicts = stbtt__cff_get_index(b);
				info.fdselect = stbtt__buf_range(b, fdselectoff[0], b.data.length-fdselectoff[0]);
			}

			stbtt__buf_seek(b, charstrings[0]);
			info.charstrings = stbtt__cff_get_index(b);
		}

		t = stbtt__find_table(data, fontstart, "maxp");
		if (t != 0)
			info.numGlyphs = ttUSHORT(data, t+4);
		else
			info.numGlyphs = 0xffff;

		// find a cmap encoding table we understand *now* to avoid searching
		// later. (todo: could make this installable)
		// the same regardless of glyph.
		numTables = ttUSHORT(data, cmap + 2);
		info.index_map = 0;
		
		for (i in 0...numTables) {
			var encoding_record: Stbtt_uint32 = cmap + 4 + 8 * i;
			// find an encoding we understand:
			switch(ttUSHORT(data, encoding_record)) {
				case STBTT_PLATFORM_ID_MICROSOFT:
					switch (ttUSHORT(data, encoding_record+2)) {
						case STBTT_MS_EID_UNICODE_BMP, STBTT_MS_EID_UNICODE_FULL:
							// MS/Unicode
							info.index_map = cmap + ttULONG(data, encoding_record+4);
					}
				case STBTT_PLATFORM_ID_UNICODE:
					// Mac/iOS has these
					// all the encodingIDs are unicode, so we don't bother to check it
					info.index_map = cmap + ttULONG(data, encoding_record+4);
			}
		}
		if (info.index_map == 0)
			return false;

		info.indexToLocFormat = ttUSHORT(data, info.head + 50);
		return true;
	}

	public static function stbtt_FindGlyphIndex(info: Stbtt_fontinfo, unicode_codepoint: Int): Int {
		var data: Blob = info.data;
		var index_map: Stbtt_uint32 = info.index_map;

		var format: Stbtt_uint16 = ttUSHORT(data, index_map + 0);
		if (format == 0) { // apple byte encoding
			var bytes: Stbtt_int32 = ttUSHORT(data, index_map + 2);
			if (unicode_codepoint < bytes-6)
				return ttBYTE(data, index_map + 6 + unicode_codepoint);
			return 0;
		} else if (format == 6) {
			var first: Stbtt_uint32 = ttUSHORT(data, index_map + 6);
			var count: Stbtt_uint32 = ttUSHORT(data, index_map + 8);
			if (unicode_codepoint >= first && unicode_codepoint < first+count)
				return ttUSHORT(data, index_map + 10 + (unicode_codepoint - first)*2);
			return 0;
		} else if (format == 2) {
			STBTT_assert(false); // @TODO: high-byte mapping for japanese/chinese/korean
			return 0;
		} else if (format == 4) { // standard mapping for windows fonts: binary search collection of ranges
			var segcount: Stbtt_uint16 = ttUSHORT(data, index_map+6) >> 1;
			var searchRange: Stbtt_uint16 = ttUSHORT(data, index_map + 8) >> 1;
			var entrySelector: Stbtt_uint16 = ttUSHORT(data, index_map+10);
			var rangeShift: Stbtt_uint16 = ttUSHORT(data, index_map+12) >> 1;

			// do a binary search of the segments
			var endCount: Stbtt_uint32 = index_map + 14;
			var search: Stbtt_uint32 = endCount;

			if (unicode_codepoint > 0xffff)
				return 0;

			// they lie from endCount .. endCount + segCount
			// but searchRange is the nearest power of two, so...
			if (unicode_codepoint >= ttUSHORT(data, search + rangeShift*2))
				search += rangeShift*2;

			// now decrement to bias correctly to find smallest
			search -= 2;
			while (entrySelector != 0) {
				var end: Stbtt_uint16;
				searchRange >>= 1;
				end = ttUSHORT(data, search + searchRange*2);
				if (unicode_codepoint > end)
					search += searchRange*2;
				--entrySelector;
			}
			search += 2;

			{
				var offset, start: Stbtt_uint16;
				var item: Stbtt_uint16 = to_stbtt_uint16((search - endCount) >> 1);

				STBTT_assert(unicode_codepoint <= ttUSHORT(data, endCount + 2*item));
				start = ttUSHORT(data, index_map + 14 + segcount*2 + 2 + 2*item);
				if (unicode_codepoint < start)
					return 0;

				offset = ttUSHORT(data, index_map + 14 + segcount*6 + 2 + 2*item);
				if (offset == 0) {
					return to_stbtt_uint16(unicode_codepoint + ttSHORT(data, index_map + 14 + segcount*4 + 2 + 2*item));
				}
				return ttUSHORT(data, offset + (unicode_codepoint-start)*2 + index_map + 14 + segcount*6 + 2 + 2*item);
			}
		} else if (format == 12 || format == 13) {
			var ngroups: Stbtt_uint32 = ttULONG(data, index_map+12);
			var low,high: Stbtt_int32;
			low = 0; high = ngroups;
			// Binary search the right group.
			while (low < high) {
				var mid: Stbtt_int32 = low + ((high-low) >> 1); // rounds down, so low <= mid < high
				var start_char: Stbtt_uint32 = ttULONG(data, index_map+16+mid*12);
				var end_char: Stbtt_uint32 = ttULONG(data, index_map+16+mid*12+4);
				if (unicode_codepoint < start_char)
					high = mid;
				else if (unicode_codepoint > end_char)
					low = mid+1;
				else {
					var start_glyph: Stbtt_uint32 = ttULONG(data, index_map+16+mid*12+8);
					if (format == 12)
						return start_glyph + unicode_codepoint-start_char;
					else // format == 13
						return start_glyph;
				}
			}
			return 0; // not found
		}
		// @TODO
		STBTT_assert(false);
		return 0;
	}

	public static function stbtt_GetCodepointShape(info: Stbtt_fontinfo, unicode_codepoint: Int): Vector<Stbtt_vertex> {
		return stbtt_GetGlyphShape(info, stbtt_FindGlyphIndex(info, unicode_codepoint));
	}

	private static function stbtt_setvertex(v: Stbtt_vertex, type: Stbtt_uint8, x: Stbtt_int32, y: Stbtt_int32, cx: Stbtt_int32, cy: Stbtt_int32): Void {
		v.type = type;
		v.x = x;
		v.y = y;
		v.cx = cx;
		v.cy = cy;
	}

	private static function stbtt__GetGlyfOffset(info: Stbtt_fontinfo, glyph_index: Int): Int {
		var g1,g2: Int;

		STBTT_assert(info.cff.data == null || info.cff.data.length == 0);

		if (glyph_index >= info.numGlyphs) return -1; // glyph index out of range
		if (info.indexToLocFormat >= 2)    return -1; // unknown index->glyph map format

		if (info.indexToLocFormat == 0) {
			g1 = info.glyf + ttUSHORT(info.data, info.loca + glyph_index * 2) * 2;
			g2 = info.glyf + ttUSHORT(info.data, info.loca + glyph_index * 2 + 2) * 2;
		} else {
			g1 = info.glyf + ttULONG (info.data, info.loca + glyph_index * 4);
			g2 = info.glyf + ttULONG (info.data, info.loca + glyph_index * 4 + 4);
		}

		return g1==g2 ? -1 : g1; // if length is 0, return -1
	}

	public static function stbtt_GetGlyphBox(info: Stbtt_fontinfo, glyph_index: Int, rect: Stbtt_temp_rect): Bool {
		if (info.cff.data != null && info.cff.data.length > 0) {
			stbtt__GetGlyphInfoT2(info, glyph_index, rect);
		} else {
			var g: Int = stbtt__GetGlyfOffset(info, glyph_index);
			if (g < 0) return false;

			rect.x0 = ttSHORT(info.data, g + 2);
			rect.y0 = ttSHORT(info.data, g + 4);
			rect.x1 = ttSHORT(info.data, g + 6);
			rect.y1 = ttSHORT(info.data, g + 8);
		}
		return true;
	}

	public static function stbtt_GetCodepointBox(info: Stbtt_fontinfo, codepoint: Int, rect: Stbtt_temp_rect): Bool {
		return stbtt_GetGlyphBox(info, stbtt_FindGlyphIndex(info,codepoint), rect);
	}

	public static function stbtt_IsGlyphEmpty(info: Stbtt_fontinfo, glyph_index: Int): Bool {
		var numberOfContours: Stbtt_int16;
		if (info.cff.data != null && info.cff.data.length > 0)
			return stbtt__GetGlyphInfoT2(info, glyph_index, null) == 0;
		var g: Int = stbtt__GetGlyfOffset(info, glyph_index);
		if (g < 0) return true;
		numberOfContours = ttSHORT(info.data, g);
		return numberOfContours == 0;
	}

	private static function stbtt__close_shape(vertices: Vector<Stbtt_vertex>, num_vertices: Int, was_off: Bool, start_off: Bool,
    sx: Stbtt_int32, sy: Stbtt_int32, scx: Stbtt_int32, scy: Stbtt_int32, cx: Stbtt_int32, cy: Stbtt_int32): Int {
		if (start_off) {
			if (was_off)
				stbtt_setvertex(vertices[num_vertices++], STBTT_vcurve, (cx+scx)>>1, (cy+scy)>>1, cx,cy);
			stbtt_setvertex(vertices[num_vertices++], STBTT_vcurve, sx,sy,scx,scy);
		} else {
			if (was_off)
				stbtt_setvertex(vertices[num_vertices++], STBTT_vcurve,sx,sy,cx,cy);
			else
				stbtt_setvertex(vertices[num_vertices++], STBTT_vline,sx,sy,0,0);
		}
		return num_vertices;
	}
	
	private static function copyVertices(from: Vector<Stbtt_vertex>, to: Vector<Stbtt_vertex>, offset: Int, count: Int): Void {
		for (i in 0...count) {
			to[offset + i] = from[i];
		}
	}

	public static function stbtt__GetGlyphShapeTT(info: Stbtt_fontinfo, glyph_index: Int): Vector<Stbtt_vertex> {
		var numberOfContours: Stbtt_int16;
		var data: Blob = info.data;
		var vertices: Vector<Stbtt_vertex> = null;
		var num_vertices: Int = 0;
		var g: Int = stbtt__GetGlyfOffset(info, glyph_index);

		if (g < 0) return null;

		numberOfContours = ttSHORT(data, g);

		if (numberOfContours > 0) {
			var flags=0,flagcount: Stbtt_uint8;
			var ins, j = 0, m, n, next_move = 0, off: Stbtt_int32 = 0;
			var was_off: Bool = false;
			var start_off: Bool = false;
			var x,y,cx,cy,sx,sy, scx,scy: Stbtt_int32;
			var endPtsOfContoursOffset: Int = g + 10;
			ins = ttUSHORT(data, endPtsOfContoursOffset + numberOfContours * 2);
			var pointsIndex: Int = endPtsOfContoursOffset + numberOfContours * 2 + 2 + ins;

			n = 1+ttUSHORT(data, endPtsOfContoursOffset + numberOfContours*2-2);

			m = n + 2*numberOfContours;  // a loose bound on how many vertices we might need
			vertices = new Vector<Stbtt_vertex>(m);
			if (vertices == null)
				return null;
			else {
				for (i in 0...vertices.length) {
					vertices[i] = new Stbtt_vertex();
				}
			}

			next_move = 0;
			flagcount=0;

			// in first pass, we load uninterpreted data into the allocated array
			// above, shifted to the end of the array so we won't overwrite it when
			// we create our final data starting from the front

			off = m - n; // starting offset for uninterpreted data, regardless of how m ends up being calculated

			// first load flags

			for (i in 0...n) {
				if (flagcount == 0) {
					flags = data.readU8(pointsIndex++);
					if (flags & 8 != 0)
						flagcount = data.readU8(pointsIndex++);
				} else
					--flagcount;
				vertices[off+i].type = flags;
			}

			// now load x coordinates
			x = 0;
			for (i in 0...n) {
				flags = vertices[off+i].type;
				if (flags & 2 != 0) {
					var dx: Stbtt_int16 = data.readU8(pointsIndex++);
					x += (flags & 16 != 0) ? dx : -dx; // ???
				} else {
					if (flags & 16 == 0) {
						var value: Stbtt_int16;
						var ch1 = data.readU8(pointsIndex + 0);
						var ch2 = data.readU8(pointsIndex + 1);
						var n = ch2 | (ch1 << 8);
						if (n & 0x8000 != 0)
							value = n - 0x10000;
						else
							value = n;
						x = x + value;
						pointsIndex += 2;
					}
				}
				vertices[off+i].x = x;
			}

			// now load y coordinates
			y = 0;
			for (i in 0...n) {
				flags = vertices[off+i].type;
				if (flags & 4 != 0) {
					var dy: Stbtt_int16 = data.readU8(pointsIndex++);
					y += (flags & 32 != 0) ? dy : -dy; // ???
				} else {
					if (flags & 32 == 0) {
						var value: Stbtt_int16;
						var ch1 = data.readU8(pointsIndex + 0);
						var ch2 = data.readU8(pointsIndex + 1);
						var n = ch2 | (ch1 << 8);
						if (n & 0x8000 != 0)
							value = n - 0x10000;
						else
							value = n;
						y = y + value;
						pointsIndex += 2;
					}
				}
				vertices[off+i].y = y;
			}

			// now convert them to our format
			num_vertices=0;
			sx = sy = cx = cy = scx = scy = 0;
			var i: Int = 0;
			while (i < n) {
				flags = vertices[off+i].type;
				x     = vertices[off+i].x;
				y     = vertices[off+i].y;

				if (next_move == i) {
					if (i != 0)
						num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx,sy,scx,scy,cx,cy);

					// now start the new one               
					start_off = (flags & 1 == 0);
					if (start_off) {
						// if we start off with an off-curve point, then when we need to find a point on the curve
						// where we can start, and we need to save some state for when we wraparound.
						scx = x;
						scy = y;
						if (vertices[off+i+1].type & 1 == 0) {
							// next point is also a curve point, so interpolate an on-point curve
							sx = (x + vertices[off+i+1].x) >> 1;
							sy = (y + vertices[off+i+1].y) >> 1;
						} else {
							// otherwise just use the next point as our start point
							sx = vertices[off+i+1].x;
							sy = vertices[off+i+1].y;
							++i; // we're using point i+1 as the starting point, so skip it
						}
					} else {
						sx = x;
						sy = y;
					}
					stbtt_setvertex(vertices[num_vertices++], STBTT_vmove,sx,sy,0,0);
					was_off = false;
					next_move = 1 + ttUSHORT(data, endPtsOfContoursOffset + j*2);
					++j;
				} else {
					if (flags & 1 == 0) { // if it's a curve
						if (was_off) // two off-curve control points in a row means interpolate an on-curve midpoint
							stbtt_setvertex(vertices[num_vertices++], STBTT_vcurve, (cx+x)>>1, (cy+y)>>1, cx, cy);
						cx = x;
						cy = y;
						was_off = true;
					} else {
						if (was_off)
							stbtt_setvertex(vertices[num_vertices++], STBTT_vcurve, x,y, cx, cy);
						else
							stbtt_setvertex(vertices[num_vertices++], STBTT_vline, x,y,0,0);
						was_off = false;
					}
				}
				++i;
			}
			num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx,sy,scx,scy,cx,cy);
		} else if (numberOfContours < 0) {
			// Compound shapes.
			var more: Int = 1;
			var compIndex: Int = g + 10;
			num_vertices = 0;
			vertices = null;
			while (more != 0) {
				var flags, gidx: Stbtt_uint16;
				var comp_num_verts = 0, i: Int;
				var comp_verts: Vector<Stbtt_vertex> = null;
				var tmp: Vector<Stbtt_vertex> = null;
				var mtx0: Float = 1;
				var mtx1: Float = 0;
				var mtx2: Float = 0;
				var mtx3: Float = 1;
				var mtx4: Float = 0;
				var mtx5: Float = 0;
				var m, n: Float;

				flags = ttSHORT(data, compIndex); compIndex+=2;
				gidx = ttSHORT(data, compIndex); compIndex+=2;

				if (flags & 2 != 0) { // XY values
					if (flags & 1 != 0) { // shorts
						mtx4 = ttSHORT(data, compIndex); compIndex+=2;
						mtx5 = ttSHORT(data, compIndex); compIndex+=2;
					} else {
						mtx4 = ttCHAR(data, compIndex); compIndex+=1;
						mtx5 = ttCHAR(data, compIndex); compIndex+=1;
					}
				}
				else {
					// @TODO handle matching point
					STBTT_assert(false);
				}
				if (flags & (1<<3) != 0) { // WE_HAVE_A_SCALE
					mtx0 = mtx3 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
					mtx1 = mtx2 = 0;
				} else if (flags & (1<<6) != 0) { // WE_HAVE_AN_X_AND_YSCALE
					mtx0 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
					mtx1 = mtx2 = 0;
					mtx3 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
				} else if (flags & (1<<7) != 0) { // WE_HAVE_A_TWO_BY_TWO
					mtx0 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
					mtx1 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
					mtx2 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
					mtx3 = ttSHORT(data, compIndex)/16384.0; compIndex+=2;
				}
		 
				// Find transformation scales.
				m = Math.sqrt(mtx0*mtx0 + mtx1*mtx1);
				n = Math.sqrt(mtx2*mtx2 + mtx3*mtx3);

				// Get indexed glyph.
				comp_verts = stbtt_GetGlyphShape(info, gidx);
				comp_num_verts = comp_verts == null ? 0 : comp_verts.length;
				if (comp_num_verts > 0) {
					// Transform vertices.
					for (i in 0...comp_num_verts) {
						var v: Stbtt_vertex = comp_verts[i];
						var x,y: Stbtt_int16;
						x=v.x; y=v.y;
						v.x = Std.int(m * (mtx0*x + mtx2*y + mtx4));
						v.y = Std.int(n * (mtx1*x + mtx3*y + mtx5));
						x=v.cx; y=v.cy;
						v.cx = Std.int(m * (mtx0*x + mtx2*y + mtx4));
						v.cy = Std.int(n * (mtx1*x + mtx3*y + mtx5));
					}
					// Append vertices.
					tmp = new Vector<Stbtt_vertex>(num_vertices+comp_num_verts);
					if (tmp == null) {
						return null;
					}
					if (num_vertices > 0) copyVertices(vertices, tmp, 0, num_vertices);
					copyVertices(comp_verts, tmp, num_vertices, comp_num_verts);
					vertices = tmp;
					num_vertices += comp_num_verts;
				}
				// More components ?
				more = flags & (1<<5);
			}
		} else {
			// numberOfCounters == 0, do nothing
		}

		if (vertices == null) return null;
		STBTT_assert(vertices.length >= num_vertices);
		if (num_vertices < vertices.length) {
			var tmp = new Vector<Stbtt_vertex>(num_vertices);
			copyVertices(vertices, tmp, 0, num_vertices);
			return tmp;
		}
		else {
			return vertices;
		}
	}

	private static inline function STBTT__CSCTX_INIT(bounds: Bool): Stbtt__csctx {
		var tmp = new Stbtt__csctx();
		tmp.bounds = bounds;
		tmp.started = false;
		tmp.first_x = 0;
		tmp.first_y = 0;
		tmp.x = 0;
		tmp.y = 0;
		tmp.min_x = 0;
		tmp.min_y = 0;
		tmp.max_x = 0;
		tmp.max_y = 0;
		// tmp.pvertices = new Vector<Stbtt_vertex>(0);
		tmp.pvertices = null;
		tmp.num_vertices = 0;
		return tmp;
	}

	private static inline function stbtt__track_vertex(c: Stbtt__csctx, x: Stbtt_int32, y: Stbtt_int32): Void {
		if (x > c.max_x || !c.started) c.max_x = x;
		if (y > c.max_y || !c.started) c.max_y = y;
		if (x < c.min_x || !c.started) c.min_x = x;
		if (y < c.min_y || !c.started) c.min_y = y;
		c.started = true;
	}

	private static inline function stbtt__csctx_v(c: Stbtt__csctx, type: Stbtt_uint8, x: Stbtt_int32, y: Stbtt_int32, cx: Stbtt_int32, cy: Stbtt_int32, cx1: Stbtt_int32, cy1: Stbtt_int32): Void {
		if (c.bounds) {
			stbtt__track_vertex(c, x, y);
			if (type == STBTT_vcubic) {
				stbtt__track_vertex(c, cx, cy);
				stbtt__track_vertex(c, cx1, cy1);
			}
		} else {
			stbtt_setvertex(c.pvertices[c.num_vertices], type, x, y, cx, cy);
			c.pvertices[c.num_vertices].cx1 = cast(cx1, Stbtt_int16);
			c.pvertices[c.num_vertices].cy1 = cast(cy1, Stbtt_int16);
		}
		c.num_vertices++;
	}

	private static inline function stbtt__csctx_close_shape(ctx: Stbtt__csctx): Void {
		if (ctx.first_x != ctx.x || ctx.first_y != ctx.y)
			stbtt__csctx_v(ctx, STBTT_vline, Std.int(ctx.first_x), Std.int(ctx.first_y), 0, 0, 0, 0);
	}

	private static inline function stbtt__csctx_rmove_to(ctx: Stbtt__csctx, dx: Float, dy: Float): Void {
		stbtt__csctx_close_shape(ctx);
		ctx.first_x = ctx.x = ctx.x + dx;
		ctx.first_y = ctx.y = ctx.y + dy;
		stbtt__csctx_v(ctx, STBTT_vmove, Std.int(ctx.x), Std.int(ctx.y), 0, 0, 0, 0);
	}

	private static inline function stbtt__csctx_rline_to(ctx: Stbtt__csctx, dx: Float, dy: Float): Void {
		ctx.x += dx;
		ctx.y += dy;
		stbtt__csctx_v(ctx, STBTT_vline, Std.int(ctx.x), Std.int(ctx.y), 0, 0, 0, 0);
	}

	private static inline function stbtt__csctx_rccurve_to(ctx: Stbtt__csctx, dx1: Float, dy1: Float, dx2: Float, dy2: Float, dx3: Float, dy3: Float): Void {
		var cx1: Float = ctx.x + dx1;
		var cy1: Float = ctx.y + dy1;
		var cx2: Float = cx1 + dx2;
		var cy2: Float = cy1 + dy2;
		ctx.x = cx2 + dx3;
		ctx.y = cy2 + dy3;
		stbtt__csctx_v(ctx, STBTT_vcubic, Std.int(ctx.x), Std.int(ctx.y), Std.int(cx1), Std.int(cy1), Std.int(cx2), Std.int(cy2));
	}

	private static inline function stbtt__get_subr(idx: Stbtt__buf, n: Int): Stbtt__buf 
	{
		var count: Int = stbtt__cff_index_count(idx);
		var bias: Int = 107;
		if (count >= 33900)
			bias = 32768;
		else if (count >= 1240)
			bias = 1131;
		n += bias;
		if (n < 0 || n >= count)
			return stbtt__new_buf(null, 0);
		return stbtt__cff_index_get(idx, n);
	}

	private static inline function stbtt__cid_get_glyph_subrs(info: Stbtt_fontinfo, glyph_index: Int): Stbtt__buf {
		var fdselect: Stbtt__buf = info.fdselect;
		var nranges: Int, start, end, v, fmt, fdselector = -1, i;

		stbtt__buf_seek(fdselect, 0);
		fmt = stbtt__buf_get8(fdselect);
		if (fmt == 0) {
			// untested
			stbtt__buf_skip(fdselect, glyph_index);
			fdselector = stbtt__buf_get8(fdselect);
		} else if (fmt == 3) {
			nranges = stbtt__buf_get16(fdselect);
			start = stbtt__buf_get16(fdselect);
			for (i in 0...nranges) {
				v = stbtt__buf_get8(fdselect);
				end = stbtt__buf_get16(fdselect);
				if (glyph_index >= start && glyph_index < end) {
					fdselector = v;
					break;
				}
				start = end;
			}
		}
		if (fdselector == -1) stbtt__new_buf(null, 0);
		return stbtt__get_subrs(info.cff, stbtt__cff_index_get(info.fontdicts, fdselector));
	}

	private static inline function STBTT__CSERR(s: String): Bool {
		return false;
	}

	private static function stbtt__run_charstring(info: Stbtt_fontinfo, glyph_index: Int, c: Stbtt__csctx): Bool {
		var in_header: Bool = true;
		var maskbits: Int = 0, subr_stack_height: Int = 0, sp: Int = 0, v: Int, i: Int, b0: Int;
		var has_subrs: Bool = false, clear_stack;
		var s: Array<Float> = [for (i in 0...48) 0];
		var subr_stack: Array<Stbtt__buf> = [for (i in 0...10) new Stbtt__buf()];
		var subrs: Stbtt__buf = info.subrs, b;
		var f: Float;

		// this currently ignores the initial width value, which isn't needed if we have hmtx
		b = stbtt__cff_index_get(info.charstrings, glyph_index);
		while (b.cursor < b.data.length) {
			i = 0;
			clear_stack = true;
			b0 = stbtt__buf_get8(b);
			switch (b0) {
			// @TODO implement hinting
			case 0x13, // hintmask
				 0x14: // cntrmask
				if (in_header)
					maskbits += Std.int(sp / 2); // implicit "vstem"
				in_header = false;
				stbtt__buf_skip(b, Std.int((maskbits + 7) / 8));

			case 0x01, // hstem
				 0x03, // vstem
				 0x12, // hstemhm
				 0x17: // vstemhm
				maskbits += Std.int(sp / 2);

			case 0x15: // rmoveto
				in_header = false;
				if (sp < 2) return STBTT__CSERR("rmoveto stack");
				stbtt__csctx_rmove_to(c, s[sp-2], s[sp-1]);
			case 0x04: // vmoveto
				in_header = false;
				if (sp < 1) return STBTT__CSERR("vmoveto stack");
				stbtt__csctx_rmove_to(c, 0, s[sp-1]);
			case 0x16: // hmoveto
				in_header = false;
				if (sp < 1) return STBTT__CSERR("hmoveto stack");
				stbtt__csctx_rmove_to(c, s[sp-1], 0);

			case 0x05: // rlineto
				if (sp < 2) return STBTT__CSERR("rlineto stack");
				while (i + 1 < sp) {
					stbtt__csctx_rline_to(c, s[i], s[i+1]);
					i += 2;
				}

			// hlineto/vlineto and vhcurveto/hvcurveto alternate horizontal and vertical
			// starting from a different place.

			case 0x07: // vlineto
				if (sp < 1) return STBTT__CSERR("vlineto stack");
				while (true) {
					if (i >= sp) break;
					stbtt__csctx_rline_to(c, 0, s[i]);
					i++;

					if (i >= sp) break;
					stbtt__csctx_rline_to(c, s[i], 0);
					i++;
				}
			case 0x06: // hlineto
				if (sp < 1) return STBTT__CSERR("hlineto stack");
				while (true) {
					if (i >= sp) break;
					stbtt__csctx_rline_to(c, s[i], 0);
					i++;

					if (i >= sp) break;
					stbtt__csctx_rline_to(c, 0, s[i]);
					i++;
				}

			case 0x1F: // hvcurveto
				if (sp < 4) return STBTT__CSERR("hvcurveto stack");
				while (true) {
					if (i + 3 >= sp) break;
					stbtt__csctx_rccurve_to(c, s[i], 0, s[i+1], s[i+2], (sp - i == 5) ? s[i+4] : 0, s[i+3]);
					i += 4;

					if (i + 3 >= sp) break;
					stbtt__csctx_rccurve_to(c, 0, s[i], s[i+1], s[i+2], s[i+3], (sp - i == 5) ? s[i + 4] : 0);
					i += 4;
				}
			case 0x1E: // vhcurveto
				if (sp < 4) return STBTT__CSERR("vhcurveto stack");
				while (true) {
					if (i + 3 >= sp) break;
					stbtt__csctx_rccurve_to(c, 0, s[i], s[i+1], s[i+2], s[i+3], (sp - i == 5) ? s[i + 4] : 0);
					i += 4;

					if (i + 3 >= sp) break;
					stbtt__csctx_rccurve_to(c, s[i], 0, s[i+1], s[i+2], (sp - i == 5) ? s[i+4] : 0, s[i+3]);
					i += 4;
				}

			case 0x08: // rrcurveto
				if (sp < 6) return STBTT__CSERR("rcurveline stack");
				while (i + 5 < sp) {
					stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
					i += 6;
				}

			case 0x18: // rcurveline
				if (sp < 8) return STBTT__CSERR("rcurveline stack");
				while (i + 5 < sp - 2) {
					stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
					i += 6;
				}
				if (i + 1 >= sp) return STBTT__CSERR("rcurveline stack");
				stbtt__csctx_rline_to(c, s[i], s[i+1]);

			case 0x19: // rlinecurve
				if (sp < 8) return STBTT__CSERR("rlinecurve stack");
				while (i + 1 < sp - 6) {
					stbtt__csctx_rline_to(c, s[i], s[i+1]);
					i += 2;
				}
				if (i + 5 >= sp) return STBTT__CSERR("rlinecurve stack");
				stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);

			case 0x1A, // vvcurveto
				 0x1B: // hhcurveto
				if (sp < 4) return STBTT__CSERR("(vv|hh)curveto stack");
				f = 0.0;
				if (sp & 1 != 0) { f = s[i]; i++; }
				while (i + 3 < sp) {
					if (b0 == 0x1B)
						stbtt__csctx_rccurve_to(c, s[i], f, s[i+1], s[i+2], s[i+3], 0.0);
					else
						stbtt__csctx_rccurve_to(c, f, s[i], s[i+1], s[i+2], 0.0, s[i+3]);
					f = 0.0;
					i += 4;
				}

			case 0x0A, // callsubr
				 0x1D: // callgsubr
				if (b0 == 0x0A) {
					if (!has_subrs) {
						if (info.fdselect.data.length != 0)
							subrs = stbtt__cid_get_glyph_subrs(info, glyph_index);
						has_subrs = true;
					}
				}
				if (sp < 1) return STBTT__CSERR("call(g|)subr stack");
				v = Std.int(s[--sp]);
				if (subr_stack_height >= 10) return STBTT__CSERR("recursion limit");
				subr_stack[subr_stack_height++] = b;
				b = stbtt__get_subr(b0 == 0x0A ? subrs : info.gsubrs, v);
				if (b.data.length == 0) return STBTT__CSERR("subr not found");
				b.cursor = 0;
				clear_stack = false;

			case 0x0B: // return
				if (subr_stack_height <= 0) return STBTT__CSERR("return outside subr");
				b = subr_stack[--subr_stack_height];
				clear_stack = false;

			case 0x0E: // endchar
				stbtt__csctx_close_shape(c);
				return true;

			case 0x0C: { // two-byte escape
				var dx1: Float, dx2, dx3, dx4, dx5, dx6, dy1, dy2, dy3, dy4, dy5, dy6;
				var dx: Float, dy;
				var b1: Int = stbtt__buf_get8(b);
				switch (b1) {
				// @TODO These "flex" implementations ignore the flex-depth and resolution,
				// and always draw beziers.
				case 0x22: // hflex
					if (sp < 7) return STBTT__CSERR("hflex stack");
					dx1 = s[0];
					dx2 = s[1];
					dy2 = s[2];
					dx3 = s[3];
					dx4 = s[4];
					dx5 = s[5];
					dx6 = s[6];
					stbtt__csctx_rccurve_to(c, dx1, 0, dx2, dy2, dx3, 0);
					stbtt__csctx_rccurve_to(c, dx4, 0, dx5, -dy2, dx6, 0);

				case 0x23: // flex
					if (sp < 13) return STBTT__CSERR("flex stack");
					dx1 = s[0];
					dy1 = s[1];
					dx2 = s[2];
					dy2 = s[3];
					dx3 = s[4];
					dy3 = s[5];
					dx4 = s[6];
					dy4 = s[7];
					dx5 = s[8];
					dy5 = s[9];
					dx6 = s[10];
					dy6 = s[11];
					//fd is s[12]
					stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
					stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);

				case 0x24: // hflex1
					if (sp < 9) return STBTT__CSERR("hflex1 stack");
					dx1 = s[0];
					dy1 = s[1];
					dx2 = s[2];
					dy2 = s[3];
					dx3 = s[4];
					dx4 = s[5];
					dx5 = s[6];
					dy5 = s[7];
					dx6 = s[8];
					stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, 0);
					stbtt__csctx_rccurve_to(c, dx4, 0, dx5, dy5, dx6, -(dy1+dy2+dy5));

				case 0x25: // flex1
					if (sp < 11) return STBTT__CSERR("flex1 stack");
					dx1 = s[0];
					dy1 = s[1];
					dx2 = s[2];
					dy2 = s[3];
					dx3 = s[4];
					dy3 = s[5];
					dx4 = s[6];
					dy4 = s[7];
					dx5 = s[8];
					dy5 = s[9];
					dx6 = dy6 = s[10];
					dx = dx1+dx2+dx3+dx4+dx5;
					dy = dy1+dy2+dy3+dy4+dy5;
					if (Math.abs(dx) > Math.abs(dy))
						dy6 = -dy;
					else
						dx6 = -dx;
					stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
					stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);

				default:
					return STBTT__CSERR("unimplemented");
				}
			}

			default:
				if (b0 != 255 && b0 != 28 && (b0 < 32 || b0 > 254))
					return STBTT__CSERR("reserved operator");

				// push immediate
				if (b0 == 255) {
					f = stbtt__buf_get32(b) / 0x10000;
				} else {
					stbtt__buf_skip(b, -1);
					f = stbtt__cff_int(b);
				}
				if (sp >= 48) return STBTT__CSERR("push stack overflow");
				s[sp++] = f;
				clear_stack = false;
			}
			if (clear_stack) sp = 0;
		}
		return STBTT__CSERR("no endchar");
	}

	public static function stbtt__GetGlyphShapeT2(info: Stbtt_fontinfo, glyph_index: Int): Vector<Stbtt_vertex> {
		// runs the charstring twice, once to count and once to output (to avoid realloc)
		var count_ctx: Stbtt__csctx = STBTT__CSCTX_INIT(true);
		var output_ctx: Stbtt__csctx = STBTT__CSCTX_INIT(false);
		if (stbtt__run_charstring(info, glyph_index, count_ctx)) {
			output_ctx.pvertices = new Vector<Stbtt_vertex>(count_ctx.num_vertices);
			for (i in 0...count_ctx.num_vertices)
				output_ctx.pvertices[i] = new Stbtt_vertex();
			if (stbtt__run_charstring(info, glyph_index, output_ctx)) {
				STBTT_assert(output_ctx.num_vertices == count_ctx.num_vertices);
				return output_ctx.pvertices;
			}
		}
		return null;
	}

	public static function stbtt__GetGlyphInfoT2(info: Stbtt_fontinfo, glyph_index: Int, rect: Stbtt_temp_rect): Int {
		var c: Stbtt__csctx = STBTT__CSCTX_INIT(true);
		var r = stbtt__run_charstring(info, glyph_index, c);
		if (rect != null) {
			rect.x0 = r ? c.min_x : 0;
			rect.y0 = r ? c.min_y : 0;
			rect.x1 = r ? c.max_x : 0;
			rect.y1 = r ? c.max_y : 0;
		}
		return r ? c.num_vertices : 0;
	}

	public static function stbtt_GetGlyphShape(info: Stbtt_fontinfo, glyph_index: Int): Vector<Stbtt_vertex> {
		if (info.cff.data == null || info.cff.data.length == 0)
			return stbtt__GetGlyphShapeTT(info, glyph_index);
		else
			return stbtt__GetGlyphShapeT2(info, glyph_index);
	}

	public static function stbtt_GetGlyphHMetrics(info: Stbtt_fontinfo, glyph_index: Int): Stbtt_temp_glyph_h_metrics {
		var numOfLongHorMetrics: Stbtt_uint16 = ttUSHORT(info.data, info.hhea + 34);
		var metrics = new Stbtt_temp_glyph_h_metrics();
		if (glyph_index < numOfLongHorMetrics) {
			metrics.advanceWidth    = ttSHORT(info.data, info.hmtx + 4*glyph_index);
			metrics.leftSideBearing = ttSHORT(info.data, info.hmtx + 4*glyph_index + 2);
		} else {
			metrics.advanceWidth    = ttSHORT(info.data, info.hmtx + 4*(numOfLongHorMetrics-1));
			metrics.leftSideBearing = ttSHORT(info.data, info.hmtx + 4*numOfLongHorMetrics + 2*(glyph_index - numOfLongHorMetrics));
		}
		return metrics;
	}

	public static function stbtt_GetGlyphKernAdvance(info: Stbtt_fontinfo, glyph1: Int, glyph2: Int): Int {
		var kern: Int = info.kern;
		var data: Blob = info.data;
		var needle, straw: Stbtt_uint32;
		var l, r, m: Int;

		// we only look at the first table. it must be 'horizontal' and format 0.
		if (info.kern == 0)
			return 0;
		if (ttUSHORT(data, kern + 2) < 1) // number of tables, need at least 1
			return 0;
		if (ttUSHORT(data, kern + 8) != 1) // horizontal flag must be set in format
			return 0;

		l = 0;
		r = ttUSHORT(data, kern + 10) - 1;
		needle = glyph1 << 16 | glyph2;
		while (l <= r) {
			m = (l + r) >> 1;
			straw = ttULONG(data, kern + 18+(m*6)); // note: unaligned read
			if (needle < straw)
				r = m - 1;
			else if (needle > straw)
				l = m + 1;
			else
				return ttSHORT(data, kern + 22+(m*6));
		}
		return 0;
	}

	public static function stbtt_GetCodepointKernAdvance(info: Stbtt_fontinfo, ch1: Int, ch2: Int): Int {
		if (info.kern == 0) // if no kerning table, don't waste time looking up both codepoint->glyphs
			return 0;
		return stbtt_GetGlyphKernAdvance(info, stbtt_FindGlyphIndex(info,ch1), stbtt_FindGlyphIndex(info,ch2));
	}

	public static function stbtt_GetCodepointHMetrics(info: Stbtt_fontinfo, codepoint: Int): Stbtt_temp_glyph_h_metrics {
		return stbtt_GetGlyphHMetrics(info, stbtt_FindGlyphIndex(info,codepoint));
	}

	public static function stbtt_GetFontVMetrics(info: Stbtt_fontinfo): Stbtt_temp_font_v_metrics {
		var metrics = new Stbtt_temp_font_v_metrics();
		metrics.ascent  = ttSHORT(info.data, info.hhea + 4);
		metrics.descent = ttSHORT(info.data, info.hhea + 6);
		metrics.lineGap = ttSHORT(info.data, info.hhea + 8);
		return metrics;
	}

	public static function stbtt_GetFontBoundingBox(info: Stbtt_fontinfo): Stbtt_temp_rect {
		var rect = new Stbtt_temp_rect();
		rect.x0 = ttSHORT(info.data, info.head + 36);
		rect.y0 = ttSHORT(info.data, info.head + 38);
		rect.x1 = ttSHORT(info.data, info.head + 40);
		rect.y1 = ttSHORT(info.data, info.head + 42);
		return rect;
	}

	public static function stbtt_ScaleForPixelHeight(info: Stbtt_fontinfo, height: Float): Float {
		var fheight: Int = ttSHORT(info.data, info.hhea + 4) - ttSHORT(info.data, info.hhea + 6);
		return height / fheight;
	}

	public static function stbtt_ScaleForMappingEmToPixels(info: Stbtt_fontinfo, pixels: Float): Float {
		var unitsPerEm: Int = ttUSHORT(info.data, info.head + 18);
		return pixels / unitsPerEm;
	}

//////////////////////////////////////////////////////////////////////////////
//
// antialiasing software rasterizer
//

	public static function stbtt_GetGlyphBitmapBoxSubpixel(font: Stbtt_fontinfo, glyph: Int, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float): Stbtt_temp_rect {
		var rect = new Stbtt_temp_rect();
		if (!stbtt_GetGlyphBox(font, glyph, rect)) {
			// e.g. space character
			rect.x0 = 0;
			rect.y0 = 0;
			rect.x1 = 0;
			rect.y1 = 0;
		} else {
			// move to integral bboxes (treating pixels as little squares, what pixels get touched)?
			var x0 = rect.x0;
			var x1 = rect.x1;
			var y0 = rect.y0;
			var y1 = rect.y1;
			rect.x0 = Math.floor( x0 * scale_x + shift_x);
			rect.y0 = Math.floor(-y1 * scale_y + shift_y);
			rect.x1 = Math.ceil( x1 * scale_x + shift_x);
			rect.y1 = Math.ceil(-y0 * scale_y + shift_y);
		}
		return rect;
	}

	public static function stbtt_GetGlyphBitmapBox(font: Stbtt_fontinfo, glyph: Int, scale_x: Float, scale_y: Float): Stbtt_temp_rect {
		return stbtt_GetGlyphBitmapBoxSubpixel(font, glyph, scale_x, scale_y,0.0,0.0);
	}

	public static function stbtt_GetCodepointBitmapBoxSubpixel(font: Stbtt_fontinfo, codepoint: Int, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float): Stbtt_temp_rect {
		return stbtt_GetGlyphBitmapBoxSubpixel(font, stbtt_FindGlyphIndex(font,codepoint), scale_x, scale_y,shift_x,shift_y);
	}

	public static function stbtt_GetCodepointBitmapBox(font: Stbtt_fontinfo, codepoint: Int, scale_x: Float, scale_y: Float): Stbtt_temp_rect {
		return stbtt_GetCodepointBitmapBoxSubpixel(font, codepoint, scale_x, scale_y,0.0,0.0);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	//  Rasterizer

	private static function stbtt__new_active(e: Vector<Stbtt__edge>, eIndex: Int, off_x: Int, start_point: Float): Stbtt__active_edge {
		var z: Stbtt__active_edge = new Stbtt__active_edge();
		var dxdy: Float = (e[eIndex].x1 - e[eIndex].x0) / (e[eIndex].y1 - e[eIndex].y0);
		STBTT_assert(z != null);
		//STBTT_assert(e->y0 <= start_point);
		if (z == null) return z;
		z.fdx = dxdy;
		z.fdy = dxdy != 0.0 ? (1.0/dxdy) : 0.0;
		z.fx = e[eIndex].x0 + dxdy * (start_point - e[eIndex].y0);
		z.fx -= off_x;
		z.direction = e[eIndex].invert ? 1.0 : -1.0;
		z.sy = e[eIndex].y0;
		z.ey = e[eIndex].y1;
		z.next = null;
		return z;
	}

	// the edge passed in here does not cross the vertical line at x or the vertical line at x+1
	// (i.e. it has already been clipped to those)
	private static function stbtt__handle_clipped_edge(scanline: Vector<Float>, scanlineIndex: Int, x: Int, e: Stbtt__active_edge, x0: Float, y0: Float, x1: Float, y1: Float): Void {
		if (y0 == y1) return;
		STBTT_assert(y0 < y1);
		STBTT_assert(e.sy <= e.ey);
		if (y0 > e.ey) return;
		if (y1 < e.sy) return;
		if (y0 < e.sy) {
			x0 += (x1-x0) * (e.sy - y0) / (y1-y0);
			y0 = e.sy;
		}
		if (y1 > e.ey) {
			x1 += (x1-x0) * (e.ey - y1) / (y1-y0);
			y1 = e.ey;
		}

		if (x0 == x)
			STBTT_assert(x1 <= x+1);
		else if (x0 == x+1)
			STBTT_assert(x1 >= x);
		else if (x0 <= x)
			STBTT_assert(x1 <= x);
		else if (x0 >= x+1)
			STBTT_assert(x1 >= x+1);
		else
			STBTT_assert(x1 >= x && x1 <= x+1);

		if (x0 <= x && x1 <= x)
			scanline[scanlineIndex + x] += e.direction * (y1-y0);
		else if (x0 >= x + 1 && x1 >= x + 1) {
			
		} else {
			STBTT_assert(x0 >= x && x0 <= x+1 && x1 >= x && x1 <= x+1);
			scanline[scanlineIndex + x] += e.direction * (y1-y0) * (1-((x0-x)+(x1-x))/2); // coverage = 1 - average x position
		}
	}

	private static function stbtt__fill_active_edges_new(scanline: Vector<Float>, scanline_fill: Vector<Float>, scanline_fillIndex: Int, len: Int, e: Stbtt__active_edge, y_top: Float): Void {
		var y_bottom: Float = y_top+1;

		while (e != null) {
			// brute force every pixel

			// compute intersection points with top & bottom
			STBTT_assert(e.ey >= y_top);

			if (e.fdx == 0) {
				var x0: Float = e.fx;
				if (x0 < len) {
					if (x0 >= 0) {
						stbtt__handle_clipped_edge(scanline, 0, Std.int(x0),e, x0,y_top, x0,y_bottom);
						stbtt__handle_clipped_edge(scanline_fill, scanline_fillIndex - 1, Std.int(x0+1),e, x0,y_top, x0,y_bottom);
					} else {
						stbtt__handle_clipped_edge(scanline_fill, scanline_fillIndex - 1, 0,e, x0,y_top, x0,y_bottom);
					}
				}
			} else {
				var x0: Float = e.fx;
				var dx: Float = e.fdx;
				var xb: Float = x0 + dx;
				var x_top, x_bottom: Float;
				var sy0,sy1: Float;
				var dy: Float = e.fdy;
				STBTT_assert(e.sy <= y_bottom && e.ey >= y_top);

				// compute endpoints of line segment clipped to this scanline (if the
				// line segment starts on this scanline. x0 is the intersection of the
				// line with y_top, but that may be off the line segment.
				if (e.sy > y_top) {
					x_top = x0 + dx * (e.sy - y_top);
					sy0 = e.sy;
				} else {
					x_top = x0;
					sy0 = y_top;
				}
				if (e.ey < y_bottom) {
					x_bottom = x0 + dx * (e.ey - y_top);
					sy1 = e.ey;
				} else {
					x_bottom = xb;
					sy1 = y_bottom;
				}

				if (x_top >= 0 && x_bottom >= 0 && x_top < len && x_bottom < len) {
					// from here on, we don't have to range check x values

					if (Std.int(x_top) == Std.int(x_bottom)) {
						var height: Float;
						// simple case, only spans one pixel
						var x: Int = Std.int(x_top);
						height = sy1 - sy0;
						STBTT_assert(x >= 0 && x < len);
						scanline[x] += e.direction * (1-((x_top - x) + (x_bottom-x))/2)  * height;
						scanline_fill[scanline_fillIndex + x] += e.direction * height; // everything right of this pixel is filled
					} else {
						var x,x1,x2: Int;
						var y_crossing, step, sign, area: Float;
						// covers 2+ pixels
						if (x_top > x_bottom) {
							// flip scanline vertically; signed area is the same
							var t: Float;
							sy0 = y_bottom - (sy0 - y_top);
							sy1 = y_bottom - (sy1 - y_top);
							t = sy0; sy0 = sy1; sy1 = t;
							t = x_bottom; x_bottom = x_top; x_top = t;
							dx = -dx;
							dy = -dy;
							t = x0; x0 = xb; xb = t;
						}

						x1 = Std.int(x_top);
						x2 = Std.int(x_bottom);
						// compute intersection with y axis at x1+1
						y_crossing = (x1+1 - x0) * dy + y_top;

						sign = e.direction;
						// area of the rectangle covered from y0..y_crossing
						area = sign * (y_crossing-sy0);
						// area of the triangle (x_top,y0), (x+1,y0), (x+1,y_crossing)
						scanline[x1] += area * (1-((x_top - x1)+(x1+1-x1))/2);

						step = sign * dy;
						for (x in x1 + 1...x2) {
							scanline[x] += area + step/2;
							area += step;
						}
						y_crossing += dy * (x2 - (x1+1));

						STBTT_assert(Math.abs(area) <= 1.01);

						scanline[x2] += area + sign * (1-((x2-x2)+(x_bottom-x2))/2) * (sy1-y_crossing);

						scanline_fill[scanline_fillIndex + x2] += sign * (sy1-sy0);
					}
				} else {
					// if edge goes outside of box we're drawing, we require
					// clipping logic. since this does not match the intended use
					// of this library, we use a different, very slow brute
					// force implementation
					for (x in 0...len) {
						// cases:
						//
						// there can be up to two intersections with the pixel. any intersection
						// with left or right edges can be handled by splitting into two (or three)
						// regions. intersections with top & bottom do not necessitate case-wise logic.
						//
						// the old way of doing this found the intersections with the left & right edges,
						// then used some simple logic to produce up to three segments in sorted order
						// from top-to-bottom. however, this had a problem: if an x edge was epsilon
						// across the x border, then the corresponding y position might not be distinct
						// from the other y segment, and it might ignored as an empty segment. to avoid
						// that, we need to explicitly produce segments based on x positions.

						// rename variables to clear pairs
						var y0: Float = y_top;
						var x1: Float = x;
						var x2: Float = x+1;
						var x3: Float = xb;
						var y3: Float = y_bottom;
						var y1,y2: Float;

						// x = e->x + e->dx * (y-y_top)
						// (y-y_top) = (x - e->x) / e->dx
						// y = (x - e->x) / e->dx + y_top
						y1 = (x - x0) / dx + y_top;
						y2 = (x+1 - x0) / dx + y_top;

						if (x0 < x1 && x3 > x2) {         // three segments descending down-right
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x1,y1);
							stbtt__handle_clipped_edge(scanline,0,x,e, x1,y1, x2,y2);
							stbtt__handle_clipped_edge(scanline,0,x,e, x2,y2, x3,y3);
						} else if (x3 < x1 && x0 > x2) {  // three segments descending down-left
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x2,y2);
							stbtt__handle_clipped_edge(scanline,0,x,e, x2,y2, x1,y1);
							stbtt__handle_clipped_edge(scanline,0,x,e, x1,y1, x3,y3);
						} else if (x0 < x1 && x3 > x1) {  // two segments across x, down-right
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x1,y1);
							stbtt__handle_clipped_edge(scanline,0,x,e, x1,y1, x3,y3);
						} else if (x3 < x1 && x0 > x1) {  // two segments across x, down-left
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x1,y1);
							stbtt__handle_clipped_edge(scanline,0,x,e, x1,y1, x3,y3);
						} else if (x0 < x2 && x3 > x2) {  // two segments across x+1, down-right
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x2,y2);
							stbtt__handle_clipped_edge(scanline,0,x,e, x2,y2, x3,y3);
						} else if (x3 < x2 && x0 > x2) {  // two segments across x+1, down-left
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x2,y2);
							stbtt__handle_clipped_edge(scanline,0,x,e, x2,y2, x3,y3);
						} else {  // one segment
							stbtt__handle_clipped_edge(scanline,0,x,e, x0,y0, x3,y3);
						}
					}
				}
			}
			e = e.next;
		}
	}

	// directly AA rasterize edges w/o supersampling
	private static function stbtt__rasterize_sorted_edges(result: Stbtt__bitmap, e: Vector<Stbtt__edge>, n: Int, vsubsample: Int, off_x: Int, off_y: Int): Void {
		var active: Stbtt__active_edge = null;
		var y: Int, j: Int = 0, i: Int;
		var scanline: Vector<Float>, scanline2: Vector<Float>;
		var scanline2Index: Int = 0;
		var eIndex: Int = 0;

		if (result.w > 64)
			scanline = new Vector<Float>(result.w * 2 + 1);
		else
			scanline = new Vector<Float>(129);

		scanline2 = scanline;
		scanline2Index = result.w;

		y = off_y;
		e[eIndex + n].y0 = (off_y + result.h) + 1;

		while (j < result.h) {
			// find center of pixel for this scanline
			var scan_y_top: Float = y + 0.0;
			var scan_y_bottom: Float = y + 1.0;
			var step = { value: active, parent: null };

			for (i in 0...result.w) scanline[i] = 0;
			for (i in 0...result.w + 1) scanline2[scanline2Index + i] = 0;

			// update all active edges;
			// remove all active edges that terminate before the top of this scanline
			while (step.value != null) {
				var z: Stbtt__active_edge = step.value;
				if (z.ey <= scan_y_top) {
					// delete from list
					if (step.parent == null) {
						active = z.next;
						step.value = z.next;
					}
					else {
						step.parent.next = z.next;
						step.value = z.next;
					}
					
					STBTT_assert(z.direction != 0);
					z.direction = 0;
				} else {
					// advance through list
					step.parent = step.value;
					step.value = step.value.next;
				}
			}

			// insert all edges that start before the bottom of this scanline
			while (e[eIndex].y0 <= scan_y_bottom) {
				if (e[eIndex].y0 != e[eIndex].y1) {
					var z: Stbtt__active_edge = stbtt__new_active(e, eIndex, off_x, scan_y_top);
					STBTT_assert(z.ey >= scan_y_top);
					if (z != null) {
						if (j == 0 && off_y != 0) {
							if (z.ey < scan_y_top) {
								// this can happen due to subpixel positioning and some kind of fp rounding error i think
								z.ey = scan_y_top;
							}
						}
						STBTT_assert(z.ey >= scan_y_top); // if we get really unlucky a tiny bit of an edge can be out of bounds
					}
					// insert at front
					z.next = active;
					active = z;
				}
				++eIndex;
			}
			
			// now process all active edges
			if (active != null)
				stbtt__fill_active_edges_new(scanline, scanline2, scanline2Index + 1, result.w, active, scan_y_top);

			{
				var sum: Float = 0;
				for (i in 0...result.w) {
					var k: Float;
					var m: Int;
					sum += scanline2[scanline2Index + i];
					k = scanline[i] + sum;
					k = Math.abs(k) * 255.0 + 0.5;
					m = Std.int(k);
					if (m > 255) m = 255;
					result.pixels.writeU8(result.pixels_offset + j * result.stride + i, m);
				}
			}
			// advance all the edges
			step.parent = null;
			step.value = active;
			while (step.value != null) {
				var z: Stbtt__active_edge = step.value;
				z.fx += z.fdx; // advance to position for current scanline
				// advance through list
				step.parent = step.value;
				step.value = step.value.next;
			}

			++y;
			++j;
		}
	}

	private static function STBTT__COMPARE(a: Stbtt__edge, b: Stbtt__edge): Bool { return a.y0 < b.y0; }

	private static function stbtt__sort_edges_ins_sort(p: Vector<Stbtt__edge>, n: Int): Void {
		var i: Int, j: Int;
		for (i in 1...n) {
			var t: Stbtt__edge = p[i];
			var a: Stbtt__edge = t;
			j = i;
			while (j > 0) {
				var b: Stbtt__edge = p[j-1];
				var c: Bool = STBTT__COMPARE(a,b);
				if (!c) break;
				p[j] = p[j-1];
				--j;
			}
			if (i != j)
				p[j] = t;
		}
	}

	private static function stbtt__sort_edges_quicksort(p: Vector<Stbtt__edge>, pIndex: Int, n: Int): Void {
		// threshhold for transitioning to insertion sort
		while (n > 12) {
			var t: Stbtt__edge;
			var c01: Bool, c12: Bool, c: Bool;
			var m: Int, i: Int, j: Int;

			// compute median of three
			m = n >> 1;
			c01 = STBTT__COMPARE(p[pIndex + 0],p[pIndex + m]);
			c12 = STBTT__COMPARE(p[pIndex + m],p[pIndex + n-1]);
			// if 0 >= mid >= end, or 0 < mid < end, then use mid
			if (c01 != c12) {
				// otherwise, we'll need to swap something else to middle
				var z: Int;
				c = STBTT__COMPARE(p[pIndex + 0],p[pIndex + n-1]);
				// 0>mid && mid<n:  0>n => n; 0<n => 0
				// 0<mid && mid>n:  0>n => 0; 0<n => n
				z = (c == c12) ? 0 : n-1;
				t = p[pIndex + z];
				p[pIndex + z] = p[pIndex + m];
				p[pIndex + m] = t;
			}
			// now p[m] is the median-of-three
			// swap it to the beginning so it won't move around
			t = p[pIndex + 0];
			p[pIndex + 0] = p[pIndex + m];
			p[pIndex + m] = t;

			// partition loop
			i=1;
			j=n-1;
			while (true) {
				// handling of equality is crucial here
				// for sentinels & efficiency with duplicates
				while (true) {
					if (!STBTT__COMPARE(p[pIndex + i], p[pIndex + 0])) break;
					++i;
				}
				while (true) {
					if (!STBTT__COMPARE(p[pIndex + 0], p[pIndex + j])) break;
					--j;
				}
				// make sure we haven't crossed
				if (i >= j) break;
				t = p[pIndex + i];
				p[pIndex + i] = p[pIndex + j];
				p[pIndex + j] = t;

				++i;
				--j;
			}
			// recurse on smaller side, iterate on larger
			if (j < (n-i)) {
				stbtt__sort_edges_quicksort(p, pIndex, j);
				pIndex += i;
				n = n-i;
			} else {
				stbtt__sort_edges_quicksort(p, pIndex + i, n-i);
				n = j;
			}
		}
	}

	private static function stbtt__sort_edges(p: Vector<Stbtt__edge>, n: Int): Void {
		stbtt__sort_edges_quicksort(p, 0, n);
		stbtt__sort_edges_ins_sort(p, n);
	}

	private static function stbtt__rasterize(result: Stbtt__bitmap, pts: Vector<Stbtt__point>, wcount: Vector<Int>, windings: Int, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float, off_x: Int, off_y: Int, invert: Bool): Void {
		var y_scale_inv: Float = invert ? -scale_y : scale_y;
		var e: Vector<Stbtt__edge>;
		var n: Int, i: Int, j: Int, k: Int, m: Int;
		var vsubsample: Int = 1;
		var ptsIndex: Int = 0;

		// vsubsample should divide 255 evenly; otherwise we won't reach full opacity

		// now we have to blow out the windings into explicit edge lists
		n = 0;
		for (i in 0...windings)
			n += wcount[i];

		e = new Vector<Stbtt__edge>(n + 1); // add an extra one as a sentinel
		if (e == null) return;
		else {
			for (i in 0...e.length) {
				e[i] = new Stbtt__edge();
			}
		}
		n = 0;

		m = 0;
		for (i in 0...windings) {
			var p: Vector<Stbtt__point> = pts;
			var pIndex: Int = ptsIndex + m;
			m += wcount[i];
			j = wcount[i] - 1;
			for (k in 0...wcount[i]) {
				var a: Int=k,b: Int=j;
				// skip the edge if horizontal
				if (p[pIndex + j].y == p[pIndex + k].y) {
					j = k;
					continue;
				}
				// add edge from j to k to the list
				e[n].invert = false;
				if (invert ? p[pIndex + j].y > p[pIndex + k].y : p[pIndex + j].y < p[pIndex + k].y) {
					e[n].invert = true;
					a = j; b = k;
				}
				e[n].x0 = p[pIndex + a].x * scale_x + shift_x;
				e[n].y0 = (p[pIndex + a].y * y_scale_inv + shift_y) * vsubsample;
				e[n].x1 = p[pIndex + b].x * scale_x + shift_x;
				e[n].y1 = (p[pIndex + b].y * y_scale_inv + shift_y) * vsubsample;
				++n;
				j = k;
			}
		}

		// now sort the edges by their highest point (should snap to integer, and then by x)
		//STBTT_sort(e, n, sizeof(e[0]), stbtt__edge_compare);
		stbtt__sort_edges(e, n);

		// now, traverse the scanlines and find the intersections on each scanline, use xor winding rule
		stbtt__rasterize_sorted_edges(result, e, n, vsubsample, off_x, off_y);
	}

	private static function stbtt__add_point(points: Vector<Stbtt__point>, n: Int, x: Float, y: Float): Void {
		if (points == null) return; // during first pass, it's unallocated
		points[n].x = x;
		points[n].y = y;
	}

	// tesselate until threshhold p is happy... @TODO warped to compensate for non-linear stretching
	private static function stbtt__tesselate_curve(points: Vector<Stbtt__point>, num_points: { value: Int }, x0: Float, y0: Float, x1: Float, y1: Float, x2: Float, y2: Float, objspace_flatness_squared: Float, n: Int): Int {
		// midpoint
		var mx: Float = (x0 + 2*x1 + x2)/4;
		var my: Float = (y0 + 2*y1 + y2)/4;
		// versus directly drawn line
		var dx: Float = (x0+x2)/2 - mx;
		var dy: Float = (y0+y2)/2 - my;
		if (n > 16) // 65536 segments on one curve better be enough!
			return 1;
		if (dx*dx+dy*dy > objspace_flatness_squared) { // half-pixel error allowed... need to be smaller if AA
			stbtt__tesselate_curve(points, num_points, x0,y0, (x0+x1)/2.0,(y0+y1)/2.0, mx,my, objspace_flatness_squared,n+1);
			stbtt__tesselate_curve(points, num_points, mx,my, (x1+x2)/2.0,(y1+y2)/2.0, x2,y2, objspace_flatness_squared,n+1);
		} else {
			stbtt__add_point(points, num_points.value,x2,y2);
			num_points.value = num_points.value+1;
		}
		return 1;
	}

	private static function stbtt__tesselate_cubic(points: Vector<Stbtt__point>, num_points: { value: Int }, x0: Float, y0: Float, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, objspace_flatness_squared: Float, n: Int): Void {
		// @TODO this "flatness" calculation is just made-up nonsense that seems to work well enough
		var dx0: Float = x1-x0;
		var dy0: Float = y1-y0;
		var dx1: Float = x2-x1;
		var dy1: Float = y2-y1;
		var dx2: Float = x3-x2;
		var dy2: Float = y3-y2;
		var dx: Float = x3-x0;
		var dy: Float = y3-y0;
		var longlen: Float = (Math.sqrt(dx0*dx0+dy0*dy0)+Math.sqrt(dx1*dx1+dy1*dy1)+Math.sqrt(dx2*dx2+dy2*dy2));
		var shortlen: Float = Math.sqrt(dx*dx+dy*dy);
		var flatness_squared: Float = longlen*longlen-shortlen*shortlen;

		if (n > 16) // 65536 segments on one curve better be enough!
			return;

		if (flatness_squared > objspace_flatness_squared) {
			var x01: Float = (x0+x1)/2;
			var y01: Float = (y0+y1)/2;
			var x12: Float = (x1+x2)/2;
			var y12: Float = (y1+y2)/2;
			var x23: Float = (x2+x3)/2;
			var y23: Float = (y2+y3)/2;

			var xa: Float = (x01+x12)/2;
			var ya: Float = (y01+y12)/2;
			var xb: Float = (x12+x23)/2;
			var yb: Float = (y12+y23)/2;

			var mx: Float = (xa+xb)/2;
			var my: Float = (ya+yb)/2;

			stbtt__tesselate_cubic(points, num_points, x0,y0, x01,y01, xa,ya, mx,my, objspace_flatness_squared,n+1);
			stbtt__tesselate_cubic(points, num_points, mx,my, xb,yb, x23,y23, x3,y3, objspace_flatness_squared,n+1);
		} else {
			stbtt__add_point(points, num_points.value,x3,y3);
			num_points.value = num_points.value+1;
		}
	}

	// returns number of contours
	private static function stbtt_FlattenCurves(vertices: Vector<Stbtt_vertex>, num_verts: Int, objspace_flatness: Float, contour_lengths: VectorOfIntPointer, num_contours: { value: Int }): Vector<Stbtt__point> {
		var points: Vector<Stbtt__point>=null;
		var num_points: Int = 0;

		var objspace_flatness_squared: Float = objspace_flatness * objspace_flatness;
		var i: Int, n: Int = 0, start: Int = 0, pass: Int;

		// count how many "moves" there are to get the contour count
		for (i in 0...num_verts)
			if (vertices[i].type == STBTT_vmove)
				++n;

		num_contours.value = n;
		if (n == 0) return null;

		contour_lengths.value = new Vector<Int>(n);

		if (contour_lengths.value == null) {
			num_contours.value = 0;
			return null;
		}

		// make two passes through the points so we don't need to realloc
		for (pass in 0...2) {
			var x: Float = 0, y: Float = 0;
			if (pass == 1) {
				points = new Vector<Stbtt__point>(num_points);
				if (points == null) {
					contour_lengths.value = null;
					num_contours.value = 0;
					return null;
				}
				else {
					for (i in 0...points.length) {
						points[i] = new Stbtt__point();
					}
				}
			}
			num_points = 0;
			n = -1;
			for (i in 0...num_verts) {
				switch (vertices[i].type) {
					case STBTT_vmove:
						// start the next contour
						if (n >= 0)
							contour_lengths.value[n] = num_points - start;
						++n;
						start = num_points;

						x = vertices[i].x; y = vertices[i].y;
						stbtt__add_point(points, num_points++, x,y);
					case STBTT_vline:
						x = vertices[i].x; y = vertices[i].y;
						stbtt__add_point(points, num_points++, x, y);
					case STBTT_vcurve:
						var num_points_reference = { value: num_points };
						stbtt__tesselate_curve(points, num_points_reference, x, y,
							vertices[i].cx, vertices[i].cy,
							vertices[i].x,  vertices[i].y,
							objspace_flatness_squared, 0);
						num_points = num_points_reference.value;
						x = vertices[i].x; y = vertices[i].y;
					case STBTT_vcubic:
						var num_points_reference = { value: num_points };
						stbtt__tesselate_cubic(points, num_points_reference, x, y,
							vertices[i].cx, vertices[i].cy,
							vertices[i].cx1, vertices[i].cy1,
							vertices[i].x,  vertices[i].y,
							objspace_flatness_squared, 0);
						num_points = num_points_reference.value;
						x = vertices[i].x; y = vertices[i].y;
				}
			}
			contour_lengths.value[n] = num_points - start;
		}

		return points;
	}

	public static function stbtt_Rasterize(result: Stbtt__bitmap, flatness_in_pixels: Float, vertices: Vector<Stbtt_vertex>, num_verts: Int, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float, x_off: Int, y_off: Int, invert: Bool): Void {
		var scale: Float = scale_x > scale_y ? scale_y : scale_x;
		var winding_count: Int = 0;
		var winding_lengths: Vector<Int> = null;
		var winding_count_reference = { value: winding_count };
		var winding_lengths_reference = new VectorOfIntPointer();
		var windings: Vector<Stbtt__point> = stbtt_FlattenCurves(vertices, num_verts, flatness_in_pixels / scale, winding_lengths_reference, winding_count_reference);
		winding_count = winding_count_reference.value;
		winding_lengths = winding_lengths_reference.value;
		if (windings != null) {
			stbtt__rasterize(result, windings, winding_lengths, winding_count, scale_x, scale_y, shift_x, shift_y, x_off, y_off, invert);
		}
	}

	public static function stbtt_GetGlyphBitmapSubpixel(info: Stbtt_fontinfo, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float, glyph: Int, region: Stbtt_temp_region): Blob {
		var ix0: Int,iy0: Int,ix1: Int,iy1: Int;
		var gbm: Stbtt__bitmap = new Stbtt__bitmap();
		var vertices: Vector<Stbtt_vertex> = stbtt_GetGlyphShape(info, glyph);
		var num_verts: Int = vertices.length;

		if (scale_x == 0) scale_x = scale_y;
		if (scale_y == 0) {
			if (scale_x == 0) return null;
			scale_y = scale_x;
		}

		var rect = stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y);
		ix0 = rect.x0;
		iy0 = rect.y0;
		ix1 = rect.x1;
		iy1 = rect.y1;
		
		// now we get the size
		gbm.w = (ix1 - ix0);
		gbm.h = (iy1 - iy0);
		gbm.pixels = null; // in case we error

		region.width  = gbm.w;
		region.height = gbm.h;
		region.xoff   = ix0;
		region.yoff   = iy0;
   
		if (gbm.w != 0 && gbm.h != 0) {
			gbm.pixels = Blob.alloc(gbm.w * gbm.h);
			if (gbm.pixels != null) {
				gbm.stride = gbm.w;

				stbtt_Rasterize(gbm, 0.35, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0, iy0, true);
			}
		}
		return gbm.pixels;
	}

	public static function stbtt_GetGlyphBitmap(info: Stbtt_fontinfo, scale_x: Float, scale_y: Float, glyph: Int, region: Stbtt_temp_region): Blob {
		return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y, 0.0, 0.0, glyph, region);
	}

	public static function stbtt_MakeGlyphBitmapSubpixel(info: Stbtt_fontinfo, output: Blob, output_offset: Int, out_w: Int, out_h: Int, out_stride: Int, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float, glyph: Int): Void {
		var ix0: Int = 0, iy0: Int = 0;
		var vertices: Vector<Stbtt_vertex> = stbtt_GetGlyphShape(info, glyph);
		var num_verts: Int = vertices == null ? 0 : vertices.length;
		var gbm: Stbtt__bitmap = new Stbtt__bitmap();

		var rect = stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y);
		ix0 = rect.x0;
		iy0 = rect.y0;
		gbm.pixels = output;
		gbm.pixels_offset = output_offset;
		gbm.w = out_w;
		gbm.h = out_h;
		gbm.stride = out_stride;

		if (gbm.w != 0 && gbm.h != 0)
			stbtt_Rasterize(gbm, 0.35, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0,iy0, true);
	}

	public static function stbtt_MakeGlyphBitmap(info: Stbtt_fontinfo, output: Blob, output_offset: Int, out_w: Int, out_h: Int, out_stride: Int, scale_x: Float, scale_y: Float, glyph: Int): Void {
		stbtt_MakeGlyphBitmapSubpixel(info, output, output_offset, out_w, out_h, out_stride, scale_x, scale_y, 0.0, 0.0, glyph);
	}

	public static function stbtt_GetCodepointBitmapSubpixel(info: Stbtt_fontinfo, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float, codepoint: Int, region: Stbtt_temp_region): Blob {
		return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y,shift_x,shift_y, stbtt_FindGlyphIndex(info,codepoint), region);
	}   

	public static function stbtt_MakeCodepointBitmapSubpixel(info: Stbtt_fontinfo, output: Blob, output_offset: Int, out_w: Int, out_h: Int, out_stride: Int, scale_x: Float, scale_y: Float, shift_x: Float, shift_y: Float, codepoint: Int): Void {
		stbtt_MakeGlyphBitmapSubpixel(info, output, output_offset, out_w, out_h, out_stride, scale_x, scale_y, shift_x, shift_y, stbtt_FindGlyphIndex(info,codepoint));
	}

	public static function stbtt_GetCodepointBitmap(info: Stbtt_fontinfo, scale_x: Float, scale_y: Float, codepoint: Int, region: Stbtt_temp_region): Blob {
		return stbtt_GetCodepointBitmapSubpixel(info, scale_x, scale_y, 0.0, 0.0, codepoint, region);
	}   

	public static function stbtt_MakeCodepointBitmap(info: Stbtt_fontinfo, output: Blob, output_offset: Int, out_w: Int, out_h: Int, out_stride: Int, scale_x: Float, scale_y: Float, codepoint: Int): Void {
		stbtt_MakeCodepointBitmapSubpixel(info, output, output_offset, out_w, out_h, out_stride, scale_x, scale_y, 0.0, 0.0, codepoint);
	}

//////////////////////////////////////////////////////////////////////////////
//
// bitmap baking
//
// This is SUPER-CRAPPY packing to keep source code small

	public static function stbtt_BakeFontBitmap(data: Blob, offset: Int, // font location (use offset=0 for plain .ttf)
                                pixel_height: Float,                      // height of font in pixels
                                pixels: Blob, pw: Int, ph: Int,          // bitmap to be filled in
                                chars: Array<Int>,          // characters to bake
                                chardata: Vector<Stbtt_bakedchar>): Int {
		var scale: Float;
		var x: Int,y: Int,bottom_y: Int;
		var f: Stbtt_fontinfo = new Stbtt_fontinfo();
		if (!stbtt_InitFont(f, data, offset))
			return -1;
		x=y=1;
		bottom_y = 1;

		scale = stbtt_ScaleForPixelHeight(f, pixel_height);

		var i = 0;
		for (index in chars) {
			var advance: Int, lsb: Int, x0: Int,y0: Int,x1: Int,y1: Int,gw: Int,gh: Int;
			var g: Int = stbtt_FindGlyphIndex(f, index);
			var metrics = stbtt_GetGlyphHMetrics(f, g);
			advance = metrics.advanceWidth;
			lsb = metrics.leftSideBearing;
			var rect = stbtt_GetGlyphBitmapBox(f, g, scale, scale);
			x0 = rect.x0;
			y0 = rect.y0;
			x1 = rect.x1;
			y1 = rect.y1;
			gw = x1-x0;
			gh = y1-y0;
			if (x + gw + 1 >= pw) {
				y = bottom_y; x = 1; // advance to next row
			}
			if (y + gh + 1 >= ph) // check if it fits vertically AFTER potentially moving to next row
				return -i;
			STBTT_assert(x+gw < pw);
			STBTT_assert(y+gh < ph);
			chardata[i].x0 = x;
			chardata[i].y0 = y;
			chardata[i].x1 = x + gw;
			chardata[i].y1 = y + gh;
			chardata[i].xadvance = scale * advance;
			chardata[i].xoff     = x0;
			chardata[i].yoff     = y0;
			x = x + gw + 1;
			if (y+gh+1 > bottom_y)
				bottom_y = y+gh+1;
			++i;
		}
		for (i in 0...pw * ph)
			pixels.writeU8(i, 0); // background of 0 around pixels
		i = 0;
		var ch:Stbtt_bakedchar;
		for (index in chars) {//bake bitmap if fits
			var g: Int = stbtt_FindGlyphIndex(f, index);
			ch = chardata[i];
			stbtt_MakeGlyphBitmap(f, pixels, ch.x0 + ch.y0 * pw, ch.x1 - ch.x0, ch.y1 - ch.y0, pw, scale, scale, g);
			++i;
		}
		return bottom_y;
	}

	public static function stbtt_GetBakedQuad(chardata: Vector<Stbtt_bakedchar>, pw: Int, ph: Int, char_index: Int, xpos: { value: Float }, ypos: { value: Float }, q: Stbtt_aligned_quad, opengl_fillrule: Bool): Void {
		var d3d_bias: Float = opengl_fillrule ? 0 : -0.5;
		var ipw: Float = 1.0 / pw, iph = 1.0 / ph;
		var b: Stbtt_bakedchar = chardata[char_index];
		var round_x: Int = Math.floor((xpos.value + b.xoff) + 0.5);
		var round_y: Int = Math.floor((ypos.value + b.yoff) + 0.5);

		q.x0 = round_x + d3d_bias;
		q.y0 = round_y + d3d_bias;
		q.x1 = round_x + b.x1 - b.x0 + d3d_bias;
		q.y1 = round_y + b.y1 - b.y0 + d3d_bias;

		q.s0 = b.x0 * ipw;
		q.t0 = b.y0 * iph;
		q.s1 = b.x1 * ipw;
		q.t1 = b.y1 * iph;

		xpos.value += b.xadvance;
	}
/*
//////////////////////////////////////////////////////////////////////////////
//
// rectangle packing replacement routines if you don't have stb_rect_pack.h
//

#ifndef STB_RECT_PACK_VERSION
#ifdef _MSC_VER
#define STBTT__NOTUSED(v)  (void)(v)
#else
#define STBTT__NOTUSED(v)  (void)sizeof(v)
#endif

typedef int stbrp_coord;

////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
//                                                                                //
// COMPILER WARNING ?!?!?                                                         //
//                                                                                //
//                                                                                //
// if you get a compile warning due to these symbols being defined more than      //
// once, move #include "stb_rect_pack.h" before #include "stb_truetype.h"         //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

typedef struct
{
   int width,height;
   int x,y,bottom_y;
} stbrp_context;

typedef struct
{
   unsigned char x;
} stbrp_node;

struct stbrp_rect
{
   stbrp_coord x,y;
   int id,w,h,was_packed;
};

static void stbrp_init_target(stbrp_context *con, int pw, int ph, stbrp_node *nodes, int num_nodes)
{
   con->width  = pw;
   con->height = ph;
   con->x = 0;
   con->y = 0;
   con->bottom_y = 0;
   STBTT__NOTUSED(nodes);
   STBTT__NOTUSED(num_nodes);   
}

static void stbrp_pack_rects(stbrp_context *con, stbrp_rect *rects, int num_rects)
{
   int i;
   for (i=0; i < num_rects; ++i) {
      if (con->x + rects[i].w > con->width) {
         con->x = 0;
         con->y = con->bottom_y;
      }
      if (con->y + rects[i].h > con->height)
         break;
      rects[i].x = con->x;
      rects[i].y = con->y;
      rects[i].was_packed = 1;
      con->x += rects[i].w;
      if (con->y + rects[i].h > con->bottom_y)
         con->bottom_y = con->y + rects[i].h;
   }
   for (   ; i < num_rects; ++i)
      rects[i].was_packed = 0;
}
#endif

//////////////////////////////////////////////////////////////////////////////
//
// bitmap baking
//
// This is SUPER-AWESOME (tm Ryan Gordon) packing using stb_rect_pack.h. If
// stb_rect_pack.h isn't available, it uses the BakeFontBitmap strategy.

STBTT_DEF int stbtt_PackBegin(stbtt_pack_context *spc, unsigned char *pixels, int pw, int ph, int stride_in_bytes, int padding, void *alloc_context)
{
   stbrp_context *context = (stbrp_context *) STBTT_malloc(sizeof(*context)            ,alloc_context);
   int            num_nodes = pw - padding;
   stbrp_node    *nodes   = (stbrp_node    *) STBTT_malloc(sizeof(*nodes  ) * num_nodes,alloc_context);

   if (context == NULL || nodes == NULL) {
      if (context != NULL) STBTT_free(context, alloc_context);
      if (nodes   != NULL) STBTT_free(nodes  , alloc_context);
      return 0;
   }

   spc->user_allocator_context = alloc_context;
   spc->width = pw;
   spc->height = ph;
   spc->pixels = pixels;
   spc->pack_info = context;
   spc->nodes = nodes;
   spc->padding = padding;
   spc->stride_in_bytes = stride_in_bytes != 0 ? stride_in_bytes : pw;
   spc->h_oversample = 1;
   spc->v_oversample = 1;

   stbrp_init_target(context, pw-padding, ph-padding, nodes, num_nodes);

   if (pixels)
      STBTT_memset(pixels, 0, pw*ph); // background of 0 around pixels

   return 1;
}

STBTT_DEF void stbtt_PackEnd  (stbtt_pack_context *spc)
{
   STBTT_free(spc->nodes    , spc->user_allocator_context);
   STBTT_free(spc->pack_info, spc->user_allocator_context);
}

STBTT_DEF void stbtt_PackSetOversampling(stbtt_pack_context *spc, unsigned int h_oversample, unsigned int v_oversample)
{
   STBTT_assert(h_oversample <= STBTT_MAX_OVERSAMPLE);
   STBTT_assert(v_oversample <= STBTT_MAX_OVERSAMPLE);
   if (h_oversample <= STBTT_MAX_OVERSAMPLE)
      spc->h_oversample = h_oversample;
   if (v_oversample <= STBTT_MAX_OVERSAMPLE)
      spc->v_oversample = v_oversample;
}

#define STBTT__OVER_MASK  (STBTT_MAX_OVERSAMPLE-1)

static void stbtt__h_prefilter(unsigned char *pixels, int w, int h, int stride_in_bytes, unsigned int kernel_width)
{
   unsigned char buffer[STBTT_MAX_OVERSAMPLE];
   int safe_w = w - kernel_width;
   int j;
   for (j=0; j < h; ++j) {
      int i;
      unsigned int total;
      STBTT_memset(buffer, 0, kernel_width);

      total = 0;

      // make kernel_width a constant in common cases so compiler can optimize out the divide
      switch (kernel_width) {
         case 2:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i];
               pixels[i] = (unsigned char) (total / 2);
            }
            break;
         case 3:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i];
               pixels[i] = (unsigned char) (total / 3);
            }
            break;
         case 4:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i];
               pixels[i] = (unsigned char) (total / 4);
            }
            break;
         case 5:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i];
               pixels[i] = (unsigned char) (total / 5);
            }
            break;
         default:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i];
               pixels[i] = (unsigned char) (total / kernel_width);
            }
            break;
      }

      for (; i < w; ++i) {
         STBTT_assert(pixels[i] == 0);
         total -= buffer[i & STBTT__OVER_MASK];
         pixels[i] = (unsigned char) (total / kernel_width);
      }

      pixels += stride_in_bytes;
   }
}

static void stbtt__v_prefilter(unsigned char *pixels, int w, int h, int stride_in_bytes, unsigned int kernel_width)
{
   unsigned char buffer[STBTT_MAX_OVERSAMPLE];
   int safe_h = h - kernel_width;
   int j;
   for (j=0; j < w; ++j) {
      int i;
      unsigned int total;
      STBTT_memset(buffer, 0, kernel_width);

      total = 0;

      // make kernel_width a constant in common cases so compiler can optimize out the divide
      switch (kernel_width) {
         case 2:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = (unsigned char) (total / 2);
            }
            break;
         case 3:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = (unsigned char) (total / 3);
            }
            break;
         case 4:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = (unsigned char) (total / 4);
            }
            break;
         case 5:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = (unsigned char) (total / 5);
            }
            break;
         default:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
               buffer[(i+kernel_width) & STBTT__OVER_MASK] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = (unsigned char) (total / kernel_width);
            }
            break;
      }

      for (; i < h; ++i) {
         STBTT_assert(pixels[i*stride_in_bytes] == 0);
         total -= buffer[i & STBTT__OVER_MASK];
         pixels[i*stride_in_bytes] = (unsigned char) (total / kernel_width);
      }

      pixels += 1;
   }
}

static float stbtt__oversample_shift(int oversample)
{
   if (!oversample)
      return 0.0f;

   // The prefilter is a box filter of width "oversample",
   // which shifts phase by (oversample - 1)/2 pixels in
   // oversampled space. We want to shift in the opposite
   // direction to counter this.
   return (float)-(oversample - 1) / (2.0f * (float)oversample);
}

// rects array must be big enough to accommodate all characters in the given ranges
STBTT_DEF int stbtt_PackFontRangesGatherRects(stbtt_pack_context *spc, stbtt_fontinfo *info, stbtt_pack_range *ranges, int num_ranges, stbrp_rect *rects)
{
   int i,j,k;

   k=0;
   for (i=0; i < num_ranges; ++i) {
      float fh = ranges[i].font_size;
      float scale = fh > 0 ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
      ranges[i].h_oversample = (unsigned char) spc->h_oversample;
      ranges[i].v_oversample = (unsigned char) spc->v_oversample;
      for (j=0; j < ranges[i].num_chars; ++j) {
         int x0,y0,x1,y1;
         int codepoint = ranges[i].array_of_unicode_codepoints == NULL ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
         int glyph = stbtt_FindGlyphIndex(info, codepoint);
         stbtt_GetGlyphBitmapBoxSubpixel(info,glyph,
                                         scale * spc->h_oversample,
                                         scale * spc->v_oversample,
                                         0,0,
                                         &x0,&y0,&x1,&y1);
         rects[k].w = (stbrp_coord) (x1-x0 + spc->padding + spc->h_oversample-1);
         rects[k].h = (stbrp_coord) (y1-y0 + spc->padding + spc->v_oversample-1);
         ++k;
      }
   }

   return k;
}

// rects array must be big enough to accommodate all characters in the given ranges
STBTT_DEF int stbtt_PackFontRangesRenderIntoRects(stbtt_pack_context *spc, stbtt_fontinfo *info, stbtt_pack_range *ranges, int num_ranges, stbrp_rect *rects)
{
   int i,j,k, return_value = 1;

   // save current values
   int old_h_over = spc->h_oversample;
   int old_v_over = spc->v_oversample;

   k = 0;
   for (i=0; i < num_ranges; ++i) {
      float fh = ranges[i].font_size;
      float scale = fh > 0 ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
      float recip_h,recip_v,sub_x,sub_y;
      spc->h_oversample = ranges[i].h_oversample;
      spc->v_oversample = ranges[i].v_oversample;
      recip_h = 1.0f / spc->h_oversample;
      recip_v = 1.0f / spc->v_oversample;
      sub_x = stbtt__oversample_shift(spc->h_oversample);
      sub_y = stbtt__oversample_shift(spc->v_oversample);
      for (j=0; j < ranges[i].num_chars; ++j) {
         stbrp_rect *r = &rects[k];
         if (r->was_packed) {
            stbtt_packedchar *bc = &ranges[i].chardata_for_range[j];
            int advance, lsb, x0,y0,x1,y1;
            int codepoint = ranges[i].array_of_unicode_codepoints == NULL ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
            int glyph = stbtt_FindGlyphIndex(info, codepoint);
            stbrp_coord pad = (stbrp_coord) spc->padding;

            // pad on left and top
            r->x += pad;
            r->y += pad;
            r->w -= pad;
            r->h -= pad;
            stbtt_GetGlyphHMetrics(info, glyph, &advance, &lsb);
            stbtt_GetGlyphBitmapBox(info, glyph,
                                    scale * spc->h_oversample,
                                    scale * spc->v_oversample,
                                    &x0,&y0,&x1,&y1);
            stbtt_MakeGlyphBitmapSubpixel(info,
                                          spc->pixels + r->x + r->y*spc->stride_in_bytes,
                                          r->w - spc->h_oversample+1,
                                          r->h - spc->v_oversample+1,
                                          spc->stride_in_bytes,
                                          scale * spc->h_oversample,
                                          scale * spc->v_oversample,
                                          0,0,
                                          glyph);

            if (spc->h_oversample > 1)
               stbtt__h_prefilter(spc->pixels + r->x + r->y*spc->stride_in_bytes,
                                  r->w, r->h, spc->stride_in_bytes,
                                  spc->h_oversample);

            if (spc->v_oversample > 1)
               stbtt__v_prefilter(spc->pixels + r->x + r->y*spc->stride_in_bytes,
                                  r->w, r->h, spc->stride_in_bytes,
                                  spc->v_oversample);

            bc->x0       = (stbtt_int16)  r->x;
            bc->y0       = (stbtt_int16)  r->y;
            bc->x1       = (stbtt_int16) (r->x + r->w);
            bc->y1       = (stbtt_int16) (r->y + r->h);
            bc->xadvance =                scale * advance;
            bc->xoff     =       (float)  x0 * recip_h + sub_x;
            bc->yoff     =       (float)  y0 * recip_v + sub_y;
            bc->xoff2    =                (x0 + r->w) * recip_h + sub_x;
            bc->yoff2    =                (y0 + r->h) * recip_v + sub_y;
         } else {
            return_value = 0; // if any fail, report failure
         }

         ++k;
      }
   }

   // restore original values
   spc->h_oversample = old_h_over;
   spc->v_oversample = old_v_over;

   return return_value;
}

STBTT_DEF void stbtt_PackFontRangesPackRects(stbtt_pack_context *spc, stbrp_rect *rects, int num_rects)
{
   stbrp_pack_rects((stbrp_context *) spc->pack_info, rects, num_rects);
}

STBTT_DEF int stbtt_PackFontRanges(stbtt_pack_context *spc, unsigned char *fontdata, int font_index, stbtt_pack_range *ranges, int num_ranges)
{
   stbtt_fontinfo info;
   int i,j,n, return_value = 1;
   //stbrp_context *context = (stbrp_context *) spc->pack_info;
   stbrp_rect    *rects;

   // flag all characters as NOT packed
   for (i=0; i < num_ranges; ++i)
      for (j=0; j < ranges[i].num_chars; ++j)
         ranges[i].chardata_for_range[j].x0 =
         ranges[i].chardata_for_range[j].y0 =
         ranges[i].chardata_for_range[j].x1 =
         ranges[i].chardata_for_range[j].y1 = 0;

   n = 0;
   for (i=0; i < num_ranges; ++i)
      n += ranges[i].num_chars;
         
   rects = (stbrp_rect *) STBTT_malloc(sizeof(*rects) * n, spc->user_allocator_context);
   if (rects == NULL)
      return 0;

   stbtt_InitFont(&info, fontdata, stbtt_GetFontOffsetForIndex(fontdata,font_index));

   n = stbtt_PackFontRangesGatherRects(spc, &info, ranges, num_ranges, rects);

   stbtt_PackFontRangesPackRects(spc, rects, n);
  
   return_value = stbtt_PackFontRangesRenderIntoRects(spc, &info, ranges, num_ranges, rects);

   STBTT_free(rects, spc->user_allocator_context);
   return return_value;
}

STBTT_DEF int stbtt_PackFontRange(stbtt_pack_context *spc, unsigned char *fontdata, int font_index, float font_size,
            int first_unicode_codepoint_in_range, int num_chars_in_range, stbtt_packedchar *chardata_for_range)
{
   stbtt_pack_range range;
   range.first_unicode_codepoint_in_range = first_unicode_codepoint_in_range;
   range.array_of_unicode_codepoints = NULL;
   range.num_chars                   = num_chars_in_range;
   range.chardata_for_range          = chardata_for_range;
   range.font_size                   = font_size;
   return stbtt_PackFontRanges(spc, fontdata, font_index, &range, 1);
}

STBTT_DEF void stbtt_GetPackedQuad(stbtt_packedchar *chardata, int pw, int ph, int char_index, float *xpos, float *ypos, stbtt_aligned_quad *q, int align_to_integer)
{
   float ipw = 1.0f / pw, iph = 1.0f / ph;
   stbtt_packedchar *b = chardata + char_index;

   if (align_to_integer) {
      float x = (float) STBTT_ifloor((*xpos + b->xoff) + 0.5f);
      float y = (float) STBTT_ifloor((*ypos + b->yoff) + 0.5f);
      q->x0 = x;
      q->y0 = y;
      q->x1 = x + b->xoff2 - b->xoff;
      q->y1 = y + b->yoff2 - b->yoff;
   } else {
      q->x0 = *xpos + b->xoff;
      q->y0 = *ypos + b->yoff;
      q->x1 = *xpos + b->xoff2;
      q->y1 = *ypos + b->yoff2;
   }

   q->s0 = b->x0 * ipw;
   q->t0 = b->y0 * iph;
   q->s1 = b->x1 * ipw;
   q->t1 = b->y1 * iph;

   *xpos += b->xadvance;
}


//////////////////////////////////////////////////////////////////////////////
//
// font name matching -- recommended not to use this
//

// check if a utf8 string contains a prefix which is the utf16 string; if so return length of matching utf8 string
static stbtt_int32 stbtt__CompareUTF8toUTF16_bigendian_prefix(const stbtt_uint8 *s1, stbtt_int32 len1, const stbtt_uint8 *s2, stbtt_int32 len2) 
{
   stbtt_int32 i=0;

   // convert utf16 to utf8 and compare the results while converting
   while (len2) {
      stbtt_uint16 ch = s2[0]*256 + s2[1];
      if (ch < 0x80) {
         if (i >= len1) return -1;
         if (s1[i++] != ch) return -1;
      } else if (ch < 0x800) {
         if (i+1 >= len1) return -1;
         if (s1[i++] != 0xc0 + (ch >> 6)) return -1;
         if (s1[i++] != 0x80 + (ch & 0x3f)) return -1;
      } else if (ch >= 0xd800 && ch < 0xdc00) {
         stbtt_uint32 c;
         stbtt_uint16 ch2 = s2[2]*256 + s2[3];
         if (i+3 >= len1) return -1;
         c = ((ch - 0xd800) << 10) + (ch2 - 0xdc00) + 0x10000;
         if (s1[i++] != 0xf0 + (c >> 18)) return -1;
         if (s1[i++] != 0x80 + ((c >> 12) & 0x3f)) return -1;
         if (s1[i++] != 0x80 + ((c >>  6) & 0x3f)) return -1;
         if (s1[i++] != 0x80 + ((c      ) & 0x3f)) return -1;
         s2 += 2; // plus another 2 below
         len2 -= 2;
      } else if (ch >= 0xdc00 && ch < 0xe000) {
         return -1;
      } else {
         if (i+2 >= len1) return -1;
         if (s1[i++] != 0xe0 + (ch >> 12)) return -1;
         if (s1[i++] != 0x80 + ((ch >> 6) & 0x3f)) return -1;
         if (s1[i++] != 0x80 + ((ch     ) & 0x3f)) return -1;
      }
      s2 += 2;
      len2 -= 2;
   }
   return i;
}

STBTT_DEF int stbtt_CompareUTF8toUTF16_bigendian(const char *s1, int len1, const char *s2, int len2) 
{
   return len1 == stbtt__CompareUTF8toUTF16_bigendian_prefix((const stbtt_uint8*) s1, len1, (const stbtt_uint8*) s2, len2);
}

// returns results in whatever encoding you request... but note that 2-byte encodings
// will be BIG-ENDIAN... use stbtt_CompareUTF8toUTF16_bigendian() to compare
STBTT_DEF const char *stbtt_GetFontNameString(const stbtt_fontinfo *font, int *length, int platformID, int encodingID, int languageID, int nameID)
{
   stbtt_int32 i,count,stringOffset;
   stbtt_uint8 *fc = font->data;
   stbtt_uint32 offset = font->fontstart;
   stbtt_uint32 nm = stbtt__find_table(fc, offset, "name");
   if (!nm) return NULL;

   count = ttUSHORT(fc+nm+2);
   stringOffset = nm + ttUSHORT(fc+nm+4);
   for (i=0; i < count; ++i) {
      stbtt_uint32 loc = nm + 6 + 12 * i;
      if (platformID == ttUSHORT(fc+loc+0) && encodingID == ttUSHORT(fc+loc+2)
          && languageID == ttUSHORT(fc+loc+4) && nameID == ttUSHORT(fc+loc+6)) {
         *length = ttUSHORT(fc+loc+8);
         return (const char *) (fc+stringOffset+ttUSHORT(fc+loc+10));
      }
   }
   return NULL;
}

static int stbtt__matchpair(stbtt_uint8 *fc, stbtt_uint32 nm, stbtt_uint8 *name, stbtt_int32 nlen, stbtt_int32 target_id, stbtt_int32 next_id)
{
   stbtt_int32 i;
   stbtt_int32 count = ttUSHORT(fc+nm+2);
   stbtt_int32 stringOffset = nm + ttUSHORT(fc+nm+4);

   for (i=0; i < count; ++i) {
      stbtt_uint32 loc = nm + 6 + 12 * i;
      stbtt_int32 id = ttUSHORT(fc+loc+6);
      if (id == target_id) {
         // find the encoding
         stbtt_int32 platform = ttUSHORT(fc+loc+0), encoding = ttUSHORT(fc+loc+2), language = ttUSHORT(fc+loc+4);

         // is this a Unicode encoding?
         if (platform == 0 || (platform == 3 && encoding == 1) || (platform == 3 && encoding == 10)) {
            stbtt_int32 slen = ttUSHORT(fc+loc+8);
            stbtt_int32 off = ttUSHORT(fc+loc+10);

            // check if there's a prefix match
            stbtt_int32 matchlen = stbtt__CompareUTF8toUTF16_bigendian_prefix(name, nlen, fc+stringOffset+off,slen);
            if (matchlen >= 0) {
               // check for target_id+1 immediately following, with same encoding & language
               if (i+1 < count && ttUSHORT(fc+loc+12+6) == next_id && ttUSHORT(fc+loc+12) == platform && ttUSHORT(fc+loc+12+2) == encoding && ttUSHORT(fc+loc+12+4) == language) {
                  slen = ttUSHORT(fc+loc+12+8);
                  off = ttUSHORT(fc+loc+12+10);
                  if (slen == 0) {
                     if (matchlen == nlen)
                        return 1;
                  } else if (matchlen < nlen && name[matchlen] == ' ') {
                     ++matchlen;
                     if (stbtt_CompareUTF8toUTF16_bigendian((char*) (name+matchlen), nlen-matchlen, (char*)(fc+stringOffset+off),slen))
                        return 1;
                  }
               } else {
                  // if nothing immediately following
                  if (matchlen == nlen)
                     return 1;
               }
            }
         }

         // @TODO handle other encodings
      }
   }
   return 0;
}

static int stbtt__matches(stbtt_uint8 *fc, stbtt_uint32 offset, stbtt_uint8 *name, stbtt_int32 flags)
{
   stbtt_int32 nlen = (stbtt_int32) STBTT_strlen((char *) name);
   stbtt_uint32 nm,hd;
   if (!stbtt__isfont(fc+offset)) return 0;

   // check italics/bold/underline flags in macStyle...
   if (flags) {
      hd = stbtt__find_table(fc, offset, "head");
      if ((ttUSHORT(fc+hd+44) & 7) != (flags & 7)) return 0;
   }

   nm = stbtt__find_table(fc, offset, "name");
   if (!nm) return 0;

   if (flags) {
      // if we checked the macStyle flags, then just check the family and ignore the subfamily
      if (stbtt__matchpair(fc, nm, name, nlen, 16, -1))  return 1;
      if (stbtt__matchpair(fc, nm, name, nlen,  1, -1))  return 1;
      if (stbtt__matchpair(fc, nm, name, nlen,  3, -1))  return 1;
   } else {
      if (stbtt__matchpair(fc, nm, name, nlen, 16, 17))  return 1;
      if (stbtt__matchpair(fc, nm, name, nlen,  1,  2))  return 1;
      if (stbtt__matchpair(fc, nm, name, nlen,  3, -1))  return 1;
   }

   return 0;
}

STBTT_DEF int stbtt_FindMatchingFont(const unsigned char *font_collection, const char *name_utf8, stbtt_int32 flags)
{
   stbtt_int32 i;
   for (i=0;;++i) {
      stbtt_int32 off = stbtt_GetFontOffsetForIndex(font_collection, i);
      if (off < 0) return off;
      if (stbtt__matches((stbtt_uint8 *) font_collection, off, (stbtt_uint8*) name_utf8, flags))
         return off;
   }
}
*/
}

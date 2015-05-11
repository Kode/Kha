package kha;

import haxe.Utf8;

using StringTools;

// To be deleted when Haxe gets UCS2 support

#if cpp

abstract SuperString(String) {
	inline public function new(value: String) {
		this = value;
	}
	
	public var length(get, never): Int;
	
	private function get_length(): Int {
		return Utf8.length(this);
	}
	
	public function charAt(index: Int): String {
		var code = Utf8.charCodeAt(this, index);
		return String.fromCharCode(code);
	}
	
	public function charCodeAt(index: Int): Int {
		return Utf8.charCodeAt(this, index);
	}
	
	public function toUpperCase(): SuperString {
		var buffer = new StringBuf();
		Utf8.iter(this, function (code: Int) {
			if (code >= 'a'.charCodeAt(0) && code <= 'z'.charCodeAt(0)) {
				buffer.addChar(code - 'a'.charCodeAt(0) + 'A'.charCodeAt(0));
			}
			else if (code == Utf8.charCodeAt('ä', 0)) {
				buffer.addChar(Utf8.charCodeAt('Ä', 0));
			}
			else if (code == Utf8.charCodeAt('ö', 0)) {
				buffer.addChar(Utf8.charCodeAt('Ö', 0));
			}
			else if (code == Utf8.charCodeAt('ü', 0)) {
				buffer.addChar(Utf8.charCodeAt('Ü', 0));
			}
			else {
				buffer.addChar(code);
			}
		});
		return new SuperString(buffer.toString());
	}

	public function toLowerCase(): SuperString {
		var buffer = new StringBuf();
		Utf8.iter(this, function (code: Int) {
			if (code >= 'A'.charCodeAt(0) && code <= 'Z'.charCodeAt(0)) {
				buffer.addChar(code - 'A'.charCodeAt(0) + 'a'.charCodeAt(0));
			}
			else if (code == Utf8.charCodeAt('Ä', 0)) {
				buffer.addChar(Utf8.charCodeAt('ä', 0));
			}
			else if (code == Utf8.charCodeAt('Ö', 0)) {
				buffer.addChar(Utf8.charCodeAt('ö', 0));
			}
			else if (code == Utf8.charCodeAt('Ü', 0)) {
				buffer.addChar(Utf8.charCodeAt('ü', 0));
			}
			else {
				buffer.addChar(code);
			}
		});
		return new SuperString(buffer.toString());
	}

	public function trim(): SuperString {
		return new SuperString(StringTools.trim(this));
	}

	public function substr(pos: Int, ?len: Int): SuperString {
		return new SuperString(Utf8.sub(this, pos, len == null ? length - pos : len));
	}

	public function substring(start: Int, end: Int): SuperString {
		return new SuperString(Utf8.sub(this, start, end - start));
	}

	public function split(splitter: String): Array<SuperString> {
		var array = new Array<SuperString>();
		var splitted = this.split(splitter);
		for (s in splitted) {
			array.push(new SuperString(s));
		}
		return array;
	}

	public function indexOf(str: String, ?startIndex: Int): Int {
		var index: Int = -1;
		var i: Int = startIndex == null ? 0 : startIndex;
		Utf8.iter(this, function (char: Int) {
			if (index < 0 && str.charCodeAt(0) == char) {
				index = i;
			}
			++i;
		});
		return index;
	}
	
	public function toString(): String {
		return this;
	}
}

#else

typedef SuperString = String;

#end

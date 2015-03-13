package kha;

import haxe.Utf8;

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
	
	public function toString(): String {
		return this;
	}
}

#else

typedef SuperString = String;

#end

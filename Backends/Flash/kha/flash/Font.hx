package kha.flash;

import kha.FontStyle;
import flash.text.TextField;
import flash.text.TextFormat;

class Font implements kha.Font {
	static var t : TextField = new TextField();
	public var name : String;
	public var style : FontStyle;
	public var size : Int;
	
	public function new(name : String, style : FontStyle, size : Int) {
		this.name = name;
		this.style = style;
		this.size = size;
		t.width = 1024;
		t.height = 1024;
	}
	
	public function getHeight() : Float {
		t.defaultTextFormat = new TextFormat(name, size, 0, style.getBold(), style.getItalic(), style.getUnderlined());
		t.text = "A";
		return t.textHeight;
	}
	
	public function charWidth(ch : String) : Float {
		return stringWidth(ch);
	}
	
	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return stringWidth(ch.substr(offset, length));
	}
	
	public function stringWidth(str : String) : Float {
		t.defaultTextFormat = new TextFormat(name, size, 0, style.getBold(), style.getItalic(), style.getUnderlined());
		t.text = str;
		return t.textWidth;
	}
	
	public function getBaselinePosition() : Float {
		return 0;
	}
}
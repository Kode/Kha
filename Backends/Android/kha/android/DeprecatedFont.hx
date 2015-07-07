package kha.android;

import android.graphics.Paint;
import android.graphics.Typeface;
import kha.FontStyle;

class DeprecatedFont implements kha.Font {
	public var name : String;
	public var style : FontStyle;
	public var size : Int;
	var paint : Paint;
	
	public function new(name : String, style : FontStyle, size : Int) {
		this.name = name;
		this.style = style;
		this.size = size;
		paint = new Paint();
		paint.setTypeface(Typeface.create(name, Typeface.NORMAL));
		paint.setTextSize(size);
	}
	
	public function getHeight() : Float {
		return size;
	}

	public function charWidth(ch : String) : Float {
		return stringWidth(ch);
	}

	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return stringWidth(ch.substr(offset, length));
	}

	public function stringWidth(str : String) : Float {
		return paint.measureText(str);
	}

	public function getBaselinePosition() : Float {
		return 0;
	}
}
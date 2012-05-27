package kha.wpf;

import kha.FontStyle;

@:classContents('
	private System.Windows.Media.FormattedText getFormat(string text = "ABC") {
		return new System.Windows.Media.FormattedText(text,
				System.Globalization.CultureInfo.GetCultureInfo("en-us"), System.Windows.FlowDirection.LeftToRight,
				new System.Windows.Media.Typeface(name), size, System.Windows.Media.Brushes.Black);
	}
')
class Font implements kha.Font {
	public var name : String;
	public var style : FontStyle;
	public var size : Int;

	public function new(name : String, style : FontStyle, size : Int) {
		this.name = name;
		this.style = style;
		this.size = size;
	}
	
	@:functionBody('
		return getFormat().Height;
	')
	public function getHeight() : Float {
		return 0;
	}

	public function charWidth(ch : String) : Float {
		return stringWidth(ch);
	}

	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return stringWidth(ch.substr(offset, length));
	}

	@:functionBody('
		return getFormat(str).Width;
	')
	public function stringWidth(str : String) : Float {
		return 0;
	}
	
	@:functionBody('
		return getFormat().Baseline;
	')
	public function getBaselinePosition() : Float {
		return 0;
	}
}
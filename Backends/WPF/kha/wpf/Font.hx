package kha.wpf;

import kha.FontStyle;

@:classCode('
	private System.Windows.Media.FormattedText getFormat(string text = "ABC") {
		System.Windows.Media.FormattedText fText = new System.Windows.Media.FormattedText(text,
				System.Globalization.CultureInfo.GetCultureInfo("en-us"), System.Windows.FlowDirection.LeftToRight,
				new System.Windows.Media.Typeface(get_name()), get_size(), System.Windows.Media.Brushes.Black);
		if (get_style().getBold()) fText.SetFontWeight(System.Windows.FontWeights.Bold);
		if (get_style().getItalic()) fText.SetFontStyle(System.Windows.FontStyles.Italic);
		if (get_style().getUnderlined()) fText.SetTextDecorations(System.Windows.TextDecorations.Underline);
		return fText;
	}
')
class Font implements kha.Font {
	public var myName: String;
	public var myStyle: FontStyle;
	public var mySize: Float;

	public function new(name: String, style: FontStyle, size: Float) {
		myName = name;
		myStyle = style;
		mySize = size;
	}
	
	public var name(get, null): String;
	
	public function get_name(): String {
		return myName;
	}
	
	public var style(get, null): FontStyle;
	
	public function get_style(): FontStyle {
		return myStyle;
	}
	
	public var size(get, null): Float;
	
	public function get_size(): Float {
		return mySize;
	}
	
	@:functionCode('
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

	@:functionCode('
		return getFormat(str).WidthIncludingTrailingWhitespace;
	')
	public function stringWidth(str : String) : Float {
		return 0;
	}
	
	@:functionCode('
		return getFormat().Baseline;
	')
	public function getBaselinePosition() : Float {
		return 0;
	}
}
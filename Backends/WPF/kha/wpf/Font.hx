package kha.wpf;

import kha.FontStyle;

@:classCode('
	private System.Windows.Media.FormattedText getFormat(string text = "ABC") {
		System.Windows.Media.FormattedText fText = new System.Windows.Media.FormattedText(text,
				System.Globalization.CultureInfo.GetCultureInfo("en-us"), System.Windows.FlowDirection.LeftToRight,
				new System.Windows.Media.Typeface(name), size, System.Windows.Media.Brushes.Black);
		if (style.getBold()) fText.SetFontWeight(System.Windows.FontWeights.Bold);
		if (style.getItalic()) fText.SetFontStyle(System.Windows.FontStyles.Italic);
		if (style.getUnderlined()) fText.SetTextDecorations(System.Windows.TextDecorations.Underline);
		return fText;
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
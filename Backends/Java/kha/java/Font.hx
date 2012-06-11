package kha.java;

import kha.FontStyle;

@:classContents('
	private static java.awt.image.BufferedImage testImage = new java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_ARGB);
	private static java.awt.Graphics2D testGraphics;
	public java.awt.Font font;
	
	static {
		testGraphics = testImage.createGraphics();
	}
')
class Font implements kha.Font {
	public function new(name : String, style : FontStyle, size : Int) {
		init(name, style, size);
	}
	
	@:functionBody('
		font = new java.awt.Font(name, 0, size);
	')
	function init(name : String, style : FontStyle, size : Int) {
		
	}
	
	@:functionBody('
		return testGraphics.getFontMetrics(font).getHeight();
	')
	public function getHeight() : Float {
		return 0;
	}
	
	@:functionBody('
		return testGraphics.getFontMetrics(font).charWidth(ch.charAt(0));
	')
	public function charWidth(ch : String) : Float {
		return 0;
	}
	
	@:functionBody('
		return stringWidth(ch.substring(offset, offset + length));
	')
	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return 0;
	}
	
	@:functionBody('
		return testGraphics.getFontMetrics(font).stringWidth(str);
	')
	public function stringWidth(str : String) : Float {
		return 0;
	}
	
	@:functionBody('
		return testGraphics.getFontMetrics(font).getHeight() - testGraphics.getFontMetrics(font).getLeading();
	')
	public function getBaselinePosition() : Float {
		return 0;
	}
}
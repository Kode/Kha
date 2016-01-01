package kha.java;

import kha.FontStyle;

@:classCode('
	private static java.awt.image.BufferedImage testImage = new java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_ARGB);
	private static java.awt.Graphics2D testGraphics;
	public java.awt.Font font;
	
	static {
		testGraphics = testImage.createGraphics();
	}
')
class Font implements kha.Font {
	public var myName: String;
	public var myStyle: FontStyle;
	public var mySize: Float;
	
	public function new(name: String, style: FontStyle, size: Float) {
		init(name, style, size);
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
		font = new java.awt.Font(name, 0, (int)size);
		myName = name;
		myStyle = style;
		mySize = size;
	')
	function init(name: String, style: FontStyle, size: Float) {
		
	}
	
	@:functionCode('
		return testGraphics.getFontMetrics(font).getHeight();
	')
	public function height(fontSize: Int): Float {
		return 0;
	}
	
	@:functionCode('
		return testGraphics.getFontMetrics(font).stringWidth(str);
	')
	public function width(fontSize: Int, str: String): Float {
		return 0;
	}
	
	@:functionCode('
		return testGraphics.getFontMetrics(font).getHeight() - testGraphics.getFontMetrics(font).getLeading();
	')
	public function baseline(fontSize: Int): Float {
		return 0;
	}
	
	@:functionCode('
		font = null;
	')
	public function unload(): Void {
		
	}
}

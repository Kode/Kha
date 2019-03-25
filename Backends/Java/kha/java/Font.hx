package kha.java;

import kha.FontStyle;
import java.awt.image.BufferedImage;
import java.awt.Graphics2D;
import java.awt.Font in JFont;

// @:classCode('
// 	private static java.awt.image.BufferedImage testImage = new java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_ARGB);
// 	private static java.awt.Graphics2D testGraphics;
// 	public java.awt.Font font;

// 	static {
// 		testGraphics = testImage.createGraphics();
// 	}
// ')
class Font implements Resource {
	private static var testImage = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
	private static var testGraphics:Graphics2D;
	public var font:JFont;
	public var myName: String;
	public var myStyle: FontStyle;
	public var mySize: Float;

	public function new(name: String, style: FontStyle, size: Float) {
		if (testGraphics == null) testGraphics = testImage.createGraphics();
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

	// @:functionCode('
	// 	font = new java.awt.Font(name, 0, (int)size);
	// 	myName = name;
	// 	myStyle = style;
	// 	mySize = size;
	// ')
	function init(name: String, style: FontStyle, size: Float) {
		font = new JFont(name, 0, Std.int(size));
		myName = name;
		myStyle = style;
		mySize = size;
	}

	// @:functionCode('
	// 	return testGraphics.getFontMetrics(font).getHeight();
	// ')
	public function height(fontSize: Int): Float {
		return testGraphics.getFontMetrics(font).getHeight();
	}

	// @:functionCode('
	// 	return testGraphics.getFontMetrics(font).stringWidth(str);
	// ')
	public function width(fontSize: Int, str: String): Float {
		return testGraphics.getFontMetrics(font).stringWidth(str);
		// return 0;
	}

	// @:functionCode('
	// 	return testGraphics.getFontMetrics(font).getHeight() - testGraphics.getFontMetrics(font).getLeading();
	// ')
	public function baseline(fontSize: Int): Float {
		return testGraphics.getFontMetrics(font).getHeight() - testGraphics.getFontMetrics(font).getLeading();
		// return 0;
	}

	// @:functionCode('
	// 	font = null;
	// ')
	public function unload(): Void {
		font = null;
	}
}

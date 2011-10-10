package com.ktxsoftware.kje.backends.java;

import java.awt.image.BufferedImage;

import com.ktxsoftware.kje.Font;

public class JavaFont implements Font {
	private java.awt.Font font;
	private static BufferedImage testImage = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
	private static java.awt.Graphics2D testGraphics;
	
	static {
		testGraphics = testImage.createGraphics();
	}
	
	public JavaFont(String name, int style, int size) {
		font = new java.awt.Font(name, 0, size);
	}

	@Override
	public double getHeight() {
		return testGraphics.getFontMetrics(font).getHeight();
	}
	
	@Override
	public double charWidth(char ch) {
		return testGraphics.getFontMetrics(font).charWidth(ch);
	}

	@Override
	public double charsWidth(char[] ch, int offset, int length) {
		return stringWidth(new String(ch, offset, length));
	}

	@Override
	public double stringWidth(String str) {
		if (str == null) throw new NullPointerException();
		return testGraphics.getFontMetrics(font).stringWidth(str);
	}
	
	@Override
	public double getBaselinePosition() {
		return testGraphics.getFontMetrics(font).getHeight() - testGraphics.getFontMetrics(font).getLeading();
	}
	
	public java.awt.Font getNativeFont() {
		return font;
	}
}
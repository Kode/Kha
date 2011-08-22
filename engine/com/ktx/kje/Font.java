package com.ktx.kje;

public interface Font {
	public static final int PLAIN = 0;
	public static final int BOLD = 1;
	public static final int ITALIC = 2;
	public static final int UNDERLINED = 4;
	
	double getHeight();
	double charWidth(char ch);
	double charsWidth(char[] ch, int offset, int length);
	double stringWidth(String str);
	double getBaselinePosition();
}
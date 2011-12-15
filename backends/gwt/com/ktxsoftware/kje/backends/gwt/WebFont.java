package com.ktxsoftware.kje.backends.gwt;

import com.ktxsoftware.kje.Font;

public class WebFont implements Font {
	public String name;
	public int style;
	public int size;
	
	public WebFont(String name, int style, int size) {
		this.name = name;
		this.style = style;
		this.size = size;
	}
	
	@Override
	public double getHeight() {
		return size;
	}

	@Override
	public double charWidth(char ch) {
		return stringWidth("" + ch);
	}

	@Override
	public double charsWidth(char[] ch, int offset, int length) {
		return stringWidth(new String(ch, offset, length));
	}

	@Override
	public double stringWidth(String str) {
		CanvasPainter.getInstance().setFont(this);
		return CanvasPainter.getInstance().context.measureText(str).getWidth();
	}

	@Override
	public double getBaselinePosition() {
		return 0;
	}
}
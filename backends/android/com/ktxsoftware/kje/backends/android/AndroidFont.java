package com.ktxsoftware.kje.backends.android;

import android.graphics.Paint;
import android.graphics.Typeface;

import com.ktxsoftware.kje.Font;

public class AndroidFont implements Font {
	public String name;
	public int style;
	public int size;
	private Paint paint;
	
	public AndroidFont(String name, int style, int size) {
		this.name = name;
		this.style = style;
		this.size = size;
		paint = new Paint();
		paint.setTypeface(Typeface.create(name, Typeface.NORMAL));
		paint.setTextSize(size);
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
		return paint.measureText(str);
	}

	@Override
	public double getBaselinePosition() {
		return 0;
	}
}
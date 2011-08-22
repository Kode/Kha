package com.ktx.kje.backends.android;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;

import com.ktx.kje.Font;
import com.ktx.kje.Image;
import com.ktx.kje.Painter;

public class CanvasPainter implements Painter {
	private Canvas c;
	private Paint paint;
	private double tx, ty;
	
	CanvasPainter(Canvas c) {
		this.c = c;
		paint = new Paint();
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		c.drawBitmap(((BitmapImage)img).getBitmap(), (float)(x + tx), (float)(y + ty), paint);
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		c.drawBitmap(((BitmapImage)img).getBitmap(),
				new Rect(round(sx), round(sy), round(sx + sw), round(sy + sh)),
				new Rect(round(tx + dx), round(ty + dy), round(tx + dx + dw), round(ty + dy + dh)), paint);
	}
	
	@Override
	public void setColor(int r, int g, int b) {
		paint.setColor(Color.argb(255, r, g, b));
	}

	@Override
	public void fillRect(double x, double y, double width, double height) {
		c.drawRect((float)(x + tx), (float)(y + ty), (float)(x + width + tx), (float)(y + width + ty), paint);
	}

	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}

	@Override
	public void drawRect(double x, double y, double width, double height) {
		c.drawRect((float)(x + tx), (float)(y + ty), (float)(x + width + tx), (float)(y + width + ty), paint);
	}

	@Override
	public void drawString(String text, double x, double y) {
		c.drawText(text, (float)(x + tx), (float)(y + ty), paint);
	}
	
	int round(double value) {
		return (int)Math.round(value);
	}

	@Override
	public void setFont(Font font) {
		paint.setTypeface(Typeface.create(((AndroidFont)font).name, Typeface.NORMAL));
	}

	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		drawString(new String(text, offset, length), x, y);
	}

	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		c.drawLine((float)(x1 + tx), (float)(y1 + ty), (float)(x2 + tx), (float)(y2 + ty), paint);
	}

	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		
	}
	
	@Override
	public void begin() {
		
	}
	
	@Override
	public void end() {
		
	}
}
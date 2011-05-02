package com.kontechs.kje.backends.android;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;

import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

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
	public void setFont(String name, int size) {
		paint.setTypeface(Typeface.create(name, Typeface.NORMAL));
	}

	@Override
	public void drawString(String text, double x, double y) {
		c.drawText(text, (float)x, (float)y, paint);
	}
	
	int round(double value) {
		return (int)Math.round(value);
	}
}
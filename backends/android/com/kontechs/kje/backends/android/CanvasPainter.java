package com.kontechs.kje.backends.android;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class CanvasPainter implements Painter {
	private Canvas c;
	private Paint paint;
	private int tx, ty;
	
	CanvasPainter(Canvas c) {
		this.c = c;
		paint = new Paint();
	}
	
	@Override
	public void drawImage(Image img, int x, int y) {
		c.drawBitmap(((BitmapImage)img).getBitmap(), x + tx, y + ty, paint);
	}
	
	@Override
	public void drawImage(Image img, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
		c.drawBitmap(((BitmapImage)img).getBitmap(), new Rect(sx, sy, sx + sw, sy + sh), new Rect(tx + dx, ty + dy, tx + dx + dw, ty + dy + dh), paint);
	}
	
	@Override
	public void setColor(int r, int g, int b) {
		paint.setColor(Color.argb(255, r, g, b));
	}

	@Override
	public void fillRect(int x, int y, int width, int height) {
		c.drawRect(x + tx, y + ty, x + width + tx, y + width + ty, paint);
	}

	@Override
	public void translate(int x, int y) {
		tx = x;
		ty = y;
	}
}
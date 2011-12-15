package com.ktxsoftware.kje.backends.android;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Typeface;

import com.ktxsoftware.kje.Font;
import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Painter;

public class CanvasPainter extends Painter {
	private Canvas c;
	private Paint paint;
	private double tx, ty;
	private int width, height;
	
	public CanvasPainter(Canvas c, int width, int height) {
		this.c = c;
		this.width = width;
		this.height = height;
		paint = new Paint();
		paint.setFilterBitmap(true);
	}
	
	private double getFactor() {
		if ((double)width / (double)height > (double)com.ktxsoftware.kje.Game.getInstance().getWidth() / (double)com.ktxsoftware.kje.Game.getInstance().getHeight())
			return (double)height / (double)com.ktxsoftware.kje.Game.getInstance().getHeight();
		else
			return (double)width / (double)com.ktxsoftware.kje.Game.getInstance().getWidth();
	}
	
	private double getXOffset() {
		if ((double)width / (double)height > (double)com.ktxsoftware.kje.Game.getInstance().getWidth() / (double)com.ktxsoftware.kje.Game.getInstance().getHeight())
			return width / 2 - com.ktxsoftware.kje.Game.getInstance().getWidth() * getFactor() / 2;
		else
			return 0;
	}
	
	private double getYOffset() {
		if ((double)width / (double)height > (double)com.ktxsoftware.kje.Game.getInstance().getWidth() / (double)com.ktxsoftware.kje.Game.getInstance().getHeight())
			return 0;
		else
			return height / 2 - com.ktxsoftware.kje.Game.getInstance().getHeight() * getFactor() / 2;
	}
	
	private double adjustX(double x) {
		return x * getFactor();
	}
	
	private double adjustY(double y) {
		return y * getFactor();
	}
	
	public double adjustXPos(double x) {
		return adjustX(x) + getXOffset();
	}
	
	public double adjustYPos(double y) {
		return adjustY(y) + getYOffset();
	}
	
	public double adjustXPosInv(double x) {
		return (x - getXOffset()) / getFactor();
	}
	
	public double adjustYPosInv(double y) {
		return (y - getYOffset()) / getFactor();
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		c.drawBitmap(((BitmapImage)img).getBitmap(), (float)adjustXPos(round(x + tx)), (float)adjustYPos(round(y + ty)), paint);
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		c.drawBitmap(((BitmapImage)img).getBitmap(),
				new Rect(round(sx), round(sy), round(sx + sw), round(sy + sh)),
				new RectF((float)adjustXPos(round(tx + dx)), (float)adjustYPos(round(ty + dy)), (float)adjustXPos(round(tx + dx + dw)), (float)adjustYPos(round(ty + dy + dh))), paint);
	}
	
	@Override
	public void setColor(int r, int g, int b) {
		paint.setColor(Color.argb(255, r, g, b));
	}

	@Override
	public void fillRect(double x, double y, double width, double height) {
		paint.setStyle(Paint.Style.FILL);
		c.drawRect((float)(adjustXPos(x + tx)), (float)(adjustYPos(y + ty)), (float)(adjustXPos(x + width + tx)), (float)(adjustYPos(y + width + ty)), paint);
	}

	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}

	@Override
	public void drawRect(double x, double y, double width, double height) {
		paint.setStyle(Paint.Style.STROKE);
		c.drawRect((float)(adjustXPos(x + tx)), (float)(adjustYPos(y + ty)), (float)(adjustXPos(x + width + tx)), (float)(adjustYPos(y + width + ty)), paint);
	}

	@Override
	public void drawString(String text, double x, double y) {
		c.drawText(text, (float)(adjustXPos(x + tx)), (float)(adjustYPos(y + ty)), paint);
	}
	
	int round(double value) {
		return (int)Math.round(value);
	}

	@Override
	public void setFont(Font font) {
		AndroidFont afont = (AndroidFont)font;
		paint.setTypeface(Typeface.create(afont.name, Typeface.NORMAL));
		paint.setTextSize((float)afont.size * (float)getFactor());
	}

	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		drawString(new String(text, offset, length), x, y);
	}

	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		c.drawLine((float)(adjustXPos(x1 + tx)), (float)(adjustYPos(y1 + ty)), (float)(adjustXPos(x2 + tx)), (float)(adjustYPos(y2 + ty)), paint);
	}

	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		
	}
	
	@Override
	public void clear() {
		paint.setStyle(Paint.Style.FILL);
		c.drawRect(0, 0, width, height, paint);
	}
	
	@Override
	public void begin() {
		
	}
	
	@Override
	public void end() {
		
	}
}
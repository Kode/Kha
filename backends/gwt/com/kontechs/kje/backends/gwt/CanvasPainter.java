package com.kontechs.kje.backends.gwt;

import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;

import com.kontechs.kje.Font;
import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class CanvasPainter implements Painter {
	private Context2d context;
	private double tx, ty;
	
	public CanvasPainter(Context2d context) {
		this.context = context;
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		context.drawImage(((WebImage)img).getIE(), tx + x, ty + y);
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		context.drawImage(((WebImage)img).getIE(), sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
	}
	
	@Override
	public void setColor(int r, int g, int b) {
		context.setStrokeStyle(CssColor.make(r, g, b));
		context.setFillStyle(CssColor.make(r, g, b));
	}
	
	@Override
	public void drawRect(double x, double y, double width, double height) {
		context.rect(tx + x, ty + y, width, height);
	}
	
	@Override
	public void fillRect(double x, double y, double width, double height) {
		context.fillRect(tx + x, ty + y, width, height);
	}

	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}

	@Override
	public void drawString(String text, double x, double y) {
		context.fillText(text, tx + x, ty + y);
	}

	@Override
	public void setFont(Font font) {
		context.setFont(((WebFont)font).name);
	}

	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		
	}

	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		context.moveTo(tx + x1, ty + y1);
		context.lineTo(tx + x2, ty + y2);
		context.moveTo(0, 0);
	}

	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		context.beginPath();
		
		context.closePath();
		context.fill();
	}
}
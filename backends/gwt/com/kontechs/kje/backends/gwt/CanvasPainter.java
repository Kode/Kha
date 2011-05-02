package com.kontechs.kje.backends.gwt;

import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;

import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class CanvasPainter implements Painter {
	private Context2d context;
	private int tx, ty;
	
	public CanvasPainter(Context2d context) {
		this.context = context;
	}
	
	public void drawImage(Image img, int x, int y) {
		if (((WebImage)img).getIE() != null) context.drawImage(((WebImage)img).getIE(), tx + x, ty + y);
	}
	
	public void drawImage(Image img, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
		if (((WebImage)img).getIE() != null) context.drawImage(((WebImage)img).getIE(), sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
	}
	
	public void setColor(int r, int g, int b) {
		context.setStrokeStyle(CssColor.make(r, g, b));
		context.setFillStyle(CssColor.make(r, g, b));
	}
	
	public void drawRect(int x, int y, int width, int height) {
		context.rect(tx + x, ty + y, width, height);
	}
	
	public void fillRect(int x, int y, int width, int height) {
		context.fillRect(tx + x, ty + y, width, height);
	}

	@Override
	public void translate(int x, int y) {
		tx = x;
		ty = y;
	}

	@Override
	public void setFont(String name, int size) {
		context.setFont(name);
	}

	@Override
	public void drawString(String text, int x, int y) {
		context.fillText(text, x, y);
	}
}
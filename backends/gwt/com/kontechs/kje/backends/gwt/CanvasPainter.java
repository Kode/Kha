package com.kontechs.kje.backends.gwt;

import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;

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
	public void setFont(String name, int size) {
		context.setFont(name);
	}

	@Override
	public void drawString(String text, double x, double y) {
		context.fillText(text, x, y);
	}
}
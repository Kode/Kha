package com.ktxsoftware.kje.backends.java;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;

import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Painter;

public class JavaPainter implements Painter {
	private Graphics2D g;
	private double tx, ty;

	public JavaPainter(Graphics2D g) {
		this.g = g;
		g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
	}
	
	private static int round(double value) {
		return (int)Math.round(value);
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		g.drawImage(((JavaImage)img).getImage(), round(tx + x), round(ty + y), null);
	}

	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		g.drawImage(((JavaImage)img).getImage(), round(tx + dx), round(ty + dy), round(tx + dx + dw), round(ty + dy + dh), round(sx), round(sy), round(sx + sw), round(sy + sh), null);
	}

	@Override
	public void setColor(int r, int g, int b) {
		this.g.setColor(new Color(r, g, b));
	}

	@Override
	public void drawRect(double x, double y, double width, double height) {
		g.drawRect(round(tx + x), round(ty + y), round(width), round(height));
	}
	
	@Override
	public void fillRect(double x, double y, double width, double height) {
		g.fillRect(round(tx + x), round(ty + y), round(width), round(height));	
	}
	
	@Override
	public void setFont(com.ktxsoftware.kje.Font font) {
		g.setFont(((JavaFont)font).getNativeFont());
	}
	
	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		g.drawChars(text, offset, length, round(tx + x), round(ty + y));
	}
	
	@Override
	public void drawString(String text, double x, double y) {
		g.drawString(text, round(tx + x), round(ty + y));
	}
	
	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		g.drawLine(round(tx + x1), round(ty + y1), round(tx + x2), round(ty + y2));
	}
	
	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		int[] xPoints = new int[]{round(tx + x1), round(tx + x2), round(tx + x3)};
		int[] yPoints = new int[]{round(ty + y1), round(ty + y2), round(ty + y3)};
		g.fillPolygon(xPoints, yPoints, 3);
	}
	
	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}
	
	@Override
	public void begin() {
		
	}
	
	@Override
	public void end() {
		
	}
}
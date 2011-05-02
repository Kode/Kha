package com.kontechs.kje.backends.java;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;

import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class GraphicsPainter implements Painter {
	private Graphics2D g;
	private double tx, ty;

	public GraphicsPainter(Graphics2D g) {
		this.g = g;
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
	public void setFont(String name, int size) {
		g.setFont(new Font(name, 0, size));
	}
	
	@Override
	public void drawString(String text, double x, double y) {
		g.drawString(text, round(tx + x), round(ty + y));
	}
	
	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}
}
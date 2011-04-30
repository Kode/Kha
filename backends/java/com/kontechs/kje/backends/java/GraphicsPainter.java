package com.kontechs.kje.backends.java;

import java.awt.Color;
import java.awt.Graphics2D;

import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class GraphicsPainter implements Painter {
	private Graphics2D g;
	private int tx, ty;

	public GraphicsPainter(Graphics2D g) {
		this.g = g;
	}
	
	@Override
	public void drawImage(Image img, int x, int y) {
		g.drawImage(((JavaImage)img).getImage(), tx + x, ty + y, null);
	}

	@Override
	public void drawImage(Image img, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
		g.drawImage(((JavaImage)img).getImage(), tx + dx, ty + dy, tx + dx + dw, ty + dy + dh, sx, sy, sx + sw, sy + sh, null);
	}

	@Override
	public void setColor(int r, int g, int b) {
		this.g.setColor(new Color(r, g, b));
	}

	@Override
	public void fillRect(int x, int y, int width, int height) {
		g.fillRect(tx + x, ty + y, width, height);	
	}
	
	public void translate(int x, int y) {
		tx = x;
		ty = y;
	}
}
package com.ktx.kje.backends.gwt;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.user.client.ui.AbsolutePanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.ktx.kje.Font;
import com.ktx.kje.Image;
import com.ktx.kje.Painter;

public class IE6Painter implements Painter {
	private double tx, ty;
	private List<com.google.gwt.user.client.ui.Image> images = new ArrayList<com.google.gwt.user.client.ui.Image>();
	private AbsolutePanel panel;
	
	public IE6Painter(FocusPanel panel, int width, int height) {
		this.panel = new AbsolutePanel();
		this.panel.setSize(Integer.toString(width), Integer.toString(height));
		panel.add(this.panel);
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		WebImage image = (WebImage)img;
		image.img.setVisible(true);
		panel.add(image.img, (int)(tx + x), (int)(ty + y));
		images.add(image.img);
	}

	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		WebImage image = (WebImage)img;
		image.img.setVisible(true);
		panel.add(image.img, (int)(tx + dx), (int)(ty + dy));
		images.add(image.img);
	}

	@Override
	public void setColor(int r, int g, int b) {
		
	}

	@Override
	public void drawRect(double x, double y, double width, double height) {
		
	}

	@Override
	public void fillRect(double x, double y, double width, double height) {
		
	}

	@Override
	public void setFont(Font font) {
		
	}

	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		
	}

	@Override
	public void drawString(String text, double x, double y) {
		
	}

	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		
	}

	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		
	}

	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}

	@Override
	public void begin() {
		for (com.google.gwt.user.client.ui.Image image : images) panel.remove(image);
		images.clear();
	}

	@Override
	public void end() {
		
	}
}
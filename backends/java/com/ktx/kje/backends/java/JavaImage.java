package com.ktx.kje.backends.java;

import java.awt.image.BufferedImage;

import com.ktx.kje.Image;

public class JavaImage implements Image {
	private BufferedImage image;
	
	public JavaImage(BufferedImage image) {
		this.image = image;
	}
	
	public java.awt.Image getImage() {
		return image;
	}
	
	@Override
	public int getWidth() {
		return image.getWidth(null);
	}

	@Override
	public int getHeight() {
		return image.getHeight(null);
	}
	
	@Override
	public boolean isAlpha(int x, int y) {
		if (x >= 0 && x < getWidth() && y >= 0 && y < getHeight()) {
			int argb = image.getRGB(x, y);
			return argb >> 24 != 0;
		}
		else return false;
	}
}
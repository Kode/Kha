package com.ktx.kje.backends.java;

import com.ktx.kje.Image;

public class JavaImage implements Image {
	private java.awt.Image image;
	
	public JavaImage(java.awt.Image image) {
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
}
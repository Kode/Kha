package com.kontechs.kje;

import java.awt.Graphics;

import javax.swing.JPanel;

import com.kontechs.kje.backends.java.JavaImage;

//TODO: Remove
public class BackgroundImage extends JPanel {
	private static final long serialVersionUID = 1L;
	private Image background_image;
	
	public BackgroundImage(Image background_image) {
		this.background_image = background_image;
		this.setBounds(0, 0, background_image.getWidth(), background_image.getHeight());
	}
	@Override
	public void paint(Graphics g) {
		super.paint(g);
		g.drawImage(((JavaImage) background_image).getImage(), 0, 0, null);
	}
	
	public void setBackgroundImage(Image background_image){
		this.background_image = background_image;
	}
}

package com.kontechs.kje.backends.gwt;

import com.google.gwt.dom.client.ImageElement;
import com.google.gwt.event.dom.client.LoadEvent;
import com.google.gwt.event.dom.client.LoadHandler;
import com.google.gwt.user.client.ui.RootPanel;

import com.kontechs.kje.Image;

public class WebImage implements Image, LoadHandler {
	private com.google.gwt.user.client.ui.Image img;
	private ImageElement ie;
	private int width, height;
	
	public WebImage(String filename) {
		if (filename == "tiles") {
			width = 448;
			height = 320;
		}
		else if (filename == "koopa") {
			width = 512;
			height = 48;
		}
		else if (filename == "jumpman") {
			width = 768;
			height = 256;
		}
		else if (filename == "gumba") {
			width = 96;
			height = 32;
		}
		else if (filename == "fly") {
			width = 384;
			height = 56;
		}
		else if (filename == "coin") {
			width = 28;
			height = 32;
		}
		else if (filename == "bonusblock") {
			width = 64;
			height = 32;
		}
		else if (filename == "blockcoin") {
			width = 16;
			height = 32;
		}
		else if (filename == "zoool") {
			width = 2352;
			height = 78;
		}
		img = new com.google.gwt.user.client.ui.Image(filename + ".png");
		img.addLoadHandler(this);
		img.setVisible(false);
	    RootPanel.get().add(img); // image must be on page to fire load
	}
	
	public void onLoad(LoadEvent event) {
		ie = (ImageElement) img.getElement().cast();
	}
	
	public ImageElement getIE() {
		return ie;
	}

	@Override
	public int getWidth() {
		return width;
		//if (ie == null || ie.getWidth() == 0) return width; //ie.getWidth returns 0 in IE9
		//return ie.getWidth();
	}

	@Override
	public int getHeight() {
		return height;
		//if (ie == null || ie.getHeight() == 0) return height;
		//return ie.getHeight();
	}
}
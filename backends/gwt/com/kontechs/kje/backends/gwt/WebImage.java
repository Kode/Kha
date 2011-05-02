package com.kontechs.kje.backends.gwt;

import com.google.gwt.dom.client.ImageElement;
import com.google.gwt.event.dom.client.LoadEvent;
import com.google.gwt.event.dom.client.LoadHandler;
import com.google.gwt.user.client.ui.RootPanel;

import com.kontechs.kje.Image;

public class WebImage implements Image {//, LoadHandler {
	//private com.google.gwt.user.client.ui.Image img;
	private ImageElement ie;
	//private int width, height;
	
	public WebImage(ImageElement ie) {//String filename) {
		this.ie = ie;
		/*if (filename.equals("tiles")) {
			width = 1024;//448;
			height = 640;//320;
		}
		else if (filename.equals("koopa")) {
			width = 512;
			height = 48;
		}
		else if (filename.equals("jumpman")) {
			width = 768;
			height = 256;
		}
		else if (filename.equals("gumba")) {
			width = 96;
			height = 32;
		}
		else if (filename.equals("fly")) {
			width = 384;
			height = 56;
		}
		else if (filename.equals("coin")) {
			width = 28;
			height = 32;
		}
		else if (filename.equals("bonusblock")) {
			width = 64;
			height = 32;
		}
		else if (filename.equals("blockcoin")) {
			width = 16;
			height = 32;
		}
		else if (filename.equals("zoool")) {
			width = 2352;
			height = 78;
		}
		else if (filename.equals("beaver") || filename.equals("beaver_Winter")) {
			width = 780;
			height = 256;
		}
		else if (filename.equals("status_line")) {
			width = 640;
			height = 42;
		}
		else if (filename.equals("heart")) {
			width = 15;
			height = 10;
		}
		else if (filename.equals("WoodCoin")) {
			width = 64;
			height = 32;
		}
		else if (filename.equals("branch") || filename.equals("branch_Winter")) {
			width = 192;
			height = 32;
		}
		else if (filename.equals("bursting_branch") || filename.equals("bursting_branch_winter")) {
			width = 768;
			height = 32;
		}
		else if (filename.equals("hole")) {
			width = 64;
			height = 64;
		}
		else if (filename.equals("dackel_sheet")) {
			width = 1024;
			height = 256;
		}
		else if (filename.equals("woodTrap") || filename.equals("woodTrapWinter")) {
			width = 96;
			height = 32;
		}
		else if (filename.equals("bear_trap")) {
			width = 96;
			height = 32;
		}
		else if (filename.equals("WoodCoinGold")) {
			width = 64;
			height = 32;
		}
		else if (filename.equals("treeBark") || filename.equals("treeBarkWinter")) {
			width = 128;
			height = 32;
		}
		else if (filename.equals("treeHole") || filename.equals("treeHoleWinter")) {
			width = 128;
			height = 32;
		}
		else if (filename.equals("waterTilesheet") || filename.equals("waterTilesheetWinter")) {
			width = 192;
			height = 64;
		}
		else if (filename.equals("jaeger_spriteSheet") || filename.equals("jaeger_winter_spriteSheet")) {
			width = 1024;
			height = 64;
		}
		else if (filename.equals("bagger_spriteSheet")) {
			width = 4096;
			height = 128;
		}
		else if (filename.equals("gewehrkugel")) {
			width = 5;
			height = 5;
		}
		else {
			System.err.println("Unknown image: " + filename);
		}
		img = new com.google.gwt.user.client.ui.Image(filename + ".png");
		img.addLoadHandler(this);
		img.setVisible(false);
	    RootPanel.get().add(img); // image must be on page to fire load*/
	}
	
	//public void onLoad(LoadEvent event) {
	//	ie = (ImageElement) img.getElement().cast();
	//}
	
	public ImageElement getIE() {
		return ie;
	}

	@Override
	public int getWidth() {
		//return width;
		//if (ie == null || ie.getWidth() == 0) return width; //ie.getWidth returns 0 in IE9
		return ie.getWidth();
	}

	@Override
	public int getHeight() {
		//return height;
		//if (ie == null || ie.getHeight() == 0) return height;
		return ie.getHeight();
	}
}
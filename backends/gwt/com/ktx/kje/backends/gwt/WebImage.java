package com.ktx.kje.backends.gwt;

import com.google.gwt.canvas.client.Canvas;
import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;
import com.google.gwt.canvas.dom.client.ImageData;
import com.google.gwt.dom.client.ImageElement;
import com.googlecode.gwtgl.binding.WebGLTexture;
import com.ktx.kje.Image;

public class WebImage implements Image {
	private ImageElement ie;
	private ImageData data;
	private int width, height;
	private String name;
	
	public com.google.gwt.user.client.ui.Image img;
	public WebGLTexture tex;
	
	private static Context2d context;
	
	static {
		Canvas canvasTmp = Canvas.createIfSupported();
	    context = canvasTmp.getContext2d();
	    canvasTmp.setCoordinateSpaceHeight(2048);
	    canvasTmp.setCoordinateSpaceWidth(2048);
	}
	
	//ie.getWidth returns 0 in IE9
	@SuppressWarnings("unused")
	private void IE9Hack() {
		if (width != 0 && height != 0) return;
		
		if (name.equals("tiles")) {
			width = 1024;
			height = 640;
		}
		else if (name.equals("sml_tiles")) {
			width = 448;
			height = 320;
		}
		else if (name.equals("koopa")) {
			width = 512;
			height = 48;
		}
		else if (name.equals("jumpman")) {
			width = 768;
			height = 256;
		}
		else if (name.equals("gumba")) {
			width = 96;
			height = 32;
		}
		else if (name.equals("fly")) {
			width = 384;
			height = 56;
		}
		else if (name.equals("coin")) {
			width = 28;
			height = 32;
		}
		else if (name.equals("bonusblock")) {
			width = 64;
			height = 32;
		}
		else if (name.equals("blockcoin")) {
			width = 16;
			height = 32;
		}
		else if (name.equals("zoool")) {
			width = 2352;
			height = 78;
		}
		else if (name.equals("beaver") || name.equals("beaver_Winter")) {
			width = 780;
			height = 256;
		}
		else if (name.equals("status_line")) {
			width = 640;
			height = 42;
		}
		else if (name.equals("heart")) {
			width = 15;
			height = 10;
		}
		else if (name.equals("WoodCoin")) {
			width = 64;
			height = 32;
		}
		else if (name.equals("branch") || name.equals("branch_Winter")) {
			width = 192;
			height = 32;
		}
		else if (name.equals("bursting_branch") || name.equals("bursting_branch_winter")) {
			width = 768;
			height = 32;
		}
		else if (name.equals("hole")) {
			width = 64;
			height = 64;
		}
		else if (name.equals("dackel_sheet")) {
			width = 1024;
			height = 256;
		}
		else if (name.equals("woodTrap") || name.equals("woodTrapWinter")) {
			width = 96;
			height = 32;
		}
		else if (name.equals("bear_trap")) {
			width = 96;
			height = 32;
		}
		else if (name.equals("WoodCoinGold")) {
			width = 64;
			height = 32;
		}
		else if (name.equals("treeBark") || name.equals("treeBarkWinter")) {
			width = 128;
			height = 32;
		}
		else if (name.equals("treeHole") || name.equals("treeHoleWinter")) {
			width = 128;
			height = 32;
		}
		else if (name.equals("waterTilesheet") || name.equals("waterTilesheetWinter")) {
			width = 192;
			height = 64;
		}
		else if (name.equals("jaeger_spriteSheet") || name.equals("jaeger_winter_spriteSheet")) {
			width = 1024;
			height = 64;
		}
		else if (name.equals("bagger_spriteSheet")) {
			width = 4096;
			height = 128;
		}
		else if (name.equals("gewehrkugel")) {
			width = 5;
			height = 5;
		}
		else {
			System.err.println("Unknown image: " + name);
		}
	}
	
	public WebImage(String name, com.google.gwt.user.client.ui.Image img) {
		this.name = name;
		this.img = img;
		this.ie = (ImageElement) img.getElement().cast();
		width = ie.getWidth();
		height = ie.getHeight();
		
		context.setStrokeStyle(CssColor.make(255, 255, 0));
		context.setFillStyle(CssColor.make(255, 255, 0));
		context.fillRect(0, 0, width, height);
		context.drawImage(ie, 0, 0, width, height, 0, 0, width, height);
		data = context.getImageData(0, 0, width, height);
		//IE9Hack();
	}
	
	public ImageElement getIE() {
		return ie;
	}

	@Override
	public int getWidth() {
		return width;
	}

	@Override
	public int getHeight() {
		return height;
	}

	@Override
	public boolean isAlpha(int x, int y) {
		return !(data.getRedAt(x, y) == 255 && data.getGreenAt(x, y) == 255);
	}
}
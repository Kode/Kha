package com.ktx.kje.backends.gwt;

import java.util.HashMap;
import java.util.Map;

import com.google.gwt.canvas.client.Canvas;
import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;
import com.google.gwt.canvas.dom.client.ImageData;
import com.google.gwt.dom.client.ImageElement;
import com.googlecode.gwtgl.binding.WebGLTexture;
import com.ktx.kje.Image;
import com.ktx.kje.xml.Node;

class ImageInfo {
	int width, height;
	
	ImageInfo(int width, int height) {
		this.width = width;
		this.height = height;
	}
}

public class WebImage implements Image {
	private ImageElement ie;
	private ImageData data;
	private int width, height;
	private static Map<String, ImageInfo> infos;
	
	public com.google.gwt.user.client.ui.Image img;
	public WebGLTexture tex;
	
	private static Context2d context;
	
	public static void init(Node node) {
		Canvas canvasTmp = Canvas.createIfSupported();
		context = canvasTmp.getContext2d();
		canvasTmp.setCoordinateSpaceHeight(2048);
		canvasTmp.setCoordinateSpaceWidth(2048);

		infos = new HashMap<String, ImageInfo>();
		node.require("images");
		for (Node n : node.getChilds()) {
			n.require("image");
			infos.put(n.getAttribute("name"), new ImageInfo(Integer.parseInt(n.getAttribute("width")), Integer.parseInt(n.getAttribute("height"))));
		}
	}
		
	public WebImage(String name, com.google.gwt.user.client.ui.Image img) {
		this.img = img;
		this.ie = (ImageElement) img.getElement().cast();
		width = infos.get(name).width; //ie.getWidth(); //ie.getWidth returns 0 in IE9
		height = infos.get(name).height; //ie.getHeight();
		
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
package kha.js;
import kha.Color;

class CSSPainter extends Painter {
	var tx : Float;
	var ty : Float;
	var images : Array<js.Image> = new Array<js.Image>();
	var panel : Dynamic; //AbsolutePanel;
	
	public function new(/*FocusPanel panel,*/ width : Int, height : Int) {
		//this.panel = new AbsolutePanel();
		//this.panel.setSize(Integer.toString(width), Integer.toString(height));
		//panel.add(this.panel);
	}
	
	override public function drawImage(img : Image, x : Float, y : Float) {
		var image = cast(img, Image).image;
		if (images.contains(image)) image = new js.Image(image.getUrl());
		image.setVisible(true);
		image.setWidth(Integer.toString(img.getWidth()));
		image.setHeight(Integer.toString(img.getHeight()));
		//if (Game_gwt.isIE6()) addAlpha(image.getElement(), image.getUrl());
		panel.add(image, (int)(tx + x), (int)(ty + y));
		images.add(image);
	}

	override public function drawImage(img : Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		var image = cast(img, Image).image;
		if (images.contains(image)) image = new js.Image(image.getUrl());
		image.setVisible(true);
		image.setWidth(Integer.toString((int)dw));
		image.setHeight(Integer.toString((int)dh));
		//if (Game_gwt.isIE6()) addAlpha(image.getElement(), image.getUrl());
		panel.add(image, (int)(tx + dx), (int)(ty + dy));
		images.add(image);
	}
	
	//public static native void addAlpha(Element image, String url) /*-{
	//	image.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + url + "')";
	//}-*/;

	override public function setColor(color: Color) {
		
	}

	override public function drawRect(x : Float, y : Float, width : Float, height : Float) {
		
	}

	override public function fillRect(x : Float, y : Float, width : Float, height : Float) {
		
	}

	override public function setFont(font : com.ktxsoftware.kha.Font) {
		
	}

	override public function drawString(text : String, x : Float, y : Float) {
		
	}

	override public function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) {
		
	}

	override public function fillTriangle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) {
		
	}

	override public function begin() {
		for (com.google.gwt.user.client.ui.Image image : images) panel.remove(image);
		images.clear();
	}

	override public function end() {
		
	}
}
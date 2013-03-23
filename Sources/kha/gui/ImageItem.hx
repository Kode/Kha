package kha.gui;

import kha.Color;
import kha.Image;
import kha.Painter;

class ImageItem extends Item {
	public function new(img: Image = null) {
		super();
		this.img = img;
		myColor = Color.fromBytes(0xff, 0xff, 0xff);
	}
	
	public var img: Image;
	
	public var myColor: Color;
	
	public var opacity: Float = 1;
	
	public var scaleX: Float = 1;
	
	public var scaleY: Float = 1;

	override public function render(painter: Painter): Void {
		if (img == null) return;
		//painter.setOpacity(opacity);
		painter.drawImage2(img, 0, 0, img.getWidth(), img.getHeight(), 0, 0, scaleX * img.getWidth(), scaleY * img.getHeight()); //, myColor
	}
	
	override private function getWidth(): Float {
		return img.getWidth() * scaleX;
	}
	
	override private function getHeight(): Float {
		return img.getHeight() * scaleY;
	}
}
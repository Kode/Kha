package kha.java;
import kha.Image;

@:classContents('
	public java.awt.Graphics2D graphics;
	
	private static int round(double value) {
		return (int)Math.round(value);
	}
')
class Painter extends kha.Painter {
	var tx : Float;
	var ty : Float;
	
	public function new() {

	}
	
	override public function translate(x : Float, y : Float) : Void {
		this.tx = x;
		this.ty = y;
	}
	
	@:functionBody('
		graphics.drawImage(((kha.java.Image)img).image, round(tx + x), round(ty + y), null);
	')
	override public function drawImage(img : Image, x : Float, y : Float) : Void {
		
	}
	
	@:functionBody('
		graphics.drawImage(((kha.java.Image)image).image, round(tx + dx), round(ty + dy), round(tx + dx + dw), round(ty + dy + dh), round(sx), round(sy), round(sx + sw), round(sy + sh), null);
	')
	override public function drawImage2(image : Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		
	}
}
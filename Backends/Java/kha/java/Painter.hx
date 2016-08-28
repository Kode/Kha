package kha.java;

import kha.Color;
import kha.Font;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.Matrix3;
import kha.Rotation;
import kha.graphics2.Style;

@:classCode('
	public java.awt.Graphics2D graphics;
	
	private static int round(double value) {
		return (int)Math.round(value);
	}
')
class Painter extends kha.graphics2.Graphics {
	var tx: Float = 0;
	var ty: Float = 0;
	private var myColor: Color;
	private var myFont: Font;
	
	public function new() {
		super();
	}
	
	@:functionCode('
		graphics.setBackground(new java.awt.Color(color));
		graphics.clearRect(0, 0, 2048, 2048);
	')
	private function clear2(color: Int): Void {
		
	}
	
	override public function clear(color: Color = null): Void {
		clear2(color != null ? color.value : Color.Black.value);
	}
	
	@:functionCode('
		graphics.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION, java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR);
	')
	function setRenderHint(): Void {
		
	}
	
	@:functionCode('
		graphics.drawImage(img.image, round(tx + x), round(ty + y), null);
	')
	override public function image(img: Image, x: Float, y: Float, ?style:Style): Void {
		
	}
	
	@:functionCode('
		graphics.drawImage(image.image, round(tx + x), round(ty + y), round(tx + x + finalWidth), round(ty + y + finalHeight), round(left), round(top), round(left + width), round(top + height), null);
	')
	override public function scaledSubImage(image: Image, x: Float, y: Float, left: Float, top: Float, width: Float, height: Float, finalWidth: Float, finalHeight: Float, ?style: Style): Void {
		
	}
	
	/*override public function get_color(): kha.Color {
		return myColor;
	}
	
	@:functionCode('
		graphics.setColor(new java.awt.Color(color));
	')
	private function setColorInternal(color: kha.Color): Void {
		
	}
	
	override public function set_color(color: kha.Color): kha.Color {
		setColorInternal(color);
		return myColor = color;
	}*/
	
	@:functionCode('
		java.awt.Stroke oldStroke = graphics.getStroke();
		graphics.setStroke(new java.awt.BasicStroke((float)style.strokeWeight));
		graphics.drawRect(round(tx + x), round(ty + y), round(width), round(height));
		graphics.setStroke(oldStroke);
	')
	private function drawRect2(x: Float, y: Float, width: Float, height: Float, style:Style): Void {
		
	}
	
	override public function rect(x: Float, y: Float, width: Float, height: Float, ?style:Style): Void {
		drawRect2(x, y, width, height, style);
	}
	
	/*@:functionCode('
		graphics.fillRect(round(tx + x), round(ty + y), round(width), round(height));
	')
	override public function fillRect(x: Float, y: Float, width: Float, height: Float) : Void {

	}*/
	
	@:functionCode('
		graphics.setFont(((kha.java.Font)font).font);
	')
	private function setFontInternal(font: Font): Void {
		
	}
	
	/*override public function get_font(): kha.Font {
		return myFont;
	}
	
	override public function set_font(font: kha.Font): kha.Font {
		setFontInternal(font);
		return myFont = font;
	}*/
	
	@:functionCode('
		graphics.drawString(text, round(tx + x), round(ty + y));
	')
	override public function text(text: String, x: Float, y: Float, ?stlye:Style): Void {
		
	}
	
	@:functionCode('
		java.awt.Stroke oldStroke = graphics.getStroke();
		graphics.setStroke(new java.awt.BasicStroke((Float)style.strokeWeight));
		graphics.drawLine(round(tx + x1), round(ty + y1), round(tx + x2), round(ty + y2));
		graphics.setStroke(oldStroke);
	')
	override public function line(x1: Float, y1: Float, x2: Float, y2: Float, ?style:Style): Void {

	}
	
	@:functionCode('
		int[] xPoints = new int[]{round(tx + x1), round(tx + x2), round(tx + x3)};
		int[] yPoints = new int[]{round(ty + y1), round(ty + y2), round(ty + y3)};
		graphics.fillPolygon(xPoints, yPoints, 3);
	')
	override public function triangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, ?style:Style): Void {
		
	}
	
	@:functionCode('
		graphics.setTransform(new java.awt.geom.AffineTransform(
			((Number)transformation._00).floatValue(), ((Number)transformation._01).floatValue(), ((Number)transformation._10).floatValue(),
			((Number)transformation._11).floatValue(), ((Number)transformation._20).floatValue(), ((Number)transformation._21).floatValue()));
	')
	override function setTransform(transformation: FastMatrix3): Void {
		
	}
}

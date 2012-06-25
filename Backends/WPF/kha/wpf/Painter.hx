package kha.wpf;

import system.windows.media.Color;
import system.windows.media.DrawingContext;

class Painter extends kha.Painter {
	public var context : DrawingContext;
	var color : Color;
	var font : Font;

	public function new() {
		font = new Font("Arial", kha.FontStyle.PLAIN, 20);
	}

	@:functionBody('
		var img = (Image)image;
		context.DrawImage(img.image, new System.Windows.Rect(dx, dy, dw, dh));
	')
	override public function drawImage2(image : kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		
	}

	@:functionBody('
		context.DrawText(
			new System.Windows.Media.FormattedText(text, 
				System.Globalization.CultureInfo.GetCultureInfo("en-us"), System.Windows.FlowDirection.LeftToRight,
				new System.Windows.Media.Typeface(font.name), font.size, new System.Windows.Media.SolidColorBrush(color)),
				new System.Windows.Point(x, y));
	')
	override public function drawString(text : String, x : Float, y : Float) : Void {
		
	}

	override public function setFont(font : kha.Font) : Void {
		this.font = cast(font, Font);
	}

	@:functionBody('
		color = System.Windows.Media.Color.FromRgb((byte)r, (byte)g, (byte)b);
	')
	override public function setColor(r : Int, g : Int, b : Int) : Void {
		
	}

	@:functionBody('
		context.DrawRectangle(null, new System.Windows.Media.Pen(new System.Windows.Media.SolidColorBrush(color), 1), new System.Windows.Rect(x, y, width, height));
	')
	override public function drawRect(x : Float, y : Float, width : Float, height : Float) : Void {
		
	}

	@:functionBody('
		context.DrawRectangle(new System.Windows.Media.SolidColorBrush(color), new System.Windows.Media.Pen(), new System.Windows.Rect(x, y, width, height));
	')
	override public function fillRect(x : Float, y : Float, width : Float, height : Float) : Void {
		
	}
	
	@:functionBody('
	context.DrawLine(new System.Windows.Media.Pen(new System.Windows.Media.SolidColorBrush(color), 1), new System.Windows.Point(x1, y1), new System.Windows.Point(x2, y2));
	')
	override function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void {
		
	}
}
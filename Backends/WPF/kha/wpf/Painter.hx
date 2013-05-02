package kha.wpf;

import kha.Animation;
import kha.FontStyle;
import system.windows.media.Color;
import system.windows.media.DrawingContext;

class Painter extends kha.Painter {
	public var context : DrawingContext;
	var color : Color;
	var font : Font;

	public function new() {
		font = new Font("Arial", new FontStyle(false, false, false), 20);
	}

	@:functionCode('
		var img = (Image)image;
		context.DrawImage(img.image, new System.Windows.Rect(dx, dy, dw, dh));
	')
	override public function drawImage2(image : kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		
	}

	@:functionCode('
		if (text != null) {
			text.Replace(\' \', (char)160); // Non-breaking space 
			System.Windows.Media.FormattedText fText = new System.Windows.Media.FormattedText(text, 
				System.Globalization.CultureInfo.GetCultureInfo("en-us"), System.Windows.FlowDirection.LeftToRight,
				new System.Windows.Media.Typeface(font.name), font.size, new System.Windows.Media.SolidColorBrush(color));
			if (font.style.getBold()) fText.SetFontWeight(System.Windows.FontWeights.Bold);
			if (font.style.getItalic()) fText.SetFontStyle(System.Windows.FontStyles.Italic);
			if (font.style.getUnderlined()) fText.SetTextDecorations(System.Windows.TextDecorations.Underline);
			context.DrawText(fText, new System.Windows.Point(x, y));
		}
	')
	override public function drawString(text : String, x : Float, y : Float) : Void {
		
	}

	override public function setFont(font : kha.Font) : Void {
		this.font = cast(font, Font);
	}

	@:functionCode('
		color = System.Windows.Media.Color.FromRgb((byte)r, (byte)g, (byte)b);
	')
	override public function setColor(r : Int, g : Int, b : Int) : Void {
		
	}

	@:functionCode('
		context.DrawRectangle(null, new System.Windows.Media.Pen(new System.Windows.Media.SolidColorBrush(color), 1), new System.Windows.Rect(x, y, width, height));
	')
	override public function drawRect(x : Float, y : Float, width : Float, height : Float) : Void {
		
	}

	@:functionCode('
		context.DrawRectangle(new System.Windows.Media.SolidColorBrush(color), new System.Windows.Media.Pen(), new System.Windows.Rect(x, y, width, height));
	')
	override public function fillRect(x : Float, y : Float, width : Float, height : Float) : Void {
		
	}
	
	@:functionCode('
		context.DrawLine(new System.Windows.Media.Pen(new System.Windows.Media.SolidColorBrush(color), 1), new System.Windows.Point(x1, y1), new System.Windows.Point(x2, y2));
	')
	override function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void {
		
	}
		
	@:functionCode('
	context.DrawVideo(((Video)video).getPlayer(), new System.Windows.Rect(x, y, width, height));
	')
	override function drawVideo(video : kha.Video, x : Float, y : Float, width : Float, height : Float) : Void {

	}
}
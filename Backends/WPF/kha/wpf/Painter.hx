package kha.wpf;

import kha.FontStyle;
import kha.Image;
import kha.Kravur;
import kha.math.FastMatrix3;
import kha.math.Matrix3;
import kha.Rotation;
import system.windows.media.Color;
import system.windows.media.DrawingContext;
import system.windows.media.DrawingVisual;
import system.windows.media.imaging.BitmapSource;
import system.windows.media.ImageBrush;
import system.windows.media.MatrixTransform;
import kha.graphics2.Style;

class Painter extends kha.graphics2.Graphics {
	public var context: DrawingContext;
	public var visual: DrawingVisual;
	public var imageSource: BitmapSource;
	private var myColor: Color;
	private var myKhaColor: kha.Color;
	private var myFont: Kravur;
	private var tx: Float;
	private var ty: Float;
	public var width: Int;
	public var height: Int;
	private static var garbageCounter: Int = 0;

	public function new(width: Int, height: Int) {
		super();
		this.width = width;
		this.height = height;
		tx = 0;
		ty = 0;
	}
	
	override public function begin(clear: Bool = true, clearColor: kha.Color = null): Void {
		if (visual != null) context = visual.RenderOpen();
		context.PushTransform(new MatrixTransform(transform._00, transform._01, transform._10, transform._11, transform._20, transform._21));
		if (clear) this.clear(clearColor);
	}
	
	override public function clear(color: kha.Color = null): Void {
		var style = new Style();
		style.fillColor = color;

		if (color == null)
			style.fillColor = this.style.fillColor;
		
		rect(0, 0, width, height, style);
	}
	
	@:functionCode('
		if (visual != null) {
			context.Close();
			((global::System.Windows.Media.Imaging.RenderTargetBitmap) imageSource).Render(visual);
			++garbageCounter;
			if (garbageCounter > 30) {
				global::System.GC.Collect(); // Because rendering into an image is a really really bad thing in WPF
			}
		}
	')
	override public function end(): Void {
		
	}
	
	private function apply(style: Style) {
		if (style == null)
			style = this.style;
		
		setColorInternal(style.fillColor.Ab, style.fillColor.Rb, style.fillColor.Gb, style.fillColor.Bb);

		return style;
	}

	override public function setTransform(transformation: FastMatrix3): Void {
		context.Pop();
		context.PushTransform(new MatrixTransform(transformation._00, transformation._01, transformation._10, transformation._11, transformation._20, transformation._21));
	}

	@:functionCode('
		apply(this.style);
		var img = (Image)imageSource;
		context.DrawImage(img.image, new global::System.Windows.Rect(tx + x, ty + y, img.get_width(), img.get_height()));
	')
	override public function image(image: Image, x: Float, y: Float, ?style: Style): Void {
	}

	@:functionCode('
		var img = (Image)imageSource;
		//var cropped = new System.Windows.Media.Imaging.CroppedBitmap(img.image, new System.Windows.Int32Rect((int)sx, (int)sy, (int)sw, (int)sh));
		//context.DrawImage(cropped, new System.Windows.Rect(tx + dx, ty + dy, dw, dh)); //super slow
		img.brush.Viewbox = new global::System.Windows.Rect(sx / img.get_width(), sy / img.get_height(), sw / img.get_width(), sh / img.get_height());
		context.DrawRectangle(img.brush, null, new global::System.Windows.Rect(tx + dx, ty + dy, dw, dh));
	')
	override public function scaledSubImage(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, ?style: Style): Void {
		
	}

	/*@:functionCode('
		if (text != null) {
			text.Replace(\' \', (char)160); // Non-breaking space 
			System.Windows.Media.FormattedText fText = new System.Windows.Media.FormattedText(text, 
				System.Globalization.CultureInfo.GetCultureInfo("en-us"), System.Windows.FlowDirection.LeftToRight,
				new System.Windows.Media.Typeface(font.get_name()), font.get_size(), new System.Windows.Media.SolidColorBrush(color));
			if (font.get_style().getBold()) fText.SetFontWeight(System.Windows.FontWeights.Bold);
			if (font.get_style().getItalic()) fText.SetFontStyle(System.Windows.FontStyles.Italic);
			if (font.get_style().getUnderlined()) fText.SetTextDecorations(System.Windows.TextDecorations.Underline);
			context.DrawText(fText, new System.Windows.Point(tx + x, ty + y));
		}
	')
	override public function drawString(text : String, x : Float, y : Float) : Void {
		
	}*/
	
	@:functionCode('
		style = apply(style);
		var img = (Image)myFont._get(myFontSize, null).getTexture();
		var xpos = tx + x;
		var ypos = ty + y;
		for (int i = 0; i < text.Length; ++i) {
			var q = myFont._get(myFontSize, null).getBakedQuad(text[i] - 32, xpos, ypos);
			if (q != null) {
				var brush = new global::System.Windows.Media.ImageBrush(img.image);
				brush.Viewbox = new global::System.Windows.Rect(q.s0, q.t0, q.s1 - q.s0, q.t1 - q.t0);
				context.PushOpacityMask(brush);
				context.DrawRectangle(new global::System.Windows.Media.SolidColorBrush(style.fillColor), null, new global::System.Windows.Rect(q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0));
				context.Pop();
				xpos += q.xadvance;
			}
		}
	')
	override public function text(text: String, x: Float, y: Float, ?style: Style): Void {
		
	}
	
	@:functionCode('
		myColor = global::System.Windows.Media.Color.FromArgb((byte)a, (byte)r, (byte)g, (byte)b);
	')
	private function setColorInternal(a: Int, r: Int, g: Int, b: Int): Void {
		
	}

	@:functionCode('
		if (width < 0.0) {
			x += width;
			width = -width;
		}
		if (height < 0.0) {
			y += height;
			height = -height;
		}
		style = apply(this.style);
		context.DrawRectangle(new global::System.Windows.Media.SolidColorBrush(style.fillColor), new global::System.Windows.Media.Pen(), new global::System.Windows.Rect(tx + x, ty + y, width, height));
	')
	override public function rect(x: Float, y: Float, width: Float, height: Float, ?style: Style): Void {
		
	}
	
	@:functionCode('
		style = apply(this.style);
		context.DrawLine(new global::System.Windows.Media.Pen(new global::System.Windows.Media.SolidColorBrush(style.fillColor), 1), new global::System.Windows.Point(tx + x1, ty + y1), new global::System.Windows.Point(tx + x2, ty + y2));
	')
	override function line(x1: Float, y1: Float, x2: Float, y2: Float, ?style: Style): Void {
		
	}
		
	@:functionCode('
		context.DrawVideo(((Video)video).getPlayer(), new global::System.Windows.Rect(tx + x, ty + y, width, height));
	')
	override function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float, ?style: Style): Void {

	}
}

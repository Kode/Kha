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

class Painter extends kha.graphics2.Graphics {
	public var context: DrawingContext;
	public var visual: DrawingVisual;
	public var image: BitmapSource;
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
		//font = new Font("Arial", new FontStyle(false, false, false), 20);
	}
	
	override public function begin(clear: Bool = true, clearColor: kha.Color = null): Void {
		if (visual != null) context = visual.RenderOpen();
		context.PushTransform(new MatrixTransform(transformation._00, transformation._01, transformation._10, transformation._11, transformation._20, transformation._21));
		if (clear) this.clear(clearColor);
	}
	
	override public function clear(color: kha.Color = null): Void {
		var prevColor = myKhaColor;
		this.color = color == null ? Color.Black : color;
		fillRect(0, 0, width, height);
		this.color = prevColor;
	}
	
	@:functionCode('
		if (visual != null) {
			context.Close();
			((global::System.Windows.Media.Imaging.RenderTargetBitmap) image).Render(visual);
			++garbageCounter;
			if (garbageCounter > 30) {
				global::System.GC.Collect(); // Because rendering into an image is a really really bad thing in WPF
			}
		}
	')
	override public function end(): Void {
		
	}
	
	override public function setTransformation(transformation: FastMatrix3): Void {
		context.Pop();
		context.PushTransform(new MatrixTransform(transformation._00, transformation._01, transformation._10, transformation._11, transformation._20, transformation._21));
	}

	@:functionCode('
		var img = (Image)image;
		context.DrawImage(img.image, new global::System.Windows.Rect(tx + x, ty + y, img.get_width(), img.get_height()));
	')
	override public function drawImage(image: Image, x: Float, y: Float): Void {

	}

	@:functionCode('
		var img = (Image)image;
		//var cropped = new System.Windows.Media.Imaging.CroppedBitmap(img.image, new System.Windows.Int32Rect((int)sx, (int)sy, (int)sw, (int)sh));
		//context.DrawImage(cropped, new System.Windows.Rect(tx + dx, ty + dy, dw, dh)); //super slow
		img.brush.Viewbox = new global::System.Windows.Rect(sx / img.get_width(), sy / img.get_height(), sw / img.get_width(), sh / img.get_height());
		context.DrawRectangle(img.brush, null, new global::System.Windows.Rect(tx + dx, ty + dy, dw, dh));
	')
	override public function drawScaledSubImage(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float): Void {
		
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
		var img = (Image)myFont._get(myFontSize).getTexture();
		var xpos = tx + x;
		var ypos = ty + y;
		for (int i = 0; i < text.Length; ++i) {
			var q = myFont._get(myFontSize).getBakedQuad(text[i] - 32, xpos, ypos);
			if (q != null) {
				var brush = new global::System.Windows.Media.ImageBrush(img.image);
				brush.Viewbox = new global::System.Windows.Rect(q.s0, q.t0, q.s1 - q.s0, q.t1 - q.t0);
				context.PushOpacityMask(brush);
				context.DrawRectangle(new global::System.Windows.Media.SolidColorBrush(myColor), null, new global::System.Windows.Rect(q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0));
				context.Pop();
				xpos += q.xadvance;
			}
		}
	')
	override public function drawString(text: String, x: Float, y: Float): Void {
		
	}
	
	override public function get_color(): kha.Color {
		return myKhaColor;
	}
	
	override public function set_color(color: kha.Color): kha.Color {
		setColorInternal(color.Ab, color.Rb, color.Gb, color.Bb);
		return myKhaColor = color;
	}
	
	override public function get_font(): kha.Font {
		return myFont;
	}
	
	override public function set_font(font: kha.Font): kha.Font {
		return this.myFont = cast(font, Kravur);
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
		context.DrawRectangle(null, new global::System.Windows.Media.Pen(new global::System.Windows.Media.SolidColorBrush(myColor), strength.value), new global::System.Windows.Rect(tx + x, ty + y, width, height));
	')
	override public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0): Void {
		
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
		context.DrawRectangle(new global::System.Windows.Media.SolidColorBrush(myColor), new global::System.Windows.Media.Pen(), new global::System.Windows.Rect(tx + x, ty + y, width, height));
	')
	override public function fillRect(x: Float, y: Float, width: Float, height: Float): Void {
		
	}
	
	@:functionCode('
		context.DrawLine(new global::System.Windows.Media.Pen(new global::System.Windows.Media.SolidColorBrush(myColor), 1), new global::System.Windows.Point(tx + x1, ty + y1), new global::System.Windows.Point(tx + x2, ty + y2));
	')
	override function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void {
		
	}
		
	@:functionCode('
		context.DrawVideo(((Video)video).getPlayer(), new global::System.Windows.Rect(tx + x, ty + y, width, height));
	')
	override function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {

	}
}

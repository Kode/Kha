package kha.js;

import kha.Color;
import kha.graphics2.Graphics;
import kha.graphics2.ImageScaleQuality;
import kha.math.FastMatrix3;
import kha.graphics2.Style;

class CanvasGraphics extends Graphics {
	private var canvas: Dynamic;
	private var webfont: kha.js.Font;
	private var width: Int;
	private var height: Int;
	private var myColor: Color;
	private var scaleQuality: ImageScaleQuality;
	private static var instance: CanvasGraphics;
	
	public function new(canvas: Dynamic, width: Int, height: Int) {
		super();
		this.canvas = canvas;
		this.width = width;
		this.height = height;
		instance = this;
		myColor = Color.fromBytes(0, 0, 0);

		canvas.save();
		//webfont = new Font("Arial", new FontStyle(false, false, false), 12);
		//canvas.globalCompositeOperation = "normal";
	}
	
	public static function stringWidth(font: kha.Font, text: String): Float {
		if (instance == null) return 5 * text.length;
		else {
			instance.font = font;
			return instance.canvas.measureText(text).width;
		}
	}
	
	override public function begin(clear: Bool = true, clearColor: Color = null): Void {
		if (clear) this.clear(clearColor);
	}
	
	override public function clear(color: Color = null): Void {
		if (color == null) color = 0xff000000;
		canvas.strokeStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		canvas.fillStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";

		if (color.A == 0) // if color is transparent, clear the screen. Note: in Canvas, transparent colors will overlay, not overwrite.
			canvas.clearRect(0, 0, width, height);
		else
			canvas.fillRect(0, 0, width, height);
	}
	
	override public function end(): Void {
		resetTransform();
		canvas.setTransform(transform._00, transform._01, transform._10, transform._11, transform._20, transform._21);
	}
	
	override public function drawImage(img: kha.Image, x: Float, y: Float, ?style: Style) {
		if (style == null)
			style = this.style;
		
		canvas.globalAlpha = style.fillColor.A;
		canvas.drawImage(cast(img, CanvasImage).image, x, y);
		canvas.globalAlpha = 1;
	}
	
	override public function drawScaledSubImage(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, ?style: Style) {
		if (style == null)
			style = this.style;

		canvas.globalAlpha = style.fillColor.A;
		try {
			if (dw < 0 || dh < 0) {
				canvas.save();
				canvas.translate(dx, dy);
				var x = 0.0;
				var y = 0.0;
				if (dw < 0) {
					canvas.scale(-1, 1);
					x = -dw;
				}
				if (dh < 0) {
					canvas.scale(1, -1);
					y = -dh;
				}
				canvas.drawImage(cast(image, CanvasImage).image, sx, sy, sw, sh, x, y, dw, dh);
				canvas.restore();
			}
			else {
				canvas.drawImage(cast(image, CanvasImage).image, sx, sy, sw, sh, dx, dy, dw, dh);
			}
		}
		catch (ex: Dynamic) {
			
		}
		canvas.globalAlpha = 1;
	}
	
	/*override public function set_color(color: Color): Color {
		myColor = color;
		canvas.strokeStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		canvas.fillStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		return color;
	}
	
	override public function get_color(): Color {
		return myColor;
	}*/
	
	override private function get_imageScaleQuality(): ImageScaleQuality {
		return scaleQuality;
	}
	
	override private function set_imageScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		if (value == ImageScaleQuality.Low) {
			canvas.mozImageSmoothingEnabled = false;
			canvas.webkitImageSmoothingEnabled = false;
			canvas.msImageSmoothingEnabled = false;
			canvas.imageSmoothingEnabled = false;
		}
		else {
			canvas.mozImageSmoothingEnabled = true;
			canvas.webkitImageSmoothingEnabled = true;
			canvas.msImageSmoothingEnabled = true;
			canvas.imageSmoothingEnabled = true;
		}
		return scaleQuality = value;
	}

	private function apply(style: Style): Style {
		if (style == null)
			style = this.style;

		canvas.fillStyle = "rgba(" + style.fillColor.Rb + "," + style.fillColor.Gb + "," + style.fillColor.Bb + "," + style.fillColor.A + ")";
		canvas.strokeStyle = "rgba(" + style.strokeColor.Rb + "," + style.strokeColor.Gb + "," + style.strokeColor.Bb + "," + style.strokeColor.A + ")";
		canvas.lineWidth = style.strokeWeight;

		canvas.setTransform(transform._00, transform._01, transform._10, transform._11, transform._20, transform._21);

		return style;
	}

	override public function quad(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float, ?style: Style): Void {
		style = apply(style);

		canvas.beginPath();
		canvas.moveTo(x1, y1);
		canvas.lineTo(x2, y2);
		canvas.lineTo(x3, y3);
		canvas.lineTo(x4, y4);
		canvas.closePath();

		if (style.fill)
			canvas.fill();
		if (style.stroke)
			canvas.stroke();
	}

	override public function rect(x: Float, y: Float, width: Float, height: Float, ?style:Style): Void {
		quad(x, y, x + width, y, x + width, y + height, x, y + height, style);
	}

	override public function line(x1: Float, y1: Float, x2: Float, y2: Float, ?style:Style): Void {
		style = apply(style);

		canvas.beginPath();
		canvas.moveTo(x1, y1);
		canvas.lineTo(x2, y2);

		if (style.stroke)
			canvas.stroke();
	}

	override public function triangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, ?style:Style): Void {
		style = apply(style);

		canvas.beginPath();
		canvas.moveTo(x1, y1);
		canvas.lineTo(x2, y2);
		canvas.lineTo(x3, y3);
		canvas.closePath();

		if (style.fill)
			canvas.fill();
		if (style.stroke)
			canvas.stroke();
	}
	
	override public function drawString(text: String, x: Float, y: Float, ?style: Style) {
		//canvas.fillText(text, tx + x, ty + y + webfont.getHeight());
		//canvas.drawImage(cast(webfont.getTexture(), Image).image, 0, 0, 50, 50, tx + x, ty + y, 50, 50);

		style = apply(style);

		var image = webfont.getImage(fontSize, myColor);
		if (image.width > 0) {
			// the image created in getImage() is not imediately useable
			var xpos = x;
			var ypos = y;
			for (i in 0...text.length) {
				var q = webfont.kravur._get(fontSize).getBakedQuad(text.charCodeAt(i) - 32, xpos, ypos);
				if (q != null) {
					if (q.s1 - q.s0 > 0 && q.t1 - q.t0 > 0 && q.x1 - q.x0 > 0 && q.y1 - q.y0 > 0)
						canvas.drawImage(image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0);
					xpos += q.xadvance;
				}
			}
		}
	}

	override public function set_font(font: kha.Font): kha.Font {
		webfont = cast(font, kha.js.Font);
		//canvas.font = webfont.size + "px " + webfont.name;
		return webfont;
	}
	
	override public function get_font(): kha.Font {
		return webfont;
	}
	
	override public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		canvas.beginPath();
		canvas.rect(x, y, width, height);
		canvas.clip();
	}
	
	override public function disableScissor(): Void {
		canvas.restore();
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float, ?style: Style): Void {
		canvas.drawImage(cast(video, Video).element, x, y, width, height, style);
	}
	
	override public function setTransformation(transformation: FastMatrix3): Void {
		canvas.setTransform(transformation._00, transformation._01, transformation._10,
			transformation._11, transformation._20, transformation._21);
	}
}

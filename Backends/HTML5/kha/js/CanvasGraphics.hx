package kha.js;

import kha.Color;
import kha.graphics2.Graphics;
import kha.graphics2.ImageScaleQuality;
import kha.math.FastMatrix3;
import js.html.CanvasRenderingContext2D;

class CanvasGraphics extends Graphics {
	var canvas: CanvasRenderingContext2D;
	var webfont: kha.js.Font;
	var myColor: Color;
	var scaleQuality: ImageScaleQuality;
	var clipping: Bool = false;

	static var instance: CanvasGraphics;

	public function new(canvas: CanvasRenderingContext2D) {
		super();
		this.canvas = canvas;
		instance = this;
		myColor = Color.fromBytes(0, 0, 0);
		// webfont = new Font("Arial", new FontStyle(false, false, false), 12);
		// canvas.globalCompositeOperation = "normal";
	}

	public static function stringWidth(font: kha.Font, text: String): Float {
		if (instance == null)
			return 5 * text.length;
		else {
			instance.font = font;
			return instance.canvas.measureText(text).width;
		}
	}

	override public function begin(clear: Bool = true, clearColor: Color = null): Void {
		if (clear)
			this.clear(clearColor);
	}

	override public function clear(color: Color = null): Void {
		if (color == null)
			color = 0x00000000;
		canvas.strokeStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		canvas.fillStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		if (color.A == 0) // if color is transparent, clear the screen. Note: in Canvas, transparent colors will overlay, not overwrite.
			canvas.clearRect(0, 0, canvas.canvas.width, canvas.canvas.height);
		else
			canvas.fillRect(0, 0, canvas.canvas.width, canvas.canvas.height);
		this.color = myColor;
	}

	override public function end(): Void {}

	/*override public function translate(x: Float, y: Float) {
		tx = x;
		ty = y;
	}*/
	override public function drawImage(img: kha.Image, x: Float, y: Float) {
		canvas.globalAlpha = opacity;
		canvas.drawImage(cast(img, CanvasImage).image, x, y);
		canvas.globalAlpha = 1;
	}

	override public function drawScaledSubImage(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float) {
		canvas.globalAlpha = opacity;
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
		catch (ex:Dynamic) {}
		canvas.globalAlpha = 1;
	}

	override function set_color(color: Color): Color {
		myColor = color;
		canvas.strokeStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		canvas.fillStyle = "rgba(" + color.Rb + "," + color.Gb + "," + color.Bb + "," + color.A + ")";
		return color;
	}

	override function get_color(): Color {
		return myColor;
	}

	override function get_imageScaleQuality(): ImageScaleQuality {
		return scaleQuality;
	}

	override function set_imageScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		if (value == ImageScaleQuality.Low) {
			untyped canvas.mozImageSmoothingEnabled = false;
			untyped canvas.webkitImageSmoothingEnabled = false;
			untyped canvas.msImageSmoothingEnabled = false;
			canvas.imageSmoothingEnabled = false;
		}
		else {
			untyped canvas.mozImageSmoothingEnabled = true;
			untyped canvas.webkitImageSmoothingEnabled = true;
			untyped canvas.msImageSmoothingEnabled = true;
			canvas.imageSmoothingEnabled = true;
		}
		return scaleQuality = value;
	}

	override public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0) {
		canvas.beginPath();
		var oldStrength = canvas.lineWidth;
		canvas.lineWidth = Math.round(strength);
		canvas.rect(x, y, width, height);
		canvas.stroke();
		canvas.lineWidth = oldStrength;
	}

	override public function fillRect(x: Float, y: Float, width: Float, height: Float) {
		canvas.globalAlpha = opacity * myColor.A;
		canvas.fillRect(x, y, width, height);
		canvas.globalAlpha = opacity;
	}

	public function drawArc(cx: Float, cy: Float, radius: Float, sAngle: Float, eAngle: Float, strength: Float = 1.0, ccw: Bool = false) {
		_drawArc(cx, cy, radius, sAngle, eAngle, strength, ccw);
	}

	public function drawCircle(cx: Float, cy: Float, radius: Float, strength: Float = 1.0) {
		_drawArc(cx, cy, radius, 0, 2 * Math.PI, strength, false);
	}

	inline function _drawArc(cx: Float, cy: Float, radius: Float, sAngle: Float, eAngle: Float, strength: Float, ccw: Bool) {
		canvas.beginPath();
		var oldStrength = canvas.lineWidth;
		canvas.lineWidth = Math.round(strength);
		canvas.arc(cx, cy, radius, sAngle, eAngle, ccw);
		canvas.stroke();
		canvas.lineWidth = oldStrength;
	}

	public function fillArc(cx: Float, cy: Float, radius: Float, sAngle: Float, eAngle: Float, ccw: Bool = false) {
		canvas.beginPath();
		canvas.arc(cx, cy, radius, sAngle, eAngle, ccw);
		canvas.fill();
	}

	public function fillCircle(cx: Float, cy: Float, radius: Float) {
		canvas.beginPath();
		canvas.arc(cx, cy, radius, 0, 2 * Math.PI, false);
		canvas.fill();
	}

	var bakedQuadCache = new kha.Kravur.AlignedQuad();

	override public function drawString(text: String, x: Float, y: Float) {
		// canvas.fillText(text, tx + x, ty + y + webfont.getHeight());
		// canvas.drawImage(cast(webfont.getTexture(), Image).image, 0, 0, 50, 50, tx + x, ty + y, 50, 50);

		var image = webfont.getImage(fontSize, myColor);
		if (image.width > 0) {
			// the image created in getImage() is not imediately useable
			var xpos = x;
			var ypos = y;
			for (i in 0...text.length) {
				var q = webfont.kravur._get(fontSize).getBakedQuad(bakedQuadCache, kha.graphics2.Graphics.fontGlyphs.indexOf(text.charCodeAt(i)), xpos, ypos);

				if (q != null) {
					if (q.s1 - q.s0 > 0 && q.t1 - q.t0 > 0 && q.x1 - q.x0 > 0 && q.y1 - q.y0 > 0)
						canvas.drawImage(image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0,
							q.y0, q.x1 - q.x0, q.y1 - q.y0);
					xpos += q.xadvance;
				}
			}
		}
	}

	override public function drawCharacters(text: Array<Int>, start: Int, length: Int, x: Float, y: Float): Void {
		var image = webfont.getImage(fontSize, myColor);
		if (image.width > 0) {
			// the image created in getImage() is not imediately useable
			var xpos = x;
			var ypos = y;
			for (i in start...start + length) {
				var q = webfont.kravur._get(fontSize).getBakedQuad(bakedQuadCache, kha.graphics2.Graphics.fontGlyphs.indexOf(text[i]), xpos, ypos);

				if (q != null) {
					if (q.s1 - q.s0 > 0 && q.t1 - q.t0 > 0 && q.x1 - q.x0 > 0 && q.y1 - q.y0 > 0)
						canvas.drawImage(image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0,
							q.y0, q.x1 - q.x0, q.y1 - q.y0);
					xpos += q.xadvance;
				}
			}
		}
	}

	override function set_font(font: kha.Font): kha.Font {
		webfont = cast(font, kha.js.Font);
		// canvas.font = webfont.size + "px " + webfont.name;
		return cast webfont;
	}

	override function get_font(): kha.Font {
		return cast webfont;
	}

	override public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0) {
		canvas.beginPath();
		var oldWith = canvas.lineWidth;
		canvas.lineWidth = Math.round(strength);
		canvas.moveTo(x1, y1);
		canvas.lineTo(x2, y2);
		canvas.moveTo(0, 0);
		canvas.stroke();
		canvas.lineWidth = oldWith;
	}

	override public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		canvas.beginPath();
		canvas.moveTo(x1, y1);
		canvas.lineTo(x2, y2);
		canvas.lineTo(x3, y3);
		canvas.closePath();
		canvas.fill();
	}

	override public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		if (!clipping) {
			canvas.save();
			clipping = true;
		}
		canvas.beginPath();
		canvas.rect(x, y, width, height);
		canvas.clip();
	}

	override public function disableScissor(): Void {
		if (clipping) {
			canvas.restore();
			clipping = false;
		}
	}

	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		canvas.drawImage(cast(video, Video).element, x, y, width, height);
	}

	override public function setTransformation(transformation: FastMatrix3): Void {
		canvas.setTransform(transformation._00, transformation._01, transformation._10, transformation._11, transformation._20, transformation._21);
	}
}

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
	
	/*public static function stringWidth(font: kha.Font, text: String): Float {
		if (instance == null) return 5 * text.length;
		else {
			instance.font = font;
			return instance.canvas.measureText(text).width;
		}
	}*/
	
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
		setTransform(transform);
	}
	
	override public function image(img: kha.Image, x: Float, y: Float, ?style: Style) {
		style = apply(style);
		canvas.globalAlpha = style.fillColor.A;
		canvas.drawImage(cast(img, CanvasImage).image, x, y);
		canvas.globalAlpha = 1;
	}
	
	override public function scaledSubImage(image: kha.Image, x: Float, y: Float, left: Float, top: Float, width: Float, height: Float, finalWidth: Float, finalHeight: Float, ?style: Style) {
		style = apply(style);
		
		canvas.globalAlpha = style.fillColor.A;
		try {
			if (finalWidth < 0 || finalHeight < 0) {
				canvas.save();
				canvas.translate(x, y);
				var x = 0.0;
				var y = 0.0;
				if (finalWidth < 0) {
					canvas.scale(-1, 1);
					x = -finalWidth;
				}
				if (finalHeight < 0) {
					canvas.scale(1, -1);
					y = -finalHeight;
				}
				canvas.drawImage(cast(image, CanvasImage).image, left, top, width, height, x, y, finalWidth, finalHeight);
				canvas.restore();
			}
			else {
				canvas.drawImage(cast(image, CanvasImage).image, left, top, width, height, x, y, finalWidth, finalHeight);
			}
		}
		catch (ex: Dynamic) {
			
		}
		canvas.globalAlpha = 1;
	}
	
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

		if (style.font != null) {
			webfont = cast(style.font, kha.js.Font);
		}

		setTransform(transform);

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

	override public function ellipse(x: Float, y: Float, radiusX: Float, radiusY: Float, ?style:Style): Void {
		style = apply(style);

		var theta = (Math.PI * 2.0) / style.circleSegments;
		var xPos = x + radiusX;
		var yPos = y + 0;

		canvas.beginPath();

		canvas.moveTo(xPos, yPos);
		for (i in 1...style.circleSegments) {
			var angle = theta * i;

			xPos = x + (radiusX * Math.cos(angle));
			yPos = y + (radiusY * Math.sin(angle));

			canvas.lineTo(xPos, yPos);
		}
		
		canvas.closePath();

		if (style.fill)
			canvas.fill();
		if (style.stroke)
			canvas.stroke();
	}

	override public function endShape(close:Bool): Void {
		apply(shapeStyle);

		canvas.beginPath();

		switch (primitiveType) {
			case Triangles:
				while (shapeVertices.length % 6 != 0) {
					vertex(shapeVertices[0], shapeVertices[1]);
				}
				
				var i = 0;
				while (i <= shapeVertices.length) {
					canvas.moveTo(shapeVertices[i], shapeVertices[i+1]);
					canvas.lineTo(shapeVertices[i+2], shapeVertices[i+3]);
					canvas.lineTo(shapeVertices[i+4], shapeVertices[i+5]);
					canvas.closePath();
					i += 6;
				}

				if (shapeStyle.fill)
					canvas.fill();
				if (shapeStyle.stroke)
					canvas.stroke();
			case Lines:
				if (close) {
					vertex(shapeVertices[0], shapeVertices[1]);
				}

				canvas.moveTo(shapeVertices[0], shapeVertices[1]);

				var i = 2;
				while (i <= shapeVertices.length) {
					canvas.lineTo(shapeVertices[i], shapeVertices[i+1]);
					i += 2;
				}

				canvas.stroke();
		}
	}
	
	override public function text(text: String, x: Float, y: Float, ?style: Style) {
		//canvas.fillText(text, tx + x, ty + y + webfont.getHeight());
		//canvas.drawImage(cast(webfont.getTexture(), Image).image, 0, 0, 50, 50, tx + x, ty + y, 50, 50);

		style = apply(style);

		var image = webfont.getImage(style.fontSize, style.fillColor);
		if (image.width > 0) {
			// the image created in getImage() is not imediately useable
			var xpos = x;
			var ypos = y;
			for (i in 0...text.length) {
				var q = webfont.kravur._get(style.fontSize).getBakedQuad(text.charCodeAt(i) - 32, xpos, ypos);
				if (q != null) {
					if (q.s1 - q.s0 > 0 && q.t1 - q.t0 > 0 && q.x1 - q.x0 > 0 && q.y1 - q.y0 > 0)
						canvas.drawImage(image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0);
					xpos += q.xadvance;
				}
			}
		}
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
	
	override public function setTransform(transform: FastMatrix3): Void {
		this.transform = transform;
		canvas.setTransform(transform._00, transform._01, transform._10,
			transform._11, transform._20, transform._21);
	}
}

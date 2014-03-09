package kha.js;

import js.Browser;
import kha.Color;
import kha.FontStyle;
import kha.Kravur;
import kha.Rotation;

class Painter extends kha.Painter {
	var canvas: Dynamic;
	var webfont: Font;
	var tx: Float;
	var ty: Float;
	var width: Int;
	var height: Int;
	private var myColor: Color;
	private static var instance: Painter;
	
	public function new(canvas: Dynamic, width: Int, height: Int) {
		super();
		this.canvas = canvas;
		this.width = width;
		this.height = height;
		tx = 0;
		ty = 0;
		instance = this;
		myColor = Color.fromBytes(0, 0, 0);
		//webfont = new Font("Arial", new FontStyle(false, false, false), 12);
		//canvas.globalCompositeOperation = "normal";
	}
	
	public static function stringWidth(font : kha.Font, text : String) {
		if (instance == null) return 5 * text.length;
		else {
			instance.setFont(font);
			return instance.canvas.measureText(text).width;
		}
	}
	
	override public function begin() {
		canvas.clearRect(0, 0, width, height);
	}
	
	override public function end() {
		
	}
	
	override public function translate(x: Float, y: Float) {
		tx = x;
		ty = y;
	}
	
	override public function drawImage(img: kha.Image, x: Float, y: Float) {
		canvas.globalAlpha = opacity;
		canvas.drawImage(cast(img, Image).image, tx + x, ty + y);
		canvas.globalAlpha = 1;
	}
	
	override public function drawImage2(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, rotation: Rotation = null) {
		canvas.globalAlpha = opacity;
		try {
			if (rotation != null) {
				canvas.save();
				canvas.translate( tx + dx + rotation.center.x, ty + dy + rotation.center.y );
				canvas.rotate(rotation.angle);
				var x = -rotation.center.x;
				var y = -rotation.center.y;
				if (dw < 0) {
					canvas.scale( -1, 1);
					x -= dw;
				}
				if (dh < 0) {
					canvas.scale( 1, -1);
					y -= dh;
				}
				canvas.drawImage(cast(image, Image).image, sx, sy, sw, sh, x, y, dw, dh);
				canvas.restore();
			} else {
				if (dw < 0 || dh < 0) {
					canvas.save();
					canvas.translate( tx + dx, ty + dy );
					var x = 0.0;
					var y = 0.0;
					if (dw < 0) {
						canvas.scale( -1, 1);
						x = -dw;
					}
					if (dh < 0) {
						canvas.scale( 1, -1);
						y = -dh;
					}
					canvas.drawImage(cast(image, Image).image, sx, sy, sw, sh, x, y, dw, dh);
					canvas.restore();
				} else {
					canvas.drawImage(cast(image, Image).image, sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
				}
			}
		}
		catch (ex : Dynamic) {
			
		}
		canvas.globalAlpha = 1;
	}
	
	override public function setColor(color: Color) {
		myColor = Color.fromValue(color.value);
		canvas.strokeStyle = "rgb(" + color.Rb + "," + color.Gb + "," + color.Bb + ")";
		canvas.fillStyle = "rgb(" + color.Rb + "," + color.Gb + "," + color.Bb + ")";
	}
	
	override public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0) {
		canvas.beginPath();
		var oldStrength = canvas.lineWidth;
		canvas.lineWidth = Math.round(strength);
		canvas.rect(tx + x, ty + y, width, height);
		canvas.stroke();
		canvas.lineWidth = oldStrength;
	}
	
	override public function fillRect(x: Float, y: Float, width: Float, height: Float) {
		canvas.globalAlpha = opacity * myColor.A;
		canvas.fillRect(tx + x, ty + y, width, height);
		canvas.globalAlpha = opacity;
	}
	
	override public function drawString(text: String, x: Float, y: Float) {
		//canvas.fillText(text, tx + x, ty + y + webfont.getHeight());
		//canvas.drawImage(cast(webfont.getTexture(), Image).image, 0, 0, 50, 50, tx + x, ty + y, 50, 50);
		
		var image = webfont.getImage(myColor);
		if (image.width > 0) {
			// the image created in getImage() is not imediately useable
			var xpos = tx + x;
			var ypos = ty + y;
			for (i in 0...text.length) {
				var q = webfont.kravur.getBakedQuad(text.charCodeAt(i) - 32, xpos, ypos);
				if (q != null) {
					if (q.s1 - q.s0 > 0 && q.t1 - q.t0 > 0 && q.x1 - q.x0 > 0 && q.y1 - q.y0 > 0)
						canvas.drawImage(image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0);
					xpos += q.xadvance;
				}
			}
		}
	}

	override public function setFont(font: kha.Font) {
		webfont = cast(font, Font);
		//canvas.font = webfont.size + "px " + webfont.name;
	}

	override public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0) {
		canvas.beginPath();
		var oldWith = canvas.lineWidth;
		canvas.lineWidth = Math.round(strength);
		canvas.moveTo(tx + x1, ty + y1);
		canvas.lineTo(tx + x2, ty + y2);
		canvas.moveTo(0, 0);
		canvas.stroke();
		canvas.lineWidth = oldWith;
	}

	override public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		canvas.beginPath();
		
		canvas.closePath();
		canvas.fill();
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		canvas.drawImage(cast(video, Video).element, x, y, width, height);
	}
}

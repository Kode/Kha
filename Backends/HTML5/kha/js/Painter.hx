package kha.js;

import js.Browser;
import js.html.ImageElement;
import kha.Color;
import kha.FontStyle;
import kha.Kravur;
import kha.Rotation;

class Painter extends kha.Painter {
	var canvas: Dynamic;
	var webfont: Kravur;
	var tx: Float;
	var ty: Float;
	var width: Int;
	var height: Int;
	private var myColor: Color;
	
	private var stringCanvas: Dynamic;
	private var stringContext: Dynamic;
	private var stringImage: Dynamic;
	private var stringsDirty: Bool = false;
	
	private static var instance: Painter;
	
	public function new(canvas: Dynamic, width: Int, height: Int) {
		this.canvas = canvas;
		this.width = width;
		this.height = height;
		tx = 0;
		ty = 0;
		instance = this;
		myColor = Color.fromBytes(0, 0, 0);
		
		stringCanvas = Browser.document.createElement("canvas");
		stringCanvas.width = width;
		stringCanvas.height = height;
		stringContext = stringCanvas.getContext("2d");
		stringImage = stringContext.createImageData(width, height);
		clearStrings();
		
		//webfont = new Font("Arial", new FontStyle(false, false, false), 12);
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
		flushStrings();
	}
	
	override public function translate(x: Float, y: Float) {
		tx = x;
		ty = y;
	}
	
	override public function drawImage(img: kha.Image, x: Float, y: Float) {
		flushStrings();
		canvas.drawImage(cast(img, Image).image, tx + x, ty + y);
	}
	
	override public function drawImage2(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, rotation: Rotation = null) {
		flushStrings();
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
	}
	
	override public function setColor(color: Color) {
		myColor = Color.fromValue(color.value);
		canvas.strokeStyle = "rgb(" + color.Rb + "," + color.Gb + "," + color.Bb + ")";
		canvas.fillStyle = "rgb(" + color.Rb + "," + color.Gb + "," + color.Bb + ")";
	}
	
	override public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0) {
		flushStrings();
		canvas.beginPath();
		var oldStrength = canvas.lineWidth;
		canvas.lineWidth = Math.round(strength);
		canvas.rect(tx + x, ty + y, width, height);
		canvas.stroke();
		canvas.lineWidth = oldStrength;
	}
	
	override public function fillRect(x: Float, y: Float, width: Float, height: Float) {
		flushStrings();
		canvas.fillRect(tx + x, ty + y, width, height);
	}
	
	private function clearStrings() {
		for (i in 0...width * height * 4) {
			stringImage.data[i] = 0;
		}
	}
	
	private function flushStrings() {
		if (!stringsDirty) return;
		stringContext.putImageData(stringImage, 0, 0);
		var img: ImageElement = cast Browser.document.createElement("img");
		img.src = stringCanvas.toDataURL("image/png");
		canvas.drawImage(img, 0, 0);
		clearStrings();
		stringsDirty = false;
	}

	override public function drawString(text: String, x: Float, y: Float) {
		//canvas.fillText(text, tx + x, ty + y + webfont.getHeight());
		//canvas.drawImage(cast(webfont.getTexture(), Image).image, 0, 0, 50, 50, tx + x, ty + y, 50, 50);
		
		/*var image = cast(webfont.getTexture(), Image);
		var xpos = tx + x;
		var ypos = ty + y;
		for (i in 0...text.length) {
			var q = webfont.getBakedQuad(text.charCodeAt(i) - 32, xpos, ypos);
			if (q != null) {
				canvas.drawImage(image.image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0);
				xpos += q.xadvance;
			}
		}*/
		
		var image = cast(webfont.getTexture(), Image);
		var src = image.getData();
		var dest = stringImage.data;
		
		var xpos = tx + x;
		var ypos = ty + y;
		for (i in 0...text.length) {
			var q = webfont.getBakedQuad(text.charCodeAt(i) - 32, xpos, ypos);
			if (q != null) {
				//canvas.drawImage(image.image, q.s0 * image.width, q.t0 * image.height, (q.s1 - q.s0) * image.width, (q.t1 - q.t0) * image.height, q.x0, q.y0, q.x1 - q.x0, q.y1 - q.y0);
				var srcx0 = cast(q.s0 * image.width, Int) + 1;
				var srcy0 = cast(q.t0 * image.height, Int) + 1;
				var srcx1 = q.s1 * image.width;
				var srcy1 = q.t1 * image.height;
				var dstx0 = cast(q.x0, Int);
				var dsty0 = cast(q.y0, Int);
				var dstx1 = cast(q.x1, Int);
				var dsty1 = cast(q.y1, Int);
				for (y in dsty0...dsty1) {
					for (x in dstx0...dstx1) {
						dest[y * width * 4 + x * 4 + 0] = 0;// myColor.Rb;
						dest[y * width * 4 + x * 4 + 1] = 0;// myColor.Gb;
						dest[y * width * 4 + x * 4 + 2] = 0;// myColor.Bb;
						dest[y * width * 4 + x * 4 + 3] = image.bytes.get(srcy0 * image.width + srcx0);// src[srcy0 * image.width * 4 + srcx0 * 4 + 3];
						++srcx0;
					}
					++srcy0;
				}
				xpos += q.xadvance;
			}
		}
		
		stringsDirty = true;
	}

	override public function setFont(font: kha.Font) {
		webfont = cast(font, Kravur);
		//canvas.font = webfont.size + "px " + webfont.name;
	}

	override public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0) {
		flushStrings();
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
		flushStrings();
		canvas.beginPath();
		
		canvas.closePath();
		canvas.fill();
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		flushStrings();
		canvas.drawImage(cast(video, Video).element, x, y, width, height);
	}
}
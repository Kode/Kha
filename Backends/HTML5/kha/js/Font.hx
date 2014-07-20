package kha.js;

import js.Browser;
import js.html.ImageElement;
import kha.Color;
import kha.FontStyle;
import kha.Kravur;

class Font implements kha.Font {
	public var myName: String;
	public var myStyle: FontStyle;
	public var mySize: Float;
	public var kravur: Kravur;
	private var images: Map<Int, ImageElement>;
	
	public function new(name: String, style: FontStyle, size: Float) {
		myName = name;
		myStyle = style;
		mySize = size;
		kravur = Kravur.get(name, style, size);
		images = new Map<Int, ImageElement>();
	}
	
	public var name(get, null): String;
	public var style(get, null): FontStyle;
	public var size(get, null): Float;
	
	public function get_name(): String {
		return kravur.get_name();
	}
	
	public function get_style(): FontStyle {
		return kravur.get_style();
	}
	
	public function get_size(): Float {
		return kravur.get_size();
	}
	
	public function getHeight(): Float {
		return kravur.getHeight();
	}

	public function charWidth(ch: String): Float {
		return kravur.charWidth(ch);
	}

	public function charsWidth(ch: String, offset: Int, length: Int): Float {
		return kravur.charsWidth(ch, offset, length);
	}

	public function stringWidth(str: String): Float {
		return kravur.stringWidth(str);
	}

	public function getBaselinePosition(): Float {
		return kravur.getBaselinePosition();
	}
	
	public function getImage(color: Color): ImageElement {
		if (!images.exists(color.value)) {
			var canvas: Dynamic = Browser.document.createElement("canvas");
			canvas.width = kravur.width;
			canvas.height = kravur.height;
			var ctx = canvas.getContext("2d");
			ctx.fillStyle = "black";
			ctx.fillRect(0, 0, kravur.width, kravur.height);
		
			var imageData = ctx.getImageData(0, 0, kravur.width, kravur.height);
			var bytes = cast(kravur.getTexture(), CanvasImage).bytes;
			for (i in 0...bytes.length) {
				imageData.data[i * 4 + 0] = color.Rb;
				imageData.data[i * 4 + 1] = color.Gb;
				imageData.data[i * 4 + 2] = color.Bb;
				imageData.data[i * 4 + 3] = bytes.get(i);
			}
			ctx.putImageData(imageData, 0, 0);
		
			var img: ImageElement = cast Browser.document.createElement("img");
			img.src = canvas.toDataURL("image/png");
			images.set(color.value, img);
		}
		return images.get(color.value);
	}
}

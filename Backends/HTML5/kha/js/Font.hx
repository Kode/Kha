package kha.js;

import js.Browser;
import js.html.ImageElement;
import kha.Color;
import kha.FontStyle;
import kha.Kravur;

class Font implements kha.Font {
	public var kravur: Kravur;
	private var images: Map<Int, Map<Int, ImageElement>> = new Map();
	
	public function new(kravur: Kravur) {
		this.kravur = kravur;
	}
	
	public function height(fontSize: Int): Float {
		return kravur._get(fontSize).getHeight();
	}
	
	public function width(fontSize: Int, str: String): Float {
		return kravur._get(fontSize).stringWidth(str);
	}
	
	public function baseline(fontSize: Int): Float {
		return kravur._get(fontSize).getBaselinePosition();
	}
	
	public function getImage(fontSize: Int, color: Color): ImageElement {
		if (!images.exists(fontSize)) {
			images[fontSize] = new Map();
		}
		if (!images[fontSize].exists(color.value)) {
			var kravur = this.kravur._get(fontSize);
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
			images[fontSize][color.value] = img;
			return img;
		}
		return images[fontSize][color.value];
	}
	
	public function unload(): Void {
		kravur = null;
		images = null;
	}
}

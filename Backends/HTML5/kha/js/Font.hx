package kha.js;

import haxe.io.Bytes;
import js.Browser;
import js.html.ImageElement;
import kha.Color;
import kha.FontStyle;
import kha.Kravur;

@:keep
class Font implements Resource {
	public var kravur: Kravur;
	private var images: Map<Int, Map<Int, ImageElement>> = new Map();
	
	public function new(blob: Blob) {
		this.kravur = new Kravur(blob);
	}
	
	public static function fromBytes(bytes: Bytes): Font {
		return new Font(Blob.fromBytes(bytes));
	}

	public function height(fontSize: Int): Float {
		return kravur._get(fontSize).getHeight();
	}
	
	public function width(fontSize: Int, str: String): Float {
		return kravur._get(fontSize).stringWidth(str);
	}
	
	public function widthOfCharacters(fontSize: Int, characters: Array<Int>, start: Int, length: Int): Float {
		return kravur._get(fontSize).charactersWidth(characters, start, length);
	}

	public function baseline(fontSize: Int): Float {
		return kravur._get(fontSize).getBaselinePosition();
	}
	
	public function getImage(fontSize: Int, color: Color, glyphs: Array<Int> = null): ImageElement {
		var imageIndex = glyphs == null ? fontSize : fontSize * 10000 + glyphs.length;
		if (!images.exists(imageIndex)) {
			images[imageIndex] = new Map();
		}
		if (!images[imageIndex].exists(color.value)) {
			var kravur = this.kravur._get(fontSize, glyphs);
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
			images[imageIndex][color.value] = img;
			return img;
		}
		return images[imageIndex][color.value];
	}
	
	public function unload(): Void {
		kravur = null;
		images = null;
	}
}

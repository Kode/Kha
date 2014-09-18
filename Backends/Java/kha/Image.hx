package kha;

import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

@:classCode('
	public java.awt.image.BufferedImage image;
')
class Image implements Canvas implements Resource {
	public function new(filename: String) {
		
	}
	
	@:functionCode('
		image.image = new java.awt.image.BufferedImage(width, height, format == 0 ? 10 : 6);
	')
	private static function create2(image: Image, width: Int, height: Int, format: Int): Void {
		
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		var img = new Image(null);
		create2(img, width, height, format == TextureFormat.L8 ? 0 : 1);
		return img;
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		var img = new Image(null);
		create2(img, width, height, format == TextureFormat.L8 ? 0 : 1);
		return img;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return null;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics { return null; }
	
	public var width(get, null): Int;
	public var height(get, null): Int;

	@:functionCode('
		return image.getWidth(null);
	')
	public function get_width(): Int {
		return 0;
	}
	
	@:functionCode('
		return image.getHeight(null);
	')
	public function get_height(): Int {
		return 0;
	}
	
	@:functionCode('
		if (x >= 0 && x < get_width() && y >= 0 && y < get_height()) {
			int argb = image.getRGB(x, y);
			return argb >> 24 != 0;
		}
		else return false;
	')
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	public function unload(): Void {
		
	}
}

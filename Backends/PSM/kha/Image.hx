package kha;

import kha.graphics2.Graphics;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

@:classCode('
	public Sce.PlayStation.Core.Graphics.Texture2D texture;
')
class Image {
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		//return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, false, false, false);
		return null;
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		//return new Image(width, height, format == null ? TextureFormat.RGBA32 : format, true, depthStencil, false);
		return null;
	}
	
	public function new(filename: String) {
		loadTexture(filename);
	}
	
	@:functionCode('
		texture = new Sce.PlayStation.Core.Graphics.Texture2D("/Application/resources/" + filename, false);
	')
	function loadTexture(filename: String) {
		
	}
	
	public var width(get, null): Int;
	
	@:functionCode('
		return texture.Width;
	')
	public function get_width(): Int {
		return 0;
	}
	
	public var height(get, null): Int;
	
	@:functionCode('
		return texture.Height;
	')
	public function get_height(): Int {
		return 0;
	}
	
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	public function unload(): Void {
		
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		if (graphics2 == null) {
			//graphics2 = new kha.flash.graphics4.Graphics2(this);
		}
		return graphics2;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			//graphics4 = new kha.flash.graphics4.Graphics(this);
		}
		return graphics4;
	}
}

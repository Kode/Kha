package kha;

import haxe.io.Bytes;
import kha.graphics2.Graphics;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import sce.playstation.core.graphics.Texture2D;

class Image {
	public var texture: Texture2D;
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
		texture = new Texture2D("/Application/resources/" + filename, false);
	}
		
	public var width(get, null): Int;
	
	public function get_width(): Int {
		return texture.Width;
	}
	
	public var height(get, null): Int;
	
	public function get_height(): Int {
		return texture.Height;
	}
	
	public var realWidth(get, null): Int;
	
	public function get_realWidth(): Int {
		return texture.Width;
	}
	
	public var realHeight(get, null): Int;
	
	public function get_realHeight(): Int {
		return texture.Height;
	}
	
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	public function unload(): Void {
		
	}
	
	public function lock(level: Int = 0): Bytes {
		return null;
	}
	
	public function unlock(): Void {
		
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
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 2048;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return true;
	}
}

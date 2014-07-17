package kha;

import kha.graphics2.Graphics;

@:allow(kha.Starter)
class Framebuffer implements Canvas {
	private var graphics2: Graphics;
	
	public function new(g2: Graphics) {
		this.graphics2 = g2;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): Graphics {
		return graphics2;
	}
	
	public var width(get, null): Int;
	
	private function get_width(): Int {
		return Sys.pixelWidth;
	}
	
	public var height(get, null): Int;
	
	private function get_height(): Int {
		return Sys.pixelHeight;
	}
}

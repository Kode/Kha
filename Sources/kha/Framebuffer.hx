package kha;

@:allow(kha.Starter)
class Framebuffer implements Canvas {
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;
	
	public function new(g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics) {
		this.graphics2 = g2;
		this.graphics4 = g4;
	}
	
	public function init(g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics): Void {
		this.graphics2 = g2;
		this.graphics4 = g4;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return graphics2;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		return graphics4;
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

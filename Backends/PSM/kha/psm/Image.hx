package kha.psm;

@:classCode('
	public Sce.PlayStation.Core.Graphics.Texture2D texture;
')
class Image implements kha.Image {
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
}

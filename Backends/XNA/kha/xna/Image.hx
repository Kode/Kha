package kha.xna;

@:classContents('
	public Microsoft.Xna.Framework.Graphics.Texture2D texture;
')
class Image implements kha.Image {
	var filename : String;
	
	public function new(filename : String) {
		this.filename = filename;
	}
	
	@:functionBody('
		texture = (Microsoft.Xna.Framework.Graphics.Texture2D)kha.Starter.getTexture(filename);
	')
	function loadImage(filename : String) {
		
	}
	
	function load() {
		loadImage(filename);
	}

	@:functionBody('
		return texture.Width;
	')
	public function getWidth() : Int {
		return 0;
	}
	
	@:functionBody('
		return texture.Height;
	')
	public function getHeight() : Int {
		return 0;
	}
	
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
}
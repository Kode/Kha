package kha.pss;

@:classContents('
	public Sce.Pss.Core.Graphics.Texture2D texture;
')
class Image implements kha.Image {
	public function new(filename : String) {
		loadTexture(filename);
	}
	
	@:functionBody('
		texture = new Sce.Pss.Core.Graphics.Texture2D("/Application/resources/" + filename, false);
	')
	function loadTexture(filename : String) {
		
	}
	
	@:functionBody('
		return texture.Width;
	')
	public function getWidth() : Int {
		return 0;
	}
	
	@:functionBody('
		return texture.Width;
	')
	public function getHeight() : Int {
		return 0;
	}
	
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
}
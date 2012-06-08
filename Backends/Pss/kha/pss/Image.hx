package kha.pss;

@:classContents('
	Sce.Pss.Core.Graphics.Texture2D texture;
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
	
	public function getWidth() : Int {
		return 100;
	}
	
	public function getHeight() : Int {
		return 100;
	}
	
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
}
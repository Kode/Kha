package kha.java;

@:classContents('
	public BufferedImage image;
')
class Image implements kha.Image {
	public function new(filename : String) {
		
	}

	@:functionBody('
		return image.getWidth(null);
	')
	public function getWidth() : Int {
		return 0;
	}
	
	@:functionBody('
		return image.getHeight(null);
	')
	public function getHeight() : Int {
		return 0;
	}
	
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
}
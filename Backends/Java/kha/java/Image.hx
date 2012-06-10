package kha.java;

@:classContents('
	public java.awt.image.BufferedImage image;
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
	
	@:functionBody('
		if (x >= 0 && x < getWidth() && y >= 0 && y < getHeight()) {
			int argb = image.getRGB(x, y);
			return argb >> 24 != 0;
		}
		else return false;
	')
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
}
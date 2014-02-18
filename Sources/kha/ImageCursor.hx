package kha;

class ImageCursor implements Cursor {
	private var image: Image;
	var _clickX : Int;
	var _clickY : Int;
	
	public var width(get,never): Int;
	public var height(get, never): Int;
	public var clickX(get,never): Int;
	public var clickY(get, never): Int;
	
	private function get_clickX() : Int {
		return _clickX;
	}
	private function get_clickY() : Int {
		return _clickY;
	}
	private function get_width() : Int {
		return image.width;
	}
	private function get_height() : Int {
		return image.height;
	}

	public function new(image: Image, clickX: Int, clickY: Int) {
		this.image = image;
		this._clickX = clickX;
		this._clickY = clickY;
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		painter.drawImage(image, x - clickX, y - clickY);
	}
	
	public function update(x : Int, y : Int): Void {
		
	}
}

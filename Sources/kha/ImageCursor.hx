package kha;

class ImageCursor implements Cursor {
	private var image: Image;
	private var clickX: Int;
	private var clickY: Int;

	public function new(image: Image, clickX: Int, clickY: Int) {
		this.image = image;
		this.clickX = clickX;
		this.clickY = clickY;
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		painter.drawImage(image, x - clickX, y - clickY);
	}
	
	public function update(x: Int, y: Int): Void {
		
	}
}

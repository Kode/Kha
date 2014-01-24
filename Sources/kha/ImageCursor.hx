package kha;

class ImageCursor implements Cursor {
	private var image: Image;

	public function new(image: Image) {
		this.image = image;
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		painter.drawImage(image, x, y);
	}
	
	public function update(): Void {
		
	}
}

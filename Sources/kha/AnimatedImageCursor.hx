package kha;

class AnimatedImageCursor implements Cursor {
	private var image: Image;
	private var width: Int;
	private var height: Int;
	private var animation: Animation;
	
	public function new(image: Image, width: Int, height: Int, animation: Animation) {
		this.image = image;
		this.width = width;
		this.height = height;
		this.animation = new Animation([], 0);
		this.animation.take(animation);
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		painter.drawImage2(image, Std.int(animation.get() * width) % image.width, Math.floor(animation.get() * width / image.width) * height, width, height, x, y, width, height);
	}
	
	public function update(): Void {
		animation.next();
	}
}

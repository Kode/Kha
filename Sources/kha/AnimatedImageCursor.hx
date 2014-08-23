package kha;
import kha.graphics2.Graphics;

class AnimatedImageCursor implements Cursor {
	private var image: Image;
	private var animation: Animation;
	
	private var _width: Int;
	private var _height: Int;
	private var _clickX : Int;
	private var _clickY : Int;
	
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
		return this._width;
	}
	private function get_height() : Int {
		return this._height;
	}
	
	public function new(image: Image, width: Int, height: Int, animation: Animation, clickX: Int, clickY: Int) {
		this.image = image;
		this._width = width;
		this._height = height;
		this._clickX = clickX;
		this._clickY = clickY;
		this.animation = new Animation([], 0);
		this.animation.take(animation);
	}
	
	public function render(g: Graphics, x: Int, y: Int): Void {
		g.drawScaledSubImage(image, Std.int(animation.get() * width) % image.width, Math.floor(animation.get() * width / image.width) * height, width, height, x - clickX, y - clickY, width, height);
	}
	
	public function update(x : Int, y : Int): Void {
		animation.next();
	}
}

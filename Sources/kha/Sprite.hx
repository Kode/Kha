package kha;

import kha.graphics2.Graphics;
import kha.math.Matrix3;
import kha.networking.Entity;

@:expose
class Sprite implements Entity {
	private var image: Image;
	private var animation: Animation;
	private var collider: Rectangle;
	
	public var x: Float;
	public var y: Float;
	public var speedx: Float;
	public var speedy: Float;
	public var accx: Float;
	public var accy: Float;
	public var maxspeedy: Float;
	public var collides: Bool;
	public var z: Int;
	public var removed: Bool = false;
	public var angle: Float = 0.0;
	public var originX: Float = 0.0;
	public var originY: Float = 0.0;
	public var scaleX: Float = 1;
	public var scaleY: Float = 1;
	
	var w: Float;
	var h: Float;
	var tempcollider: Rectangle;
	
	public function new(image: Image, width: Int = 0, height: Int = 0, z: Int = 1) {
		this.image = image;
		x = 0;
		y = 0;
		h = height;
		w = width;
		if (this.width  == 0 && image != null) this.width  = image.width;
		if (this.height == 0 && image != null) this.height = image.height;
		this.z = z;
		collider = new Rectangle(0, 0, this.width, this.height);
		speedx = speedy = 0;
		accx = 0;
		accy = 0.2;
		animation = Animation.create(0);
		maxspeedy = 5.0;
		collides = true;
		tempcollider = new Rectangle(0, 0, 0, 0);
	}
	
	// change sprite x,y, width, height as collisionrect and add a image rect
	public function collisionRect(): Rectangle {
		tempcollider.x = x;
		tempcollider.y = y;
		tempcollider.width  = collider.width * scaleX;
		tempcollider.height = collider.height * scaleY;
		return tempcollider;
	}
	
	public function setAnimation(animation: Animation): Void {
		this.animation.take(animation);
	}
	
	public function update(): Void {
		animation.next();
	}
	
	public function render(g: Graphics): Void {
		if (image != null) {
			g.color = Color.White;
			if (angle != 0) g.pushTransformation(g.transformation * Matrix3.translation(x + originX, y + originY) * Matrix3.rotation(angle) * Matrix3.translation(-x - originX, -y - originY));
			g.drawScaledSubImage(image, Std.int(animation.get() * w) % image.width, Math.floor(animation.get() * w / image.width) * h, w, h, Math.round(x - collider.x * scaleX), Math.round(y - collider.y * scaleY), width, height);
			if (angle != 0) g.popTransformation();
		}
		#if debug
			g.color = Color.fromBytes(255, 0, 0);
			g.drawRect(x - collider.x * scaleX, y - collider.y * scaleY, width, height);
			g.color = Color.fromBytes(0, 255, 0);
			g.drawRect(tempcollider.x, tempcollider.y, tempcollider.width, tempcollider.height);
		#end
	}
	
	public function hitFrom(dir: Direction): Void {
		
	}
	
	public function hit(sprite: Sprite): Void {
		
	}
	
	public function setImage(image: Image): Void {
		this.image = image;
	}
	
	public function outOfView(): Void {
		
	}
	
	function get_width(): Float {
		return w * scaleX;
	}
	
	function set_width(value: Float): Float {
		return w = value;
	}
	
	public var width(get, set): Float;
	
	function get_height(): Float {
		return h * scaleY;
	}
	
	function set_height(value: Float): Float {
		return h = value;
	}
	
	public var height(get, set): Float;
	
	public function id(): Int {
		return _id;
	}
	
	public function size(): Int {
		return _size;
	}
}

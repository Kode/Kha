package kha;

class Sprite {
	private var image : Image;
	private var animation : Animation;
	private var collider : Rectangle;
	
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;
	public var speedx : Float;
	public var speedy : Float;
	public var accx : Float;
	public var accy : Float;
	public var maxspeedy : Float;
	public var collides : Bool;
	public var z : Int;
	var tempcollider : Rectangle;
	
	public function new(image: Image, width: Int = 0, height: Int = 0, z: Int = 1) {
		this.image = image;
		x = 0;
		y = 0;
		this.width = width;
		this.height = height;
		if (this.width  == 0) this.width  = image.width;
		if (this.height == 0) this.height = image.height;
		this.z = z;
		collider = new Rectangle(0, 0, width, height);
		speedx = speedy = 0;
		accx = 0;
		accy = 0.2;
		animation = Animation.create(0);
		maxspeedy = 5.0;
		collides = true;
		tempcollider = new Rectangle(0, 0, 0, 0);
	}
	
	public function collisionRect() : Rectangle {
		tempcollider.x = x;
		tempcollider.y = y;
		tempcollider.width = collider.width;
		tempcollider.height = collider.height;
		return tempcollider;
	}
	
	public function setAnimation(animation : Animation) : Void {
		this.animation.take(animation);
	}
	
	public function update() : Void {
		animation.next();
	}
	
	public function render(painter : Painter) : Void {
		if (image != null) {
			painter.drawImage2(image, Std.int(animation.get() * width) % image.width, Math.floor(animation.get() * width / image.width) * height, width, height, Math.round(x - collider.x), Math.round(y - collider.y), width, height);
		}
	}
	
	public function hitFrom(dir : Direction) : Void {
		
	}
	
	public function hit(sprite : Sprite) : Void {
		
	}
	
	public function setImage(image : Image) : Void {
		this.image = image;
	}
	
	public function outOfView() : Void {
		
	}
}
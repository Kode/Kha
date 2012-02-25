package com.ktxsoftware.kha;

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
	
	public function new(image : Image, width : Int, height : Int, z : Int) {
		this.image = image;
		x = 0;
		y = 0;
		this.width = width;
		this.height = height;
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
	
	public function setAnimation(animation : Animation) {
		this.animation = animation;
	}
	
	public function update() {
		animation.next();
	}
	
	public function render(painter : Painter) {
		if (image != null) {
			painter.drawImage2(image, Std.int(animation.get() * width) % image.getWidth(), Math.floor(animation.get() * width / image.getWidth()) * height, width, height, Math.round(x - collider.x), Math.round(y - collider.y), width, height);
		}
	}
	
	public function hitFrom(dir : Direction) {
		
	}
	
	public function hit(sprite : Sprite) {
		
	}
	
	public function setImage(image : Image) {
		this.image = image;
	}
	
	public function outOfView() {
		
	}
}
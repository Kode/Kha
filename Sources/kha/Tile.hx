package kha;

class Tile {
	public var imageIndex : Int;
	public var visible : Bool;
	var collides : Bool;
	
	public function new(imageIndex: Int, collides: Bool) {
		this.imageIndex = imageIndex;
		this.collides = collides;
		visible = true;
	}
	
	public function collision(rect: Rectangle) : Bool {
		return collides;
	}
}
package kha;

class Tile {
	public var imageIndex : Int;
	public var visible : Bool;
	public var collides : Bool;
	
	public function new(imageIndex : Int) {
		this.imageIndex = imageIndex;
		visible = true;
		collides = false;
	}	
}
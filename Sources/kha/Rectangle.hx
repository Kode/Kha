package kha;

class Rectangle {
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;
	
	public function new(x : Float, y : Float, width : Float, height : Float) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	public function setPos(x : Int, y : Int) {
		this.x = x;
		this.y = y;
	}

	public function moveX(xdelta : Int) {
		x += xdelta;
	}
	
	public function moveY(ydelta : Int) {
		y += ydelta;
	}
	
	public function collision(r : Rectangle) : Bool {
		var a : Bool;
		var b : Bool;
		if (x < r.x) a = r.x < x + width;
		else a = x < r.x + r.width;
		if (y < r.y) b = r.y < y + height;
		else b = y < r.y + r.height;
		return a && b;
	}
}
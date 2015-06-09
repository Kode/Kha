package kha;

/**
 * Stores a rectangle.
 */
class Rectangle {
	/**
	 * The X coordinate of the point.
	 */
	public var x : Float;
	/**
	 * The Y coordinate of the point.
	 */
	public var y : Float;
	/**
	 * The width of the rectangle.
	 */
	public var width : Float;
	/**
	 * The height of the rectangle.
	 */
	public var height : Float;

	/**
	 * Instantiate a new rectangle.
	 * 
	 * @param	x		The X-coordinate of the rectangle in space.
	 * @param	y		The Y-coordinate of the rectangle in space.
	 * @param	width	Desired width of the rectangle.
	 * @param	height	Desired height of the rectangle.
	 */
	public function new(x : Float, y : Float, width : Float, height : Float) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	/**
	 * Set the rectangle position.
	 */
	public function setPos(x : Int, y : Int) {
		this.x = x;
		this.y = y;
	}

	/**
	 * Move the rectangle in the X axis.
	 *
	 * @param xdelta		The amount to move.
	 */
	public function moveX(xdelta : Int) {
		x += xdelta;
	}

	/**
	 * Move the rectangle in the Y axis.
	 *
	 * @param ydelta		The ammount to move.
	 */
	public function moveY(ydelta : Int) {
		y += ydelta;
	}

	/**
	 * Checks to see if some Rectangle object overlaps this Rectangle object.
	 * 
	 * @param	r	The rectangle being tested.
	 * 
	 * @return	Whether or not the two rectangles overlap.
	 */
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
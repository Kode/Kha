package kha;

//
// VirtualAnalogStick
//
// The VirtualAnalogStick is for systems which do not have a normal
// analog stick. The virtual analog stick is displayed on the screen and can
// be controlled by touch or mouse controls.
//

//
// How to use:
//
// - Create a new VirtualAnalogStick.
// - Call mouse handlers (mouseDown(), mouseUp(), mouseMove()), when they are called in your Game-class.
// - Use the angle and strength variables of the VirtualAnalogStick to determine in which direction the user holds it.
// - Override the render()-function to make a beautiful virtual analog stick.
// - If your VirtualAnalogStick has another shape than a simple circle, override the checkMouseCollision()-function.
//   You might also want to override isMouseWithinMoveArea() and isMouseWithinDeadArea().
// - If the interaction should be canceled, for example if your game or a level in your game restarts, or if
//   the virtual dpad loses focus, because a window has been opened, or in any similar case, call reset().
//
// Caution:
// - Take care that nothing weird happens when the user presses on both a real analog stick, or dpad, and the
//   virtual analog stick at the same time. Because this can happen on systems that have both. You can use
//   user_is_interacting to handle this.
//
// Look into the VirtualAnalogStickDemo to see how the VirtualAnalogStick can be used.
//

class VirtualAnalogStick {
	// Direction that the user is pressing:
	public var angle   : Float;
	public var strength: Float;
	
	// To check if the user is currently using the virtual analog stick at all:
	public var user_is_interacting: Bool;
		// Indicates that the user is interacting with the virtual analog stick, because he clicked/touched it.
		// The interaction is continued until the user releases the mouse button or stops touching. It
		// is continued even while the mouse/touch position is outside of the virtual analog stick.
	
	// Position and sizes:
	public var x            : Int;
	public var y            : Int;
	public var size         : Int;
	public var dead_distance: Int; // No reaction inside the dead_distance to the center
	public var full_distance: Int; // Full reaction (strength 1.0) at full_distance to the center
	public var move_distance: Int; // No reaction outside the move_distance to the center
	
	//
	// Constructor
	//
	// x, y     : Position on screen in pixels
	// size     : Size in pixels (used for both width and height)
	// dead_area: Within this area in the center no direction is pressed
	// move_area: Outside of this area no direction is pressed
	//
	public function new(x: Int, y: Int, size: Int, dead_distance: Int, full_distance: Int, move_distance: Int) {
		this.x             = x;
		this.y             = y;
		this.size          = size;
		this.dead_distance = dead_distance;
		this.full_distance = full_distance;
		this.move_distance = move_distance;
		
		resetInteraction();
	}
	
	//
	// reset()
	//
	// If the interaction should be canceled, for example if your game or a level in your game restarts,
	// or if the stick loses focus, because a window has been opened, or in any similar case, call reset().
	//
	public function reset() {
		resetInteraction();
	}
	
	// Private
	private function resetInteraction() {
		angle    = 0.0;
		strength = 0.0;
		user_is_interacting = false;
	}
	
	// Private
	private function updateDirection(mouse_x: Int, mouse_y: Int) {
		angle    = 0.0;
		strength = 0.0;
		if (user_is_interacting) {
			// Determine the direction in which the virtual analog stick is hold.
			// No direction inside the "dead-area" or outside the "move-area".
			if ((isMouseWithinMoveDistance(mouse_x, mouse_y)) && (!isMouseWithinDeadDistance(mouse_x, mouse_y))) {
				var mid_x: Float = x + size / 2;
				var mid_y: Float = y + size / 2;
				var dx: Float = mouse_x - mid_x;
				var dy: Float = mouse_y - mid_y;
				if (dx == 0.0 && dy == 0.0) { // Angle not defined in the center
					angle    = 0.0;
					strength = 0.0;
				}
				else {
					angle    = Math.atan2(-dy, dx);
					strength = (Math.sqrt(dx * dx + dy * dy) - dead_distance) / (full_distance - dead_distance);
					if (strength > 1.0) strength = 1.0;
				}
			}
		}
	}
	
	//
	// Mouse handlers
	//
	// Call these when the mouse handlers in your Game-class are called
	//
	
	public function mouseMove(mouse_x: Int, mouse_y: Int) {
		updateDirection(mouse_x, mouse_y);
	}
	
	public function mouseDown(mouse_x: Int, mouse_y: Int) {
		if (checkMouseCollision(mouse_x, mouse_y)) {
			user_is_interacting = true;
			updateDirection(mouse_x, mouse_y);
		}
	}
	
	public function mouseUp(mouse_x: Int, mouse_y: Int) {
		user_is_interacting = false;
	}
	
	//
	// checkMouseCollision()
	//
	// Checks if the mouse or touch is on the virtual analog stick.
	// Here, this is just a simple circle collision test.
	// If your stick has another shape, override this function.
	//
	public function checkMouseCollision(mouse_x: Int, mouse_y: Int): Bool {
		if ((mouse_x >= x) && (mouse_y >= y) && (mouse_x < x + size) && (mouse_y < y + size)) return true;
		return false;
	}
	
	//
	// isMouseWithinMoveDistance()
	// isMouseWithinFullDistance()
	// isMouseWithinDeadDistance()
	//
	// Further functions for collision/direction detection.
	// You may want to override these, too.
	//
	
	public function distanceToCenter(mouse_x: Int, mouse_y: Int): Float {
		var mid_x: Float = x + size / 2;
		var mid_y: Float = y + size / 2;
		var dx: Float = mouse_x - mid_x;
		var dy: Float = mouse_y - mid_y;
		var distance: Float = Math.sqrt(dx * dx + dy * dy);
		return distance;
	}
	
	public function isMouseWithinMoveDistance(mouse_x: Int, mouse_y: Int): Bool {
		if (distanceToCenter(mouse_x, mouse_y) <= move_distance) return true;
		return false;
	}
	
	public function isMouseWithinFullDistance(mouse_x: Int, mouse_y: Int): Bool {
		if (distanceToCenter(mouse_x, mouse_y) <= full_distance) return true;
		return false;
	}
	
	public function isMouseWithinDeadDistance(mouse_x: Int, mouse_y: Int): Bool {
		if (distanceToCenter(mouse_x, mouse_y) <= dead_distance) return true;
		return false;
	}

	//
	// render() function.
	// Please override this with your own function.
	//
	public function render(painter: kha.graphics2.Graphics) {
		// Draw the virtual analog stick
		if (user_is_interacting) {
			painter.color = kha.Color.Red;
		}
		else {
			painter.color = kha.Color.White;
		}
		// Border
		//painter.drawRect(x, y, size, size);
		// Cross
		//painter.drawRect(x + Std.int((size - dead_area) / 2), y                                  , dead_area, size);
		//painter.drawRect(x                                  , y + Std.int((size - dead_area) / 2), size, dead_area);
		// Center of cross
		painter.color = kha.Color.Black;
		//painter.drawRect(x + Std.int(size / 2) - dead_area, y + Std.int(size / 2) - dead_area, dead_area * 2 + 1, dead_area * 2 + 1);
	}
}

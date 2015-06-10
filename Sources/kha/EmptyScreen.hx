package kha;

/**
 * An empty screen.
 * This will be the default screen.
 */
class EmptyScreen extends Game {
	/**
	 * The color of the screen.
	 */
	private var color: Color;

	/**
	 * Initialize a new screen.
	 */
	public function new(color: Color) {
		super("Nothing", false);
		this.color = color;
	}

	/**
	 * Render the screen.
	 */
	override public function render(frame: Framebuffer): Void {
		#if !VR_GEAR_VR 
		startRender(frame);
		frame.g2.color = color;
		frame.g2.fillRect(0, 0, 10000, 10000);
		endRender(frame);
		#end
	}

	/**
	 * Override this to get your own custom update behavior.
	 * Called per frame or various times per frame.
	 */	
	override public function update(): Void {
		
	}
}
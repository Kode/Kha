package kha;

class EmptyScreen extends Game {
	private var color: Color;

	public function new(color: Color) {
		super("Nothing", false);
		this.color = color;
	}
	
	override public function render(frame: Framebuffer): Void {
		#if !VR_GEAR_VR 
		startRender(frame);
		frame.g2.color = color;
		frame.g2.fillRect(0, 0, 10000, 10000);
		endRender(frame);
		#end
	}
	
	override public function update(): Void {
		
	}
}

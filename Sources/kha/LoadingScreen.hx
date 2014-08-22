package kha;

class LoadingScreen extends Game {
	public function new() {
		super("Loading", false);
	}
	
	override public function render(frame: Framebuffer): Void {
		startRender(frame);
		if (Loader.the != null) {
			frame.g2.color = Color.fromBytes(0, 0, 255);
			frame.g2.fillRect(frame.width / 4, frame.height / 2 - 10, Loader.the.getLoadPercentage() * frame.width / 2 / 100, 20);
			frame.g2.color = Color.fromBytes(28, 28, 28);
			frame.g2.drawRect(frame.width / 4, frame.height / 2 - 10, frame.width / 2, 20);
		}
		endRender(frame);
	}
	
	override public function update(): Void {
		
	}
}

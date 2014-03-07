package kha;

class EmptyScreen extends Game {
	private var myColor: Color;

	public function new(color: Color) {
		super("Nothing", false);
		myColor = color;
	}
	
	override public function render(painter: Painter): Void {
		startRender(painter);
		painter.setColor(myColor);
		painter.fillRect(0, 0, 10000, 10000);
		endRender(painter);
	}
	
	override public function update(): Void {
		
	}
}

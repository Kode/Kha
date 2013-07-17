package kha;

class EmptyScreen extends Game {
	private var myColor: Color;

	public function new(color: Color) {
		super("Nothing", false);
		myColor = color;
	}
	
	override public function render(painter: Painter) {
		painter.setColor(myColor);
		painter.fillRect(0, 0, 10000, 10000);
	}
	
	override public function update() {
		
	}
}

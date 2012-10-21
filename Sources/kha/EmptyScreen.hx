package kha;

class EmptyScreen extends Game {
	public function new(color: Color) {
		super("Nothing", false);
		myColor = color;
	}
	
	override public function render(painter: Painter) {
		painter.setColor(myColor.r, myColor.g, myColor.b);
		painter.fillRect(0, 0, 10000, 10000);
	}
	
	override public function update() {
		
	}
	
	private var myColor: Color;
}
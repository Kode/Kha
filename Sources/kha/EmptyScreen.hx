package kha;

class EmptyScreen extends Game {
	public function new(color: Color) {
		super("Nothing", false);
		myColor = color;
	}
	
	override public function render(painter: Painter) {
		painter.setColor(myColor.Rb, myColor.Gb, myColor.Bb);
		painter.fillRect(0, 0, 10000, 10000);
	}
	
	override public function update() {
		
	}
	
	private var myColor: Color;
}
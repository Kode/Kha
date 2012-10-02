package kha;

class EmptyScreen extends Game {
	var color: Color;
	
	public function new(width: Int, height: Int, color: Color) {
		super("Nothing", width, height, false);
		this.color = color;
	}
	
	override public function render(painter : Painter) {
		painter.setColor(color.r, color.g, color.b);
		painter.fillRect(0, 0, width, height);
	}
	
	override public function update() {
		
	}
}